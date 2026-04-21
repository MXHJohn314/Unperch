// =============================================================================
// walkolution_device.dart
// =============================================================================
// Abstract base for Walkolution desk treadmill drivers.
//
// ---------------------------------------------------------------------------
// RESEARCH FINDINGS — Walkolution  [April 2026]
// ---------------------------------------------------------------------------
//
// Protocol type : NOT APPLICABLE — no BLE / electronics present.
//
// Summary:
//   Walkolution treadmills are fully manual, non-motorised walking desks.
//   The belt is driven entirely by foot power (like a non-electric treadmill).
//   There is NO motor, NO power supply, NO electronics, and NO BLE radio in
//   any Walkolution product as of April 2026.
//
//   Product line confirmed manual:
//     • Walkolution (original) — https://walkolution.com/products/walkolution
//     • Walkolution 2           — https://walkolution.com/products/walkolution2
//
//   The brand markets "no electricity, no maintenance, no noise" as a feature.
//
// What this means for Unperch:
//   • There is no BLE connection to establish.
//   • Speed, steps, and calorie data cannot be read from the device itself.
//   • If a user owns a Walkolution they would need a separate wearable
//     (e.g. Fitbit, Apple Watch) or manual input for step/calorie tracking.
//   • This driver hierarchy placeholder is preserved in case Walkolution
//     ships an accessory sensor or a future motorised model with BLE.
//
// All control / telemetry methods throw [UnsupportedError] (not
// [UnimplementedError]) to distinguish "impossible by design" from
// "not yet implemented".
// =============================================================================

import 'abstract_treadmill_device.dart';
import 'treadmill_device.dart';

/// Abstract driver for Walkolution desk treadmills.
///
/// Walkolution products are fully manual with no electronics.  All BLE
/// operations throw [UnsupportedError].  This class exists as a placeholder
/// in case a future sensor-equipped Walkolution model ships.
abstract class WalkolutionDevice extends AbstractTreadmillDevice {
  WalkolutionDevice({
    required super.device,
    required super.model,
    super.firmwareVersion,
  }) : super(make: TreadmillMake.walkolution);

  // ---- Unsupported operations ---------------------------------------------

  @override
  Future<void> connect() {
    throw UnsupportedError(
      'WalkolutionDevice.connect: Walkolution treadmills are fully manual '
      'with no electronics or BLE radio.  BLE connectivity is not possible. '
      'If you are seeing a Walkolution device advertise over BLE, it is likely '
      'a third-party sensor accessory — open a GitHub issue with the service '
      'UUIDs so the driver can be implemented.',
    );
  }

  @override
  Future<void> disconnect() async {
    // No-op: can never be connected.
  }

  @override
  Future<void> setSpeed(double kmh) {
    throw UnsupportedError(
      'WalkolutionDevice.setSpeed: Walkolution treadmills are non-motorised. '
      'Belt speed cannot be set programmatically.',
    );
  }

  @override
  Future<double> getSpeed() {
    throw UnsupportedError(
      'WalkolutionDevice.getSpeed: Walkolution treadmills have no speed '
      'sensor.  Consider inferring speed from a paired wearable.',
    );
  }

  @override
  Future<int> getSteps() {
    throw UnsupportedError(
      'WalkolutionDevice.getSteps: No step counter available on device.',
    );
  }

  @override
  Future<double> getCalories() {
    throw UnsupportedError(
      'WalkolutionDevice.getCalories: No calorie sensor available on device.',
    );
  }

  @override
  Future<Duration> getSessionDuration() {
    throw UnsupportedError(
      'WalkolutionDevice.getSessionDuration: No session tracking available.',
    );
  }
}
