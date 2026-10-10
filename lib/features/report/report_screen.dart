import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/native_bridge.dart';
import '../../data/providers.dart';
import '../../report/report_pdf.dart';

/// Flow B (PRD §7.1): pick sections → generate on-device → share or save.
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});
  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _sections = {...ReportSection.values};
  ImpactLevel? _work;
  ImpactLevel? _relationships;
  final _daysMissed = TextEditingController();
  bool _busy = false;
  Uint8List? _pdf;

  @override
  void dispose() {
    _daysMissed.dispose();
    super.dispose();
  }

  String get _fileName {
    final d = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    // Neutral name: it may show up in Downloads or a chat.
    return 'symptom-report-${d.year}-${two(d.month)}-${two(d.day)}.pdf';
  }

  Future<void> _generate() async {
    setState(() {
      _busy = true;
      _pdf = null;
    });
    try {
      // One-shot DB reads, not provider futures: Riverpod pauses providers
      // that no visible widget is listening to, so their futures can hang.
      final episodes = ref.read(episodeRepositoryProvider);
      final latest =
          await ref.read(assessmentRepositoryProvider).watchLatest().first;
      final input = ReportInput(
        sections: Set.of(_sections),
        episodes: await episodes.watchEpisodes().first,
        checkIns: await episodes.watchAllCheckIns().first,
        treatments: await ref.read(treatmentRepositoryProvider).all(),
        selfCheck: latest?.$2,
        selfCheckDate: latest?.$1,
        workImpact: _work,
        relationshipImpact: _relationships,
        daysMissed: int.tryParse(_daysMissed.text.trim()),
        generatedAt: DateTime.now(),
        regularFont: (await rootBundle.load('assets/fonts/Roboto-Regular.ttf'))
            .buffer
            .asUint8List(),
        boldFont: (await rootBundle.load('assets/fonts/Roboto-Bold.ttf'))
            .buffer
            .asUint8List(),
      );
      // Off the UI thread (PRD §10.7): the screen stays responsive.
      final bytes = await buildReportPdfInBackground(input);
      if (mounted) setState(() => _pdf = bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not create the report: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() => SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(_pdf!, mimeType: 'application/pdf')],
        fileNameOverrides: [_fileName],
      ));

  Future<void> _save() async {
    final saved = await NativeBridge.saveDocument(
        name: _fileName, mime: 'application/pdf', bytes: _pdf!);
    if (saved && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Report saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final episodes = ref.watch(allEpisodesProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Doctor report')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'A PDF summary of your logs to bring to an appointment. It is '
              'created on this phone; you choose where it goes.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (episodes.length < 3)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card.filled(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Tip: log at least 3 events first'),
                  subtitle: Text('You have ${episodes.length} so far. More '
                      'events give your doctor a clearer picture.'),
                ),
              ),
            ),
          _Header('Include'),
          for (final s in ReportSection.values)
            CheckboxListTile(
              title: Text(s.label),
              value: _sections.contains(s),
              onChanged: (on) => setState(() {
                on! ? _sections.add(s) : _sections.remove(s);
                _pdf = null;
              }),
            ),
          if (_sections.contains(ReportSection.impact)) ...[
            _Header('Impact (optional)'),
            _ImpactQuestion(
              label: 'How much does it affect your work or studies?',
              value: _work,
              onChanged: (v) => setState(() {
                _work = v;
                _pdf = null;
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _daysMissed,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Days missed last month',
                  helperText: 'Work or study days missed because of symptoms',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() => _pdf = null),
              ),
            ),
            _ImpactQuestion(
              label: 'How much does it affect your relationships?',
              value: _relationships,
              onChanged: (v) => setState(() {
                _relationships = v;
                _pdf = null;
              }),
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _pdf == null
                ? FilledButton.icon(
                    onPressed:
                        _busy || _sections.isEmpty ? null : _generate,
                    icon: _busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.picture_as_pdf_outlined),
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56)),
                    label: Text(_busy ? 'Creating…' : 'Create PDF'),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Report ready (${(_pdf!.length / 1024).round()} KB)',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _share,
                        icon: const Icon(Icons.share_outlined),
                        style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(56)),
                        label: const Text('Share or print'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save_alt),
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56)),
                        label: const Text('Save to device'),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(text,
          style: theme.textTheme.titleSmall
              ?.copyWith(color: theme.colorScheme.primary)),
    );
  }
}

class _ImpactQuestion extends StatelessWidget {
  const _ImpactQuestion(
      {required this.label, required this.value, required this.onChanged});
  final String label;
  final ImpactLevel? value;
  final ValueChanged<ImpactLevel?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ImpactLevel>(
              emptySelectionAllowed: true,
              showSelectedIcon: false,
              segments: [
                for (final l in ImpactLevel.values)
                  ButtonSegment(value: l, label: Text(l.label)),
              ],
              selected: {?value},
              onSelectionChanged: (s) => onChanged(s.isEmpty ? null : s.first),
            ),
          ),
        ],
      ),
    );
  }
}
