import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:unperch/core/datastore/unperch_datastore.dart';

// ---------------------------------------------------------------------------
// TtsService
// ---------------------------------------------------------------------------

/// Thin wrapper around [FlutterTts] that reads initial settings from
/// [UnperchDataStore] and exposes a simple speak / stop / config API.
class TtsService {
  TtsService._(this._tts);

  final FlutterTts _tts;

  // -------------------------------------------------------------------------
  // Factory constructor — initialises from DataStore prefs
  // -------------------------------------------------------------------------

  /// Creates and initialises a [TtsService] using preferences stored in [store].
  static Future<TtsService> create(UnperchDataStore store) async {
    final tts = FlutterTts();

    await tts.setVolume(1.0);
    await tts.setSpeechRate(store.ttsSpeed);
    await tts.setPitch(store.ttsPitch);

    if (store.ttsVoice != null) {
      // flutter_tts setVoice expects a Map<String, String> on some platforms;
      // on others a plain string is fine.  We store the voice *name* and pass
      // it to both APIs so either platform accepts it.
      try {
        await tts.setVoice({'name': store.ttsVoice!, 'locale': ''});
      } catch (_) {
        // Ignore: platform may not support setVoice at init time.
      }
    }

    return TtsService._(tts);
  }

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Stops any in-progress speech, then speaks [text].
  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Stops any in-progress speech immediately.
  Future<void> stop() => _tts.stop();

  /// Sets the TTS voice by name.  Pass [null] to reset to the platform default.
  Future<void> setVoice(String? voice) async {
    if (voice == null) return;
    try {
      await _tts.setVoice({'name': voice, 'locale': ''});
    } catch (_) {
      // Some platforms require a locale — silently ignore unsupported calls.
    }
  }

  /// Sets the speech rate multiplier (1.0 = normal speed).
  Future<void> setSpeed(double speed) => _tts.setSpeechRate(speed);

  /// Sets the pitch multiplier (1.0 = normal pitch).
  Future<void> setPitch(double pitch) => _tts.setPitch(pitch);

  /// Returns the display names of all available voices on this device.
  Future<List<String>> availableVoices() async {
    final raw = await _tts.getVoices;
    if (raw == null) return [];
    // flutter_tts returns List<dynamic> where each item is either a Map or a
    // plain String depending on platform.
    final voices = <String>[];
    for (final item in raw) {
      if (item is Map) {
        final name = item['name'];
        if (name is String && name.isNotEmpty) voices.add(name);
      } else if (item is String && item.isNotEmpty) {
        voices.add(item);
      }
    }
    return voices;
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Synchronous [Provider] for [TtsService].
///
/// Override this in your [ProviderScope] with an already-resolved instance,
/// analogous to [unperchDataStoreProvider]:
///
/// ```dart
/// final tts = await TtsService.create(store);
/// ProviderScope(
///   overrides: [ttsServiceProvider.overrideWithValue(tts)],
///   child: const UnperchApp(),
/// );
/// ```
final ttsServiceProvider = Provider<TtsService>((ref) {
  throw UnimplementedError(
    'ttsServiceProvider must be overridden in ProviderScope. '
    'Call TtsService.create(store) at app startup and supply the result.',
  );
});
