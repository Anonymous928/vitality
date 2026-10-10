import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain.dart';
import '../../data/providers.dart';
import '../../notifications/check_in_scheduler.dart';

Future<void> showLogEventSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true, // cover the bottom NavigationBar
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => const LogEventSheet(),
  );
}

enum _WhenPreset { now, hourAgo, lastNight, pick }

/// Fast path: When (defaults to "Just now") → Type → Save = 2 taps.
class LogEventSheet extends ConsumerStatefulWidget {
  const LogEventSheet({super.key});

  @override
  ConsumerState<LogEventSheet> createState() => _LogEventSheetState();
}

class _LogEventSheetState extends ConsumerState<LogEventSheet> {
  _WhenPreset _when = _WhenPreset.now;
  DateTime? _picked;
  EpisodeType? _type;

  bool _showDetails = false;
  int? _sleep;
  bool? _alcohol;
  int? _stress;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  DateTime get _occurredAt {
    final now = DateTime.now();
    return switch (_when) {
      _WhenPreset.now => now,
      _WhenPreset.hourAgo => now.subtract(const Duration(hours: 1)),
      // 3am today if it's past 3am, otherwise 3am yesterday.
      _WhenPreset.lastNight => () {
          final t = DateTime(now.year, now.month, now.day, 3);
          return t.isAfter(now) ? t.subtract(const Duration(days: 1)) : t;
        }(),
      _WhenPreset.pick => _picked ?? now,
    };
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _picked ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_picked ?? now),
    );
    if (time == null) return;
    var t = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (t.isAfter(now)) t = now;
    setState(() {
      _picked = t;
      _when = _WhenPreset.pick;
    });
  }

  void _save() {
    final type = _type;
    if (type == null) return;
    final repo = ref.read(episodeRepositoryProvider);
    final settings = ref.read(settingsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final occurredAt = _occurredAt;

    // Optimistic UI: close and confirm immediately, write in the background.
    Navigator.of(context).pop();
    messenger.showSnackBar(const SnackBar(
      content: Text('Logged. We\'ll check in on you gently.'),
    ));

    repo
        .logEpisode(
          occurredAt: occurredAt,
          type: type,
          sleepQuality: _sleep,
          alcohol: _alcohol,
          stress: _stress,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        )
        .then((id) async {
      await CheckInScheduler.instance.requestPermission();
      await CheckInScheduler.instance.scheduleFor(
        episodeId: id,
        occurredAt: occurredAt,
        text: settings.notificationText,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Log event', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            Text('When?', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (preset, label) in [
                  (_WhenPreset.now, 'Just now'),
                  (_WhenPreset.hourAgo, '1h ago'),
                  (_WhenPreset.lastNight, 'Last night'),
                ])
                  ChoiceChip(
                    label: Text(label),
                    selected: _when == preset,
                    onSelected: (_) => setState(() => _when = preset),
                  ),
                ChoiceChip(
                  avatar: const Icon(Icons.schedule, size: 18),
                  label: Text(_when == _WhenPreset.pick && _picked != null
                      ? _formatPicked(context, _picked!)
                      : 'Pick time'),
                  selected: _when == _WhenPreset.pick,
                  onSelected: (_) => _pickTime(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Type?', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final t in EpisodeType.values)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _TypeTile(
                        type: t,
                        selected: _type == t,
                        onTap: () => setState(() => _type = t),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() => _showDetails = !_showDetails),
              icon: Icon(_showDetails ? Icons.expand_less : Icons.expand_more),
              label: const Text('Add details (optional)'),
            ),
            if (_showDetails) ..._details(theme),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _type == null ? null : _save,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56)),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatPicked(BuildContext context, DateTime t) {
    final loc = MaterialLocalizations.of(context);
    return '${loc.formatShortMonthDay(t)}, '
        '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(t))}';
  }

  List<Widget> _details(ThemeData theme) => [
        _ScaleRow(
          label: 'Sleep last night',
          low: 'Poor',
          high: 'Great',
          value: _sleep,
          onChanged: (v) => setState(() => _sleep = v),
        ),
        _ScaleRow(
          label: 'Stress',
          low: 'Low',
          high: 'High',
          value: _stress,
          onChanged: (v) => setState(() => _stress = v),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                  child: Text('Alcohol in last 24h',
                      style: theme.textTheme.bodyMedium)),
              SegmentedButton<bool>(
                emptySelectionAllowed: true,
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: false, label: Text('No')),
                  ButtonSegment(value: true, label: Text('Yes')),
                ],
                selected: {?_alcohol},
                onSelectionChanged: (s) =>
                    setState(() => _alcohol = s.isEmpty ? null : s.first),
              ),
            ],
          ),
        ),
        // Before-interventions picker arrives with the treatment log.
        TextField(
          controller: _note,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Note',
            border: OutlineInputBorder(),
          ),
        ),
      ];
}

class _TypeTile extends StatelessWidget {
  const _TypeTile(
      {required this.type, required this.selected, required this.onTap});
  final EpisodeType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      child: Card.outlined(
        margin: EdgeInsets.zero,
        color: selected ? scheme.secondaryContainer : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? scheme.secondary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(type.icon, size: 32),
                const SizedBox(height: 8),
                Text(type.label, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScaleRow extends StatelessWidget {
  const _ScaleRow({
    required this.label,
    required this.low,
    required this.high,
    required this.value,
    required this.onChanged,
  });
  final String label, low, high;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label  ·  1 = $low, 5 = $high'),
          const SizedBox(height: 6),
          SegmentedButton<int>(
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            segments: [
              for (var i = 1; i <= 5; i++)
                ButtonSegment(value: i, label: Text('$i')),
            ],
            selected: {?value},
            onSelectionChanged: (s) => onChanged(s.isEmpty ? null : s.first),
          ),
        ],
      ),
    );
  }
}
