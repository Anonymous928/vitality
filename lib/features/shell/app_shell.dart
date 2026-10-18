import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../lock/lock_gate.dart';
import '../../core/brand.dart';

/// Material 3 bottom navigation with 4 tabs (PRD §7.2). Each tab keeps its
/// own navigation stack and scroll position via StatefulShellRoute.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  static const _titles = ['Today', 'Calendar', 'Insights', 'Learn'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockOn = ref.watch(settingsProvider.select((s) => s.appLock));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          shell.currentIndex == 0 ? appName : _titles[shell.currentIndex],
        ),
        actions: [
          if (lockOn)
            IconButton(
              tooltip: 'Lock now',
              icon: const Icon(Icons.lock_outline),
              onPressed: () => ref.read(lockedProvider.notifier).lock(),
            ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Learn',
          ),
        ],
      ),
    );
  }
}
