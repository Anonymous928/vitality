import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/domain.dart';
import '../data/analysis.dart';
import '../data/database.dart';
import '../data/self_check.dart';
import '../core/brand.dart';

/// Doctor-ready report (PRD §6.5). Built entirely on-device, off the UI
/// thread (everything in [ReportInput] is plain data, so it can cross into
/// an isolate).

enum ReportSection {
  selfCheck('Self-check (Waldinger criteria)'),
  summary('Episode summary'),
  curve('Average recovery curve'),
  symptoms('Symptom distribution'),
  treatments('Treatments tried'),
  impact('Impact on daily life'),
  primer('One-page POIS primer for clinicians');

  const ReportSection(this.label);
  final String label;
}

enum ImpactLevel {
  notAtAll('Not at all'),
  aLittle('A little'),
  aLot('A lot'),
  severely('Severely');

  const ImpactLevel(this.label);
  final String label;
}

class ReportInput {
  const ReportInput({
    required this.sections,
    required this.episodes,
    required this.checkIns,
    required this.treatments,
    required this.selfCheck,
    required this.selfCheckDate,
    required this.workImpact,
    required this.relationshipImpact,
    required this.daysMissed,
    required this.generatedAt,
    required this.regularFont,
    required this.boldFont,
  });

  final Set<ReportSection> sections;
  final List<Episode> episodes;
  final List<CheckIn> checkIns;
  final List<Treatment> treatments;
  final SelfCheckAnswers? selfCheck;
  final DateTime? selfCheckDate;
  final ImpactLevel? workImpact;
  final ImpactLevel? relationshipImpact;
  final int? daysMissed;
  final DateTime generatedAt;
  final Uint8List regularFont;
  final Uint8List boldFont;
}

const _ink = PdfColor.fromInt(0xFF1A1C1E);
const _muted = PdfColor.fromInt(0xFF5C5F63);
const _rule = PdfColor.fromInt(0xFFD5D7DB);
const _accent = PdfColor.fromInt(0xFF2A78D6); // dataviz slot 1 (light)
const _reference = PdfColor.fromInt(0xFF74777F); // neutral reference line

/// Runs [buildReportPdf] on a background isolate. Deliberately a top-level,
/// non-async function: a closure created inside an async method or a State
/// captures that whole context, which can't be sent to another isolate.
Future<Uint8List> buildReportPdfInBackground(ReportInput input) =>
    Isolate.run(() => buildReportPdf(input));

Future<Uint8List> buildReportPdf(ReportInput input) async {
  final theme = pw.ThemeData.withFont(
    base: pw.Font.ttf(ByteData.sublistView(input.regularFont)),
    bold: pw.Font.ttf(ByteData.sublistView(input.boldFont)),
  ).copyWith(defaultTextStyle: const pw.TextStyle(fontSize: 10, color: _ink));
  final doc = pw.Document(
    theme: theme,
    title: 'POIS symptom history',
    creator: appName,
  );
  final s = computeInsights(input.episodes, input.checkIns);
  final has = input.sections.contains;

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(44, 40, 44, 40),
      footer: _footer,
      build: (context) => [
        _header(input, s),
        if (has(ReportSection.selfCheck)) ..._selfCheck(input),
        if (has(ReportSection.summary)) ..._summary(input, s),
        if (has(ReportSection.curve)) ..._curve(s),
        if (has(ReportSection.symptoms)) ..._symptoms(s),
        if (has(ReportSection.treatments)) ..._treatments(input),
        if (has(ReportSection.impact)) ..._impact(input),
      ],
    ),
  );

  if (has(ReportSection.primer)) {
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(44, 40, 44, 40),
        footer: _footer,
        build: (_) => _primer(),
      ),
    );
  }
  return doc.save();
}

// ----------------------------------------------------------------- layout

