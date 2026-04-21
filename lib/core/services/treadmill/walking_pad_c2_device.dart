// =============================================================================
// walking_pad_c2_device.dart
// =============================================================================
// Concrete driver for the KingSmith WalkingPad C2.
//
// The C2 uses the same GATT UUIDs and packet framing as the A1.
// Speed range: 0.5 – 6.0 km/h.
//
// The C2 is also sold as the WalkingPad C2 Mini in some markets; the protocol
// is identical.  Confirmed by darnfish/walkingpad and indiefan/king_smith.
// =============================================================================

import 'dart:math' as math;

import 'treadmill_device.dart';
import 'walking_pad_device.dart';

/// Driver for the KingSmith WalkingPad C2.
class WalkingPadC2Device extends WalkingPadDevice {
  WalkingPadC2Device({
    required super.device,
    super.firmwareVersion,
  }) : super(model: TreadmillModel.walkingPadC2);

  // Speed range for C2 (km/h).
  static const double _minSpeed = 0.5;
  static const double _maxSpeed = 6.0;

  @override
  Future<void> setSpeed(double kmh) {
    final clamped = kmh.clamp(_minSpeed, _maxSpeed);
    final ticks = math.max(0, (clamped * 10).round());
    return sendCommand(0xa2, [ticks]);
  }
}
