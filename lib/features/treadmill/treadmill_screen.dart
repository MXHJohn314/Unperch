import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unperch/core/services/treadmill/treadmill_device.dart';
import 'package:unperch/core/services/treadmill/treadmill_provider.dart';
import 'package:unperch/core/services/treadmill/treadmill_registry.dart';

// ---------------------------------------------------------------------------
// Treadmill Device Screen
// ---------------------------------------------------------------------------

/// Manages BLE treadmill scanning, connecting, and live session stats display.
class TreadmillScreen extends ConsumerStatefulWidget {
  const TreadmillScreen({super.key});

  @override
  ConsumerState<TreadmillScreen> createState() => _TreadmillScreenState();
}

class _TreadmillScreenState extends ConsumerState<TreadmillScreen> {
  // --- Session stats (refreshed periodically when connected) ---
  double _currentSpeed = 0.0;
  int _sessionSteps = 0;
  double _sessionCalories = 0.0;
  Duration _sessionDuration = Duration.zero;
  Timer? _statsTimer;

  // --- Speed slider value ---
  double _sliderSpeed = 1.0;
  bool _isRunning = false;

  @override
  void dispose() {
    _statsTimer?.cancel();
    super.dispose();
  }

  void _startStatsPolling(TreadmillDevice device) {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted) return;
      final speed = await device.getSpeed();
      final steps = await device.getSteps();
      final calories = await device.getCalories();
      final duration = await device.getSessionDuration();
      if (mounted) {
        setState(() {
          _currentSpeed = speed;
          _sessionSteps = steps;
          _sessionCalories = calories;
          _sessionDuration = duration;
        });
      }
    });
  }

  void _stopStatsPolling() {
    _statsTimer?.cancel();
    _statsTimer = null;
  }

  Future<void> _scan() async {
    await ref.read(treadmillProvider.notifier).scan();
  }

  Future<void> _connect(TreadmillScanResult result) async {
    final treadmillDevice =
        TreadmillRegistry.create(result.model, result.device);
    await ref.read(treadmillProvider.notifier).connect(treadmillDevice);
    _startStatsPolling(treadmillDevice);
  }

  Future<void> _disconnect() async {
    _stopStatsPolling();
    await ref.read(treadmillProvider.notifier).disconnect();
    if (mounted) {
      setState(() {
        _currentSpeed = 0.0;
        _sessionSteps = 0;
        _sessionCalories = 0.0;
        _sessionDuration = Duration.zero;
        _sliderSpeed = 1.0;
        _isRunning = false;
      });
    }
  }

  Future<void> _setSpeed(double kmh) async {
    final device = ref.read(activeTreadmillProvider);
    if (device == null) return;
    await device.setSpeed(kmh);
    setState(() => _sliderSpeed = kmh);
  }

  Future<void> _toggleStartStop() async {
    final device = ref.read(activeTreadmillProvider);
    if (device == null) return;
    if (_isRunning) {
      await device.setSpeed(0.0);
      setState(() {
        _isRunning = false;
        _currentSpeed = 0.0;
      });
    } else {
      await device.setSpeed(_sliderSpeed);
      setState(() => _isRunning = true);
    }
  }

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final treadmillState = ref.watch(treadmillProvider);
    final activeDevice = ref.watch(activeTreadmillProvider);

    // Begin polling whenever we observe a transition to connected.
    if (treadmillState is TreadmillConnected &&
        activeDevice != null &&
        _statsTimer == null) {
      _startStatsPolling(activeDevice);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Treadmill')),
      body: switch (treadmillState) {
        TreadmillConnected() => _buildConnected(activeDevice!),
        TreadmillConnecting() => _buildConnecting(activeDevice?.displayName),
        TreadmillError(:final message) => _buildError(message),
        TreadmillDisconnected() => _buildDisconnected(),
      },
    );
  }

  // ---------------------------------------------------------------------------
  // State A: Disconnected / scanning
  // ---------------------------------------------------------------------------

  Widget _buildDisconnected() {
    final scanAsync = ref.watch(treadmillScanResultsProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_walk, size: 80),
            const SizedBox(height: 16),
            Text(
              'No treadmill connected',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _scan,
              icon: const Icon(Icons.bluetooth_searching),
              label: const Text('Scan for devices'),
            ),
            const SizedBox(height: 24),
            scanAsync.when(
              data: (results) {
                if (results.isEmpty) {
                  return const Text(
                    'No supported devices found nearby.',
                    textAlign: TextAlign.center,
                  );
                }
                return SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, i) => _ScanResultTile(
                      result: results[i],
                      onConnect: _connect,
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text('Scan error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // State B: Connecting
  // ---------------------------------------------------------------------------

  Widget _buildConnecting(String? name) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Connecting to ${name ?? 'device'}…',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _disconnect,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // State C: Connected
  // ---------------------------------------------------------------------------

  Widget _buildConnected(TreadmillDevice device) {
    final info = device.deviceInfo;
    final makeName = info.make.name;
    final modelName = info.model.name;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device name + model chip
          Row(
            children: [
              Expanded(
                child: Text(
                  device.displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Chip(
                label: Text('$makeName / $modelName'),
                avatar: const Icon(Icons.bluetooth_connected, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2x2 stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _StatCard(
                label: 'Current Speed',
                value: '${_currentSpeed.toStringAsFixed(1)} km/h',
                icon: Icons.speed,
              ),
              _StatCard(
                label: 'Session Steps',
                value: '$_sessionSteps',
                icon: Icons.directions_walk,
              ),
              _StatCard(
                label: 'Session Calories',
                value: '${_sessionCalories.toStringAsFixed(0)} kcal',
                icon: Icons.local_fire_department,
              ),
              _StatCard(
                label: 'Duration',
                value: _formatDuration(_sessionDuration),
                icon: Icons.timer_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Speed control
          Text(
            'Speed: ${_sliderSpeed.toStringAsFixed(1)} km/h',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Slider(
            value: _sliderSpeed,
            min: 0.5,
            max: 6.0,
            divisions: 11,
            label: '${_sliderSpeed.toStringAsFixed(1)} km/h',
            onChanged: (v) => setState(() => _sliderSpeed = v),
            onChangeEnd: _setSpeed,
          ),
          const SizedBox(height: 8),
          Center(
            child: FilledButton.icon(
              onPressed: _toggleStartStop,
              icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
              label: Text(_isRunning ? 'Stop' : 'Start'),
            ),
          ),
          const SizedBox(height: 32),

          // Disconnect
          Center(
            child: OutlinedButton.icon(
              onPressed: _disconnect,
              icon: const Icon(Icons.bluetooth_disabled),
              label: const Text('Disconnect'),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error state
  // ---------------------------------------------------------------------------

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Connection error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _disconnect,
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scan result tile
// ---------------------------------------------------------------------------

class _ScanResultTile extends StatelessWidget {
  const _ScanResultTile({
    required this.result,
    required this.onConnect,
  });

  final TreadmillScanResult result;
  final Future<void> Function(TreadmillScanResult) onConnect;

  IconData _rssiIcon(int rssi) {
    if (rssi >= -60) return Icons.signal_wifi_4_bar;
    if (rssi >= -75) return Icons.network_wifi_3_bar;
    if (rssi >= -85) return Icons.network_wifi_2_bar;
    return Icons.network_wifi_1_bar;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_rssiIcon(result.rssi)),
      title: Text(
        result.deviceName.isNotEmpty ? result.deviceName : 'Unknown device',
      ),
      subtitle: Text('${result.model.name} · ${result.rssi} dBm'),
      trailing: FilledButton.tonal(
        onPressed: () => onConnect(result),
        child: const Text('Connect'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats card
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
