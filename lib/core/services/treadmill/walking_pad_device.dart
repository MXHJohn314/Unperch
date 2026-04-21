// =============================================================================
// walking_pad_device.dart
// =============================================================================
// Abstract base for all KingSmith WalkingPad drivers.
//
// ---------------------------------------------------------------------------
// RESEARCH FINDINGS — WalkingPad (KingSmith)  [April 2026]
// ---------------------------------------------------------------------------
//
// Protocol type : Proprietary (NOT FTMS)
//
// Open-source references:
//   • ph4r05/ph4-walkingpad (Python)   https://github.com/ph4r05/ph4-walkingpad
//     Primary reverse-engineering reference.  Protocol documented in pad.py
//     and in Issue #5 "FYI BLE Protocol".
//   • darnfish/walkingpad (Node.js)    https://github.com/darnfish/walkingpad
//   • DorianRudolph/QWalkingPad (C++)  https://github.com/DorianRudolph/QWalkingPad
//   • indiefan/king_smith (HA)         https://github.com/indiefan/king_smith
//   • huserben/walkingpad (C#)         https://github.com/huserben/walkingpad
//
// Applies to: A1, A1 Pro, C2, R1, R2, X21 (all share the same chipset /
//             protocol; only supported speed range differs).
//
// BLE GATT layout:
//   Service     0000fe00-0000-1000-8000-00805f9b34fb  (vendor-specific)
//     Char RX   0000fe01-0000-1000-8000-00805f9b34fb  (NOTIFY — status updates)
//     Char TX   0000fe02-0000-1000-8000-00805f9b34fb  (WRITE_WITHOUT_RESPONSE — commands)
//
// Packet framing:
//   [0xf7, CMD, PARAM…, CHECKSUM, 0xfd]
//   Checksum = sum(bytes[1 .. len-2]) % 256   (excludes 0xf7 and 0xfd)
//
// Command bytes (CMD):
//   0xa1  — Set mode / start / stop
//              PARAM[0]: 0x00 = standby, 0x01 = manual, 0x02 = automatic
//   0xa2  — Set speed
//              PARAM[0]: speed in 0.1 km/h units (e.g. 0x19 = 2.5 km/h)
//   0xa0  — Request status (poll)  — no additional params
//   0xa3  — Set child-lock (0x00 off, 0x01 on)
//   0xa4  — Set units (0x00 metric, 0x01 imperial)
//   0xa5  — Set max speed (safety cap)
//
// Status notification format (CMD byte 0xa2 in response):
//   Byte  0    : 0xf8  (response header)
//   Byte  1    : 0xa2  (status message ID)
//   Byte  2    : mode (0 = standby, 1 = manual, 2 = auto)
//   Byte  3    : current speed (0.1 km/h units)
//   Byte  4    : reserved / display state
//   Byte  5-6  : elapsed time (seconds, big-endian)
//   Byte  7-8  : distance (0.01 km units, big-endian)
//   Byte  9-10 : step count (big-endian)
//   Byte  11   : reserved
//   Byte  12   : calories (kcal, 0.1 kcal units)
//   …          : trailing checksum + 0xfd
//   (Full packet ~18 bytes — exact layout from ph4r05 Issue #5)
//
// The device broadcasts status automatically at ~1 Hz while the belt is
// running; a manual poll via 0xa0 is needed when idle.
// =============================================================================

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'abstract_treadmill_device.dart';
import 'treadmill_device.dart';

/// Abstract driver for all KingSmith WalkingPad models.
///
/// Provides GATT UUID constants, packet helpers, and a shared notification
/// listener.  Model-specific subclasses override [setSpeed], [getSpeed], etc.
abstract class WalkingPadDevice extends AbstractTreadmillDevice {
  WalkingPadDevice({
    required super.device,
    required super.model,
    super.firmwareVersion,
  }) : super(make: TreadmillMake.walkingPad);

  // ---- GATT UUID constants ------------------------------------------------

  /// Vendor-specific service (all WalkingPad models).
  static const String serviceUuid =
      '0000fe00-0000-1000-8000-00805f9b34fb';

  /// Notification characteristic — device pushes status updates here.
  static const String rxCharUuid =
      '0000fe01-0000-1000-8000-00805f9b34fb';

  /// Write characteristic — send commands here (write-without-response).
  static const String txCharUuid =
      '0000fe02-0000-1000-8000-00805f9b34fb';

  // ---- Command bytes ------------------------------------------------------

  static const int _framingStart = 0xf7;
  static const int _framingEnd   = 0xfd;

  static const int _cmdMode      = 0xa1; // start/stop/standby
  static const int _cmdSpeed     = 0xa2; // set belt speed
  static const int _cmdPollStatus = 0xa0; // request status update

  // Mode parameter values for _cmdMode
  static const int modeStandby   = 0x00;
  static const int modeManual    = 0x01;
  static const int modeAutomatic = 0x02;

  // ---- Internal state -----------------------------------------------------

  BluetoothCharacteristic? _txChar;
  BluetoothCharacteristic? _rxChar;
  StreamSubscription<List<int>>? _notifySubscription;

  // Latest parsed status snapshot (updated by notification handler).
  _WalkingPadStatus _lastStatus = const _WalkingPadStatus();

  // ---- Lifecycle ----------------------------------------------------------

