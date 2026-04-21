// =============================================================================
// i_walk_device.dart
// =============================================================================
// Abstract base for iWalk under-desk treadmill drivers.
//
// ---------------------------------------------------------------------------
// RESEARCH FINDINGS — iWalk  [April 2026]
// ---------------------------------------------------------------------------
//
// Protocol type : UNKNOWN — no public reverse-engineering documentation found.
//
// What is known:
//   • iWalk sells several under-desk walking pads / treadmills marketed under
//     the "iWalk" brand (distinct from KingSmith WalkingPad).
//   • Devices have a companion app (iOS/Android) for speed control and stats.
//   • BLE is confirmed present (app communicates wirelessly).
//   • No public GitHub projects, teardowns, or protocol captures have been
//     identified as of April 2026.
//
// Hypotheses (NOT confirmed — require BLE sniffing to validate):
//   • iWalk may share chipset vendors with WalkingPad / similar Chinese OEM
//     walking pad brands, making the FE00/FE01/FE02 UUID pattern a plausible
//     starting point for investigation.
//   • Alternatively the device may use the FFF0/FFF1/FFF2 vendor pattern that
//     appears in several generic fitness BLE peripherals.
//   • FTMS (0x1826) support is unlikely given the proprietary app ecosystem,
//     but cannot be ruled out.
//
// Recommended investigation approach:
//   1. Pair an iWalk device with nRF Connect or LightBlue; enumerate services.
//   2. Sniff traffic between the official iWalk app and the device using
//      Wireshark + Android BLE HCI snoop log (`/sdcard/btsnoop_hci.log`).
//   3. Update this file with confirmed UUIDs and protocol bytes.
//
// Until the protocol is confirmed all control/telemetry methods throw
// [UnimplementedError] with a descriptive message.
// =============================================================================

import 'abstract_treadmill_device.dart';
import 'treadmill_device.dart';

/// Abstract driver for iWalk under-desk treadmills.
///
/// Protocol is not yet publicly documented.  All methods throw
/// [UnimplementedError] until BLE traffic is captured and analysed.
abstract class IWalkDevice extends AbstractTreadmillDevice {
  IWalkDevice({
    required super.device,
    required super.model,
    super.firmwareVersion,
  }) : super(make: TreadmillMake.iWalk);

  // ---- Placeholder UUID constants -----------------------------------------
  // These are HYPOTHETICAL and must be confirmed via BLE sniffing.
  // DO NOT write to these characteristics until protocol is verified.

  /// Hypothetical service UUID — unconfirmed.
  /// Possible candidates: 0000fe00-…  or  0000fff0-…
  static const String serviceUuidHypothetical =
      '0000fe00-0000-1000-8000-00805f9b34fb';

  // ---- Unimplemented telemetry / control ----------------------------------

  @override
  Future<void> setSpeed(double kmh) {
    throw UnimplementedError(
      'IWalkDevice.setSpeed: iWalk BLE protocol not yet reversed. '
      'Sniff traffic between the official iWalk app and the device '
      '(Android HCI snoop log or nRF Sniffer) to identify the service UUID, '
      'characteristic UUIDs, and command byte format, then implement here.',
    );
  }

  @override
  Future<double> getSpeed() {
    throw UnimplementedError(
      'IWalkDevice.getSpeed: iWalk BLE protocol not yet reversed. '
      'See class-level comment for investigation approach.',
    );
  }

  @override
  Future<int> getSteps() {
    throw UnimplementedError(
      'IWalkDevice.getSteps: iWalk BLE protocol not yet reversed.',
    );
  }

  @override
  Future<double> getCalories() {
    throw UnimplementedError(
      'IWalkDevice.getCalories: iWalk BLE protocol not yet reversed.',
    );
  }

  @override
  Future<Duration> getSessionDuration() {
    throw UnimplementedError(
      'IWalkDevice.getSessionDuration: iWalk BLE protocol not yet reversed.',
    );
  }
}
