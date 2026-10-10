import 'package:drift/drift.dart';

import 'database.dart';

/// Treatment classes from the evidence library (PRD §2.3). Used only for
/// grouping; the app never suggests a treatment or dose.
const treatmentClasses = [
  'Antihistamine',
  'Alpha-blocker',
  'NSAID / anti-inflammatory',
  'Hyposensitization',
  'Hormonal',
  'Biologic',
  'SSRI / psychiatric',
  'Supplement or diet',
  'Other',
];

class TreatmentRepository {
  TreatmentRepository(this._db);
  final AppDatabase _db;

  Stream<List<Treatment>> watchAll() {
    final q = _db.select(_db.treatments)
      ..orderBy([
        // Ongoing first, then most recently started.
        (t) => OrderingTerm(
            expression: t.endedAt.isNull(), mode: OrderingMode.desc),
        (t) => OrderingTerm.desc(t.startedAt),
      ]);
    return q.watch();
  }

  Future<List<Treatment>> all() => _db.select(_db.treatments).get();

  Future<void> save({
    int? id,
    required String name,
    String? treatmentClass,
    String? dose,
    String? prescriber,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    final row = TreatmentsCompanion(
      name: Value(name),
      treatmentClass: Value(treatmentClass),
      dose: Value(dose),
      prescriber: Value(prescriber),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
    );
    if (id == null) return _db.into(_db.treatments).insert(row);
    return (_db.update(_db.treatments)..where((t) => t.id.equals(id)))
        .write(row);
  }

  Future<void> delete(int id) =>
      (_db.delete(_db.treatments)..where((t) => t.id.equals(id))).go();
}