  @override
  Future<void> onConnected() async {
    final service = await findService(serviceUuid);
    if (service == null) {
      throw StateError(
        'WalkingPad service $serviceUuid not found on device $deviceId',
      );
    }
    _txChar = findCharacteristic(service, txCharUuid);
    _rxChar = findCharacteristic(service, rxCharUuid);

    if (_txChar == null || _rxChar == null) {
      throw StateError(
        'WalkingPad TX or RX characteristic not found on device $deviceId',
      );
    }

    // Subscribe to status notifications.
    await _rxChar!.setNotifyValue(true);
    _notifySubscription = _rxChar!.lastValueStream.listen(_handleNotification);
  }

  @override
  Future<void> disconnect() async {
    await _notifySubscription?.cancel();
    _notifySubscription = null;
    await super.disconnect();
  }

  // ---- Packet builder / parser --------------------------------------------

  /// Build a framed WalkingPad command packet.
  ///
  ///   [0xf7, cmd, …params, checksum, 0xfd]
  List<int> _buildPacket(int cmd, List<int> params) {
    final inner = [cmd, ...params];
    final checksum = inner.fold<int>(0, (acc, b) => acc + b) % 256;
    return [_framingStart, ...inner, checksum, _framingEnd];
  }

  void _handleNotification(List<int> data) {
    // Status notifications start with 0xf8 followed by the original CMD byte.
    if (data.length < 3 || data[0] != 0xf8) return;
    if (data[1] == _cmdSpeed && data.length >= 13) {
      _lastStatus = _WalkingPadStatus.fromBytes(data);
    }
  }

  // ---- Shared command helpers (used by subclasses) -----------------------

  /// Send a raw command.  Subclasses should call this rather than writing
  /// directly so that the checksum framing is always applied.
  Future<void> sendCommand(int cmd, List<int> params) async {
    if (_txChar == null) {
      throw StateError(
          'sendCommand called before characteristics were discovered.');
    }
    final packet = _buildPacket(cmd, params);
    await writeCharacteristic(_txChar!, packet);
  }

  /// Request an immediate status snapshot from the device.
  Future<void> pollStatus() => sendCommand(_cmdPollStatus, []);

  /// Set belt mode (standby / manual / automatic).
  Future<void> setMode(int mode) => sendCommand(_cmdMode, [mode]);

  // ---- TreadmillDevice telemetry (default implementations) ---------------
  //
  // Subclasses may override these if model-specific parsing differs.

  @override
  Future<double> getSpeed() async {
    await pollStatus();
    // Give the notification a short window to arrive.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _lastStatus.speedKmh;
  }

  @override
  Future<int> getSteps() async {
    await pollStatus();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _lastStatus.steps;
  }

  @override
  Future<double> getCalories() async {
    await pollStatus();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _lastStatus.caloriesKcal;
  }

  @override
  Future<Duration> getSessionDuration() async {
    await pollStatus();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _lastStatus.elapsed;
  }

  /// Set speed in km/h.  Converts to 0.1 km/h ticks internally.
  ///
  /// The firmware silently clamps values outside the device's supported range;
  /// model-specific subclasses should clamp before calling this to surface
  /// errors early.
  @override
  Future<void> setSpeed(double kmh) async {
    final ticks = math.max(0, (kmh * 10).round());
    await sendCommand(_cmdSpeed, [ticks]);
  }

  /// Most recent status snapshot (updated by BLE notifications at ~1 Hz).
  // ignore: library_private_types_in_public_api — intentionally package-internal
  _WalkingPadStatus get lastStatus => _lastStatus;
}

// ---------------------------------------------------------------------------
// Internal status snapshot
// ---------------------------------------------------------------------------

/// Parsed representation of a WalkingPad 0xa2 status notification.
class _WalkingPadStatus {
  const _WalkingPadStatus({
    this.mode = 0,
    this.speedKmh = 0.0,
    this.elapsed = Duration.zero,
    this.distanceKm = 0.0,
    this.steps = 0,
    this.caloriesKcal = 0.0,
  });

  final int mode;
  final double speedKmh;
  final Duration elapsed;
  final double distanceKm;
  final int steps;
  final double caloriesKcal;

  /// Parse a raw 0xf8 / 0xa2 notification payload.
  ///
  /// Byte layout (from ph4r05/ph4-walkingpad Issue #5):
  ///   [0] 0xf8  header
  ///   [1] 0xa2  message type
  ///   [2] mode
  ///   [3] speed (0.1 km/h)
  ///   [4] display state (ignored)
  ///   [5,6] elapsed seconds (big-endian)
  ///   [7,8] distance (0.01 km, big-endian)
  ///   [9,10] steps (big-endian)
  ///   [11] reserved
  ///   [12] calories (0.1 kcal)
  factory _WalkingPadStatus.fromBytes(List<int> d) {
    if (d.length < 13) return const _WalkingPadStatus();
    return _WalkingPadStatus(
      mode:          d[2],
      speedKmh:      d[3] / 10.0,
      elapsed:       Duration(seconds: (d[5] << 8) | d[6]),
      distanceKm:    ((d[7] << 8) | d[8]) / 100.0,
      steps:         (d[9] << 8) | d[10],
      caloriesKcal:  d[12] / 10.0,
    );
  }
}
