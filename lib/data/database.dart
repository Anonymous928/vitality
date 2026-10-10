import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../core/domain.dart';

part 'database.g.dart';

/// Stored as JSON text: {"fatigue": 2, "cognitive": 1}
class SymptomScoresConverter
    extends TypeConverter<Map<SymptomCluster, Severity>, String> {
  const SymptomScoresConverter();

  @override
  Map<SymptomCluster, Severity> fromSql(String fromDb) {
    final raw = jsonDecode(fromDb) as Map<String, dynamic>;
    return {
      for (final e in raw.entries)
        SymptomCluster.values.byName(e.key): Severity.values[e.value as int],
    };
  }

  @override
  String toSql(Map<SymptomCluster, Severity> value) =>
      jsonEncode({for (final e in value.entries) e.key.name: e.value.index});
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();
  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List).cast<String>();
  @override
  String toSql(List<String> value) => jsonEncode(value);
}

class Episodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get occurredAt => dateTime()();
  IntColumn get type => intEnum<EpisodeType>()();

  // Optional context ("Add details").
  IntColumn get sleepQuality => integer().nullable()(); // 1-5
  BoolColumn get alcohol => boolean().nullable()();
  IntColumn get stress => integer().nullable()(); // 1-5
  TextColumn get preInterventions => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get note => text().nullable()();

  DateTimeColumn get recoveredAt => dateTime().nullable()();
  IntColumn get recoveryPct => integer().nullable()();

  // Aggregates maintained on write (PRD §10.7 rule 4).
  IntColumn get peakSeverity => intEnum<Severity>().nullable()();
  IntColumn get checkInCount => integer().withDefault(const Constant(0))();
}

class CheckIns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get episodeId =>
      integer().references(Episodes, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get at => dateTime()();
  IntColumn get overall => integer()(); // Feeling.value, 1-5
  TextColumn get symptomScores => text()
      .map(const SymptomScoresConverter())
      .withDefault(const Constant('{}'))();
  IntColumn get severity => intEnum<Severity>()(); // derived, stored for speed
  TextColumn get note => text().nullable()();
}

/// One row per calendar day touched by an episode. Precomputed on write so
/// the calendar, ring and charts never scan raw check-ins.
class DailySummaries extends Table {
  IntColumn get day => integer()(); // dayKey()
  IntColumn get maxSeverity => intEnum<Severity>().nullable()();
  IntColumn get activeEpisodeId => integer().nullable()();
  IntColumn get checkInCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {day};
}

class Treatments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get treatmentClass => text().nullable()();
  TextColumn get dose => text().nullable()(); // user-entered only, never suggested
  TextColumn get prescriber => text().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get endedAt => dateTime().nullable()();
}

class Assessments extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get waldingerAnswers => text()(); // JSON
  TextColumn get onsetType => text().nullable()(); // primary | secondary | unsure
}

/// Small key/value store for preferences. Kept in the encrypted DB so there's
/// no second storage system to secure.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  Episodes,
  CheckIns,
  DailySummaries,
  Treatments,
  Assessments,
  Settings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Opens the encrypted database on a background isolate (PRD §10.7 rule 3).
  ///
  /// [hexKey] is a random 256-bit key from the Android Keystore. Because it is
  /// already full-entropy, key stretching is pointless, so we set kdf_iter=1
  /// and skip the slow derivation on every launch (PRD §10.7 rule 5).
  static Future<AppDatabase> open(String hexKey) async {
    final dir = await getApplicationSupportDirectory();
    return openFile(File(p.join(dir.path, 'afterglow.db')), hexKey);
  }

  static AppDatabase openFile(File file, String hexKey) {
    return AppDatabase(
      NativeDatabase.createInBackground(
        file,
        setup: (Database raw) {
          if (raw.select('PRAGMA cipher;').isEmpty) {
            throw StateError('SQLite build has no encryption support');
          }
          raw.execute("PRAGMA cipher = 'chacha20';");
          raw.execute('PRAGMA kdf_iter = 1;');
          raw.execute("PRAGMA hexkey = '$hexKey';");
          // Fails fast with "file is not a database" if the key is wrong.
          raw.select('SELECT count(*) FROM sqlite_master;');
        },
      ),
    );
  }
}
