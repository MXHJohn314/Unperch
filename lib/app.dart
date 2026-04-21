import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Route paths
// ---------------------------------------------------------------------------

class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/';
  static const String home = '/home';
  static const String calendar = '/calendar';
  static const String overview = '/overview';
  static const String settings = '/settings';
  static const String treadmill = '/treadmill';
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

final _router = GoRouter(
  initialLocation: AppRoutes.onboarding,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      // TODO: redirect to /home once onboarding is complete (read DataStore flag)
      builder: (context, state) => const _StubScreen(label: 'Onboarding'),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const _StubScreen(label: 'Home'),
    ),
    GoRoute(
      path: AppRoutes.calendar,
      builder: (context, state) => const _StubScreen(label: 'Calendar'),
    ),
    GoRoute(
      path: AppRoutes.overview,
      builder: (context, state) => const _StubScreen(label: 'Overview'),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const _StubScreen(label: 'Settings'),
    ),
    GoRoute(
      path: AppRoutes.treadmill,
      builder: (context, state) => const _StubScreen(label: 'Treadmill'),
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
    return MaterialApp.router(
      title: 'Unperch',
      themeMode: ThemeMode.system,
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
      // TODO: add high-contrast theme once design tokens are defined
      routerConfig: _router,
    );
  }
}

// ---------------------------------------------------------------------------
// Temporary stub screen — replaced by real feature screens as they are built
// ---------------------------------------------------------------------------

class _StubScreen extends StatelessWidget {
  const _StubScreen({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(
        child: Text(
          '$label — not yet implemented',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
