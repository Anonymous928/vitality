// Generates build/sample_report.pdf from realistic fake data, for reviewing
// the report's layout and wording (e.g. by medical advisors).
// Run: flutter test tool/sample_report_test.dart
import 'dart:io';

import 'package:afterglow/core/domain.dart';
import 'package:afterglow/data/database.dart';
import 'package:afterglow/data/episode_repository.dart';
import 'package:afterglow/data/self_check.dart';
import 'package:afterglow/data/treatment_repository.dart';
import 'package:afterglow/report/report_pdf.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('render sample report', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = EpisodeRepository(db);
    final t0 = DateTime(2026, 7, 1, 22);
    for (var i = 0; i < 6; i++) {
      final start = t0.add(Duration(days: 9 * i));
      final id = await repo.logEpisode(
          occurredAt: start,
          type: EpisodeType.values[i % 3],
          preInterventions: i >= 3 ? ['Cetirizine'] : []);
      await repo.addCheckIn(
          episodeId: id,
          overall: Feeling.meh,
          scores: {SymptomCluster.cognitive: Severity.moderate},
          at: start.add(const Duration(hours: 1)));
      await repo.addCheckIn(
          episodeId: id,
          overall: i >= 3 ? Feeling.bad : Feeling.awful,
          scores: {
            SymptomCluster.fatigue: Severity.severe,
            SymptomCluster.fluLike: Severity.mild,
          },
          at: start.add(Duration(hours: 20 + i)));
      await repo.addCheckIn(
          episodeId: id,
          overall: Feeling.good,
          at: start.add(const Duration(hours: 60)));
      await repo.markRecovered(id,
          recoveryPct: 90, at: start.add(Duration(hours: 70 + 6 * i)));
    }
    await TreatmentRepository(db).save(
        name: 'Cetirizine',
        treatmentClass: 'Antihistamine',
        dose: '10 mg once daily',
        prescriber: 'Dr Rao (GP)',
        startedAt: DateTime(2026, 7, 25));

    final bytes = await buildReportPdf(ReportInput(
      sections: {...ReportSection.values},
      episodes: await db.select(db.episodes).get(),
      checkIns: await db.select(db.checkIns).get(),
      treatments: await db.select(db.treatments).get(),
      selfCheck: const SelfCheckAnswers(
        symptoms: {
          SymptomCluster.fatigue,
          SymptomCluster.cognitive,
          SymptomCluster.fluLike,
        },
        onset: Onset.minutes,
        frequency: Frequency.almostAlways,
        duration: DurationAnswer.twoToSeven,
        resolves: YesNoUnsure.yes,
        onsetType: OnsetType.secondary,
        triggers: {EpisodeType.solo, EpisodeType.nocturnal},
        redFlags: false,
      ),
      selfCheckDate: DateTime(2026, 7, 1),
      workImpact: ImpactLevel.aLot,
      relationshipImpact: ImpactLevel.aLittle,
      daysMissed: 4,
      generatedAt: DateTime(2026, 10, 10),
      regularFont: File('assets/fonts/Roboto-Regular.ttf').readAsBytesSync(),
      boldFont: File('assets/fonts/Roboto-Bold.ttf').readAsBytesSync(),
    ));
    File('build/sample_report.pdf').writeAsBytesSync(bytes);
    await db.close();
  });
}
