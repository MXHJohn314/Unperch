// =============================================================================
// urevo_device.dart
// =============================================================================
// Abstract base for Urevo Strol series treadmill drivers.
//
// ---------------------------------------------------------------------------
// RESEARCH FINDINGS — Urevo (Strol series)  [April 2026]
// ---------------------------------------------------------------------------
//
// Protocol type : Proprietary (NOT FTMS) — PARTIALLY KNOWN
//
// Open-source references:
//   • blak3r/treadspan (ESP32 firmware)  https://github.com/blak3r/treadspan
//     This project reverse-engineers the UREVO app's BLE communication so an
//     ESP32 can impersonate the official app.  It documents the UREVO protocol
//     alongside LifeSpan and Sperax.
//
// Confirmed facts (from treadspan README / firmware):
//   • Urevo Strol 2E, Strol 2S Pro confirmed BLE-capable.
//   • The treadspan ESP32 acts as a BLE central, connects to the Strol,
//     and mimics the official UREVO app — meaning the protocol IS documented
//     in the treadspan firmware source.
//   • The protocol is proprietary (not FTMS).
//
// HOWEVER — the exact service UUIDs, characteristic UUIDs, and command byte
// sequences are embedded in the treadspan firmware source code which was not
// fully retrievable via search at the time of writing (April 2026).  The
// treadspan GitHub repository at https://github.com/blak3r/treadspan is the
// authoritative source for these details.
//
// Known/inferred details (from treadspan project description):
//   • BLE communication is between the UREVO app (central) and the treadmill
//     (peripheral).
//   • Protocol appears similar in structure to other Chinese OEM walking pad
//     protocols: a small number of vendor-specific services + characteristics,
//     proprietary framed byte packets.
//   • FTMS is NOT used.
//
// UUID candidates to investigate (unconfirmed):
//   • 0000fff0 / fff1 / fff2  — common pattern for Chinese OEM fitness BLE
//   • 0000fe00 / fe01 / fe02  — WalkingPad chipset (possibly shared)
//   Examine the treadspan Arduino/ESP32 source (BluetoothSerial or NimBLE
//   usage) to identify the actual UUIDs.
//
// Recommended investigation approach:
//   1. Clone https://github.com/blak3r/treadspan and read the firmware source.
//   2. Identify service/char UUIDs and packet format for the UREVO device.
//   3. Alternatively, use Android HCI snoop log while the official UREVO app
//      is paired to the treadmill.
//   4. Update this file with confirmed UUIDs and implement the methods below.
//
// Until confirmed, all control/telemetry methods throw [UnimplementedError].
// =============================================================================

import 'abstract_treadmill_device.dart';
import 'treadmill_device.dart';

/// Abstract driver for Urevo Strol series under-desk treadmills.
///
/// Protocol partially documented via blak3r/treadspan but exact UUIDs and
/// byte sequences require further extraction from that firmware source.
/// All methods throw [UnimplementedError] until confirmed.
abstract class UrevoDevice extends AbstractTreadmillDevice {
  UrevoDevice({
    required super.device,
    required super.model,
    super.firmwareVersion,
  }) : super(make: TreadmillMake.urevo);

  // ---- Placeholder UUID constants -----------------------------------------
  // UNCONFIRMED — extract from https://github.com/blak3r/treadspan firmware.

  /// Likely vendor-specific service UUID — UNCONFIRMED.
  static const String serviceUuidHypothetical =
      '0000fff0-0000-1000-8000-00805f9b34fb';

  /// Likely notify characteristic — UNCONFIRMED.
  static const String rxCharUuidHypothetical =
      '0000fff1-0000-1000-8000-00805f9b34fb';

  /// Likely write characteristic — UNCONFIRMED.
  static const String txCharUuidHypothetical =
      '0000fff2-0000-1000-8000-00805f9b34fb';

  // ---- Unimplemented operations -------------------------------------------

  @override
  Future<void> setSpeed(double kmh) {
    throw UnimplementedError(
      'UrevoDevice.setSpeed: Urevo Strol BLE protocol not yet fully '
      'extracted.  See https://github.com/blak3r/treadspan for the ESP32 '
      'firmware that implements this protocol — extract service/char UUIDs '
      'and command bytes from the source, then implement here.',
    );
  }

  @override
  Future<double> getSpeed() {
    throw UnimplementedError(
      'UrevoDevice.getSpeed: Urevo Strol BLE protocol not yet implemented. '
      'See class-level comment.',
    );
  }

  @override
  Future<int> getSteps() {
    throw UnimplementedError(
      'UrevoDevice.getSteps: Urevo Strol BLE protocol not yet implemented.',
    );
  }

  @override
  Future<double> getCalories() {
    throw UnimplementedError(
      'UrevoDevice.getCalories: Urevo Strol BLE protocol not yet implemented.',
    );
  }

  @override
  Future<Duration> getSessionDuration() {
    throw UnimplementedError(
      'UrevoDevice.getSessionDuration: Urevo Strol BLE protocol not yet '
      'implemented.',
    );
  }
}
