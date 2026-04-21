// =============================================================================
// life_span_tr1200_dt_device.dart
// =============================================================================
// Concrete driver for the LifeSpan TR1200-DT desk treadmill (BLE-capable
// console variants: DT3 2018+, DT5, DT7).
//
// Protocol: Proprietary — see life_span_device.dart class header comment.
// Sources:  brandonarbini/treadmill, daeken/lifespan.py, lostmsu/LifeSpan.cs,
//           blak3r/treadspan.
//
// Speed range: 0.8 – 4.0 km/h (0.5 – 2.5 mph), typical desk-use cap.
// The LifeSpan app enforces this range; the console will ignore out-of-range
// commands but we clamp here to fail fast.
//
// CAUTION: The TR1200-DT (original) and early DT3 consoles use a wired UART
// interface — they have NO BLE.  Only 2018+ DT3, DT5, and DT7 consoles are
// BLE-capable.  The registry should match devices by advertised name prefix
// (e.g. "LifeSpan", "TR1200") to avoid connecting to non-BLE units.
// =============================================================================

import 'life_span_device.dart';
import 'treadmill_device.dart';

/// Driver for the LifeSpan TR1200-DT (DT3/DT5/DT7 console, BLE variant).
class LifeSpanTR1200DTDevice extends LifeSpanDevice {
  LifeSpanTR1200DTDevice({
    required super.device,
    super.firmwareVersion,
  }) : super(model: TreadmillModel.lifeSpanTR1200DT);

  // TR1200-DT speed range (km/h).
  @override
  double get minSpeedKmh => 0.8; // 0.5 mph

  @override
  double get maxSpeedKmh => 4.0; // 2.5 mph
}
