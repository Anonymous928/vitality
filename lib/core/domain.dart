import 'package:flutter/material.dart';

/// What triggered an episode. Labels are deliberately neutral (PRD §6.2, §9).
enum EpisodeType {
  partnered('With partner', Icons.people_outline),
  solo('Solo', Icons.person_outline),
  nocturnal('During sleep', Icons.bedtime_outlined);

  const EpisodeType(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// The 7 symptom clusters from the PRD (§6.1, §6.2).
enum SymptomCluster {
  fatigue('Fatigue', Icons.battery_2_bar),
  cognitive('Brain fog', Icons.cloud_outlined),
  fluLike('Flu-like', Icons.thermostat_outlined),
  allergic('Allergy-like', Icons.air),
  mood('Mood', Icons.mood_bad_outlined),
  muscular('Muscle weakness', Icons.accessibility_new),
  other('Other', Icons.more_horiz);

  const SymptomCluster(this.label, this.icon);
  final String label;
  final IconData icon;

  static const defaultTop3 = [fatigue, cognitive, fluLike];
}

/// One severity scale used everywhere: chips, calendar, curves.
/// Always shown with its text label so it works without colour vision.
enum Severity {
  none('None', Color(0xFF43A047)),
  mild('Mild', Color(0xFFFDD835)),
  moderate('Moderate', Color(0xFFFB8C00)),
  severe('Severe', Color(0xFFE53935));

  const Severity(this.label, this.color);
  final String label;
  final Color color;

  /// Readable text colour on top of [color].
  Color get onColor => this == Severity.mild ? Colors.black87 : Colors.white;
}

/// Daylio-style 5-point "How do you feel?" scale. Value 1 = awful … 5 = great.
enum Feeling {
  awful(1, 'Awful', Icons.sentiment_very_dissatisfied),
  bad(2, 'Bad', Icons.sentiment_dissatisfied),
  meh(3, 'Okay', Icons.sentiment_neutral),
  good(4, 'Good', Icons.sentiment_satisfied),
  great(5, 'Normal', Icons.sentiment_very_satisfied);

  const Feeling(this.value, this.label, this.icon);
  final int value;
  final String label;
  final IconData icon;

  static Feeling fromValue(int v) => values.firstWhere((f) => f.value == v);

  /// How this overall rating maps onto the shared severity scale.
  Severity get severity => switch (this) {
        great || good => Severity.none,
        meh => Severity.mild,
        bad => Severity.moderate,
        awful => Severity.severe,
      };
}

/// Severity of a single check-in: the worst of the overall feeling and any
/// individual symptom score.
Severity checkInSeverity(int overall, Map<SymptomCluster, Severity> scores) {
  var worst = Feeling.fromValue(overall).severity;
  for (final s in scores.values) {
    if (s.index > worst.index) worst = s;
  }
  return worst;
}

/// Calendar-day helpers. Days are stored as an int (days since epoch, local)
/// so DailySummary lookups are cheap integer comparisons.
int dayKey(DateTime t) =>
    DateTime.utc(t.year, t.month, t.day).millisecondsSinceEpoch ~/ 86400000;

DateTime dayFromKey(int key) {
  final u = DateTime.fromMillisecondsSinceEpoch(key * 86400000, isUtc: true);
  return DateTime(u.year, u.month, u.day);
}
