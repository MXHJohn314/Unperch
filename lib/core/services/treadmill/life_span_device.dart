// =============================================================================
// life_span_device.dart
// =============================================================================
// Abstract base for all LifeSpan treadmill drivers.
//
// ---------------------------------------------------------------------------
// RESEARCH FINDINGS — LifeSpan Fitness  [April 2026]
// ---------------------------------------------------------------------------
//
// Protocol type : Proprietary (NOT FTMS)
//
// Open-source references:
//   • blak3r/treadspan (ESP32 firmware, mimics LifeSpan Fit app over BLE)
//       https://github.com/blak3r/treadspan
//   • brandonarbini/treadmill (Python/Node, LifeSpan BLE control)
//       https://github.com/brandonarbini/treadmill
//   • daeken/lifespan.py (UART + BLE gist, earliest reversal)
//       https://gist.github.com/daeken/a3d3c4da11ca1c2d2b84
//   • lostmsu/LifeSpan.cs (C# gist, keep-alive approach)
//       https://gist.github.com/lostmsu/1b0d4a33e5ca2418c2b52797eb720ec7
//
// Affected models (BLE-capable):
//   TR1200-DT3 (2018+), TR1200-DT5, TR1200-DT7, TR5000-DT3 (2018+),
//   TR5000-DT5, TR5000-DT7, TR5500 series.
//   Older TR1200-DT / TR5500-DT units used a wired UART console (4800 baud,
//   TTL 5 V) — no BLE.
//
// BLE GATT layout (TR1200-DT3 and later, from brandonarbini / treadspan):
//   The console contains the BLE module.  The console must be powered (plugged
//   in) for BLE to be available.
//
//   Service (primary)    : 0000fff0-0000-1000-8000-00805f9b34fb  (proprietary)
//     Char data/notify   : 0000fff1-0000-1000-8000-00805f9b34fb  (NOTIFY)
//     Char command/write : 0000fff2-0000-1000-8000-00805f9b34fb  (WRITE)
//
//   Note: Some firmware revisions use 128-bit UUIDs in a different base.
//   If the FFF0 service is not found, fall back to scanning for a service
//   whose UUID starts with "0000fff0".
//
// Keep-alive requirement:
//   The console disconnects if it does not receive a message within ~2 s.
//   Drivers must send a keep-alive packet on a timer while connected.
//   The keep-alive byte sequence (from lostmsu) is: [0xf5, 0x00, 0x00, 0xf5]
//   (identical to the standard "ping" packet used by the LifeSpan Fit app).
//
// Command framing (from brandonarbini + daeken):
//   [START, CMD, PARAM_HI, PARAM_LO, CHECKSUM]
//   START     : 0xf5
//   CMD       : see below
//   CHECKSUM  : (CMD + PARAM_HI + PARAM_LO) % 256
//
// Known command bytes (CMD):
//   0x01  — Set speed   PARAM = speed in 0.1 mph (US units); convert from km/h
//   0x02  — Start belt
//   0x03  — Stop belt
//   0x04  — Get status  (poll)
//   0x05  — Keep-alive  (params 0x00 0x00)
//
// Status response format (from notify char):
//   Byte 0  : 0xf5 header echo
//   Byte 1  : CMD echo
//   Byte 2  : speed (0.1 mph)
//   Byte 3  : incline (0 for desk models)
//   Byte 4  : steps lo
//   Byte 5  : steps hi   → steps = (hi << 8) | lo
//   Byte 6  : distance lo (0.01 miles)
//   Byte 7  : distance hi
//   Byte 8  : calories lo
//   Byte 9  : calories hi
//   Byte 10 : elapsed time (minutes)
//   Byte 11 : checksum
//
// Speed conversion:
//   The LifeSpan protocol uses 0.1 mph increments internally.
//   1 km/h ≈ 0.621371 mph → multiply kmh by 6.21371 to get 0.1-mph ticks.
//   Minimum speed typically 0.8 km/h (0.5 mph); maximum varies by model.
//
// CAUTION: The exact byte layout above is synthesised from multiple community
// reversals and may have minor variations across firmware versions.  Validate
// with a BLE sniffer against the official LifeSpan Fit app before shipping.
// =============================================================================

