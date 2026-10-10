import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain.dart';
import '../../data/providers.dart';
import '../../data/self_check.dart';

/// The POIS Self-Check (PRD §6.1): one question per page, then a result
/// page with the Waldinger checklist. Saved as an Assessment when the
/// result is shown. Used standalone and inside onboarding.
class SelfCheckFlow extends ConsumerStatefulWidget {
  const SelfCheckFlow({super.key, required this.onFinished, this.finishLabel});

  /// Called when the user leaves the result page.
  final ValueChanged<SelfCheckAnswers> onFinished;
  final String? finishLabel;

  @override
  ConsumerState<SelfCheckFlow> createState() => _SelfCheckFlowState();
}

class _SelfCheckFlowState extends ConsumerState<SelfCheckFlow> {
  final _pages = PageController();
  int _page = 0;
  var _a = const SelfCheckAnswers();

  static const _questionCount = 8;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  bool get _answered => switch (_page) {
        0 => _a.symptoms.isNotEmpty,
        1 => _a.onset != null,
        2 => _a.frequency != null,
        3 => _a.duration != null,
        4 => _a.resolves != null,
        5 => _a.onsetType != null,
        6 => _a.triggers.isNotEmpty,
        7 => _a.redFlags != null,
        _ => true,
      };

  void _go(int page) {
    if (page == _questionCount) {
      ref.read(assessmentRepositoryProvider).save(_a);
    }
    setState(() => _page = page);
    _pages.animateToPage(page,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  void _set(SelfCheckAnswers a) => setState(() => _a = a);

  @override
  Widget build(BuildContext context) {
    final onResult = _page == _questionCount;
    return Column(
      children: [
        if (!onResult)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                      value: (_page + 1) / _questionCount),
                ),
                const SizedBox(width: 12),
                Text('${_page + 1} of $_questionCount',
                    style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ),
        Expanded(
          child: PageView(
            controller: _pages,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _MultiQuestion<SymptomCluster>(
                title: 'Which of these do you notice after orgasm?',
                hint: 'Choose all that apply.',
                options: {for (final s in SymptomCluster.values) s: s.label},
                icons: {for (final s in SymptomCluster.values) s: s.icon},
                selected: _a.symptoms,
                onChanged: (v) => _set(_a.copyWith(symptoms: v)),
              ),
              _SingleQuestion<Onset>(
                title: 'How soon do symptoms usually start?',
                options: {for (final o in Onset.values) o: o.label},
                value: _a.onset,
                onChanged: (v) => _set(_a.copyWith(onset: v)),
              ),
              _SingleQuestion<Frequency>(
                title: 'How often do you get symptoms afterwards?',
                options: {for (final o in Frequency.values) o: o.label},
                value: _a.frequency,
                onChanged: (v) => _set(_a.copyWith(frequency: v)),
              ),
              _SingleQuestion<DurationAnswer>(
                title: 'How long do most symptoms last?',
                options: {for (final o in DurationAnswer.values) o: o.label},
                value: _a.duration,
                onChanged: (v) => _set(_a.copyWith(duration: v)),
              ),
              _SingleQuestion<YesNoUnsure>(
                title: 'Do the symptoms go away on their own?',
                options: {for (final o in YesNoUnsure.values) o: o.label},
                value: _a.resolves,
                onChanged: (v) => _set(_a.copyWith(resolves: v)),
              ),
              _SingleQuestion<OnsetType>(
                title: 'When did this start for you?',
                options: {for (final o in OnsetType.values) o: o.label},
                value: _a.onsetType,
                onChanged: (v) => _set(_a.copyWith(onsetType: v)),
              ),
              _MultiQuestion<EpisodeType>(
                title: 'When does it happen?',
                hint: 'Choose all that apply.',
                options: {
                  EpisodeType.partnered: 'After sex with a partner',
                  EpisodeType.solo: 'After masturbation',
                  EpisodeType.nocturnal: 'After a wet dream / during sleep',
                },
                icons: {for (final t in EpisodeType.values) t: t.icon},
                selected: _a.triggers,
                onChanged: (v) => _set(_a.copyWith(triggers: v)),
              ),
              _SingleQuestion<bool>(
                title: 'Have you ever had any of these afterwards?',
                hint: 'Fever above 38.5 °C, trouble breathing, swelling of '
                    'the lips, face or throat, chest pain, or fainting.',
                options: const {true: 'Yes', false: 'No'},
                value: _a.redFlags,
                onChanged: (v) => _set(_a.copyWith(redFlags: v)),
              ),
              SelfCheckResult(answers: _a),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              if (_page > 0 && !onResult)
                TextButton(
                    onPressed: () => _go(_page - 1),
                    child: const Text('Back')),
              const Spacer(),
              FilledButton(
                onPressed: !_answered
                    ? null
                    : onResult
                        ? () => widget.onFinished(_a)
                        : () => _go(_page + 1),
                style: FilledButton.styleFrom(minimumSize: const Size(140, 52)),
                child: Text(onResult
                    ? (widget.finishLabel ?? 'Done')
                    : _page == _questionCount - 1
                        ? 'See results'
                        : 'Next'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SingleQuestion<T> extends StatelessWidget {
  const _SingleQuestion({
    required this.title,
    this.hint,
    required this.options,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String? hint;
  final Map<T, String> options;
  final T? value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
      children: [
        _QuestionTitle(title: title, hint: hint),
        RadioGroup<T>(
          groupValue: value,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          child: Column(
            children: [
              for (final e in options.entries)
                RadioListTile<T>(value: e.key, title: Text(e.value)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MultiQuestion<T> extends StatelessWidget {
  const _MultiQuestion({
    required this.title,
    this.hint,
    required this.options,
    required this.icons,
    required this.selected,
    required this.onChanged,
  });
  final String title;
  final String? hint;
  final Map<T, String> options;
  final Map<T, IconData> icons;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
      children: [
        _QuestionTitle(title: title, hint: hint),
        for (final e in options.entries)
          CheckboxListTile(
            secondary: Icon(icons[e.key]),
            title: Text(e.value),
            value: selected.contains(e.key),
            onChanged: (on) => onChanged(on!
                ? {...selected, e.key}
                : selected.where((x) => x != e.key).toSet()),
          ),
      ],
    );
  }
}

class _QuestionTitle extends StatelessWidget {
  const _QuestionTitle({required this.title, this.hint});
  final String title;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.headlineSmall),
          if (hint != null) ...[
            const SizedBox(height: 8),
            Text(hint!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}

/// Result page. Wording follows the compliance guardrails (PRD §8):
/// "consistent with", never "you have".
class SelfCheckResult extends StatelessWidget {
  const SelfCheckResult({super.key, required this.answers});
  final SelfCheckAnswers answers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final met = answers.criteriaMet;
    final summary = switch (met) {
      5 => 'Your answers are consistent with all five features of POIS '
          'described in the medical literature (Waldinger\'s criteria).',
      >= 3 => 'Your answers are consistent with some of the features of POIS '
          'described in the medical literature. Many people with POIS don\'t '
          'match every one: in one registry, nearly half didn\'t get symptoms '
          'every single time.',
      _ => 'Your answers match few of the features usually described for '
          'POIS. Other conditions can cause similar symptoms, so it\'s worth '
          'talking to a doctor about what you\'re experiencing.',
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      children: [
        if (answers.redFlags == true)
          Card.filled(
            color: theme.colorScheme.errorContainer,
            child: ListTile(
              leading: Icon(Icons.warning_amber_rounded,
                  color: theme.colorScheme.onErrorContainer),
              title: Text('Some symptoms need prompt medical care',
                  style: TextStyle(color: theme.colorScheme.onErrorContainer)),
              subtitle: Text(
                'Fever above 38.5 °C, trouble breathing, swelling of the face '
                'or throat, chest pain or fainting are not typical of POIS. '
                'If they happen, seek medical care straight away.',
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ),
        Text("You're not imagining this", style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(summary, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        Text('$met of 5 features matched', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        for (var i = 0; i < 5; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              answers.criteria[i]
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: answers.criteria[i]
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            title: Text(SelfCheckAnswers.criteriaLabels[i]),
            subtitle: Text(answers.criteria[i] ? 'Matches' : 'Not matched or not sure'),
          ),
        const SizedBox(height: 8),
        Text(
          'Only a clinician can diagnose POIS. Logging your episodes will give '
          'you and your doctor a much clearer picture, and you can include '
          'this checklist in your doctor report.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Standalone route: Learn → Self-check.
class SelfCheckScreen extends StatelessWidget {
  const SelfCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Self-check')),
      body: SelfCheckFlow(onFinished: (_) => Navigator.of(context).pop()),
    );
  }
}
