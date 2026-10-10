import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain.dart';
import '../../data/database.dart';
import '../../data/providers.dart';

enum _View { month, year }

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  _View _view = _View.month;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Center(
          child: SegmentedButton<_View>(
            segments: const [
              ButtonSegment(value: _View.month, label: Text('Month')),
              ButtonSegment(value: _View.year, label: Text('Year in Pixels')),
            ],
            selected: {_view},
            onSelectionChanged: (s) => setState(() => _view = s.first),
          ),
        ),
        const SizedBox(height: 16),
        if (_view == _View.month)
          _MonthView(
            month: _month,
            onChange: (m) => setState(() => _month = m),
          )
        else
          _YearView(year: _month.year,
              onChange: (y) => setState(() => _month = DateTime(y, _month.month))),
        const SizedBox(height: 20),
        const SeverityLegend(),
      ],
    );
  }
}

/// Days with no stored check-in that still fall inside the active episode.
Set<int> _ongoingDays(Episode? active) {
  if (active == null) return const {};
  final today = dayKey(DateTime.now());
  return {for (var d = dayKey(active.occurredAt); d <= today; d++) d};
}

class _MonthView extends ConsumerWidget {
  const _MonthView({required this.month, required this.onChange});
  final DateTime month;
  final ValueChanged<DateTime> onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loc = MaterialLocalizations.of(context);
    final summaries = ref.watch(monthSummariesProvider(month)).value ?? const {};
    final ongoing = _ongoingDays(ref.watch(activeEpisodeProvider).value);
    final today = dayKey(DateTime.now());

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = loc.firstDayOfWeekIndex; // 0 = Sunday
    final leading = (DateTime(month.year, month.month, 1).weekday % 7 -
            firstWeekday) %
        7;
    final isCurrentMonth =
        month.year == DateTime.now().year && month.month == DateTime.now().month;

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Previous month',
              icon: const Icon(Icons.chevron_left),
              onPressed: () => onChange(DateTime(month.year, month.month - 1)),
            ),
            Expanded(
              child: Text(loc.formatMonthYear(month),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium),
            ),
            IconButton(
              tooltip: 'Next month',
              icon: const Icon(Icons.chevron_right),
              onPressed: isCurrentMonth
                  ? null
                  : () => onChange(DateTime(month.year, month.month + 1)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Text(
                  loc.narrowWeekdays[(i + firstWeekday) % 7],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leading + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
          itemBuilder: (context, i) {
            if (i < leading) return const SizedBox.shrink();
            final date = DateTime(month.year, month.month, i - leading + 1);
            final key = dayKey(date);
            return _DayCell(
              date: date,
              summary: summaries[key],
              ongoing: ongoing.contains(key),
              isToday: key == today,
              future: key > today,
            );
          },
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.summary,
    required this.ongoing,
    required this.isToday,
    required this.future,
  });
  final DateTime date;
  final DailySummary? summary;
  final bool ongoing, isToday, future;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sev = summary?.maxSeverity;
    final inEpisode = summary?.activeEpisodeId != null || ongoing;

    final bg = sev?.color ??
        (inEpisode ? scheme.secondaryContainer : scheme.surfaceContainerLow);
    final fg = sev?.onColor ??
        (inEpisode ? scheme.onSecondaryContainer : scheme.onSurface);
    final label = sev?.label ?? (inEpisode ? 'Episode, no check-in' : 'No entries');

    return Semantics(
      label: '${MaterialLocalizations.of(context).formatFullDate(date)}: $label',
      excludeSemantics: true,
      child: Opacity(
        opacity: future ? 0.4 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: isToday ? Border.all(color: scheme.primary, width: 2) : null,
          ),
          alignment: Alignment.center,
          child: Text('${date.day}',
              style: TextStyle(color: fg, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}

/// Daylio "Year in Pixels": 12 columns × 31 rows of tiny day squares.
class _YearView extends ConsumerWidget {
  const _YearView({required this.year, required this.onChange});
  final int year;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final summaries = ref.watch(yearSummariesProvider(year)).value ?? const {};
    final ongoing = _ongoingDays(ref.watch(activeEpisodeProvider).value);

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Previous year',
              icon: const Icon(Icons.chevron_left),
              onPressed: () => onChange(year - 1),
            ),
            Expanded(
              child: Text('$year',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium),
            ),
            IconButton(
              tooltip: 'Next year',
              icon: const Icon(Icons.chevron_right),
              onPressed:
                  year >= DateTime.now().year ? null : () => onChange(year + 1),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(width: 20),
            for (var m = 1; m <= 12; m++)
              Expanded(
                child: Text(
                  'JFMAMJJASOND'[m - 1],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall,
                ),
              ),
          ],
        ),
        for (var d = 1; d <= 31; d++)
          Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(d % 5 == 0 || d == 1 ? '$d' : '',
                    style: theme.textTheme.labelSmall),
              ),
              for (var m = 1; m <= 12; m++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(1),
                    child: AspectRatio(
                      aspectRatio: 1.6,
                      child: _pixel(scheme, summaries, ongoing, year, m, d),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _pixel(ColorScheme scheme, Map<int, DailySummary> summaries,
      Set<int> ongoing, int year, int m, int d) {
    if (d > DateTime(year, m + 1, 0).day) return const SizedBox.shrink();
    final key = dayKey(DateTime(year, m, d));
    final s = summaries[key];
    final color = s?.maxSeverity?.color ??
        (s?.activeEpisodeId != null || ongoing.contains(key)
            ? scheme.secondaryContainer
            : scheme.surfaceContainerHighest);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Colour key with text labels, so the scale never relies on colour alone.
class SeverityLegend extends StatelessWidget {
  const SeverityLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final s in Severity.values) _LegendItem(color: s.color, label: s.label),
        _LegendItem(color: scheme.secondaryContainer, label: 'Episode, no check-in'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
