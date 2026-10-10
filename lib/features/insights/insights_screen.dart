import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain.dart';
import '../../data/analysis.dart';
import '../../data/providers.dart';
import 'recovery_chart.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final insights = ref.watch(insightsProvider).value;
    if (insights == null) return const SizedBox.shrink();

    if (insights.episodeCount == 0) {
      return _Empty(
        icon: Icons.show_chart,
        title: 'Your recovery curve',
        body: 'Log an event and check in a few times while you recover. '
            'Your curve will appear here.',
      );
    }

    final s = insights;
    final remaining = baselineMinEpisodes - s.recoveredCount;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Card.outlined(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recovery curve', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                if (s.latest == null && s.averageCurve == null)
                  const Text('Check in during an episode to see its curve.')
                else
                  RecoveryChart(
                    latest: s.latest?.points,
                    average: s.averageCurve,
                  ),
              ],
            ),
          ),
        ),
        if (!s.hasBaseline)
          Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log ${remaining <= 0 ? 'a few more check-ins' : '$remaining more ${remaining == 1 ? 'event' : 'events'} through to recovery'} '
                    'to unlock your personal baseline',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (s.recoveredCount / baselineMinEpisodes)
                        .clamp(0.0, 1.0),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        _StatGrid(tiles: [
          if (s.meanDurationHours != null)
            ('Typical recovery', formatHours(s.meanDurationHours!),
                '${s.recoveredCount} recovered'),
          if (s.meanPeakHours != null)
            ('Worst point',
                s.meanPeakHours! < 1
                    ? formatHours(s.meanPeakHours!)
                    : 'about ${formatHours(s.meanPeakHours!)}',
                'after the event'),
          if (s.pctSymptomatic != null)
            ('Had symptoms', '${(s.pctSymptomatic! * 100).round()}%',
                'of ${s.episodesWithCheckIns} rated '
                    '${s.episodesWithCheckIns == 1 ? 'event' : 'events'}'),
          ('Events logged', '${s.episodeCount}',
              '${s.checkInCount} ${s.checkInCount == 1 ? 'check-in' : 'check-ins'}'),
        ]),
        if (s.episodesWithCheckIns > 0) ...[
          const SizedBox(height: 16),
          Text('Symptoms', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Events where each reached Mild or worse',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          for (final e in (s.symptomEpisodes.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value))))
            if (e.value > 0) _SymptomBar(
                symptom: e.key, count: e.value, of: s.episodesWithCheckIns),
        ],
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: () => context.push('/report'),
          icon: const Icon(Icons.description_outlined),
          label: const Text('Create a doctor report'),
        ),
        const SizedBox(height: 8),
        Text(
          'These are simple summaries of what you logged, not a diagnosis. '
          'Patterns from a few events can be noisy.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.tiles});
  final List<(String, String, String)> tiles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.6,
      children: [
        for (final (label, value, caption) in tiles)
          Card.filled(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: theme.textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(value, style: theme.textTheme.titleLarge),
                  Text(caption,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SymptomBar extends StatelessWidget {
  const _SymptomBar(
      {required this.symptom, required this.count, required this.of});
  final SymptomCluster symptom;
  final int count, of;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(symptom.icon, size: 20),
          const SizedBox(width: 8),
          SizedBox(width: 120, child: Text(symptom.label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: count / of,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count of $of', style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title, body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
