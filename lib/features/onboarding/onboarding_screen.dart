import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain.dart';
import '../../data/providers.dart';
import '../../notifications/check_in_scheduler.dart';
import '../lock/lock_gate.dart';
import '../selfcheck/self_check_flow.dart';

/// ~5 short steps, no paywall, minimal setup (PRD §7.2): privacy promise →
/// self-check → top 3 symptoms → reminders → lock/discretion.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _page = 0;
  List<SymptomCluster> _top = [...SymptomCluster.defaultTop3];
  bool _selfCheckDone = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    setState(() => _page++);
    _pages.animateToPage(_page,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  void _finish() {
    ref.read(settingsProvider.notifier).update(
        (s) => s.copyWith(topSymptoms: _top, onboarded: true));
    context.go('/today');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pages,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _Step(
              icon: Icons.shield_outlined,
              title: 'Private by design',
              body: [
                const _Bullet(Icons.wifi_off,
                    'This app has no internet permission. Nothing you log can leave your phone unless you export it yourself.'),
                const _Bullet(Icons.no_accounts_outlined,
                    'No account, no ads, no tracking.'),
                const _Bullet(Icons.lock_outline,
                    'Your journal is stored encrypted on this phone.'),
                const _Bullet(Icons.medical_information_outlined,
                    'This is a self-tracking tool. It doesn\'t diagnose or recommend treatment.'),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.push('/privacy'),
                    icon: const Icon(Icons.policy_outlined),
                    label: const Text('Read the privacy policy'),
                  ),
                ),
              ],
              primary: 'Get started',
              onPrimary: _next,
            ),
            Column(
              children: [
                _SkipBar(
                  title: 'Self-check',
                  onSkip: _selfCheckDone ? null : _next,
                ),
                Expanded(
                  child: SelfCheckFlow(
                    finishLabel: 'Continue',
                    onResult: () => setState(() => _selfCheckDone = true),
                    onFinished: (a) {
                      final picked = [
                        for (final s in SymptomCluster.values)
                          if (a.symptoms.contains(s) &&
                              s != SymptomCluster.other)
                            s,
                      ];
                      if (picked.isNotEmpty) {
                        setState(() => _top = picked.take(3).toList());
                      }
                      _next();
                    },
                  ),
                ),
              ],
            ),
            _Step(
              icon: Icons.checklist,
              title: 'Your top 3 symptoms',
              subtitle: 'These appear on every check-in so rating takes a '
                  'couple of taps. You can change them any time.',
              body: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in SymptomCluster.values)
                      FilterChip(
                        avatar: Icon(s.icon, size: 18),
                        label: Text(s.label),
                        selected: _top.contains(s),
                        onSelected: (on) => setState(() {
                          if (on && _top.length < 3) _top = [..._top, s];
                          if (!on) _top = _top.where((x) => x != s).toList();
                        }),
                      ),
                  ],
                ),
              ],
              primary: 'Next',
              onPrimary: _top.isEmpty ? null : _next,
            ),
            _Step(
              icon: Icons.notifications_none,
              title: 'Gentle check-in reminders',
              subtitle: 'After you log an event, we remind you to rate how '
                  'you feel at about 1 hour, 6 hours, 1 day, then daily until '
                  'you\'re back to normal. The text is neutral and hidden on '
                  'the lock screen.',
              body: const [],
              primary: 'Turn on reminders',
              onPrimary: () async {
                await CheckInScheduler.instance.requestPermission();
                _next();
              },
              secondary: 'Not now',
              onSecondary: _next,
            ),
            _Step(
              icon: Icons.visibility_off_outlined,
              title: 'Keep it discreet',
              subtitle: 'Optional. You can change these in Settings.',
              body: [
                Consumer(builder: (context, ref, _) {
                  final s = ref.watch(settingsProvider);
                  final ctl = ref.read(settingsProvider.notifier);
                  return Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('App lock'),
                        subtitle: const Text(
                            'Require your screen lock or fingerprint'),
                        value: s.appLock,
                        onChanged: (v) async {
                          if (v &&
                              !await LockController.authenticate(
                                  'Turn on app lock')) {
                            return;
                          }
                          ctl.update((x) => x.copyWith(appLock: v));
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Hide in recent apps'),
                        subtitle: const Text('Blocks screenshots too'),
                        value: s.secureScreen,
                        onChanged: (v) =>
                            ctl.update((x) => x.copyWith(secureScreen: v)),
                      ),
                    ],
                  );
                }),
              ],
              primary: 'Finish',
              onPrimary: _finish,
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.body,
    required this.primary,
    required this.onPrimary,
    this.secondary,
    this.onSecondary,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> body;
  final String primary;
  final VoidCallback? onPrimary;
  final String? secondary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                Icon(icon, size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(title, style: theme.textTheme.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 12),
                  Text(subtitle!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
                const SizedBox(height: 24),
                ...body,
              ],
            ),
          ),
          FilledButton(
            onPressed: onPrimary,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            child: Text(primary),
          ),
          if (secondary != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onSecondary, child: Text(secondary!)),
          ],
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
              child:
                  Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _SkipBar extends StatelessWidget {
  const _SkipBar({required this.title, required this.onSkip});
  final String title;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 8, 0),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          // Keeps the bar's height stable once the result page shows.
          Visibility.maintain(
            visible: onSkip != null,
            child: TextButton(
                onPressed: onSkip, child: const Text('Skip for now')),
          ),
        ],
      ),
    );
  }
}
