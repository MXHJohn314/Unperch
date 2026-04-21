import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unperch/core/enums/enums.dart';

// ---------------------------------------------------------------------------
// Internal key constants — never refer to raw strings outside this file.
// ---------------------------------------------------------------------------

const _kShiftStartMinutes = 'shiftStartMinutes';
const _kShiftEndMinutes = 'shiftEndMinutes';
const _kWorkingDays = 'workingDays';
const _kWaterIntervalMinutes = 'waterIntervalMinutes';
const _kExerciseIntervalMinutes = 'exerciseIntervalMinutes';
const _kEquippedItems = 'equippedItems';
const _kExcludedBodyRegions = 'excludedBodyRegions';
const _kTtsVoice = 'ttsVoice';
const _kTtsSpeed = 'ttsSpeed';
const _kTtsPitch = 'ttsPitch';
const _kTheme = 'theme';
const _kOnboardingComplete = 'onboardingComplete';
const _kComplianceStreakThreshold = 'complianceStreakThreshold';

// ---------------------------------------------------------------------------
// DataStore wrapper
// ---------------------------------------------------------------------------

/// Typed wrapper around [SharedPreferences] for all Unperch user preferences.
///
/// Obtain via [unperchDataStoreProvider].
class UnperchDataStore {
  const UnperchDataStore(this._prefs);

  final SharedPreferences _prefs;

  // -------------------------------------------------------------------------
  // Shift
  // -------------------------------------------------------------------------

  /// Start of the user's work shift, expressed as minutes from midnight.
  int get shiftStartMinutes => _prefs.getInt(_kShiftStartMinutes) ?? 540; // 09:00

  Future<void> setShiftStartMinutes(int value) =>
      _prefs.setInt(_kShiftStartMinutes, value);

  /// End of the user's work shift, expressed as minutes from midnight.
  int get shiftEndMinutes => _prefs.getInt(_kShiftEndMinutes) ?? 1020; // 17:00

  Future<void> setShiftEndMinutes(int value) =>
      _prefs.setInt(_kShiftEndMinutes, value);

  // -------------------------------------------------------------------------
  // Working days
  // -------------------------------------------------------------------------

  /// The days of the week on which the user works.
  ///
  /// Stored as a comma-separated list of [DayOfWeek] enum names,
  /// e.g. "monday,tuesday,wednesday,thursday,friday".
  Set<DayOfWeek> get workingDays {
    final raw = _prefs.getString(_kWorkingDays);
    if (raw == null || raw.isEmpty) {
      return {
        DayOfWeek.monday,
        DayOfWeek.tuesday,
        DayOfWeek.wednesday,
        DayOfWeek.thursday,
        DayOfWeek.friday,
      };
    }
    return raw
        .split(',')
        .map((name) => DayOfWeek.values.firstWhere((e) => e.name == name))
        .toSet();
  }

  Future<void> setWorkingDays(Set<DayOfWeek> days) =>
      _prefs.setString(_kWorkingDays, days.map((e) => e.name).join(','));

  // -------------------------------------------------------------------------
  // Reminder intervals
  // -------------------------------------------------------------------------

  /// How often (in minutes) a water reminder fires during a shift.
  int get waterIntervalMinutes =>
      _prefs.getInt(_kWaterIntervalMinutes) ?? 60;

  Future<void> setWaterIntervalMinutes(int value) =>
      _prefs.setInt(_kWaterIntervalMinutes, value);

  /// How often (in minutes) an exercise reminder fires during a shift.
  int get exerciseIntervalMinutes =>
      _prefs.getInt(_kExerciseIntervalMinutes) ?? 90;

  Future<void> setExerciseIntervalMinutes(int value) =>
      _prefs.setInt(_kExerciseIntervalMinutes, value);

  // -------------------------------------------------------------------------
  // Equipment
  // -------------------------------------------------------------------------

