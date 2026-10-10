import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/domain.dart';
import 'app_settings.dart';
import 'database.dart';
import 'episode_repository.dart';

/// Overridden in main() with the opened database, so nothing downstream ever
/// has to await the DB.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

final initialSettingsProvider = Provider<AppSettings>(
  (ref) => throw UnimplementedError('initialSettingsProvider must be overridden'),
);

final episodeRepositoryProvider =
    Provider((ref) => EpisodeRepository(ref.watch(databaseProvider)));

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(initialSettingsProvider);

  /// Optimistic: UI updates immediately, the write happens in the background.
  void update(AppSettings Function(AppSettings) change) {
    state = change(state);
    SettingsStore(ref.read(databaseProvider)).save(state);
  }
}

final activeEpisodeProvider = StreamProvider<Episode?>(
  (ref) => ref.watch(episodeRepositoryProvider).watchActiveEpisode(),
);

final latestCheckInProvider = StreamProvider.family<CheckIn?, int>(
  (ref, episodeId) =>
      ref.watch(episodeRepositoryProvider).watchLatestCheckIn(episodeId),
);

final allEpisodesProvider = StreamProvider<List<Episode>>(
  (ref) => ref.watch(episodeRepositoryProvider).watchEpisodes(),
);

/// Personal baseline: mean duration of recovered episodes, once there are
/// at least 3 (PRD flow A step 4). Null until then.
final baselineDurationProvider = StreamProvider<Duration?>((ref) {
  return ref
      .watch(episodeRepositoryProvider)
      .watchRecoveredDurations()
      .map((hours) {
    if (hours.length < 3) return null;
    final recent = hours.take(10).toList();
    final mean = recent.reduce((a, b) => a + b) / recent.length;
    return Duration(minutes: (mean * 60).round());
  });
});

/// Summaries for one calendar month, keyed by dayKey.
final monthSummariesProvider =
    StreamProvider.family<Map<int, DailySummary>, DateTime>((ref, month) {
  final first = dayKey(DateTime(month.year, month.month, 1));
  final last = dayKey(DateTime(month.year, month.month + 1, 0));
  return ref.watch(episodeRepositoryProvider).watchSummaries(first, last);
});

final yearSummariesProvider =
    StreamProvider.family<Map<int, DailySummary>, int>((ref, year) {
  return ref.watch(episodeRepositoryProvider).watchSummaries(
        dayKey(DateTime(year, 1, 1)),
        dayKey(DateTime(year, 12, 31)),
      );
});

/// Number of days in the last 30 that had moderate-or-worse symptoms.
final lowDaysLast30Provider = StreamProvider<int>((ref) {
  final today = dayKey(DateTime.now());
  return ref
      .watch(episodeRepositoryProvider)
      .watchSummaries(today - 29, today)
      .map((m) => m.values
          .where((d) =>
              d.maxSeverity != null &&
              d.maxSeverity!.index >= Severity.moderate.index)
          .length);
});
