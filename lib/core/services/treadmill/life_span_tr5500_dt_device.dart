// =============================================================================
// life_span_tr5500_dt_device.dart
// =============================================================================
// Concrete driver for the LifeSpan TR5500-DT desk treadmill.
//
// Protocol: Same proprietary BLE protocol as TR1200-DT — see
// life_span_device.dart class header comment.
//
// The TR5500 series is the commercial/high-duty variant.  It has a slightly
// wider speed range (up to 4.8 km/h / 3.0 mph in desk mode).
//
// CAUTION: The exact byte layout for TR5500-DT has not been independently
// verified — it is inferred from the shared LifeSpan firmware stack that
// brandonarbini/treadmill and blak3r/treadspan both target.  Validate with a
// BLE sniffer against the official LifeSpan Fit app on a TR5500 unit.
// =============================================================================

import 'life_span_device.dart';
import 'treadmill_device.dart';

/// Driver for the LifeSpan TR5500-DT desk treadmill.
class LifeSpanTR5500DTDevice extends LifeSpanDevice {
  LifeSpanTR5500DTDevice({
    required super.device,
    super.firmwareVersion,
  }) : super(model: TreadmillModel.lifeSpanTR5500DT);

  // TR5500-DT speed range (km/h) — slightly wider than TR1200-DT.
  @override
  double get minSpeedKmh => 0.8; // 0.5 mph

  @override
  double get maxSpeedKmh => 4.8; // 3.0 mph (commercial desk mode)
}
