import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unperch/core/datastore/unperch_datastore.dart';
import 'package:unperch/features/onboarding/steps/body_exclusions_step.dart';
import 'package:unperch/features/onboarding/steps/equipment_step.dart';
import 'package:unperch/features/onboarding/steps/notifications_step.dart';
import 'package:unperch/features/onboarding/steps/reminder_intervals_step.dart';
import 'package:unperch/features/onboarding/steps/shift_hours_step.dart';
import 'package:unperch/features/onboarding/steps/tts_preferences_step.dart';
import 'package:unperch/features/onboarding/steps/working_days_step.dart';

// ---------------------------------------------------------------------------
// Step metadata
// ---------------------------------------------------------------------------

const _stepTitles = [
  'Shift Hours',
  'Working Days',
  'Equipment',
  'Reminders',
  'Body Regions',
  'Voice',
  'Notifications',
];

const _totalSteps = 7;

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onNext() {
    if (_currentPage < _totalSteps - 1) {
      _goToPage(_currentPage + 1);
    } else {
      _finish();
    }
  }

  void _onBack() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  Future<void> _finish() async {
    await ref.read(unperchDataStoreProvider).setOnboardingComplete(true);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentPage + 1) / _totalSteps;
    final isLastPage = _currentPage == _totalSteps - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitles[_currentPage]),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
          ),
        ),
      ),
      body: Column(
        children: [
          // Step counter
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Row(
              children: [
                Text(
                  'Step ${_currentPage + 1} of $_totalSteps',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: const [
                _ScrollableStep(child: ShiftHoursStep()),
                _ScrollableStep(child: WorkingDaysStep()),
                _ScrollableStep(child: EquipmentStep()),
                _ScrollableStep(child: ReminderIntervalsStep()),
                _ScrollableStep(child: BodyExclusionsStep()),
                _ScrollableStep(child: TtsPreferencesStep()),
                _ScrollableStep(child: NotificationsStep()),
              ],
            ),
          ),
          // Navigation buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _onBack,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _onNext,
                      child: Text(isLastPage ? "Let's go" : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper: wraps a step in a scrollable so it never overflows on small screens
// ---------------------------------------------------------------------------

class _ScrollableStep extends StatelessWidget {
  const _ScrollableStep({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: child,
    );
  }
}
