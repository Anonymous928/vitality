import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../log/log_event_sheet.dart';

/// Set when the home-screen widget asks to log; Today opens the sheet.
final pendingLogProvider =
    NotifierProvider<PendingLog, bool>(PendingLog.new);

class PendingLog extends Notifier<bool> {
  @override
  bool build() => false;
  void request() => state = true;
  void clear() => state = false;
}

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeEpisodeProvider).value;
    if (ref.watch(pendingLogProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(pendingLogProvider.notifier).clear();
        if (context.mounted) showLogEventSheet(context);
      });
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showLogEventSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Log event'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: active == null
                  ? null
                  : () => context.push('/episode/${active.id}'),
              child: RecoveryRing(episode: active),
            ),
          ),
          const SizedBox(height: 24),
          if (active != null) _CheckInCard(episode: active),
          const _Last30Card(),
          _InfoCard(
            icon: Icons.description_outlined,
            title: 'Prepare for a doctor visit',
            subtitle: 'Create a PDF report from your logs',
            onTap: () => context.push('/report'),
          ),
          const _InfoCard(
            icon: Icons.lightbulb_outline,
            title: "You're not imagining this",
            subtitle:
                'POIS is listed by the NIH as a rare disease. Tracking your '
                'episodes helps you and your doctor see the pattern.',
          ),
        ],
      ),
    );
  }
}

/// Clue-style circle + Visible-style gauge: "Day 2 of ~4".
class RecoveryRing extends ConsumerWidget {
  const RecoveryRing({super.key, required this.episode});
  final Episode? episode;

  static const _size = 200.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final baseline = ref.watch(baselineDurationProvider).value;

    final String headline;
    final String caption;
    double progress;
    Color color;

    final e = episode;
    if (e == null) {
      headline = 'Feeling normal';
      caption = 'No active episode';
      progress = 1;
      color = Severity.none.color;
    } else {
      final elapsed = DateTime.now().difference(e.occurredAt);
      final day = elapsed.inDays + 1;
      if (baseline != null) {
        final expectedDays = (baseline.inHours / 24).ceil().clamp(1, 30);
        headline = 'Day $day of ~$expectedDays';
        progress = (elapsed.inMinutes / baseline.inMinutes).clamp(0.02, 1.0);
      } else {
        headline = 'Day $day';
        // Typical course is 2–7 days; use 4 as a neutral midpoint.
        progress = (elapsed.inHours / (4 * 24)).clamp(0.02, 1.0);
      }
      caption = 'recovering';
      final peak = e.peakSeverity;
      color = peak == null ? theme.colorScheme.primary : peak.color;
    }

    return Semantics(
      label: '$headline, $caption',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: _size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 14,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(headline,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(caption,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  if (e != null && baseline == null) ...[
                    const SizedBox(height: 4),
                    Text('typical: 2–7 days',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckInCard extends ConsumerWidget {
  const _CheckInCard({required this.episode});
  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last = ref.watch(latestCheckInProvider(episode.id)).value;
    final since = last == null
        ? null
        : DateTime.now().difference(last.at);
    final due = since == null || since.inHours >= 4;

    return Card.filled(
      color: due ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(Icons.favorite_border),
        title: Text(due ? 'Check-in due' : 'Checked in recently'),
        subtitle: Text(last == null
            ? 'Tap to rate how you feel'
            : 'Last: ${Feeling.fromValue(last.overall).label} · '
                '${_ago(since!)} ago'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/checkin/${episode.id}'),
      ),
    );
  }

  static String _ago(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }
}

class _Last30Card extends ConsumerWidget {
  const _Last30Card();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowDays = ref.watch(lowDaysLast30Provider).value ?? 0;
    final episodes = ref.watch(allEpisodesProvider).value ?? const [];
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final recent = episodes.where((e) => e.occurredAt.isAfter(cutoff)).length;

    return Card.filled(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(Icons.calendar_view_month_outlined),
        title: Text('Last 30 days: $lowDays low '
            '${lowDays == 1 ? 'day' : 'days'}'),
        subtitle: Text('$recent ${recent == 1 ? 'event' : 'events'} logged'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/calendar'),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.onTap});
  final IconData icon;
  final String title, subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
