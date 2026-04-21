// =============================================================================
// treadmill_device.dart
// =============================================================================
// Core interface, enums, sealed state, and device-info data class for the
// Unperch treadmill BLE integration layer.
//
// All brand-specific drivers implement [TreadmillDevice] via the shared
// [AbstractTreadmillDevice] base class.
// =============================================================================

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// The manufacturer / brand of a supported treadmill.
enum TreadmillMake {
  walkingPad,
  lifeSpan,
  iWalk,
  walkolution,
  urevo,
}

/// Every known model across all supported makes.
///
/// Add new entries here as new models are verified and drivers are written.
enum TreadmillModel {
  // WalkingPad (KingSmith)
  walkingPadA1,
  walkingPadC2,
  walkingPadX21,

  // LifeSpan
  lifeSpanTR1200DT,
  lifeSpanTR5500DT,

  // iWalk
  iWalkGeneric,

  // Walkolution
  // NOTE: All current Walkolution products are fully manual (no motor, no
  // electronics).  No BLE support exists as of April 2026.  This entry is a
  // placeholder in case a motorised or sensor-equipped model ships in future.
  walkolutionGeneric,

  // Urevo
  urevoStrol,
}

// ---------------------------------------------------------------------------
// TreadmillState — sealed class
// ---------------------------------------------------------------------------

/// Live connection / operational state of a [TreadmillDevice].
sealed class TreadmillState {
  const TreadmillState();
}

/// No active BLE connection.
final class TreadmillDisconnected extends TreadmillState {
  const TreadmillDisconnected();
}

/// BLE connection is being established (scanning + GATT discovery in
/// progress).
final class TreadmillConnecting extends TreadmillState {
  const TreadmillConnecting();
}

/// BLE connection is established and the device is ready for commands.
final class TreadmillConnected extends TreadmillState {
  const TreadmillConnected();
}

/// An unrecoverable error occurred (connection loss, GATT failure, etc.).
final class TreadmillError extends TreadmillState {
  const TreadmillError(this.message);
  final String message;
}

// ---------------------------------------------------------------------------
// TreadmillDeviceInfo — data class
// ---------------------------------------------------------------------------

/// Static metadata about a paired treadmill device.
class TreadmillDeviceInfo {
  const TreadmillDeviceInfo({
    required this.make,
    required this.model,
    this.firmwareVersion,
    this.macAddress,
  });

  final TreadmillMake make;
  final TreadmillModel model;

  /// Firmware / software version string as reported by the device, if known.
  final String? firmwareVersion;

  /// BLE MAC address (Android) or UUID (iOS), if available.
  final String? macAddress;

  @override
  String toString() =>
      'TreadmillDeviceInfo(make: $make, model: $model, '
      'fw: $firmwareVersion, mac: $macAddress)';
}

// ---------------------------------------------------------------------------
// TreadmillDevice — interface
// ---------------------------------------------------------------------------

/// The primary contract that every treadmill driver must satisfy.
///
/// Obtain a concrete instance via [TreadmillRegistry] during BLE scan result
/// processing.
abstract interface class TreadmillDevice {
  // ---- Identity -----------------------------------------------------------

  /// The platform-level device identifier (MAC on Android, UUID on iOS).
  String get deviceId;

  /// A human-readable name suitable for display in the UI (e.g. "WalkingPad
  /// A1 – 4F:2A").
  String get displayName;

  /// The make (brand) of this device.
  TreadmillMake get make;

  /// The specific model of this device.
  TreadmillModel get model;

  // ---- State stream -------------------------------------------------------

  /// Broadcasts [TreadmillState] transitions.  Always emits the current state
  /// immediately upon first listen (replay-1 behaviour expected from the
  /// implementation).
  Stream<TreadmillState> get stateStream;

  // ---- Connection lifecycle -----------------------------------------------

  /// Initiate a BLE connection and perform GATT service discovery.
  ///
  /// The [stateStream] will transition:
  ///   disconnected → connecting → connected  (on success)
  ///   disconnected → connecting → error(…)   (on failure)
  Future<void> connect();

  /// Gracefully terminate the BLE connection.
  ///
  /// The [stateStream] will transition to [TreadmillDisconnected].
  Future<void> disconnect();

  // ---- Control ------------------------------------------------------------

  /// Set the belt speed.
  ///
  /// [kmh] is in kilometres per hour.  The driver is responsible for
  /// converting to the device's native unit (e.g. 0.1 km/h ticks).
  ///
  /// Throws [StateError] if the device is not connected.
  Future<void> setSpeed(double kmh);

  // ---- Telemetry ----------------------------------------------------------

  /// Read the current belt speed in km/h.
  Future<double> getSpeed();

  /// Read the cumulative step count for the current (or most recent) session.
  Future<int> getSteps();

  /// Read the estimated calorie burn (kcal) for the current/last session.
  Future<double> getCalories();

  /// Read the elapsed duration of the current/last session.
  Future<Duration> getSessionDuration();

  // ---- Metadata -----------------------------------------------------------

  /// Static device metadata (make, model, firmware version, MAC address).
  TreadmillDeviceInfo get deviceInfo;
}
