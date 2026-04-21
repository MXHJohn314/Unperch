// =============================================================================
// i_walk_generic_device.dart
// =============================================================================
// Concrete driver for iWalk under-desk treadmills (generic / unknown model).
//
// Protocol: UNKNOWN — see i_walk_device.dart class header comment for
// investigation approach.
//
// All methods delegate upward to IWalkDevice which throws [UnimplementedError].
// =============================================================================

import 'i_walk_device.dart';
import 'treadmill_device.dart';

/// Generic driver for iWalk under-desk treadmills.
///
/// Used when a BLE scan matches a device name prefix consistent with iWalk
/// but no model-specific driver exists yet.  All operations throw
/// [UnimplementedError] — see [IWalkDevice] class comment for how to
/// reverse-engineer the protocol and complete this driver.
class IWalkGenericDevice extends IWalkDevice {
  IWalkGenericDevice({
    required super.device,
    super.firmwareVersion,
  }) : super(model: TreadmillModel.iWalkGeneric);
}
