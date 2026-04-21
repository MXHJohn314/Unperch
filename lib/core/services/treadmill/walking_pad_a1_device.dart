// =============================================================================
// walking_pad_a1_device.dart
// =============================================================================
// Concrete driver for the KingSmith WalkingPad A1.
//
// Protocol source: ph4r05/ph4-walkingpad, darnfish/walkingpad, Issue #5.
// The A1 uses the same GATT UUIDs and packet framing as all WalkingPad models.
// The only model-specific constraint is the supported speed range.
//
// Speed range: 0.5 – 6.0 km/h (A1 / A1 Pro).
// =============================================================================

import 'dart:math' as math;

import 'treadmill_device.dart';
import 'walking_pad_device.dart';

/// Driver for the KingSmith WalkingPad A1 (and A1 Pro).
///
/// All protocol logic lives in [WalkingPadDevice].  This class clamps speed
/// to the A1's supported range and provides the factory constructor used by
/// [TreadmillRegistry].
class WalkingPadA1Device extends WalkingPadDevice {
  WalkingPadA1Device({
    required super.device,
    super.firmwareVersion,
  }) : super(model: TreadmillModel.walkingPadA1);

  // Speed range for A1 / A1 Pro (km/h).
  static const double _minSpeed = 0.5;
  static const double _maxSpeed = 6.0;

  @override
  Future<void> setSpeed(double kmh) {
    final clamped = kmh.clamp(_minSpeed, _maxSpeed);
    final ticks = math.max(0, (clamped * 10).round());
    return sendCommand(0xa2, [ticks]);
  }
}
