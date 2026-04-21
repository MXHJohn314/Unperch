import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unperch/core/datastore/unperch_datastore.dart';
import 'package:unperch/features/calendar/calendar_screen.dart';
import 'package:unperch/features/calendar/day_view_screen.dart';
import 'package:unperch/features/home/home_screen.dart';
import 'package:unperch/features/onboarding/onboarding_screen.dart';
import 'package:unperch/core/enums/enums.dart';
import 'package:unperch/features/overview/overview_screen.dart';
import 'package:unperch/features/equipment/equipment_screen.dart';
import 'package:unperch/features/settings/settings_screen.dart';
import 'package:unperch/features/treadmill/treadmill_screen.dart';

// ---------------------------------------------------------------------------
// Route paths
// ---------------------------------------------------------------------------

class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String root = '/';
  static const String home = '/home';
  static const String calendar = '/calendar';
  static const String overview = '/overview';
  static const String settings = '/settings';
  static const String equipment = '/equipment';
  static const String treadmill = '/treadmill';
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

GoRouter _buildRouter(UnperchDataStore store) => GoRouter(
      initialLocation: AppRoutes.root,
      redirect: (context, state) {
        final onboardingDone = store.onboardingComplete;
        final loc = state.uri.path;
        // If onboarding is not done and not already on onboarding, redirect there.
        if (!onboardingDone && loc != AppRoutes.onboarding) {
          return AppRoutes.onboarding;
        }
        // If onboarding is done and user hits root or onboarding, send to home.
        if (onboardingDone &&
            (loc == AppRoutes.root || loc == AppRoutes.onboarding)) {
          return AppRoutes.home;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.root,
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
    GoRoute(
      path: AppRoutes.calendar,
      builder: (context, state) => const CalendarScreen(),
      routes: [
        GoRoute(
          path: 'day/:isoDate',
          builder: (context, state) => DayViewScreen(
            isoDate: state.pathParameters['isoDate']!,
          ),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.overview,
      builder: (context, state) => const OverviewScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.equipment,
      builder: (context, state) => const EquipmentScreen(),
    ),
    GoRoute(
      path: AppRoutes.treadmill,
      builder: (context, state) => const TreadmillScreen(),
    ),
  ],
);

// ---------------------------------------------------------------------------
// Root widget
// ---------------------------------------------------------------------------

/// Entry point wrapped by [ProviderScope] in main.dart.
///
/// Theme is set to [ThemeMode.system] for now.
/// TODO: replace with a Riverpod provider that reads the `theme` key from
/// [UnperchDataStore] so light / dark / high-contrast can be driven from
/// user settings.
class UnperchApp extends ConsumerWidget {
  const UnperchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(unperchDataStoreProvider);
    final themePref = ref.watch(themePreferenceProvider);
    final themeMode = _themePrefToMode(themePref);
    return MaterialApp.router(
      title: 'Unperch',
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      highContrastTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
        useMaterial3: true,
        visualDensity: VisualDensity.compact,
        textTheme: Typography.blackCupertino.apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
      ),
      highContrastDarkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
        useMaterial3: true,
        visualDensity: VisualDensity.compact,
        textTheme: Typography.whiteCupertino.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      routerConfig: _buildRouter(store),
    );
  }

  ThemeMode _themePrefToMode(ThemePreference pref) {
    switch (pref) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.highContrast:
        // High contrast uses platform accessibility theming; fall back to system.
        return ThemeMode.system;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }
}