import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'abstract_treadmill_device.dart';
import 'treadmill_device.dart';

/// Abstract driver for BLE-capable LifeSpan desk treadmills.
///
/// Provides shared constants, framing helpers, keep-alive timer, and a
/// default status parser.  Model-specific subclasses may tighten the speed
/// range clamping.
abstract class LifeSpanDevice extends AbstractTreadmillDevice {
  LifeSpanDevice({
    required super.device,
    required super.model,
    super.firmwareVersion,
  }) : super(make: TreadmillMake.lifeSpan);

  // ---- GATT UUID constants ------------------------------------------------

  static const String serviceUuid =
      '0000fff0-0000-1000-8000-00805f9b34fb';

  /// Notification characteristic — device pushes status here.
  static const String rxCharUuid =
      '0000fff1-0000-1000-8000-00805f9b34fb';

  /// Write characteristic — send commands here.
  static const String txCharUuid =
      '0000fff2-0000-1000-8000-00805f9b34fb';

  // ---- Protocol constants -------------------------------------------------

  static const int _frameStart = 0xf5;

  static const int _cmdSetSpeed   = 0x01;
  static const int _cmdStart      = 0x02;
  static const int _cmdStop       = 0x03;
  static const int _cmdGetStatus  = 0x04;
  static const int _cmdKeepAlive  = 0x05;

  // Keep-alive interval — must be < 2 s to prevent console auto-disconnect.
  static const Duration _keepAliveInterval = Duration(milliseconds: 1500);

  // Speed limits (km/h) — model-specific subclasses should override.
  double get minSpeedKmh => 0.8;
  double get maxSpeedKmh => 6.4; // 4.0 mph, typical desk model cap

  // ---- Internal state -----------------------------------------------------

  BluetoothCharacteristic? _txChar;
  BluetoothCharacteristic? _rxChar;
  StreamSubscription<List<int>>? _notifySubscription;
  Timer? _keepAliveTimer;
  _LifeSpanStatus _lastStatus = const _LifeSpanStatus();

  // ---- Lifecycle ----------------------------------------------------------

  @override
  Future<void> onConnected() async {
    final service = await findService(serviceUuid);
    if (service == null) {
      throw StateError(
        'LifeSpan service $serviceUuid not found on device $deviceId',
      );
    }
    _txChar = findCharacteristic(service, txCharUuid);
    _rxChar = findCharacteristic(service, rxCharUuid);

    if (_txChar == null || _rxChar == null) {
      throw StateError(
        'LifeSpan TX/RX characteristics not found on device $deviceId',
      );
    }

    await _rxChar!.setNotifyValue(true);
    _notifySubscription =
        _rxChar!.lastValueStream.listen(_handleNotification);

    // Start keep-alive pings.
    _keepAliveTimer = Timer.periodic(_keepAliveInterval, (_) => _sendKeepAlive());
  }

  @override
  Future<void> disconnect() async {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
    await _notifySubscription?.cancel();
    _notifySubscription = null;
    await super.disconnect();
  }

  // ---- Packet builder -----------------------------------------------------

  List<int> _buildPacket(int cmd, int paramHi, int paramLo) {
    final checksum = (cmd + paramHi + paramLo) % 256;
    return [_frameStart, cmd, paramHi, paramLo, checksum];
  }

  Future<void> _sendRaw(int cmd, int paramHi, int paramLo) async {
    if (_txChar == null) return;
    await writeCharacteristic(_txChar!, _buildPacket(cmd, paramHi, paramLo));
  }

  Future<void> _sendKeepAlive() => _sendRaw(_cmdKeepAlive, 0x00, 0x00);

  // ---- Notification handler -----------------------------------------------

