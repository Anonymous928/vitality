import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/domain.dart';
import '../../data/analysis.dart';

/// Series colours, validated with the dataviz palette checker against the
/// M3 surfaces: blue (categorical slot 1) for the focus series, neutral gray
/// for the reference ("highlight one, gray the rest"). The average is also
/// dashed, so the two never differ by colour alone.
class ChartColors {
  static Color latest(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF3987E5) : const Color(0xFF2A78D6);
  static Color average(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF8E9099) : const Color(0xFF74777F);
}

/// Severity (0 None .. 3 Severe) against days since the event.
class RecoveryChart extends StatelessWidget {
  const RecoveryChart({super.key, this.latest, this.average});
  final List<CurvePoint>? latest;
  final List<CurvePoint>? average;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final b = theme.brightness;
    final labelStyle = theme.textTheme.labelSmall
        ?.copyWith(color: scheme.onSurfaceVariant);

    final allX = [...?latest, ...?average].map((p) => p.hours);
    final maxDays = math.max(3, (allX.fold<double>(0, math.max) / 24).ceil());
    final maxX = math.min(maxDays, 10) * 24.0;

    List<FlSpot> spots(List<CurvePoint> pts) => [
          for (final p in pts)
            if (p.hours <= maxX) FlSpot(p.hours, p.severity),
        ];

    final series = <LineChartBarData>[
      if (average != null && average!.isNotEmpty)
        LineChartBarData(
          spots: spots(average!),
          color: ChartColors.average(b),
          barWidth: 2,
          dashArray: const [6, 4],
          dotData: const FlDotData(show: false),
        ),
      if (latest != null && latest!.isNotEmpty)
        LineChartBarData(
          spots: spots(latest!),
          color: ChartColors.latest(b),
          barWidth: 2,
          dotData: FlDotData(
            getDotPainter: (_, _, bar, _) => FlDotCirclePainter(
              radius: 4,
              color: bar.color!,
              strokeWidth: 2,
              strokeColor: scheme.surface,
            ),
          ),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          children: [
            if (latest != null && latest!.isNotEmpty)
              _LegendLine(
                  color: ChartColors.latest(b),
                  dashed: false,
                  label: 'Latest episode'),
            if (average != null && average!.isNotEmpty)
              _LegendLine(
                  color: ChartColors.average(b),
                  dashed: true,
                  label: 'Your average'),
          ],
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 1.6,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: maxX,
              minY: 0,
              maxY: 3,
              lineBarsData: series,
              clipData: const FlClipData.all(),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: scheme.outlineVariant, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 68,
                    interval: 1,
                    getTitlesWidget: (v, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(Severity.values[v.round()].label,
                          style: labelStyle),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: Text('Days since event', style: labelStyle),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 24,
                    reservedSize: 24,
                    getTitlesWidget: (v, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text('${(v / 24).round()}', style: labelStyle),
                    ),
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => scheme.inverseSurface,
                  getTooltipItems: (touched) => [
                    for (final t in touched)
                      LineTooltipItem(
                        '${t.bar.dashArray == null ? 'Latest' : 'Average'}: '
                        '${_severityText(t.y)} · ${_dayText(t.x)}',
                        TextStyle(
                            color: scheme.onInverseSurface, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _TableView(latest: latest, average: average),
      ],
    );
  }
}

String _severityText(double y) {
  final s = Severity.values[y.round().clamp(0, 3)];
  return y == y.roundToDouble() ? s.label : '${y.toStringAsFixed(1)} (${s.label})';
}

String _dayText(double hours) => hours < 24
    ? '${hours.round()}h'
    : 'day ${(hours / 24).toStringAsFixed(1)}';

class _LegendLine extends StatelessWidget {
  const _LegendLine(
      {required this.color, required this.dashed, required this.label});
  final Color color;
  final bool dashed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 2,
          child: dashed
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                      3, (_) => Container(width: 5, height: 2, color: color)),
                )
              : ColoredBox(color: color),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

/// Accessible table alternative to the chart.
class _TableView extends StatelessWidget {
  const _TableView({this.latest, this.average});
  final List<CurvePoint>? latest;
  final List<CurvePoint>? average;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String, String)>[
      for (final p in latest ?? const <CurvePoint>[])
        ('Latest', _dayText(p.hours), _severityText(p.severity)),
      for (final p in average ?? const <CurvePoint>[])
        ('Average', _dayText(p.hours), _severityText(p.severity)),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text('View as table'),
      children: [
        Table(
          columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
          children: [
            for (final r in [('Series', 'Time', 'Severity'), ...rows])
              TableRow(children: [
                for (final cell in [r.$1, r.$2, r.$3])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(cell),
                  ),
              ]),
          ],
        ),
      ],
    );
  }
}
