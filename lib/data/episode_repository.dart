import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../core/domain.dart';
import 'database.dart';

/// All episode/check-in writes go through here so the precomputed
/// aggregates (Episode.peakSeverity, DailySummaries) can never drift out of
/// sync with the raw data.
class EpisodeRepository {
  EpisodeRepository(this._db);
  final AppDatabase _db;

  // ---------------------------------------------------------------- reads

  /// The most recent episode that hasn't been marked recovered.
  Stream<Episode?> watchActiveEpisode() {
    final q = _db.select(_db.episodes)
      ..where((e) => e.recoveredAt.isNull())
      ..orderBy([(e) => OrderingTerm.desc(e.occurredAt)])
      ..limit(1);
    return q.watchSingleOrNull();
  }

  Stream<List<Episode>> watchEpisodes() {
    final q = _db.select(_db.episodes)
      ..orderBy([(e) => OrderingTerm.desc(e.occurredAt)]);
    return q.watch();
  }

  Future<Episode?> episode(int id) =>
      (_db.select(_db.episodes)..where((e) => e.id.equals(id)))
          .getSingleOrNull();

  Stream<Episode?> watchEpisode(int id) =>
      (_db.select(_db.episodes)..where((e) => e.id.equals(id)))
          .watchSingleOrNull();

  Stream<List<CheckIn>> watchCheckIns(int episodeId) {
    final q = _db.select(_db.checkIns)
      ..where((c) => c.episodeId.equals(episodeId))
      ..orderBy([(c) => OrderingTerm.asc(c.at)]);
    return q.watch();
  }

  /// Episodes that cover [day] (dayKey): started on or before it and not
  /// recovered before it.
  Stream<List<Episode>> watchEpisodesOnDay(int day) {
    final start = dayFromKey(day);
    final end = dayFromKey(day + 1);
    final q = _db.select(_db.episodes)
      ..where((e) =>
          e.occurredAt.isSmallerThanValue(end) &
          (e.recoveredAt.isNull() | e.recoveredAt.isBiggerOrEqualValue(start)))
      ..orderBy([(e) => OrderingTerm.asc(e.occurredAt)]);
    return q.watch();
  }

  Stream<CheckIn?> watchLatestCheckIn(int episodeId) {
    final q = _db.select(_db.checkIns)
      ..where((c) => c.episodeId.equals(episodeId))
      ..orderBy([(c) => OrderingTerm.desc(c.at)])
      ..limit(1);
    return q.watchSingleOrNull();
  }

  Stream<List<CheckIn>> watchAllCheckIns() => _db.select(_db.checkIns).watch();

  Stream<List<CheckIn>> watchCheckInsBetween(DateTime from, DateTime to) {
    final q = _db.select(_db.checkIns)
      ..where((c) => c.at.isBetweenValues(from, to))
      ..orderBy([(c) => OrderingTerm.asc(c.at)]);
    return q.watch();
  }

  Stream<List<Episode>> watchEpisodesBetween(DateTime from, DateTime to) {
    final q = _db.select(_db.episodes)
      ..where((e) => e.occurredAt.isBetweenValues(from, to))
      ..orderBy([(e) => OrderingTerm.asc(e.occurredAt)]);
    return q.watch();
  }

  /// Summaries for [fromDay]..[toDay] inclusive (dayKey values).
  Stream<Map<int, DailySummary>> watchSummaries(int fromDay, int toDay) {
    final q = _db.select(_db.dailySummaries)
      ..where((d) => d.day.isBetweenValues(fromDay, toDay));
    return q.watch().map((rows) => {for (final r in rows) r.day: r});
  }

  /// Durations (in hours) of recovered episodes, newest first.
  Stream<List<double>> watchRecoveredDurations() {
    final q = _db.select(_db.episodes)
      ..where((e) => e.recoveredAt.isNotNull())
      ..orderBy([(e) => OrderingTerm.desc(e.occurredAt)]);
    return q.watch().map((rows) => [
          for (final e in rows)
            e.recoveredAt!.difference(e.occurredAt).inMinutes / 60.0,
        ]);
  }

