// =============================================================================
// abstract_treadmill_device.dart
// =============================================================================
// Shared BLE scaffolding for all treadmill drivers.
//
// Every brand-specific abstract class (WalkingPadDevice, LifeSpanDevice, …)
// extends this class.  It owns the flutter_blue_plus [BluetoothDevice]
// reference, manages connection-state transitions, and provides low-level
// GATT read/write helpers.
// =============================================================================

import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'treadmill_device.dart';

/// Shared BLE scaffolding that all concrete treadmill drivers inherit.
///
/// Sub-classes must:
///   1. Expose BLE GATT UUID constants as `static const` fields.
///   2. Implement [setSpeed], [getSpeed], [getSteps], [getCalories], and
///      [getSessionDuration].
///   3. Optionally override [onConnected] to perform device-specific
///      post-connection setup (subscribe to notify characteristics, etc.).
abstract class AbstractTreadmillDevice implements TreadmillDevice {
  AbstractTreadmillDevice({
    required BluetoothDevice device,
    required TreadmillMake make,
    required TreadmillModel model,
    String? firmwareVersion,
  })  : _device = device,
        _make = make,
        _model = model,
        _firmwareVersion = firmwareVersion,
        _stateController = StreamController<TreadmillState>.broadcast() {
    // Seed the stream with the initial disconnected state so that first
    // listeners receive a value immediately.
    _currentState = const TreadmillDisconnected();

    // Mirror flutter_blue_plus connection-state changes into our sealed type.
    _connectionSubscription = device.connectionState.listen(
      _onFbpConnectionState,
      onError: (Object e) => _emitState(TreadmillError(e.toString())),
    );
  }

  // ---- Private fields -----------------------------------------------------

  final BluetoothDevice _device;
  final TreadmillMake _make;
  final TreadmillModel _model;
  final String? _firmwareVersion;
  final StreamController<TreadmillState> _stateController;
  late TreadmillState _currentState;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  // ---- TreadmillDevice identity -------------------------------------------

  @override
  String get deviceId => _device.remoteId.str;

  @override
  String get displayName => _device.platformName.isNotEmpty
      ? _device.platformName
      : '${_make.name} ($deviceId)';

  @override
  TreadmillMake get make => _make;

  @override
  TreadmillModel get model => _model;

  @override
  TreadmillDeviceInfo get deviceInfo => TreadmillDeviceInfo(
        make: _make,
        model: _model,
        firmwareVersion: _firmwareVersion,
        macAddress: deviceId,
      );

  // ---- State stream -------------------------------------------------------

  @override
  Stream<TreadmillState> get stateStream => _stateController.stream;

  /// The most-recently emitted state.
  TreadmillState get currentState => _currentState;

  // ---- Connection lifecycle -----------------------------------------------

  @override
  Future<void> connect() async {
    if (_currentState is TreadmillConnected ||
        _currentState is TreadmillConnecting) {
      return;
    }
    _emitState(const TreadmillConnecting());
    try {
      await _device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );
      // onConnected() is called by _onFbpConnectionState when flutter_blue_plus
      // reports BluetoothConnectionState.connected.
    } catch (e) {
      _emitState(TreadmillError('connect() failed: $e'));
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _device.disconnect();
    } catch (_) {
      // Ignore errors during a deliberate disconnect.
    }
    // State will be updated by _onFbpConnectionState.
  }

  /// Called once after a successful BLE connection and GATT discovery.
  ///
  /// Override in brand-specific classes to subscribe to notify characteristics
  /// or perform any other device-specific initialisation.
  Future<void> onConnected() async {}

  // ---- Protected GATT helpers ---------------------------------------------

  /// Write [bytes] to [characteristic] without waiting for a response.
  ///
  /// Uses `WriteType.withoutResponse` by default, which matches most
  /// proprietary treadmill protocols.  Pass [withResponse] = `true` for
  /// characteristics that require a GATT write-with-response.
  Future<void> writeCharacteristic(
    BluetoothCharacteristic characteristic,
    List<int> bytes, {
    bool withResponse = false,
  }) async {
    _assertConnected('writeCharacteristic');
    await characteristic.write(
      bytes,
      withoutResponse: !withResponse,
    );
  }

  /// Read the current value of [characteristic] and return the raw byte list.
  Future<List<int>> readCharacteristic(
    BluetoothCharacteristic characteristic,
  ) async {
    _assertConnected('readCharacteristic');
    return characteristic.read();
  }

  /// Discover services on the connected device and return the full list.
  ///
  /// Results are cached by flutter_blue_plus after the first call.
  Future<List<BluetoothService>> discoverServices() async {
    _assertConnected('discoverServices');
    return _device.discoverServices();
  }

  /// Find a service by its UUID string (case-insensitive).
  ///
  /// Returns `null` if the service is not found rather than throwing, so
  /// callers can emit a descriptive [TreadmillError].
  Future<BluetoothService?> findService(String uuidString) async {
    final services = await discoverServices();
    final target = uuidString.toLowerCase();
    for (final s in services) {
      if (s.uuid.toString().toLowerCase() == target) return s;
    }
    return null;
  }

  /// Find a characteristic by UUID within a given service.
  BluetoothCharacteristic? findCharacteristic(
    BluetoothService service,
    String uuidString,
  ) {
    final target = uuidString.toLowerCase();
    for (final c in service.characteristics) {
      if (c.uuid.toString().toLowerCase() == target) return c;
    }
    return null;
  }

  // ---- Abstract telemetry / control (brand-specific) ----------------------

  @override
  Future<void> setSpeed(double kmh);

  @override
  Future<double> getSpeed();

  @override
  Future<int> getSteps();

  @override
  Future<double> getCalories();

  @override
  Future<Duration> getSessionDuration();

  // ---- Internal helpers ---------------------------------------------------

  void _emitState(TreadmillState state) {
    _currentState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  Future<void> _onFbpConnectionState(
    BluetoothConnectionState fbpState,
  ) async {
    switch (fbpState) {
      case BluetoothConnectionState.connected:
        try {
          await onConnected();
          _emitState(const TreadmillConnected());
        } catch (e) {
          _emitState(TreadmillError('onConnected() failed: $e'));
        }
      case BluetoothConnectionState.disconnected:
        _emitState(const TreadmillDisconnected());
      // flutter_blue_plus may add more states in future versions; ignore them.
      // ignore: unreachable_switch_case
      default:
        break;
    }
  }

  void _assertConnected(String caller) {
    if (_currentState is! TreadmillConnected) {
      throw StateError(
        '$caller called but device is not connected '
        '(state: $_currentState)',
      );
    }
  }

  /// Release resources.  Call when permanently discarding this driver.
  Future<void> dispose() async {
    await _connectionSubscription?.cancel();
    await _stateController.close();
  }
}
