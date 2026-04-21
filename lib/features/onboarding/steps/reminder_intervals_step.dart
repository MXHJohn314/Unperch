import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unperch/core/datastore/unperch_datastore.dart';

class ReminderIntervalsStep extends ConsumerStatefulWidget {
  const ReminderIntervalsStep({super.key});

  @override
  ConsumerState<ReminderIntervalsStep> createState() =>
      _ReminderIntervalsStepState();
}

class _ReminderIntervalsStepState
    extends ConsumerState<ReminderIntervalsStep> {
  late double _waterInterval;
  late double _exerciseInterval;

  @override
  void initState() {
    super.initState();
    final store = ref.read(unperchDataStoreProvider);
    _waterInterval = store.waterIntervalMinutes.toDouble();
    _exerciseInterval = store.exerciseIntervalMinutes.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How often should we check in?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Set the interval between each type of reminder.',
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
                  _IntervalSlider(
                    icon: Icons.water_drop_outlined,
                    label: 'Water reminder',
                    value: _waterInterval,
                    onChanged: (v) => setState(() => _waterInterval = v),
                    onChangeEnd: (v) async {
                      final store = ref.read(unperchDataStoreProvider);
                      await store.setWaterIntervalMinutes(v.round());
                    },
                  ),
                  const Divider(height: 32),
                  _IntervalSlider(
                    icon: Icons.directions_run,
                    label: 'Exercise reminder',
                    value: _exerciseInterval,
                    onChanged: (v) => setState(() => _exerciseInterval = v),
                    onChangeEnd: (v) async {
                      final store = ref.read(unperchDataStoreProvider);
                      await store.setExerciseIntervalMinutes(v.round());
                    },
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

class _IntervalSlider extends StatelessWidget {
  const _IntervalSlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final IconData icon;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final rounded = value.round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
        Slider(
          value: value,
          min: 15,
          max: 120,
          divisions: 7, // (120-15)/15 = 7 steps
          label: '$rounded min',
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Every $rounded minutes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}