  void _handleNotification(List<int> data) {
    if (data.length < 12 || data[0] != _frameStart) return;
    _lastStatus = _LifeSpanStatus.fromBytes(data);
  }

  // ---- TreadmillDevice implementation ------------------------------------

  @override
  Future<void> setSpeed(double kmh) async {
    // LifeSpan uses 0.1 mph increments.
    final clampedKmh = kmh.clamp(minSpeedKmh, maxSpeedKmh);
    final tenthsMph = (clampedKmh * 6.21371).round(); // 1 km/h = ~6.21 0.1-mph ticks
    final hi = (tenthsMph >> 8) & 0xff;
    final lo = tenthsMph & 0xff;
    await _sendRaw(_cmdSetSpeed, hi, lo);
  }

  @override
  Future<double> getSpeed() async {
    await _sendRaw(_cmdGetStatus, 0x00, 0x00);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _lastStatus.speedKmh;
  }

  @override
  Future<int> getSteps() async {
    await _sendRaw(_cmdGetStatus, 0x00, 0x00);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _lastStatus.steps;
  }

  @override
  Future<double> getCalories() async {
    await _sendRaw(_cmdGetStatus, 0x00, 0x00);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _lastStatus.caloriesKcal;
  }

  @override
  Future<Duration> getSessionDuration() async {
    await _sendRaw(_cmdGetStatus, 0x00, 0x00);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _lastStatus.elapsed;
  }

  // ---- Start / stop (convenience, not in TreadmillDevice interface) -------

  /// Command the belt to start moving.
  Future<void> startBelt() => _sendRaw(_cmdStart, 0x00, 0x00);

  /// Command the belt to stop.
  Future<void> stopBelt() => _sendRaw(_cmdStop, 0x00, 0x00);

  /// Most recent polled status snapshot as raw speed (km/h), steps, calories,
  /// and elapsed duration.  Access individual fields via the returned record.
  ({double speedKmh, int steps, double caloriesKcal, Duration elapsed})
      get lastStatusSnapshot => (
            speedKmh: _lastStatus.speedKmh,
            steps: _lastStatus.steps,
            caloriesKcal: _lastStatus.caloriesKcal,
            elapsed: _lastStatus.elapsed,
          );
}

// ---------------------------------------------------------------------------
// Internal status snapshot
// ---------------------------------------------------------------------------

class _LifeSpanStatus {
  const _LifeSpanStatus({
    this.speedKmh = 0.0,
    this.steps = 0,
    this.distanceMiles = 0.0,
    this.caloriesKcal = 0.0,
    this.elapsed = Duration.zero,
  });

  final double speedKmh;
  final int steps;
  final double distanceMiles;
  final double caloriesKcal;
  final Duration elapsed;

  /// Parse a raw LifeSpan status notification.
  ///
  /// Byte layout (synthesised from daeken / brandonarbini / lostmsu):
  ///   [0] 0xf5 header
  ///   [1] CMD echo
  ///   [2] speed (0.1 mph)
  ///   [3] incline (0 for desk models)
  ///   [4] steps lo, [5] steps hi
  ///   [6] distance lo (0.01 miles), [7] distance hi
  ///   [8] calories lo, [9] calories hi
  ///   [10] elapsed minutes
  ///   [11] checksum
  factory _LifeSpanStatus.fromBytes(List<int> d) {
    if (d.length < 12) return const _LifeSpanStatus();
    final speedTenthsMph = d[2];
    final speedKmh = speedTenthsMph / 10.0 * 1.60934; // convert mph → km/h
    final steps = (d[5] << 8) | d[4];
    final distanceMiles = ((d[7] << 8) | d[6]) / 100.0;
    final calories = ((d[9] << 8) | d[8]).toDouble();
    final elapsedMin = d[10];
    return _LifeSpanStatus(
      speedKmh:      speedKmh,
      steps:         steps,
      distanceMiles: distanceMiles,
      caloriesKcal:  calories,
      elapsed:       Duration(minutes: elapsedMin),
    );
  }
}
