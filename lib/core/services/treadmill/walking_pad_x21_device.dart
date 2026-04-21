// =============================================================================
// walking_pad_x21_device.dart
// =============================================================================
// Concrete driver for the KingSmith WalkingPad X21.
//
// The X21 is a foldable/dual-mode model (walking + running) with a higher
// maximum speed than the A1/C2.
//
// Protocol: Same GATT UUIDs and packet framing as all WalkingPad models
// (confirmed via DorianRudolph/QWalkingPad and community reports).
//
// Speed range: 0.5 – 12.0 km/h (running mode).
// NOTE: The X21 has a running mode; be cautious sending high speeds without
// confirming the user has attached the safety lanyard.
// =============================================================================

import 'dart:math' as math;

import 'treadmill_device.dart';
import 'walking_pad_device.dart';

/// Driver for the KingSmith WalkingPad X21.
class WalkingPadX21Device extends WalkingPadDevice {
  WalkingPadX21Device({
    required super.device,
    super.firmwareVersion,
  }) : super(model: TreadmillModel.walkingPadX21);

  // Speed range for X21 (km/h) — running model, higher cap.
  static const double _minSpeed = 0.5;
  static const double _maxSpeed = 12.0;

  @override
  Future<void> setSpeed(double kmh) {
    final clamped = kmh.clamp(_minSpeed, _maxSpeed);
    final ticks = math.max(0, (clamped * 10).round());
    return sendCommand(0xa2, [ticks]);
  }
}