String _date(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

pw.Widget _footer(pw.Context context) => pw.Container(
  alignment: pw.Alignment.centerRight,
  margin: const pw.EdgeInsets.only(top: 12),
  child: pw.Text(
    'Patient-reported data. Not a diagnosis.   Page ${context.pageNumber} of ${context.pagesCount}',
    style: const pw.TextStyle(fontSize: 8, color: _muted),
  ),
);

pw.Widget _h2(String text) => pw.Padding(
  padding: const pw.EdgeInsets.only(top: 18, bottom: 6),
  child: pw.Text(
    text,
    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
  ),
);

pw.Widget _note(String text) => pw.Padding(
  padding: const pw.EdgeInsets.only(top: 4),
  child: pw.Text(text, style: const pw.TextStyle(fontSize: 8.5, color: _muted)),
);

pw.Widget _table(
  List<String>? headers,
  List<List<String>> rows, {
  Map<int, pw.TableColumnWidth>? widths,
}) => pw.TableHelper.fromTextArray(
  headers: headers,
  data: rows,
  // Key/value tables (no headers) must not bold their first row.
  headerCount: headers == null ? 0 : 1,
  columnWidths: widths,
  border: const pw.TableBorder(
    horizontalInside: pw.BorderSide(color: _rule, width: 0.5),
    bottom: pw.BorderSide(color: _rule, width: 0.5),
  ),
  headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
  headerDecoration: const pw.BoxDecoration(
    border: pw.Border(bottom: pw.BorderSide(color: _ink, width: 0.75)),
  ),
  cellStyle: const pw.TextStyle(fontSize: 9),
  cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
  cellAlignment: pw.Alignment.centerLeft,
  headerAlignment: pw.Alignment.centerLeft,
);

pw.Widget _header(ReportInput input, InsightsSummary s) {
  final eps = input.episodes;
  final period = eps.isEmpty
      ? 'No events logged yet'
      : '${_date(eps.map((e) => e.occurredAt).reduce((a, b) => a.isBefore(b) ? a : b))}'
            ' to ${_date(eps.map((e) => e.occurredAt).reduce((a, b) => a.isAfter(b) ? a : b))}';
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'POIS symptom history',
        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'Patient-reported record of post-orgasmic symptoms, prepared for a clinical consultation.',
        style: const pw.TextStyle(color: _muted),
      ),
      pw.SizedBox(height: 10),
      _table(
        null,
        [
          ['Generated', _date(input.generatedAt)],
          ['Period covered', period],
          ['Source', 'Self-logged in the $appName app (offline, on-device)'],
        ],
        widths: const {0: pw.FixedColumnWidth(110)},
      ),
    ],
  );
}

List<pw.Widget> _selfCheck(ReportInput input) {
  final a = input.selfCheck;
  if (a == null) {
    return [
      _h2('Self-check (Waldinger criteria)'),
      pw.Text('The patient has not completed the self-check.'),
    ];
  }
  final answers = [
    a.symptoms.isEmpty
        ? 'None selected'
        : a.symptoms.map((s) => s.label).join(', '),
    a.onset?.label ?? '-',
    a.frequency?.label ?? '-',
    a.duration?.label ?? '-',
    a.resolves?.label ?? '-',
  ];
  return [
    _h2('Self-check (Waldinger criteria)'),
    _table(
      ['Criterion', 'Patient answer', 'Met'],
      [
        for (var i = 0; i < 5; i++)
          [
            SelfCheckAnswers.criteriaLabels[i],
            answers[i],
            a.criteria[i] ? 'Yes' : 'No / unsure',
          ],
      ],
      widths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(3),
        2: pw.FixedColumnWidth(60),
      },
    ),
    pw.SizedBox(height: 6),
    _table(
      null,
      [
        ['Criteria met', '${a.criteriaMet} of 5'],
        ['Onset', a.onsetType?.reportLabel ?? '-'],
        [
          'Triggers reported',
          a.triggers.isEmpty
              ? '-'
              : a.triggers
                    .map(
                      (t) => switch (t) {
                        EpisodeType.partnered => 'partnered sex',
                        EpisodeType.solo => 'masturbation',
                        EpisodeType.nocturnal => 'nocturnal emission',
                      },
                    )
                    .join(', '),
        ],
        [
          'Red-flag symptoms',
          a.redFlags == true
              ? 'Reported (fever >38.5 C, breathing difficulty, facial/throat swelling, chest pain or fainting)'
              : 'None reported',
        ],
        if (input.selfCheckDate != null)
          ['Completed', _date(input.selfCheckDate!)],
      ],
      widths: const {0: pw.FixedColumnWidth(110)},
    ),
  ];
}

