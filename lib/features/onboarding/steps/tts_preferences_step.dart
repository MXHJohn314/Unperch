import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:unperch/core/datastore/unperch_datastore.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _flutterTtsProvider = Provider<FlutterTts>((ref) {
  final tts = FlutterTts();
  ref.onDispose(tts.stop);
  return tts;
});

final _availableVoicesProvider = FutureProvider<List<String>>((ref) async {
  final tts = ref.watch(_flutterTtsProvider);
  final raw = await tts.getVoices;
  if (raw == null) return [];
  final voices = <String>[];
  for (final v in raw as List) {
    if (v is Map) {
      final name = v['name']?.toString();
      if (name != null && name.isNotEmpty) voices.add(name);
    }
  }
  return voices;
});

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class TtsPreferencesStep extends ConsumerStatefulWidget {
  const TtsPreferencesStep({super.key});

  @override
  ConsumerState<TtsPreferencesStep> createState() => _TtsPreferencesStepState();
}

class _TtsPreferencesStepState extends ConsumerState<TtsPreferencesStep> {
  late double _speed;
  late double _pitch;
  String? _voice;
  bool _previewing = false;

  @override
  void initState() {
    super.initState();
    final store = ref.read(unperchDataStoreProvider);
    _speed = store.ttsSpeed;
    _pitch = store.ttsPitch;
    _voice = store.ttsVoice;
  }

  Future<void> _preview() async {
    if (_previewing) return;
    setState(() => _previewing = true);
    try {
      final tts = ref.read(_flutterTtsProvider);
      await tts.setSpeechRate(_speed);
      await tts.setPitch(_pitch);
      if (_voice != null) await tts.setVoice({'name': _voice!, 'locale': ''});
      await tts.speak("Time to unperch! Let's do some desk squats.");
    } finally {
      if (mounted) setState(() => _previewing = false);
    }
  }

  Future<void> _setSpeed(double v) async {
    setState(() => _speed = v);
    await ref.read(unperchDataStoreProvider).setTtsSpeed(v);
  }

  Future<void> _setPitch(double v) async {
    setState(() => _pitch = v);
    await ref.read(unperchDataStoreProvider).setTtsPitch(v);
  }

  Future<void> _setVoice(String? v) async {
    setState(() => _voice = v);
    if (v != null) {
      await ref.read(unperchDataStoreProvider).setTtsVoice(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final voicesAsync = ref.watch(_availableVoicesProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How should Unperch sound?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Customize the voice used for reminders.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Voice selector
                  voicesAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    ),
                    error: (_, __) => Text(
                      'Could not load voices.',
                      style: TextStyle(color: colorScheme.error),
                    ),
                    data: (voices) {
                      if (voices.isEmpty) {
                        return Text(
                          'No voices available on this device.',
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      }
                      final effectiveVoice =
                          (_voice != null && voices.contains(_voice))
                              ? _voice
                              : voices.first;
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Voice',
                          border: OutlineInputBorder(),
                        ),
                        value: effectiveVoice,
                        isExpanded: true,
                        items: voices
                            .map((v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(
                                    v,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: _setVoice,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Speed slider
                  Text(
                    'Speech speed',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Slider(
                    value: _speed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: _speed.toStringAsFixed(1),
                    onChanged: (v) => setState(() => _speed = v),
                    onChangeEnd: _setSpeed,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '${_speed.toStringAsFixed(1)}×',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Pitch slider
                  Text(
                    'Pitch',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Slider(
                    value: _pitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: _pitch.toStringAsFixed(1),
                    onChanged: (v) => setState(() => _pitch = v),
                    onChangeEnd: _setPitch,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '${_pitch.toStringAsFixed(1)}×',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Preview button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: _previewing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.volume_up_outlined),
                      label: const Text('Preview'),
                      onPressed: _previewing ? null : _preview,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
