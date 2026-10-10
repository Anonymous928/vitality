import 'dart:convert';
import 'dart:io';

import 'package:afterglow/core/domain.dart';
import 'package:afterglow/data/database.dart';
import 'package:afterglow/data/episode_repository.dart';
import 'package:afterglow/data/treatment_repository.dart';
import 'package:afterglow/features/learn/evidence.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('published privacy policy matches the in-app copy', () {
    // docs/privacy.md is served by GitHub Pages for the Play listing; the
    // two must never drift apart (PRD 9.1). Fix: cp assets/legal/privacy_policy.md docs/privacy.md
    expect(File('docs/privacy.md').readAsStringSync(),
        File('assets/legal/privacy_policy.md').readAsStringSync());
  });

  test('evidence library parses and follows the content rules', () {
    final lib = EvidenceLibrary.fromJson(jsonDecode(
            File('assets/content/evidence.json').readAsStringSync())
        as Map<String, dynamic>);
    expect(lib.entries, isNotEmpty);
    for (final e in lib.entries) {
      expect(lib.grades.containsKey(e.grade), isTrue, reason: e.id);
      expect(e.sources, isNotEmpty, reason: '${e.id} needs a source');
      // Every treatment class in the log has a matching entry.
      expect(treatmentClasses.contains(e.treatmentClass), isTrue,
          reason: e.id);
      // Never dose: no "mg" figures in evidence content.
      final text = [e.summary, ...e.reported, ...e.cautions].join(' ');
      expect(RegExp(r'\d+\s*mg').hasMatch(text), isFalse, reason: e.id);
    }
    // PRD 8: these are always specialist-supervised.
    for (final id in ['hyposensitization', 'hormonal', 'biologics']) {
      expect(lib.entries.firstWhere((e) => e.id == id).supervisedOnly, isTrue);
    }
  });

  test('delete everything empties every table', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = EpisodeRepository(db);
    final id = await repo.logEpisode(
        occurredAt: DateTime(2026, 10, 1), type: EpisodeType.solo);
    await repo.addCheckIn(episodeId: id, overall: Feeling.bad);
    await TreatmentRepository(db).save(name: 'X');
    await db.deleteEverything();
    for (final t in db.allTables) {
      expect(await db.select(t).get(), isEmpty, reason: t.actualTableName);
    }
    await db.close();
  });
}