List<pw.Widget> _summary(ReportInput input, InsightsSummary s) {
  final byType = {for (final t in EpisodeType.values) t: 0};
  for (final e in input.episodes) {
    byType[e.type] = byType[e.type]! + 1;
  }
  String? perMonth() {
    if (input.episodes.length < 2) return null;
    final first = input.episodes
        .map((e) => e.occurredAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final months = math.max(
      1.0,
      input.generatedAt.difference(first).inDays / 30.44,
    );
    return (input.episodes.length / months).toStringAsFixed(1);
  }

  return [
    _h2('Episode summary'),
    _table(
      null,
      [
        ['Events logged', '${s.episodeCount}'],
        ['Events per month', perMonth() ?? '-'],
        [
          'By trigger',
          'Partnered ${byType[EpisodeType.partnered]}, solo ${byType[EpisodeType.solo]}, nocturnal ${byType[EpisodeType.nocturnal]}',
        ],
        ['Check-ins recorded', '${s.checkInCount}'],
        [
          'Events with any symptoms',
          s.pctSymptomatic == null
              ? '-'
              : '${(s.pctSymptomatic! * 100).round()}% (${s.episodesWithCheckIns} '
                    '${s.episodesWithCheckIns == 1 ? 'event' : 'events'} rated)',
        ],
        [
          'Mean time to worst symptoms',
          s.meanPeakHours == null ? '-' : formatHours(s.meanPeakHours!),
        ],
        [
          'Mean time to recovery',
          s.meanDurationHours == null
              ? '-'
              : '${formatHours(s.meanDurationHours!)} (${s.recoveredCount} recovered '
                    '${s.recoveredCount == 1 ? 'event' : 'events'})',
        ],
      ],
      widths: const {0: pw.FixedColumnWidth(170)},
    ),
    _note(
      'Severity scale used throughout: 0 None, 1 Mild, 2 Moderate, 3 Severe '
      '(worst of the overall rating and individual symptom ratings).',
    ),
  ];
}

List<pw.Widget> _curve(InsightsSummary s) {
  final avg = s.averageCurve;
  final latest = s.latest?.points;
  if ((avg == null || avg.isEmpty) && (latest == null || latest.isEmpty)) {
    return [_h2('Recovery curve'), pw.Text('Not enough check-in data yet.')];
  }
  final maxDays = math.min(
    10,
    math.max(
      3,
      ([...?avg, ...?latest].map((p) => p.hours).fold<double>(0, math.max) / 24)
          .ceil(),
    ),
  );
  final maxX = maxDays * 24.0;
  List<pw.PointChartValue> pts(List<CurvePoint> list) => [
    for (final p in list)
      if (p.hours <= maxX) pw.PointChartValue(p.hours, p.severity),
  ];

  // Inseparable keeps the heading on the same page as its chart.
  return [
    pw.Inseparable(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _h2(
            avg != null
                ? 'Average recovery curve'
                : 'Recovery curve (latest event)',
          ),
          pw.SizedBox(
            height: 190,
            child: pw.Chart(
              grid: pw.CartesianGrid(
                xAxis: pw.FixedAxis(
                  [for (var d = 0; d <= maxDays; d++) d * 24],
                  format: (v) => '${v ~/ 24}',
                  textStyle: const pw.TextStyle(fontSize: 8, color: _muted),
                  color: _rule,
                ),
                yAxis: pw.FixedAxis(
                  [0, 1, 2, 3],
                  format: (v) => Severity.values[v.toInt()].label,
                  textStyle: const pw.TextStyle(fontSize: 8, color: _muted),
                  divisions: true,
                  divisionsColor: _rule,
                  divisionsWidth: 0.5,
                  color: _rule,
                ),
              ),
              datasets: [
                if (avg != null && avg.isNotEmpty)
                  pw.LineDataSet(
                    legend: 'Average of recovered events',
                    data: pts(avg),
                    color: _reference,
                    drawPoints: false,
                    lineWidth: 1.5,
                  ),
                if (latest != null && latest.isNotEmpty)
                  pw.LineDataSet(
                    legend: 'Latest event',
                    data: pts(latest),
                    color: _accent,
                    pointSize: 2.5,
                    lineWidth: 1.5,
                  ),
              ],
              bottom: pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text(
                  'Days since event',
                  style: const pw.TextStyle(fontSize: 8, color: _muted),
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              if (avg != null && avg.isNotEmpty)
                ..._legend(_reference, 'Average of recovered events (grey)'),
              if (latest != null && latest.isNotEmpty)
                ..._legend(_accent, 'Latest event (blue, with points)'),
            ],
          ),
          if (avg != null)
            _note(
              'Average: within each time window, each recovered event contributes '
              'its worst rating; windows after recovery count as None.',
            ),
        ],
      ),
    ),
  ];
}

