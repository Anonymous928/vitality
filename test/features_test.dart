import 'dart:convert';
import 'dart:io';

import 'package:afterglow/core/domain.dart';
import 'package:afterglow/data/analysis.dart';
import 'package:afterglow/data/database.dart';
import 'package:afterglow/data/episode_repository.dart';
import 'package:afterglow/data/export.dart';
import 'package:afterglow/data/self_check.dart';
import 'package:afterglow/data/treatment_repository.dart';
import 'package:afterglow/report/report_pdf.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late EpisodeRepository repo;
  final t0 = DateTime(2026, 9, 1, 22);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = EpisodeRepository(db);
  });
  tearDown(() => db.close());

  /// Three recovered episodes, a week apart, peaking ~a day in.
  Future<void> seed({List<String> pre = const []}) async {
    for (var i = 0; i < 3; i++) {
      final start = t0.add(Duration(days: 7 * i));
      final id = await repo.logEpisode(
          occurredAt: start,
          type: EpisodeType.solo,
          preInterventions: i == 2 ? pre : const []);
      await repo.addCheckIn(
          episodeId: id,
          overall: Feeling.bad,
          scores: {SymptomCluster.cognitive: Severity.moderate},
          at: start.add(const Duration(hours: 2)));
      await repo.addCheckIn(
          episodeId: id,
          overall: Feeling.awful,
          scores: {SymptomCluster.fatigue: Severity.severe},
          at: start.add(const Duration(hours: 26)));
      await repo.markRecovered(id, at: start.add(const Duration(hours: 72)));
    }
  }

  Future<InsightsSummary> insights() async => computeInsights(
      await db.select(db.episodes).get(), await db.select(db.checkIns).get());

  test('insights: baseline, peak timing, symptom counts', () async {
    await seed();
    final s = await insights();
    expect(s.episodeCount, 3);
    expect(s.hasBaseline, isTrue);
    expect(s.meanDurationHours, 72);
    expect(s.meanPeakHours, 26);
    expect(s.pctSymptomatic, 1.0);
    expect(s.symptomEpisodes[SymptomCluster.fatigue], 3);
    expect(s.symptomEpisodes[SymptomCluster.cognitive], 3);
    expect(s.symptomEpisodes[SymptomCluster.mood], 0);

    // Curve rises to Severe in the 24-36h bin and returns to None after
    // recovery at 72h.
    final curve = {for (final p in s.averageCurve!) p.hours: p.severity};
    expect(curve[30], 3); // bin 24-36
    expect(curve[84], 0); // bin 72-96, after recovery
    expect(s.latest!.points.last.severity, 0); // recovery point
  });

  test('insights: no baseline with fewer than 3 recovered', () async {
    final id = await repo.logEpisode(occurredAt: t0, type: EpisodeType.solo);
    await repo.addCheckIn(episodeId: id, overall: Feeling.meh, at: t0);
    final s = await insights();
    expect(s.hasBaseline, isFalse);
    expect(s.latest, isNotNull);
    expect(s.meanDurationHours, isNull);
  });

  test('treatment comparison splits by taken-before and active period',
      () async {
    await seed(pre: ['Cetirizine']);
    await TreatmentRepository(db).save(name: 'Cetirizine');
    await TreatmentRepository(db).save(
        name: 'Ibuprofen', startedAt: t0.add(const Duration(days: 6)));
    final cmp = compareTreatments(await db.select(db.treatments).get(),
        await db.select(db.episodes).get(), await db.select(db.checkIns).get());
    final byName = {for (final c in cmp) c.treatment.name: c};
    expect(byName['Cetirizine']!.withStats.episodes, 1);
    expect(byName['Cetirizine']!.withoutStats.episodes, 2);
    expect(byName['Ibuprofen']!.withStats.episodes, 2); // weeks 2 and 3
    expect(byName['Ibuprofen']!.withStats.meanPeak, 3);
  });

  test('self-check criteria and JSON round-trip', () {
    const a = SelfCheckAnswers(
      symptoms: {SymptomCluster.fatigue, SymptomCluster.cognitive},
      onset: Onset.minutes,
      frequency: Frequency.often,
      duration: DurationAnswer.twoToSeven,
      resolves: YesNoUnsure.yes,
      onsetType: OnsetType.secondary,
      triggers: {EpisodeType.solo},
      redFlags: false,
    );
    expect(a.criteria, [true, true, false, true, true]);
    expect(a.criteriaMet, 4);
    final back = SelfCheckAnswers.fromJson(
        jsonDecode(jsonEncode(a.toJson())) as Map<String, dynamic>,
        a.onsetType!.name);
    expect(back.criteria, a.criteria);
    expect(back.triggers, a.triggers);
    expect(back.onsetType, OnsetType.secondary);
    expect(const SelfCheckAnswers(symptoms: {SymptomCluster.other}).c1Symptoms,
        isFalse);
  });

  test('PDF report builds with all sections', () async {
    await seed(pre: ['Cetirizine']);
    await TreatmentRepository(db).save(name: 'Cetirizine', dose: '10 mg');
    final bytes = await buildReportPdf(ReportInput(
      sections: {...ReportSection.values},
      episodes: await db.select(db.episodes).get(),
      checkIns: await db.select(db.checkIns).get(),
      treatments: await db.select(db.treatments).get(),
      selfCheck: const SelfCheckAnswers(redFlags: true),
      selfCheckDate: DateTime(2026, 9, 1),
      workImpact: ImpactLevel.aLot,
      relationshipImpact: null,
      daysMissed: 4,
      generatedAt: DateTime(2026, 10, 10),
      regularFont: File('assets/fonts/Roboto-Regular.ttf').readAsBytesSync(),
      boldFont: File('assets/fonts/Roboto-Bold.ttf').readAsBytesSync(),
    ));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(5000));
  });

  test('PDF report builds with no data', () async {
    final bytes = await buildReportPdf(ReportInput(
      sections: {...ReportSection.values},
      episodes: const [],
      checkIns: const [],
      treatments: const [],
      selfCheck: null,
      selfCheckDate: null,
      workImpact: null,
      relationshipImpact: null,
      daysMissed: null,
      generatedAt: DateTime(2026, 10, 10),
      regularFont: File('assets/fonts/Roboto-Regular.ttf').readAsBytesSync(),
      boldFont: File('assets/fonts/Roboto-Bold.ttf').readAsBytesSync(),
    ));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('export contains all records as versioned JSON', () async {
    await seed();
    await TreatmentRepository(db).save(name: 'Cetirizine');
    await AssessmentRepository(db).save(const SelfCheckAnswers(
        onset: Onset.hours, onsetType: OnsetType.primary));
    final j = jsonDecode(utf8.decode(await buildExport(db)))
        as Map<String, dynamic>;
    expect(j['format'], exportFormat);
    expect(j['version'], 1);
    expect(j['episodes'], hasLength(3));
    expect(j['checkIns'], hasLength(6));
    expect(j['treatments'], hasLength(1));
    expect(j['selfChecks'][0]['onsetType'], 'primary');
    expect((j['checkIns'] as List).first['symptoms'],
        {'cognitive': 'moderate'});
  });
}
