import 'package:afterglow/core/domain.dart';
import 'package:afterglow/data/database.dart';
import 'package:afterglow/data/episode_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late EpisodeRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = EpisodeRepository(db);
  });
  tearDown(() => db.close());

  Future<Map<int, DailySummary>> summaries() async => {
        for (final s in await db.select(db.dailySummaries).get()) s.day: s,
      };

  test('logging an episode creates a summary for its day', () async {
    final t = DateTime(2026, 10, 1, 22);
    final id = await repo.logEpisode(occurredAt: t, type: EpisodeType.solo);

    final s = await summaries();
    expect(s.keys, [dayKey(t)]);
    expect(s[dayKey(t)]!.activeEpisodeId, id);
    expect(s[dayKey(t)]!.maxSeverity, isNull);
    expect(await repo.watchActiveEpisode().first, isNotNull);
  });

  test('check-ins set peak severity and per-day max', () async {
    final t = DateTime(2026, 10, 1, 22);
    final id = await repo.logEpisode(occurredAt: t, type: EpisodeType.solo);

    await repo.addCheckIn(
        episodeId: id,
        overall: Feeling.meh,
        scores: {SymptomCluster.fatigue: Severity.moderate},
        at: t.add(const Duration(hours: 1)));
    await repo.addCheckIn(
        episodeId: id,
        overall: Feeling.awful,
        at: t.add(const Duration(hours: 20)));
    await repo.addCheckIn(
        episodeId: id,
        overall: Feeling.good,
        at: t.add(const Duration(hours: 44)));

    final e = (await repo.episode(id))!;
    expect(e.peakSeverity, Severity.severe);
    expect(e.checkInCount, 3);

    final s = await summaries();
    expect(s[dayKey(t)]!.maxSeverity, Severity.moderate); // 23:00 check-in
    expect(s[dayKey(t) + 1]!.maxSeverity, Severity.severe);
    expect(s[dayKey(t) + 2]!.maxSeverity, Severity.none);
    expect(s[dayKey(t) + 1]!.activeEpisodeId, id);
  });

  test('recovery closes the episode and covers days through recovery',
      () async {
    final t = DateTime(2026, 10, 1, 22);
    final id = await repo.logEpisode(occurredAt: t, type: EpisodeType.nocturnal);
    await repo.markRecovered(id,
        recoveryPct: 90, at: t.add(const Duration(days: 3)));

    expect(await repo.watchActiveEpisode().first, isNull);
    final s = await summaries();
    expect(s.keys.toList()..sort(),
        [dayKey(t), dayKey(t) + 1, dayKey(t) + 2, dayKey(t) + 3]);
    expect(await repo.watchRecoveredDurations().first, [72.0]);
  });

  test('deleting an episode removes its summaries and check-ins', () async {
    final t = DateTime(2026, 10, 1, 22);
    final id = await repo.logEpisode(occurredAt: t, type: EpisodeType.solo);
    await repo.addCheckIn(
        episodeId: id, overall: Feeling.bad, at: t.add(const Duration(hours: 3)));
    await repo.markRecovered(id, at: t.add(const Duration(days: 2)));

    await repo.deleteEpisode(id);
    expect(await summaries(), isEmpty);
    expect(await db.select(db.checkIns).get(), isEmpty);
  });

  test('days are local calendar days across DST', () {
    final d = DateTime(2026, 3, 29, 12);
    expect(dayFromKey(dayKey(d)), DateTime(2026, 3, 29));
    expect(dayKey(DateTime(2026, 3, 30, 0, 30)) - dayKey(d), 1);
  });

  test('settings converter round-trips', () {
    const c = SymptomScoresConverter();
    final m = {SymptomCluster.cognitive: Severity.severe};
    expect(c.fromSql(c.toSql(m)), m);
  });

  test('foreign keys are on', () async {
    final r = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(r.data.values.first, 1);
  });
}
