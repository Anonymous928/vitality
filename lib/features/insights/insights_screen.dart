import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  static const _unlockAt = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final episodes = ref.watch(allEpisodesProvider).value ?? const [];
    final baseline = ref.watch(baselineDurationProvider).value;

    if (baseline == null) {
      final recovered = episodes.where((e) => e.recoveredAt != null).length;
      final remaining = _unlockAt - recovered;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart,
                  size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('Your recovery curve',
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Log $remaining more '
                '${remaining == 1 ? 'event' : 'events'} through to recovery '
                'to unlock your recovery curve and personal baseline.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(value: recovered / _unlockAt),
            ],
          ),
        ),
      );
    }

    final days = baseline.inHours / 24;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card.filled(
          child: ListTile(
            leading: const Icon(Icons.timelapse),
            title: Text('Typical recovery: ${days.toStringAsFixed(1)} days'),
            subtitle: const Text('Average of your recent recovered episodes'),
          ),
        ),
        Card.filled(
          child: ListTile(
            leading: const Icon(Icons.event_note_outlined),
            title: Text('${episodes.length} events logged'),
          ),
        ),
        // Recovery curve chart (fl_chart) is the next build step.
      ],
    );
  }
}
