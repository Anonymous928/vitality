import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Evidence library (PRD §6.4): bundled JSON, updated only via app releases.
/// No dosing, ever. Hormones, biologics and hyposensitization are marked
/// "specialist-supervised only".

class EvidenceGrade {
  const EvidenceGrade(this.label, this.description);
  final String label, description;
}

class EvidenceSource {
  const EvidenceSource(this.label, this.url);
  final String label, url;
}

class EvidenceEntry {
  EvidenceEntry.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        treatmentClass = j['treatmentClass'] as String?,
        title = j['title'] as String,
        examples = (j['examples'] as List).cast<String>(),
        grade = j['grade'] as String,
        supervisedOnly = j['supervisedOnly'] as bool,
        summary = j['summary'] as String,
        reported = (j['reported'] as List).cast<String>(),
        sideEffects = (j['sideEffects'] as List).cast<String>(),
        cautions = (j['cautions'] as List).cast<String>(),
        sources = [
          for (final s in j['sources'] as List)
            EvidenceSource(s['label'] as String, s['url'] as String),
        ];

  final String id;
  final String? treatmentClass;
  final String title;
  final List<String> examples;
  final String grade;
  final bool supervisedOnly;
  final String summary;
  final List<String> reported, sideEffects, cautions;
  final List<EvidenceSource> sources;
}

class EvidenceLibrary {
  EvidenceLibrary.fromJson(Map<String, dynamic> j)
      : reviewed = j['reviewed'] as bool,
        lastUpdated = j['lastUpdated'] as String,
        intro = j['intro'] as String,
        redFlags = j['redFlags'] as String,
        grades = {
          for (final e in (j['grades'] as Map<String, dynamic>).entries)
            e.key: EvidenceGrade(
                e.value['label'] as String, e.value['description'] as String),
        },
        entries = [
          for (final e in j['entries'] as List)
            EvidenceEntry.fromJson(e as Map<String, dynamic>),
        ];

  final bool reviewed;
  final String lastUpdated, intro, redFlags;
  final Map<String, EvidenceGrade> grades;
  final List<EvidenceEntry> entries;

  EvidenceEntry? forTreatmentClass(String? c) =>
      entries.where((e) => e.treatmentClass == c).firstOrNull;
}

/// Loaded lazily the first time it's needed (PRD §10.7 rule 6).
final evidenceProvider = FutureProvider<EvidenceLibrary>((ref) async {
  final raw = await rootBundle.loadString('assets/content/evidence.json');
  return EvidenceLibrary.fromJson(jsonDecode(raw) as Map<String, dynamic>);
});

class EvidenceLibraryScreen extends ConsumerWidget {
  const EvidenceLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lib = ref.watch(evidenceProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Evidence library')),
      body: lib == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (!lib.reviewed) const _DraftBanner(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(lib.intro, style: theme.textTheme.bodyMedium),
                ),
                for (final e in lib.entries)
                  ListTile(
                    title: Text(e.title),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _GradeChip(lib.grades[e.grade]!.label),
                          if (e.supervisedOnly) const _SupervisedChip(),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          EvidenceEntryScreen(library: lib, entry: e),
                    )),
                  ),
                const Divider(height: 32),
                _GradeKey(lib: lib),
              ],
            ),
    );
  }
}

class EvidenceEntryScreen extends StatelessWidget {
  const EvidenceEntryScreen(
      {super.key, required this.library, required this.entry});
  final EvidenceLibrary library;
  final EvidenceEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final e = entry;
    final grade = library.grades[e.grade]!;

    Widget section(String title, List<String> items) => Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              for (final i in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(child: Text(i)),
                    ],
                  ),
                ),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(e.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (!library.reviewed)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _DraftBanner(inset: false),
            ),
          if (e.supervisedOnly)
            Card.filled(
              color: theme.colorScheme.tertiaryContainer,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: Icon(Icons.local_hospital_outlined,
                    color: theme.colorScheme.onTertiaryContainer),
                title: Text('Specialist-supervised only',
                    style: TextStyle(
                        color: theme.colorScheme.onTertiaryContainer)),
                subtitle: Text(
                    'Only under the care of a specialist who can monitor you.',
                    style: TextStyle(
                        color: theme.colorScheme.onTertiaryContainer)),
              ),
            ),
          Wrap(spacing: 8, children: [_GradeChip('Evidence: ${grade.label}')]),
          const SizedBox(height: 4),
          Text(grade.description, style: theme.textTheme.bodySmall),
          if (e.examples.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Examples: ${e.examples.join(', ')}',
                style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),
          Text(e.summary, style: theme.textTheme.bodyLarge),
          section('What has been reported', e.reported),
          section('Possible side effects', e.sideEffects),
          section('Things to know', e.cautions),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text('Sources', style: theme.textTheme.titleMedium),
          ),
          for (final s in e.sources)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.open_in_new, size: 20),
              title: Text(s.label),
              onTap: () => launchUrl(Uri.parse(s.url),
                  mode: LaunchMode.externalApplication),
            ),
          const SizedBox(height: 16),
          Card.outlined(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'This is general information, not medical advice, and it '
                'doesn\'t list every risk. Talk to a clinician before '
                'starting, stopping or combining treatments.\n\n'
                '${library.redFlags}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftBanner extends StatelessWidget {
  const _DraftBanner({this.inset = true});
  final bool inset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card.filled(
      color: scheme.secondaryContainer,
      margin: inset ? const EdgeInsets.fromLTRB(16, 8, 16, 0) : EdgeInsets.zero,
      child: ListTile(
        leading: Icon(Icons.rate_review_outlined,
            color: scheme.onSecondaryContainer),
        title: Text('Draft content',
            style: TextStyle(color: scheme.onSecondaryContainer)),
        subtitle: Text(
            'Not yet reviewed by our medical advisors. It may change.',
            style: TextStyle(color: scheme.onSecondaryContainer)),
      ),
    );
  }
}

class _GradeChip extends StatelessWidget {
  const _GradeChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Chip(
        avatar: const Icon(Icons.science_outlined, size: 16),
        label: Text(label),
        visualDensity: VisualDensity.compact,
      );
}

class _SupervisedChip extends StatelessWidget {
  const _SupervisedChip();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(Icons.local_hospital_outlined,
          size: 16, color: scheme.onTertiaryContainer),
      label: Text('Specialist only',
          style: TextStyle(color: scheme.onTertiaryContainer)),
      backgroundColor: scheme.tertiaryContainer,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _GradeKey extends StatelessWidget {
  const _GradeKey({required this.lib});
  final EvidenceLibrary lib;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About the evidence grades', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final g in lib.grades.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text.rich(TextSpan(children: [
                TextSpan(
                    text: '${g.label}: ',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: g.description),
              ])),
            ),
          Text('Content last updated ${lib.lastUpdated}.',
              style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
