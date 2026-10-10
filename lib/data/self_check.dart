import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/domain.dart';
import 'database.dart';

/// Answers to the POIS Self-Check, mapped onto Waldinger's 5 criteria
/// (PRD §2.1, §6.1). The app never diagnoses: results are phrased as
/// "consistent with features described in POIS literature".
class SelfCheckAnswers {
  const SelfCheckAnswers({
    this.symptoms = const {},
    this.onset,
    this.frequency,
    this.duration,
    this.resolves,
    this.onsetType,
    this.triggers = const {},
    this.redFlags,
  });

  final Set<SymptomCluster> symptoms;
  final Onset? onset;
  final Frequency? frequency;
  final DurationAnswer? duration;
  final YesNoUnsure? resolves;
  final OnsetType? onsetType;
  final Set<EpisodeType> triggers;
  final bool? redFlags;

  /// Criterion 1: a characteristic set of symptoms. "Other" alone doesn't
  /// count.
  bool get c1Symptoms => symptoms.any((s) => s != SymptomCluster.other);

  /// Criterion 2: onset within seconds, minutes or a few hours.
  bool get c2Onset => onset == Onset.minutes || onset == Onset.hours;

  /// Criterion 3: after more than 90% of ejaculations.
  bool get c3Frequency => frequency == Frequency.almostAlways;

  /// Criterion 4: most symptoms last 2–7 days.
  bool get c4Duration => duration == DurationAnswer.twoToSeven;

  /// Criterion 5: symptoms go away on their own.
  bool get c5Resolves => resolves == YesNoUnsure.yes;

  List<bool> get criteria =>
      [c1Symptoms, c2Onset, c3Frequency, c4Duration, c5Resolves];
  int get criteriaMet => criteria.where((c) => c).length;

  static const criteriaLabels = [
    'Characteristic symptoms (flu-like, fatigue, brain fog, muscle weakness, mood, allergy-like)',
    'Onset within seconds, minutes or a few hours',
    'Symptoms after more than 90% of ejaculations',
    'Most symptoms last 2 to 7 days',
    'Symptoms go away on their own',
  ];

  SelfCheckAnswers copyWith({
    Set<SymptomCluster>? symptoms,
    Onset? onset,
    Frequency? frequency,
    DurationAnswer? duration,
    YesNoUnsure? resolves,
    OnsetType? onsetType,
    Set<EpisodeType>? triggers,
    bool? redFlags,
  }) =>
      SelfCheckAnswers(
        symptoms: symptoms ?? this.symptoms,
        onset: onset ?? this.onset,
        frequency: frequency ?? this.frequency,
        duration: duration ?? this.duration,
        resolves: resolves ?? this.resolves,
        onsetType: onsetType ?? this.onsetType,
        triggers: triggers ?? this.triggers,
        redFlags: redFlags ?? this.redFlags,
      );

  Map<String, Object?> toJson() => {
        'v': 1,
        'symptoms': symptoms.map((s) => s.name).toList(),
        'onset': onset?.name,
        'frequency': frequency?.name,
        'duration': duration?.name,
        'resolves': resolves?.name,
        'triggers': triggers.map((t) => t.name).toList(),
        'redFlags': redFlags,
      };

  factory SelfCheckAnswers.fromJson(Map<String, dynamic> j, String? onsetType) {
    T? byName<T extends Enum>(List<T> values, Object? name) =>
        name == null ? null : values.asNameMap()[name];
    return SelfCheckAnswers(
      symptoms: {
        for (final n in (j['symptoms'] as List? ?? const []))
          ?byName(SymptomCluster.values, n),
      },
      onset: byName(Onset.values, j['onset']),
      frequency: byName(Frequency.values, j['frequency']),
      duration: byName(DurationAnswer.values, j['duration']),
      resolves: byName(YesNoUnsure.values, j['resolves']),
      onsetType: byName(OnsetType.values, onsetType),
      triggers: {
        for (final n in (j['triggers'] as List? ?? const []))
          ?byName(EpisodeType.values, n),
      },
      redFlags: j['redFlags'] as bool?,
    );
  }
}

enum Onset {
  minutes('Within seconds or minutes'),
  hours('Within a few hours'),
  later('The next day or later'),
  unsure('Not sure');

  const Onset(this.label);
  final String label;
}

enum Frequency {
  almostAlways('Almost every time (9 out of 10 or more)'),
  often('More than half the time'),
  sometimes('Sometimes'),
  unsure('Not sure');

  const Frequency(this.label);
  final String label;
}

enum DurationAnswer {
  underTwo('Less than 2 days'),
  twoToSeven('2 to 7 days'),
  overSeven('More than a week'),
  unsure('Not sure');

  const DurationAnswer(this.label);
  final String label;
}

enum YesNoUnsure {
  yes('Yes'),
  no('No'),
  unsure('Not sure');

  const YesNoUnsure(this.label);
  final String label;
}

enum OnsetType {
  primary('Since my first experiences (in adolescence)',
      'Primary (since first ejaculations)'),
  secondary('It started later in life', 'Secondary (began later in life)'),
  unsure('Not sure', 'Not sure');

  const OnsetType(this.label, this.reportLabel);
  final String label;
  final String reportLabel;
}

class AssessmentRepository {
  AssessmentRepository(this._db);
  final AppDatabase _db;

  Stream<(DateTime, SelfCheckAnswers)?> watchLatest() {
    final q = _db.select(_db.assessments)
      ..orderBy([(a) => OrderingTerm.desc(a.date)])
      ..limit(1);
    return q.watchSingleOrNull().map((a) => a == null
        ? null
        : (
            a.date,
            SelfCheckAnswers.fromJson(
                jsonDecode(a.waldingerAnswers) as Map<String, dynamic>,
                a.onsetType),
          ));
  }

  Future<void> save(SelfCheckAnswers answers) =>
      _db.into(_db.assessments).insert(AssessmentsCompanion.insert(
            date: DateTime.now(),
            waldingerAnswers: jsonEncode(answers.toJson()),
            onsetType: Value(answers.onsetType?.name),
          ));
}