List<pw.Widget> _legend(PdfColor color, String label) => [
  pw.Container(width: 14, height: 2, color: color),
  pw.SizedBox(width: 4),
  pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
  pw.SizedBox(width: 14),
];

List<pw.Widget> _symptoms(InsightsSummary s) {
  if (s.episodesWithCheckIns == 0) {
    return [_h2('Symptom distribution'), pw.Text('No check-ins yet.')];
  }
  final rows = s.symptomEpisodes.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return [
    _h2('Symptom distribution'),
    _table(
      ['Symptom', 'Events with symptom (Mild or worse)', '%'],
      [
        for (final e in rows)
          [
            e.key.label,
            '${e.value} of ${s.episodesWithCheckIns}',
            '${(e.value * 100 / s.episodesWithCheckIns).round()}%',
          ],
      ],
      widths: const {2: pw.FixedColumnWidth(50)},
    ),
  ];
}

List<pw.Widget> _treatments(ReportInput input) {
  if (input.treatments.isEmpty) {
    return [_h2('Treatments tried'), pw.Text('None recorded.')];
  }
  String period(Treatment t) =>
      '${t.startedAt == null ? '?' : _date(t.startedAt!)} - ${t.endedAt == null ? 'ongoing' : _date(t.endedAt!)}';
  String stats(GroupStats g) {
    final parts = [
      'n=${g.episodes}',
      if (g.meanPeak != null) 'peak ${g.meanPeak!.toStringAsFixed(1)}',
      if (g.meanDurationHours != null) formatHours(g.meanDurationHours!),
    ];
    return parts.join(', ');
  }

  final cmp = compareTreatments(
    input.treatments,
    input.episodes,
    input.checkIns,
  );
  return [
    _h2('Treatments tried'),
    _table(
      ['Treatment', 'Type', 'Dose (as entered)', 'Prescriber', 'Period'],
      [
        for (final t in input.treatments)
          [
            t.name,
            t.treatmentClass ?? '-',
            t.dose ?? '-',
            t.prescriber ?? '-',
            period(t),
          ],
      ],
    ),
    pw.SizedBox(height: 8),
    _table(
      ['Treatment', 'Events with it', 'Events without it'],
      [
        for (final c in cmp)
          [c.treatment.name, stats(c.withStats), stats(c.withoutStats)],
      ],
    ),
    _note(
      '"With" = logged as taken beforehand, or the event fell within the '
      'treatment period. Peak = mean worst severity (0-3); duration = mean '
      'time to recovery. Uncontrolled, self-reported comparison: small '
      'numbers are unreliable.',
    ),
  ];
}

List<pw.Widget> _impact(ReportInput input) {
  return [
    _h2('Impact on daily life'),
    _table(
      null,
      [
        ['Effect on work or study', input.workImpact?.label ?? 'Not answered'],
        [
          'Days of work or study missed in the last month',
          input.daysMissed?.toString() ?? 'Not answered',
        ],
        [
          'Effect on relationships',
          input.relationshipImpact?.label ?? 'Not answered',
        ],
      ],
      widths: const {0: pw.FixedColumnWidth(230)},
    ),
  ];
}

