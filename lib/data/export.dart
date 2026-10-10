import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'database.dart';

/// Full data export as readable, versioned JSON. Not encrypted: the user is
/// warned before saving. No import yet (planned alongside an encrypted
/// format).
const exportFormat = 'afterglow-export';
const exportVersion = 1;

Future<Uint8List> buildExport(AppDatabase db) async {
  final episodes = await db.select(db.episodes).get();
  final checkIns = await db.select(db.checkIns).get();
  final treatments = await db.select(db.treatments).get();
  final assessments = await db.select(db.assessments).get();

  return Isolate.run(() {
    String? iso(DateTime? d) => d?.toIso8601String();
    final data = {
      'format': exportFormat,
      'version': exportVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'severityScale': ['none', 'mild', 'moderate', 'severe'],
      'episodes': [
        for (final e in episodes)
          {
            'id': e.id,
            'occurredAt': iso(e.occurredAt),
            'type': e.type.name,
            'sleepQuality': e.sleepQuality,
            'alcohol': e.alcohol,
            'stress': e.stress,
            'preInterventions': e.preInterventions,
            'note': e.note,
            'recoveredAt': iso(e.recoveredAt),
            'recoveryPct': e.recoveryPct,
          },
      ],
      'checkIns': [
        for (final c in checkIns)
          {
            'id': c.id,
            'episodeId': c.episodeId,
            'at': iso(c.at),
            'overall': c.overall,
            'severity': c.severity.name,
            'symptoms': {
              for (final s in c.symptomScores.entries) s.key.name: s.value.name,
            },
            'note': c.note,
          },
      ],
      'treatments': [
        for (final t in treatments)
          {
            'id': t.id,
            'name': t.name,
            'class': t.treatmentClass,
            'dose': t.dose,
            'prescriber': t.prescriber,
            'startedAt': iso(t.startedAt),
            'endedAt': iso(t.endedAt),
          },
      ],
      'selfChecks': [
        for (final a in assessments)
          {
            'date': iso(a.date),
            'answers': jsonDecode(a.waldingerAnswers),
            'onsetType': a.onsetType,
          },
      ],
    };
    return Uint8List.fromList(
        utf8.encode(const JsonEncoder.withIndent('  ').convert(data)));
  });
}
