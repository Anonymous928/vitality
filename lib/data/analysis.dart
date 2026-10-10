import 'dart:isolate';
import 'dart:math' as math;

import '../core/domain.dart';
import 'database.dart';

/// Descriptive, transparent statistics only (PRD §6.3): no models, no
/// "AI". Everything here is a pure function of the user's own rows so it can
/// run in a background isolate and be unit tested.

/// A point on a recovery curve: [hours] since the trigger, [severity] on the
/// 0 (None) .. 3 (Severe) scale.
class CurvePoint {
  const CurvePoint(this.hours, this.severity);
  final double hours;
  final double severity;
}

class EpisodeCurve {
  const EpisodeCurve(this.episode, this.points);
  final Episode episode;
  final List<CurvePoint> points;
}

/// Comparison of episodes with vs without a treatment.
class TreatmentComparison {
  const TreatmentComparison({
    required this.treatment,
    required this.withStats,
    required this.withoutStats,
  });
  final Treatment treatment;
  final GroupStats withStats;
  final GroupStats withoutStats;
}

class GroupStats {
  const GroupStats({
    required this.episodes,
    this.meanPeak,
    this.meanDurationHours,
  });
  final int episodes;
  final double? meanPeak; // 0..3
  final double? meanDurationHours;
}

class InsightsSummary {
  const InsightsSummary({
    required this.episodeCount,
    required this.recoveredCount,
    required this.checkInCount,
    this.meanDurationHours,
    this.meanPeakHours,
    this.pctSymptomatic,
    this.averageCurve,
    this.latest,
    required this.symptomEpisodes,
    required this.episodesWithCheckIns,
  });

  final int episodeCount;
  final int recoveredCount;
  final int checkInCount;

  /// Mean time from trigger to "recovered" (recovered episodes only).
  final double? meanDurationHours;

  /// Mean time from trigger to the worst check-in.
  final double? meanPeakHours;

  /// Share of episodes (with ≥1 check-in) that had any symptoms: the
  /// ">90% of the time" criterion, measured rather than recalled.
  final double? pctSymptomatic;

  /// Personal baseline curve; null until [baselineMinEpisodes] recovered
  /// episodes have check-ins.
  final List<CurvePoint>? averageCurve;

  /// The most recent episode that has check-ins.
  final EpisodeCurve? latest;

  /// For each symptom: number of episodes in which it reached Mild or worse.
  final Map<SymptomCluster, int> symptomEpisodes;
  final int episodesWithCheckIns;

  bool get hasBaseline => averageCurve != null;
}

const baselineMinEpisodes = 3;

/// [computeInsights] on a background isolate (top-level and non-async so the
/// closure only captures the two lists).
Future<InsightsSummary> computeInsightsInBackground(
  List<Episode> episodes,
  List<CheckIn> checkIns,
) => Isolate.run(() => computeInsights(episodes, checkIns));

/// Bin edges (hours) for the average curve: dense early, where symptoms
/// change fastest, sparse later.
const curveBinEdges = [0, 3, 6, 12, 24, 36, 48, 72, 96, 120, 144, 168];

InsightsSummary computeInsights(
  List<Episode> episodes,
  List<CheckIn> checkIns,
) {
  final byEpisode = <int, List<CheckIn>>{};
  for (final c in checkIns) {
    (byEpisode[c.episodeId] ??= []).add(c);
  }
  for (final list in byEpisode.values) {
    list.sort((a, b) => a.at.compareTo(b.at));
  }

  final recovered = episodes.where((e) => e.recoveredAt != null).toList();
  final durations = [
    for (final e in recovered)
      e.recoveredAt!.difference(e.occurredAt).inMinutes / 60.0,
  ];

  final withCheckIns = episodes
      .where((e) => byEpisode.containsKey(e.id))
      .toList();

  final peakHours = <double>[];
  var symptomatic = 0;
  final symptomEpisodes = {for (final s in SymptomCluster.values) s: 0};
  for (final e in withCheckIns) {
    final list = byEpisode[e.id]!;
    var worst = list.first;
    for (final c in list) {
      if (c.severity.index > worst.severity.index) worst = c;
    }
    peakHours.add(_hoursSince(e, worst.at));
    if (worst.severity != Severity.none) symptomatic++;
    for (final s in SymptomCluster.values) {
      if (list.any(
        (c) => (c.symptomScores[s]?.index ?? 0) >= Severity.mild.index,
      )) {
        symptomEpisodes[s] = symptomEpisodes[s]! + 1;
      }
    }
  }

  final baselineEpisodes = recovered
      .where((e) => byEpisode.containsKey(e.id))
      .toList();

  EpisodeCurve? latest;
  if (withCheckIns.isNotEmpty) {
    final e = withCheckIns.reduce(
      (a, b) => a.occurredAt.isAfter(b.occurredAt) ? a : b,
    );
    latest = EpisodeCurve(e, episodeCurve(e, byEpisode[e.id]!));
  }

  return InsightsSummary(
    episodeCount: episodes.length,
    recoveredCount: recovered.length,
    checkInCount: checkIns.length,
    meanDurationHours: _mean(durations),
    meanPeakHours: _mean(peakHours),
    pctSymptomatic: withCheckIns.isEmpty
        ? null
        : symptomatic / withCheckIns.length,
    averageCurve: baselineEpisodes.length >= baselineMinEpisodes
        ? averageCurve(baselineEpisodes, byEpisode)
        : null,
    latest: latest,
    symptomEpisodes: symptomEpisodes,
    episodesWithCheckIns: withCheckIns.length,
  );
}

