import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../notifications/check_in_scheduler.dart';

/// "Fog Mode" check-in (PRD §6.2): large targets, ≤3 taps, chips instead of
/// sliders. Face → (optional symptom chips) → Save.
class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key, required this.episodeId, this.editing});
  final int episodeId;

  /// When set, edits this check-in instead of adding one.
  final CheckIn? editing;

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  Feeling? _feeling;
  final _scores = <SymptomCluster, Severity>{};
  bool _allSymptoms = false;

  @override
  void initState() {
    super.initState();
    final c = widget.editing;
    if (c != null) {
      _feeling = Feeling.fromValue(c.overall);
      _scores.addAll(c.symptomScores);
      final top = ref.read(settingsProvider).topSymptoms;
      _allSymptoms = _scores.keys.any((s) => !top.contains(s));
    }
  }

  void _save() {
    final feeling = _feeling;
    if (feeling == null) return;
    final repo = ref.read(episodeRepositoryProvider);
    final editing = widget.editing;
    if (editing != null) {
      repo.updateCheckIn(editing, overall: feeling, scores: Map.of(_scores));
    } else {
      repo.addCheckIn(
        episodeId: widget.episodeId,
        overall: feeling,
        scores: Map.of(_scores),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(editing != null ? 'Check-in updated' : 'Check-in saved')));
    context.pop();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this check-in?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    ref.read(episodeRepositoryProvider).deleteCheckIn(widget.editing!);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Check-in deleted')));
    context.pop();
  }

  Future<void> _recovered() async {
    final pct = await showDialog<int>(
      context: context,
      builder: (_) => const RecoveredDialog(),
    );
    if (pct == null || !mounted) return;
    final repo = ref.read(episodeRepositoryProvider);
    if (_feeling != null) {
      await repo.addCheckIn(
          episodeId: widget.episodeId,
          overall: _feeling!,
          scores: Map.of(_scores));
    }
    repo.markRecovered(widget.episodeId, recoveryPct: pct);
    CheckInScheduler.instance.cancelFor(widget.episodeId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Welcome back. Recovery recorded.')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = ref.watch(settingsProvider.select((s) => s.topSymptoms));
    final shown = _allSymptoms ? SymptomCluster.values : top;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editing == null ? 'Check-in' : 'Edit check-in'),
        actions: [
          if (widget.editing != null)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text('How do you feel?',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final f in Feeling.values)
                Expanded(
                  child: _FaceButton(
                    feeling: f,
                    selected: _feeling == f,
                    onTap: () => setState(() => _feeling = f),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          for (final s in shown)
            _SymptomRow(
              symptom: s,
              value: _scores[s],
              onChanged: (v) => setState(() {
                if (v == null) {
                  _scores.remove(s);
                } else {
                  _scores[s] = v;
                }
              }),
            ),
          TextButton(
            onPressed: () => setState(() => _allSymptoms = !_allSymptoms),
            child: Text(_allSymptoms ? 'Show fewer' : 'All symptoms'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _feeling == null ? null : _save,
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(64)),
            child: const Text('Save', style: TextStyle(fontSize: 18)),
          ),
          if (widget.editing == null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _recovered,
            icon: const Icon(Icons.wb_sunny_outlined),
            style:
                OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            label: const Text("I'm back to normal"),
          ),
          ],
        ],
      ),
    );
  }
}

class _FaceButton extends StatelessWidget {
  const _FaceButton(
      {required this.feeling, required this.selected, required this.onTap});
  final Feeling feeling;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: feeling.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(feeling.icon,
                  size: 44,
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant),
              const SizedBox(height: 4),
              Text(feeling.label,
                  style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _SymptomRow extends StatelessWidget {
  const _SymptomRow(
      {required this.symptom, required this.value, required this.onChanged});
  final SymptomCluster symptom;
  final Severity? value;
  final ValueChanged<Severity?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(symptom.icon, size: 20),
            const SizedBox(width: 8),
            Text(symptom.label, style: Theme.of(context).textTheme.titleSmall),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<Severity>(
              emptySelectionAllowed: true,
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                minimumSize: const Size(0, 52),
                selectedBackgroundColor: value?.color,
                selectedForegroundColor: value?.onColor,
              ),
              segments: [
                for (final s in Severity.values)
                  ButtonSegment(value: s, label: Text(s.label)),
              ],
              selected: {?value},
              onSelectionChanged: (sel) =>
                  onChanged(sel.isEmpty ? null : sel.first),
            ),
          ),
        ],
      ),
    );
  }
}

class RecoveredDialog extends StatefulWidget {
  const RecoveredDialog({super.key});
  @override
  State<RecoveredDialog> createState() => _RecoveredDialogState();
}

class _RecoveredDialogState extends State<RecoveredDialog> {
  int _pct = 100;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Back to normal?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How close to your usual self do you feel?'),
          const SizedBox(height: 16),
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 70, label: Text('70%')),
              ButtonSegment(value: 80, label: Text('80%')),
              ButtonSegment(value: 90, label: Text('90%')),
              ButtonSegment(value: 100, label: Text('100%')),
            ],
            selected: {_pct},
            onSelectionChanged: (s) => setState(() => _pct = s.first),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not yet')),
        FilledButton(
            onPressed: () => Navigator.pop(context, _pct),
            child: const Text('Mark recovered')),
      ],
    );
  }
}