  // --------------------------------------------------------------- writes

  Future<int> logEpisode({
    required DateTime occurredAt,
    required EpisodeType type,
    int? sleepQuality,
    bool? alcohol,
    int? stress,
    List<String> preInterventions = const [],
    String? note,
  }) {
    return _db.transaction(() async {
      final id = await _db.into(_db.episodes).insert(EpisodesCompanion.insert(
            occurredAt: occurredAt,
            type: type,
            sleepQuality: Value(sleepQuality),
            alcohol: Value(alcohol),
            stress: Value(stress),
            preInterventions: Value(preInterventions),
            note: Value(note),
          ));
      await _recomputeDays(dayKey(occurredAt), dayKey(occurredAt));
      return id;
    });
  }

  Future<void> addCheckIn({
    required int episodeId,
    required Feeling overall,
    Map<SymptomCluster, Severity> scores = const {},
    String? note,
    DateTime? at,
  }) {
    final when = at ?? DateTime.now();
    return _mutate(episodeId, () async {
      await _db.into(_db.checkIns).insert(CheckInsCompanion.insert(
            episodeId: episodeId,
            at: when,
            overall: overall.value,
            symptomScores: Value(scores),
            severity: checkInSeverity(overall.value, scores),
            note: Value(note),
          ));
    });
  }

  Future<void> updateCheckIn(
    CheckIn c, {
    required Feeling overall,
    required Map<SymptomCluster, Severity> scores,
  }) {
    return _mutate(c.episodeId, () async {
      await (_db.update(_db.checkIns)..where((x) => x.id.equals(c.id)))
          .write(CheckInsCompanion(
        overall: Value(overall.value),
        symptomScores: Value(scores),
        severity: Value(checkInSeverity(overall.value, scores)),
      ));
    });
  }

  Future<void> deleteCheckIn(CheckIn c) {
    return _mutate(c.episodeId, () async {
      await (_db.delete(_db.checkIns)..where((x) => x.id.equals(c.id))).go();
    });
  }

  Future<void> updateEpisode(
    int episodeId, {
    required DateTime occurredAt,
    required EpisodeType type,
    int? sleepQuality,
    bool? alcohol,
    int? stress,
    List<String> preInterventions = const [],
    String? note,
  }) {
    return _mutate(episodeId, () async {
      await (_db.update(_db.episodes)..where((e) => e.id.equals(episodeId)))
          .write(EpisodesCompanion(
        occurredAt: Value(occurredAt),
        type: Value(type),
        sleepQuality: Value(sleepQuality),
        alcohol: Value(alcohol),
        stress: Value(stress),
        preInterventions: Value(preInterventions),
        note: Value(note),
      ));
    });
  }

  Future<void> markRecovered(int episodeId, {int? recoveryPct, DateTime? at}) {
    return _mutate(episodeId, () async {
      await (_db.update(_db.episodes)..where((e) => e.id.equals(episodeId)))
          .write(EpisodesCompanion(
        recoveredAt: Value(at ?? DateTime.now()),
        recoveryPct: Value(recoveryPct),
      ));
    });
  }

  /// Undo "back to normal" (e.g. tapped by mistake).
  Future<void> reopen(int episodeId) {
    return _mutate(episodeId, () async {
      await (_db.update(_db.episodes)..where((e) => e.id.equals(episodeId)))
          .write(const EpisodesCompanion(
        recoveredAt: Value(null),
        recoveryPct: Value(null),
      ));
    });
  }

  Future<void> deleteEpisode(int episodeId) {
    return _mutate(episodeId, () async {
      // Check-ins go with it (ON DELETE CASCADE).
      await (_db.delete(_db.episodes)..where((x) => x.id.equals(episodeId)))
          .go();
    });
  }

  // ------------------------------------------------------------- internal

