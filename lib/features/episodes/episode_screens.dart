import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain.dart';
import '../../data/analysis.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../notifications/check_in_scheduler.dart';
import '../checkin/check_in_screen.dart';
import '../log/log_event_sheet.dart';

String _when(BuildContext context, DateTime t) {
  final loc = MaterialLocalizations.of(context);
  return '${loc.formatMediumDate(t)}, '
      '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(t))}';
}

/// One event: its details, status and check-ins, with edit/delete for all
/// of them (so a mis-tap is always fixable).
class EpisodeDetailScreen extends ConsumerWidget {
  const EpisodeDetailScreen({super.key, required this.episodeId});
  final int episodeId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this event?'),
        content: const Text('Its check-ins are deleted too.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    ref.read(episodeRepositoryProvider).deleteEpisode(episodeId);
    CheckInScheduler.instance.cancelFor(episodeId);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Event deleted')));
    context.pop();
  }

  Future<void> _markRecovered(BuildContext context, WidgetRef ref) async {
    final pct = await showDialog<int>(
      context: context,
      builder: (_) => const RecoveredDialog(),
    );
    if (pct == null) return;
    ref
        .read(episodeRepositoryProvider)
        .markRecovered(episodeId, recoveryPct: pct);
    CheckInScheduler.instance.cancelFor(episodeId);
  }

  Future<void> _reopen(WidgetRef ref, Episode e) async {
    await ref.read(episodeRepositoryProvider).reopen(episodeId);
    // Remaining reminders (those still in the future) come back.
    CheckInScheduler.instance.scheduleFor(
      episodeId: episodeId,
      occurredAt: e.occurredAt,
      text: ref.read(settingsProvider).notificationText,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final e = ref.watch(episodeProvider(episodeId)).value;
    final checkIns =
        ref.watch(episodeCheckInsProvider(episodeId)).value ?? const [];

    if (e == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This event no longer exists.')),
      );
    }

    final recovered = e.recoveredAt != null;
    final status = recovered ? 'Back to normal' : 'Recovering';
    final statusDetail = recovered
        ? 'after ${formatHours(e.recoveredAt!.difference(e.occurredAt).inMinutes / 60)}'
              '${e.recoveryPct == null ? '' : ' · ${e.recoveryPct}% of usual'}'
        : 'Day ${DateTime.now().difference(e.occurredAt).inDays + 1}';

    final details = [
      if (e.sleepQuality != null) 'Sleep ${e.sleepQuality}/5',
      if (e.stress != null) 'Stress ${e.stress}/5',
      if (e.alcohol != null) e.alcohol! ? 'Alcohol' : 'No alcohol',
      if (e.preInterventions.isNotEmpty)
        'Taken beforehand: ${e.preInterventions.join(', ')}',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showLogEventSheet(context, editing: e),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/checkin/$episodeId'),
        icon: const Icon(Icons.add),
        label: const Text('Add check-in'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(e.type.icon, size: 32),
            title: Text(e.type.label, style: theme.textTheme.titleLarge),
            subtitle: Text(_when(context, e.occurredAt)),
            trailing: e.peakSeverity == null
                ? null
                : SeverityChip(e.peakSeverity!),
          ),
          Card.filled(
            child: ListTile(
              leading: Icon(
                recovered ? Icons.wb_sunny_outlined : Icons.hourglass_bottom,
              ),
              title: Text(status),
              subtitle: Text(statusDetail),
              trailing: recovered
                  ? TextButton(
                      onPressed: () => _reopen(ref, e),
                      child: const Text('Not yet'),
                    )
                  : TextButton(
                      onPressed: () => _markRecovered(context, ref),
                      child: const Text('Back to normal'),
                    ),
            ),
          ),
          if (details.isNotEmpty || e.note != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                [...details, ?e.note].join('\n'),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          const SizedBox(height: 8),
          Text('Check-ins', style: theme.textTheme.titleMedium),
          if (checkIns.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No check-ins yet.'),
            ),
          for (final c in checkIns.reversed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Feeling.fromValue(c.overall).icon),
              title: Text(
                '${Feeling.fromValue(c.overall).label} · '
                '${_when(context, c.at)}',
              ),
              subtitle: c.symptomScores.isEmpty
                  ? null
                  : Text(
                      [
                        for (final s in c.symptomScores.entries)
                          '${s.key.label}: ${s.value.label}',
                      ].join(', '),
                    ),
              trailing: const Icon(Icons.edit_outlined, size: 20),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      CheckInScreen(episodeId: episodeId, editing: c),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Severity always with its text label (never colour alone).
class SeverityChip extends StatelessWidget {
  const SeverityChip(this.severity, {super.key});
  final Severity severity;

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(severity.label, style: TextStyle(color: severity.onColor)),
    backgroundColor: severity.color,
    side: BorderSide.none,
    visualDensity: VisualDensity.compact,
  );
}

class EpisodeTile extends StatelessWidget {
  const EpisodeTile({
    super.key,
    required this.episode,
    this.closeSheet = false,
  });
  final Episode episode;

  /// Inside a bottom sheet: close it before opening the event.
  final bool closeSheet;

  @override
  Widget build(BuildContext context) {
    final e = episode;
    final status = e.recoveredAt == null
        ? 'recovering'
        : formatHours(e.recoveredAt!.difference(e.occurredAt).inMinutes / 60);
    return ListTile(
      leading: Icon(e.type.icon),
      title: Text(_when(context, e.occurredAt)),
      subtitle: Text('${e.type.label} · $status'),
      trailing: e.peakSeverity == null ? null : SeverityChip(e.peakSeverity!),
      onTap: () {
        final router = GoRouter.of(context);
        if (closeSheet) Navigator.of(context).pop();
        router.push('/episode/${e.id}');
      },
    );
  }
}

class AllEventsScreen extends ConsumerWidget {
  const AllEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodes = ref.watch(allEpisodesProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('All events')),
      body: episodes.isEmpty
          ? const Center(child: Text('Nothing logged yet.'))
          : ListView.builder(
              itemCount: episodes.length,
              itemBuilder: (_, i) => EpisodeTile(episode: episodes[i]),
            ),
    );
  }
}

/// Calendar day tap: what was going on that day.
Future<void> showDaySheet(BuildContext context, DateTime day) {
  return showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (_) => _DaySheet(day: day),
  );
}

class _DaySheet extends ConsumerWidget {
  const _DaySheet({required this.day});
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final episodes =
        ref.watch(episodesOnDayProvider(dayKey(day))).value ?? const [];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              MaterialLocalizations.of(context).formatFullDate(day),
              style: theme.textTheme.titleMedium,
            ),
          ),
          if (episodes.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Text('Nothing logged on this day.'),
            )
          else
            for (final e in episodes) EpisodeTile(episode: e, closeSheet: true),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
