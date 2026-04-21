// =============================================================================
// urevo_strol_device.dart
// =============================================================================
// Concrete driver for the Urevo Strol series (Strol 2E, Strol 2S Pro, etc.).
//
// Protocol: Proprietary — partially documented via blak3r/treadspan.
// All methods throw [UnimplementedError] until byte sequences are confirmed.
// See urevo_device.dart class header comment for investigation approach.
// =============================================================================

import 'treadmill_device.dart';
import 'urevo_device.dart';

/// Driver for the Urevo Strol series under-desk treadmill.
///
/// Protocol is known to be proprietary (see blak3r/treadspan) but the exact
/// byte sequences have not been extracted into this driver yet.  All
/// operations throw [UnimplementedError].
class UrevoStrolDevice extends UrevoDevice {
  UrevoStrolDevice({
    required super.device,
    super.firmwareVersion,
  }) : super(model: TreadmillModel.urevoStrol);
}