  /// The equipment items the user has available.
  ///
  /// Stored as a comma-separated list of [EquipmentTag] enum names.
  Set<EquipmentTag> get equippedItems {
    final raw = _prefs.getString(_kEquippedItems);
    if (raw == null || raw.isEmpty) return {EquipmentTag.bodyweight};
    return raw
        .split(',')
        .map((name) => EquipmentTag.values.firstWhere((e) => e.name == name))
        .toSet();
  }

  Future<void> setEquippedItems(Set<EquipmentTag> items) =>
      _prefs.setString(_kEquippedItems, items.map((e) => e.name).join(','));

  // -------------------------------------------------------------------------
  // Excluded body regions
  // -------------------------------------------------------------------------

  /// Body regions excluded from exercise suggestions (e.g. due to injury).
  ///
  /// Stored as a comma-separated list of [BodyRegion] enum names.
  Set<BodyRegion> get excludedBodyRegions {
    final raw = _prefs.getString(_kExcludedBodyRegions);
    if (raw == null || raw.isEmpty) return {};
    return raw
        .split(',')
        .map((name) => BodyRegion.values.firstWhere((e) => e.name == name))
        .toSet();
  }

  Future<void> setExcludedBodyRegions(Set<BodyRegion> regions) =>
      _prefs.setString(
        _kExcludedBodyRegions,
        regions.map((e) => e.name).join(','),
      );

  // -------------------------------------------------------------------------
  // TTS preferences
  // -------------------------------------------------------------------------

  /// The TTS voice identifier string (platform-specific).
  String? get ttsVoice => _prefs.getString(_kTtsVoice);

  Future<void> setTtsVoice(String voice) =>
      _prefs.setString(_kTtsVoice, voice);

  /// TTS playback speed multiplier (1.0 = normal).
  double get ttsSpeed => _prefs.getDouble(_kTtsSpeed) ?? 1.0;

  Future<void> setTtsSpeed(double speed) =>
      _prefs.setDouble(_kTtsSpeed, speed);

  /// TTS pitch multiplier (1.0 = normal).
  double get ttsPitch => _prefs.getDouble(_kTtsPitch) ?? 1.0;

  Future<void> setTtsPitch(double pitch) =>
      _prefs.setDouble(_kTtsPitch, pitch);

  // -------------------------------------------------------------------------
  // Theme
  // -------------------------------------------------------------------------

  /// The user's preferred app theme.
  ThemePreference get theme {
    final name = _prefs.getString(_kTheme);
    if (name == null) return ThemePreference.system;
    return ThemePreference.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ThemePreference.system,
    );
  }

  Future<void> setTheme(ThemePreference value) =>
      _prefs.setString(_kTheme, value.name);

  // -------------------------------------------------------------------------
  // Onboarding
  // -------------------------------------------------------------------------

  /// Whether the user has completed the first-run onboarding wizard.
  bool get onboardingComplete =>
      _prefs.getBool(_kOnboardingComplete) ?? false;

  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_kOnboardingComplete, value);

  // -------------------------------------------------------------------------
  // Compliance
  // -------------------------------------------------------------------------

  /// The fraction of scheduled reminders that must be completed in a shift-day
  /// for that day to count toward the active streak.
  ///
  /// Defaults to 0.7 (70 %).
  double get complianceStreakThreshold =>
      _prefs.getDouble(_kComplianceStreakThreshold) ?? 0.7;

  Future<void> setComplianceStreakThreshold(double value) =>
      _prefs.setDouble(_kComplianceStreakThreshold, value);
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Async provider that resolves [SharedPreferences] and constructs the store.
///
/// Usage:
/// ```dart
/// final store = ref.watch(unperchDataStoreProvider);
/// ```
final unperchDataStoreProvider = Provider<UnperchDataStore>((ref) {
  throw UnimplementedError(
    'unperchDataStoreProvider must be overridden with a '
    'ProviderScope override that supplies an initialised SharedPreferences. '
    'See app.dart for the override pattern.',
  );
});

/// Helper to build the override in [ProviderScope]:
///
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// runApp(
///   ProviderScope(
///     overrides: [
///       unperchDataStoreProvider.overrideWithValue(UnperchDataStore(prefs)),
///     ],
///     child: const UnperchApp(),
///   ),
/// );
/// ```
