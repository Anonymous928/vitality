import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/native_bridge.dart';
import 'core/theme.dart';
import 'data/providers.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/checkin/check_in_screen.dart';
import 'features/episodes/episode_screens.dart';
import 'features/insights/insights_screen.dart';
import 'features/learn/community_screen.dart';
import 'features/learn/evidence.dart';
import 'features/learn/learn_screen.dart';
import 'features/lock/lock_gate.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/report/report_screen.dart';
import 'features/selfcheck/self_check_flow.dart';
import 'features/settings/privacy_policy_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/today/today_screen.dart';
import 'features/treatments/treatments_screen.dart';
import 'notifications/check_in_scheduler.dart';
import 'core/brand.dart';

/// Wallpaper accent, read lazily the first time dynamic colour is enabled.
final accentColorProvider = FutureProvider<Color?>(
  (ref) => WindowPrivacy.accentColor(),
);

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/today',
    // First run goes through onboarding (no paywall, ~5 steps).
    redirect: (_, state) =>
        !ref.read(settingsProvider).onboarded &&
            state.matchedLocation != '/onboarding' &&
            state.matchedLocation != '/privacy'
        ? '/onboarding'
        : null,
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/today', builder: (_, _) => const TodayScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (_, _) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                builder: (_, _) => const InsightsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                builder: (_, _) => const LearnScreen(),
                routes: [
                  GoRoute(
                    path: 'community',
                    builder: (_, _) => const CommunityScreen(),
                  ),
                  GoRoute(
                    path: 'evidence',
                    builder: (_, _) => const EvidenceLibraryScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/checkin/:episodeId',
        builder: (_, state) => CheckInScreen(
          episodeId: int.parse(state.pathParameters['episodeId']!),
        ),
      ),
      GoRoute(
        path: '/episode/:id',
        builder: (_, state) => EpisodeDetailScreen(
          episodeId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(path: '/events', builder: (_, _) => const AllEventsScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/treatments', builder: (_, _) => const TreatmentsScreen()),
      GoRoute(path: '/self-check', builder: (_, _) => const SelfCheckScreen()),
      GoRoute(path: '/report', builder: (_, _) => const ReportScreen()),
      // Reachable from onboarding, so the redirect above lets it through.
      GoRoute(path: '/privacy', builder: (_, _) => const PrivacyPolicyScreen()),
    ],
  );

  // Notification taps → Fog Mode check-in.
  void handle(String payload) {
    if (payload.startsWith('checkin:')) {
      router.push('/checkin/${payload.substring(8)}');
    }
  }

  CheckInScheduler.instance.onTap = handle;
  CheckInScheduler.instance.launchPayload().then((p) {
    if (p != null) handle(p);
  });

  // Home-screen widget "Log event" → Today with the log sheet open.
  void launchAction(String action) {
    if (action != 'log') return;
    router.go('/today');
    ref.read(pendingLogProvider.notifier).request();
  }

  NativeBridge.onLaunchAction(launchAction);
  NativeBridge.takeLaunchAction().then((a) {
    if (a != null) launchAction(a);
  });
  return router;
});

/// Keeps the home-screen widget's status in step with the data. The widget
/// recomputes "Day N" itself, so this only runs when something changes.
final widgetSyncProvider = Provider<void>((ref) {
  final active = ref.watch(activeEpisodeProvider);
  final baseline = ref.watch(baselineDurationProvider);
  final hide = ref.watch(settingsProvider.select((s) => s.appLock));
  if (!active.hasValue || !baseline.hasValue) return;
  NativeBridge.updateWidget(
    episodeStart: active.value?.occurredAt,
    expectedDays: baseline.value == null
        ? null
        : (baseline.value!.inHours / 24).ceil(),
    hideStatus: hide,
  );
});

class AfterglowApp extends ConsumerWidget {
  const AfterglowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final useDynamic = ref.watch(
      settingsProvider.select((s) => s.dynamicColor),
    );
    final router = ref.watch(routerProvider);
    ref.watch(widgetSyncProvider);

    final seed = useDynamic ? ref.watch(accentColorProvider).value : null;

    return MaterialApp.router(
      title: appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: buildTheme(Brightness.light, seed: seed),
      darkTheme: buildTheme(Brightness.dark, seed: seed),
      routerConfig: router,
      builder: (context, child) => LockGate(child: child!),
    );
  }
}