// Clinician primer. Wording to be reviewed by the medical advisory board
// before release (PRD §9).
List<pw.Widget> _primer() {
  pw.Widget p(String t) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Text(
      t,
      style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.5),
    ),
  );
  pw.Widget bullet(String t) => pw.Bullet(
    text: t,
    style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.5),
  );
  return [
    pw.Text(
      'Post-Orgasmic Illness Syndrome (POIS): a primer for clinicians',
      style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
    ),
    pw.SizedBox(height: 4),
    pw.Text(
      'Included by the patient for context. Summarises published literature.',
      style: const pw.TextStyle(color: _muted, fontSize: 9),
    ),
    _h2('What it is'),
    p(
      'POIS is a rare, under-recognised condition in which flu-like and '
      'allergy-like symptoms, marked fatigue and cognitive difficulty begin '
      'within seconds to hours of ejaculation and typically last 2 to 7 '
      'days. It is listed by the NIH Genetic and Rare Diseases Information '
      'Center. It has been described mainly in men; reports in women exist '
      'but are scarce. Primary (from first ejaculations) and secondary '
      '(later-onset) forms are described.',
    ),
    _h2('Proposed diagnostic criteria (Waldinger et al.)'),
    bullet(
      'A characteristic set of symptoms: flu-like state, extreme fatigue, '
      'muscle weakness, mood disturbance, impaired memory/concentration, '
      'nasal congestion, itchy eyes.',
    ),
    bullet('Onset within seconds, minutes or a few hours of ejaculation.'),
    bullet('Symptoms after more than 90% of ejaculations.'),
    bullet('Most symptoms last 2 to 7 days.'),
    bullet('Symptoms resolve spontaneously.'),
    _h2('Proposed mechanisms (none established)'),
    p(
      'Immunological or allergic response to the patient\'s own seminal '
      'fluid (positive autologous semen skin-prick tests have been '
      'reported in a large share of one cohort); hormonal or '
      'neuroendocrine changes; withdrawal-like neurochemical response; '
      'autonomic dysregulation. POIS may represent more than one condition.',
    ),
    _h2('Management reported in the literature'),
    p(
      'No treatment has been validated in controlled trials. Case reports and '
      'small series describe responses to antihistamines, NSAIDs, '
      'alpha-blockers, SSRIs/benzodiazepines, hormonal therapy in '
      'hypogonadal patients, omalizumab, and specialist-supervised '
      'hyposensitisation with autologous semen. The patient\'s logs in this '
      'report may help evaluate an individual trial of treatment.',
    ),
    _h2('Considerations raised in the literature'),
    bullet('Exclude other causes of the presenting symptoms.'),
    bullet(
      'Hormonal evaluation (e.g. testosterone, LH, FSH, prolactin, '
      'cortisol), particularly in secondary onset.',
    ),
    bullet(
      'Allergy/immunology assessment, including autologous semen '
      'skin-prick testing where available.',
    ),
    bullet(
      'Screening for distress, depression and relationship strain, which '
      'are common in surveyed patients.',
    ),
    _h2('Selected references'),
    for (final r in const [
      'Waldinger MD, Schweitzer DH. Postorgasmic illness syndrome: two cases. J Sex Marital Ther. 2002.',
      'Waldinger MD, et al. Postorgasmic illness syndrome (POIS) in 45 Dutch Caucasian males: clinical characteristics and evidence for an immunogenic pathogenesis (part 1). J Sex Med. 2011.',
      'Nguyen HMT, et al. Post-orgasmic illness syndrome: a review. Sex Med Rev. 2018.',
      'Abdessater M, et al. Post orgasmic illness syndrome: what do we know till now? Basic Clin Androl. 2019.',
    ])
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Text(r, style: const pw.TextStyle(fontSize: 8.5)),
      ),
  ];
}
