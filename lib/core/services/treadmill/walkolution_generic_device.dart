// =============================================================================
// walkolution_generic_device.dart
// =============================================================================
// Concrete driver (placeholder) for Walkolution desk treadmills.
//
// Walkolution products are fully manual with no electronics or BLE radio.
// All operations throw [UnsupportedError].  See walkolution_device.dart for
// full explanation.
// =============================================================================

import 'treadmill_device.dart';
import 'walkolution_device.dart';

/// Placeholder driver for Walkolution desk treadmills (non-electronic).
///
/// This class will only ever be instantiated if a future Walkolution product
/// ships with a BLE sensor.  Until then, [WalkolutionDevice] methods throw
/// [UnsupportedError].
class WalkolutionGenericDevice extends WalkolutionDevice {
  WalkolutionGenericDevice({
    required super.device,
    super.firmwareVersion,
  }) : super(model: TreadmillModel.walkolutionGeneric);
}