/// One episode's curve: a point at the trigger (unknown → plotted from the
/// first check-in), each check-in, and 0 at recovery.
List<CurvePoint> episodeCurve(Episode e, List<CheckIn> sorted) {
  return [
    for (final c in sorted)
      CurvePoint(_hoursSince(e, c.at), c.severity.index.toDouble()),
    if (e.recoveredAt != null) CurvePoint(_hoursSince(e, e.recoveredAt!), 0),
  ];
}

/// Averages recovered episodes into [curveBinEdges] bins. Within a bin an
/// episode contributes its worst check-in; bins entirely after recovery
/// count as 0 so the curve returns to baseline. Empty bins are skipped.
List<CurvePoint> averageCurve(
  List<Episode> episodes,
  Map<int, List<CheckIn>> byEpisode,
) {
  final points = <CurvePoint>[];
  for (var b = 0; b < curveBinEdges.length - 1; b++) {
    final lo = curveBinEdges[b].toDouble();
    final hi = curveBinEdges[b + 1].toDouble();
    final values = <double>[];
    for (final e in episodes) {
      final inBin = (byEpisode[e.id] ?? const <CheckIn>[]).where((c) {
        final h = _hoursSince(e, c.at);
        return h >= lo && h < hi;
      });
      if (inBin.isNotEmpty) {
        values.add(inBin.map((c) => c.severity.index).reduce(math.max) * 1.0);
      } else if (e.recoveredAt != null &&
          _hoursSince(e, e.recoveredAt!) <= lo) {
        values.add(0);
      }
    }
    if (values.isNotEmpty) {
      points.add(CurvePoint((lo + hi) / 2, _mean(values)!));
    }
  }
  return points;
}

/// Episodes "with" a treatment: logged as taken before, or occurring while
/// the treatment was active. Everything else is "without".
List<TreatmentComparison> compareTreatments(
  List<Treatment> treatments,
  List<Episode> episodes,
  List<CheckIn> checkIns,
) {
  final peakByEpisode = <int, int>{};
  for (final c in checkIns) {
    peakByEpisode[c.episodeId] = math.max(
      peakByEpisode[c.episodeId] ?? 0,
      c.severity.index,
    );
  }
  GroupStats stats(Iterable<Episode> group) {
    final peaks = [
      for (final e in group)
        if (peakByEpisode[e.id] != null) peakByEpisode[e.id]!.toDouble(),
    ];
    final durations = [
      for (final e in group)
        if (e.recoveredAt != null)
          e.recoveredAt!.difference(e.occurredAt).inMinutes / 60.0,
    ];
    return GroupStats(
      episodes: group.length,
      meanPeak: _mean(peaks),
      meanDurationHours: _mean(durations),
    );
  }

  return [
    for (final t in treatments)
      () {
        bool isWith(Episode e) =>
            e.preInterventions.contains(t.name) || isActiveAt(t, e.occurredAt);
        return TreatmentComparison(
          treatment: t,
          withStats: stats(episodes.where(isWith)),
          withoutStats: stats(episodes.where((e) => !isWith(e))),
        );
      }(),
  ];
}

bool isActiveAt(Treatment t, DateTime when) =>
    t.startedAt != null &&
    !when.isBefore(t.startedAt!) &&
    (t.endedAt == null || when.isBefore(t.endedAt!));

double _hoursSince(Episode e, DateTime t) =>
    math.max(0, t.difference(e.occurredAt).inMinutes / 60.0);

double? _mean(List<double> xs) =>
    xs.isEmpty ? null : xs.reduce((a, b) => a + b) / xs.length;

/// "2.5 days" / "18 hours".
String formatHours(double hours) {
  if (hours < 1) return 'under 1 hour';
  if (hours < 1.5) return '1 hour';
  if (hours < 36) return '${hours.round()} hours';
  final days = hours / 24;
  return '${days.toStringAsFixed(days < 10 ? 1 : 0)} days';
}
