import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'data/providers.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/checkin/check_in_screen.dart';
import 'features/insights/insights_screen.dart';
import 'features/learn/community_screen.dart';
import 'features/learn/learn_screen.dart';
import 'features/lock/lock_gate.dart';
import 'features/settings/settings_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/today/today_screen.dart';
import 'notifications/check_in_scheduler.dart';

/// Wallpaper accent, read lazily the first time dynamic colour is enabled.
final accentColorProvider =
    FutureProvider<Color?>((ref) => WindowPrivacy.accentColor());

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/today',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/today', builder: (_, _) => const TodayScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/calendar', builder: (_, _) => const CalendarScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/insights', builder: (_, _) => const InsightsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/learn',
              builder: (_, _) => const LearnScreen(),
              routes: [
                GoRoute(
                  path: 'community',
                  builder: (_, _) => const CommunityScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/checkin/:episodeId',
        builder: (_, state) => CheckInScreen(
          episodeId: int.parse(state.pathParameters['episodeId']!),
        ),
      ),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
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
  return router;
});

class AfterglowApp extends ConsumerWidget {
  const AfterglowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final useDynamic =
        ref.watch(settingsProvider.select((s) => s.dynamicColor));
    final router = ref.watch(routerProvider);

    final seed = useDynamic ? ref.watch(accentColorProvider).value : null;

    return MaterialApp.router(
      title: 'Afterglow',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: buildTheme(Brightness.light, seed: seed),
      darkTheme: buildTheme(Brightness.dark, seed: seed),
      routerConfig: router,
      builder: (context, child) => LockGate(child: child!),
    );
  }
}
