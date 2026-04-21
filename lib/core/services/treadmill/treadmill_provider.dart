// =============================================================================
// treadmill_provider.dart
// =============================================================================
// Riverpod state management for the active treadmill connection.
//
// Exposes:
//   • [treadmillProvider]  — StateNotifierProvider<TreadmillNotifier, TreadmillState>
//   • [activeTreadmillProvider] — the currently connected TreadmillDevice (or null)
//   • [treadmillScanResultsProvider] — stream of BLE scan results filtered to
//     supported treadmill devices
// =============================================================================

import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'treadmill_device.dart';
import 'treadmill_registry.dart';

// ---------------------------------------------------------------------------
// Scan results provider
// ---------------------------------------------------------------------------

/// Stream of [ScanResult]s that match a known treadmill model.
///
/// Filters the raw flutter_blue_plus scan stream through [TreadmillRegistry].
/// UI layers can listen to this to populate a device-picker list.
final treadmillScanResultsProvider =
    StreamProvider.autoDispose<List<TreadmillScanResult>>((ref) async* {
  // flutter_blue_plus accumulates results; re-emit whenever the list changes.
  await for (final results in FlutterBluePlus.scanResults) {
    final matched = results
        .map((r) {
          final model = TreadmillRegistry.modelForDevice(
            deviceName: r.device.platformName,
            serviceUuids: r.advertisementData.serviceUuids
                .map((u) => u.toString())
                .toList(),
          );
          if (model == null) return null;
          return TreadmillScanResult(scanResult: r, model: model);
        })
        .whereType<TreadmillScanResult>()
        .toList();
    yield matched;
  }
});

// ---------------------------------------------------------------------------
// Active treadmill provider
// ---------------------------------------------------------------------------

/// The [TreadmillDevice] that is currently connected (or `null`).
///
/// Derived from [treadmillProvider] state; exposed separately so UI widgets
/// that only need the device reference don't have to pattern-match the state.
final activeTreadmillProvider = Provider.autoDispose<TreadmillDevice?>((ref) {
  final notifier = ref.watch(treadmillProvider.notifier);
  return notifier.activeDevice;
});

// ---------------------------------------------------------------------------
// TreadmillNotifier + provider
// ---------------------------------------------------------------------------

/// The primary Riverpod provider for treadmill state.
final treadmillProvider =
    StateNotifierProvider<TreadmillNotifier, TreadmillState>(
  (ref) => TreadmillNotifier(),
);

/// Manages the lifecycle of the active [TreadmillDevice].
///
/// Call [scan], [connect], and [disconnect] from UI / feature layers.
class TreadmillNotifier extends StateNotifier<TreadmillState> {
  TreadmillNotifier() : super(const TreadmillDisconnected());

  TreadmillDevice? _activeDevice;
  StreamSubscription<TreadmillState>? _deviceStateSub;

  /// The currently held device reference (may be null or not yet connected).
  TreadmillDevice? get activeDevice => _activeDevice;

  // ---- Scan ---------------------------------------------------------------

  /// Start a BLE scan for supported treadmill devices.
  ///
  /// Scan results are available via [treadmillScanResultsProvider].
  /// Stops any ongoing scan before starting a new one.
  ///
  /// [timeout] defaults to 10 s; pass `null` for an indefinite scan
  /// (remember to call [stopScan] manually).
  Future<void> scan({Duration timeout = const Duration(seconds: 10)}) async {
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    // Advertise all vendor-specific service UUIDs we know about so the OS
    // can filter on hardware level (improves battery life on iOS/Android).
    // Leave empty to catch everything (noisier but safer during development).
    await FlutterBluePlus.startScan(timeout: timeout);
  }

  /// Stop an ongoing BLE scan.
  Future<void> stopScan() => FlutterBluePlus.stopScan();

  // ---- Connect ------------------------------------------------------------

  /// Connect to [device].
  ///
  /// Disconnects from any currently active device first.
  /// The notifier's [state] mirrors the device's [stateStream].
  Future<void> connect(TreadmillDevice device) async {
    if (_activeDevice != null) {
      await disconnect();
    }

    _activeDevice = device;

    // Mirror device state into this notifier's state.
    _deviceStateSub = device.stateStream.listen(
      (s) => state = s,
      onError: (Object e) => state = TreadmillError(e.toString()),
    );

    await device.connect();
  }

  // ---- Disconnect ---------------------------------------------------------

  /// Disconnect from the active device and clear it.
  Future<void> disconnect() async {
    await _deviceStateSub?.cancel();
    _deviceStateSub = null;

    await _activeDevice?.disconnect();
    _activeDevice = null;

    state = const TreadmillDisconnected();
  }

  // ---- Cleanup ------------------------------------------------------------

  @override
  void dispose() {
    _deviceStateSub?.cancel();
    // Do not await here; dispose() is synchronous in Riverpod.
    _activeDevice?.disconnect();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Helper data class
// ---------------------------------------------------------------------------

/// A BLE scan result paired with the [TreadmillModel] the registry matched.
class TreadmillScanResult {
  const TreadmillScanResult({
    required this.scanResult,
    required this.model,
  });

  final ScanResult scanResult;
  final TreadmillModel model;

  BluetoothDevice get device => scanResult.device;
  String get deviceName => scanResult.device.platformName;
  int get rssi => scanResult.rssi;
}