  /// Every change to an episode or its check-ins goes through here: apply
  /// [change], refresh the episode's aggregates, then rebuild the day
  /// summaries over the union of the days it covered before and after, so
  /// an edit that moves or shortens an episode leaves nothing stale.
  Future<void> _mutate(int episodeId, Future<void> Function() change) {
    return _db.transaction(() async {
      final before = await _dayRange(episodeId);
      await change();
      await _refreshEpisodeAggregates(episodeId);
      final after = await _dayRange(episodeId);
      final ranges = [?before, ?after];
      if (ranges.isEmpty) return;
      await _recomputeDays(
        ranges.map((r) => r.$1).reduce(math.min),
        ranges.map((r) => r.$2).reduce(math.max),
      );
    });
  }

  /// Days an episode touches: from the event to the later of recovery and
  /// its last check-in. Null if the episode doesn't exist.
  Future<(int, int)?> _dayRange(int episodeId) async {
    final e = await episode(episodeId);
    if (e == null) return null;
    final lastCheckIn = await (_db.selectOnly(_db.checkIns)
          ..addColumns([_db.checkIns.at.max()])
          ..where(_db.checkIns.episodeId.equals(episodeId)))
        .map((r) => r.read(_db.checkIns.at.max()))
        .getSingle();
    final end = [e.occurredAt, e.recoveredAt, lastCheckIn]
        .whereType<DateTime>()
        .reduce((a, b) => a.isAfter(b) ? a : b);
    return (dayKey(e.occurredAt), dayKey(end));
  }

  Future<void> _refreshEpisodeAggregates(int episodeId) async {
    if (await episode(episodeId) == null) return;
    final peak = _db.checkIns.severity.max();
    final count = _db.checkIns.id.count();
    final row = await (_db.selectOnly(_db.checkIns)
          ..addColumns([peak, count])
          ..where(_db.checkIns.episodeId.equals(episodeId)))
        .getSingle();
    final peakIdx = row.read(peak);
    await (_db.update(_db.episodes)..where((x) => x.id.equals(episodeId)))
        .write(EpisodesCompanion(
      peakSeverity: Value(peakIdx == null ? null : Severity.values[peakIdx]),
      checkInCount: Value(row.read(count) ?? 0),
    ));
  }

  /// Rebuilds DailySummaries for an inclusive range of days. Ranges are small
  /// (one episode ≈ 2–7 days) so this stays well under a frame.
  Future<void> _recomputeDays(int fromDay, int toDay) async {
    final from = dayFromKey(fromDay);
    final to = dayFromKey(toDay + 1);

    final checkIns = await (_db.select(_db.checkIns)
          ..where((c) => c.at.isBiggerOrEqualValue(from) & c.at.isSmallerThanValue(to)))
        .get();
    final episodes = await (_db.select(_db.episodes)
          ..where((e) =>
              e.occurredAt.isSmallerThanValue(to) &
              (e.recoveredAt.isNull() | e.recoveredAt.isBiggerOrEqualValue(from))))
        .get();

    await _db.batch((b) {
      for (var day = fromDay; day <= toDay; day++) {
        final dayCheckIns = checkIns.where((c) => dayKey(c.at) == day);
        final covering = episodes.where((e) =>
            dayKey(e.occurredAt) <= day &&
            (e.recoveredAt == null || dayKey(e.recoveredAt!) >= day));

        if (dayCheckIns.isEmpty && covering.isEmpty) {
          b.deleteWhere(_db.dailySummaries, (d) => d.day.equals(day));
          continue;
        }

        Severity? max;
        for (final c in dayCheckIns) {
          if (max == null || c.severity.index > max.index) max = c.severity;
        }
        b.insert(
          _db.dailySummaries,
          DailySummariesCompanion.insert(
            day: Value(day),
            maxSeverity: Value(max),
            activeEpisodeId:
                Value(covering.isEmpty ? null : covering.last.id),
            checkInCount: Value(dayCheckIns.length),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }
}
