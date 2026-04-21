// =============================================================================
// treadmill_registry.dart
// =============================================================================
// Maps [TreadmillModel] → factory function that constructs the correct
// [TreadmillDevice] subclass from a [BluetoothDevice].
//
// Usage during BLE scan:
//   1. Call [TreadmillRegistry.modelForDevice] to identify the model from a
//      scan result's advertised name / service UUIDs.
//   2. Call [TreadmillRegistry.create] with the identified model and the
//      [BluetoothDevice] to instantiate the driver.
// =============================================================================

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'i_walk_generic_device.dart';
import 'life_span_tr1200_dt_device.dart';
import 'life_span_tr5500_dt_device.dart';
import 'treadmill_device.dart';
import 'urevo_strol_device.dart';
import 'walking_pad_a1_device.dart';
import 'walking_pad_c2_device.dart';
import 'walking_pad_x21_device.dart';
import 'walkolution_generic_device.dart';

/// Factory signature: given a [BluetoothDevice], produce a [TreadmillDevice].
typedef TreadmillFactory = TreadmillDevice Function(BluetoothDevice device);

/// Registry that maps [TreadmillModel] → [TreadmillFactory].
///
/// This is the single place to update when adding a new model driver.
class TreadmillRegistry {
  TreadmillRegistry._();

  // ---- Factory map --------------------------------------------------------

  static final Map<TreadmillModel, TreadmillFactory> _factories = {
    TreadmillModel.walkingPadA1: (d) => WalkingPadA1Device(device: d),
    TreadmillModel.walkingPadC2: (d) => WalkingPadC2Device(device: d),
    TreadmillModel.walkingPadX21: (d) => WalkingPadX21Device(device: d),
    TreadmillModel.lifeSpanTR1200DT: (d) => LifeSpanTR1200DTDevice(device: d),
    TreadmillModel.lifeSpanTR5500DT: (d) => LifeSpanTR5500DTDevice(device: d),
    TreadmillModel.iWalkGeneric: (d) => IWalkGenericDevice(device: d),
    TreadmillModel.walkolutionGeneric: (d) =>
        WalkolutionGenericDevice(device: d),
    TreadmillModel.urevoStrol: (d) => UrevoStrolDevice(device: d),
  };

  // ---- Name-matching heuristics -------------------------------------------
  //
  // Maps advertised device name substrings (lower-case) to a [TreadmillModel].
  // The first matching entry wins, so more-specific patterns must come first.
  //
  // These heuristics are best-effort — validate against real scan results and
  // tighten patterns as needed.

  static final List<(String nameSubstring, TreadmillModel model)>
      _nameHeuristics = [
    // WalkingPad models — advertise as "WalkingPad" or "KS-ST-A1C" etc.
    ('walkingpad x21',  TreadmillModel.walkingPadX21),
    ('ks-st-x21',       TreadmillModel.walkingPadX21),
    ('walkingpad c2',   TreadmillModel.walkingPadC2),
    ('ks-st-c2',        TreadmillModel.walkingPadC2),
    ('walkingpad a1',   TreadmillModel.walkingPadA1),
    ('ks-st-a1',        TreadmillModel.walkingPadA1),
    // Fallback: any "walkingpad" or "kingsmith" device → A1 driver (safest default)
    ('walkingpad',      TreadmillModel.walkingPadA1),
    ('kingsmith',       TreadmillModel.walkingPadA1),

    // LifeSpan
    ('tr5500',          TreadmillModel.lifeSpanTR5500DT),
    ('tr5000',          TreadmillModel.lifeSpanTR1200DT), // TR5000 shares protocol
    ('tr1200',          TreadmillModel.lifeSpanTR1200DT),
    ('lifespan',        TreadmillModel.lifeSpanTR1200DT),

    // Urevo
    ('urevo',           TreadmillModel.urevoStrol),
    ('strol',           TreadmillModel.urevoStrol),

    // iWalk
    ('iwalk',           TreadmillModel.iWalkGeneric),

    // Walkolution (no BLE — should never appear in scan results, but included
    // so the registry can surface a meaningful error rather than ignoring it)
    ('walkolution',     TreadmillModel.walkolutionGeneric),
  ];

  // ---- Public API ---------------------------------------------------------

  /// Attempt to identify the [TreadmillModel] for a BLE scan result.
  ///
  /// [deviceName] is the advertised peripheral name (case-insensitive).
  /// [serviceUuids] are the UUIDs advertised in the scan record.
  ///
  /// Returns `null` if no match is found (unsupported / unknown device).
  static TreadmillModel? modelForDevice({
    required String deviceName,
    List<String> serviceUuids = const [],
  }) {
    final nameLower = deviceName.toLowerCase();

    // Service-UUID-based matching (more reliable than name strings).
    for (final uuid in serviceUuids) {
      final uuidLower = uuid.toLowerCase();
      if (uuidLower.contains('fe00')) return TreadmillModel.walkingPadA1;
      if (uuidLower.contains('fff0')) {
        // FFF0 is shared by LifeSpan and possibly others — fall through to name
        // matching for disambiguation.
        break;
      }
    }

    // Name substring matching.
    for (final (substring, model) in _nameHeuristics) {
      if (nameLower.contains(substring)) return model;
    }

    return null;
  }

  /// Create a [TreadmillDevice] driver for the given [model] and [device].
  ///
  /// Throws [ArgumentError] if no factory is registered for [model].
  static TreadmillDevice create(TreadmillModel model, BluetoothDevice device) {
    final factory = _factories[model];
    if (factory == null) {
      throw ArgumentError.value(
        model,
        'model',
        'No TreadmillFactory registered for TreadmillModel.$model',
      );
    }
    return factory(device);
  }

  /// Returns `true` if a factory is registered for [model].
  static bool supports(TreadmillModel model) => _factories.containsKey(model);

  /// All models that have a registered factory.
  static Set<TreadmillModel> get supportedModels => _factories.keys.toSet();
}
