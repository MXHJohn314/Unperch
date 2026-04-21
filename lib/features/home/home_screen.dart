import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unperch/features/calendar/calendar_screen.dart';
import 'package:unperch/features/equipment/equipment_screen.dart';
import 'package:unperch/features/overview/overview_screen.dart';
import 'package:unperch/features/settings/settings_screen.dart';

// ---------------------------------------------------------------------------
// Home screen — main navigation shell
// ---------------------------------------------------------------------------

/// Bottom-navigation shell that hosts the four primary tabs.
///
/// Tab state is preserved via [IndexedStack]. The Overview tab (index 0)
/// shows a persistent FAB for quick access to the Treadmill screen.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart),
      label: 'Overview',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: 'Calendar',
    ),
    NavigationDestination(
      icon: Icon(Icons.fitness_center_outlined),
      selectedIcon: Icon(Icons.fitness_center),
      label: 'Equipment',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  static const _screens = [
    OverviewScreen(),
    CalendarScreen(),
    EquipmentScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: _destinations,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              tooltip: 'Treadmill',
              onPressed: () => context.push('/treadmill'),
              child: const Icon(Icons.directions_walk),
            )
          : null,
    );
  }
}
