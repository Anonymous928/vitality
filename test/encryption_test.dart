import 'dart:io';

import 'package:afterglow/core/domain.dart';
import 'package:afterglow/data/database.dart';
import 'package:afterglow/data/episode_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tmp;
  late File file;
  final key = 'ab' * 32;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('afterglow_enc');
    file = File('${tmp.path}/test.db');
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  test('database file is encrypted and needs the right key', () async {
    var db = AppDatabase.openFile(file, key);
    await EpisodeRepository(db)
        .logEpisode(occurredAt: DateTime(2026, 10, 1), type: EpisodeType.solo);
    await db.close();

    // Plain SQLite files start with "SQLite format 3".
    final header = String.fromCharCodes(file.readAsBytesSync().take(15));
    expect(header, isNot('SQLite format 3'));

    final wrong = AppDatabase.openFile(file, 'cd' * 32);
    await expectLater(wrong.select(wrong.episodes).get(), throwsA(anything));
    await wrong.close();

    db = AppDatabase.openFile(file, key);
    expect(await db.select(db.episodes).get(), hasLength(1));
    await db.close();
  });
}
