import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unperch/core/datastore/unperch_datastore.dart';

class ShiftHoursStep extends ConsumerStatefulWidget {
  const ShiftHoursStep({super.key});

  @override
  ConsumerState<ShiftHoursStep> createState() => _ShiftHoursStepState();
}

class _ShiftHoursStepState extends ConsumerState<ShiftHoursStep> {
  late int _startMinutes;
  late int _endMinutes;

  @override
  void initState() {
    super.initState();
    final store = ref.read(unperchDataStoreProvider);
    _startMinutes = store.shiftStartMinutes;
    _endMinutes = store.shiftEndMinutes;
  }

  TimeOfDay _minutesToTimeOfDay(int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

  int _timeOfDayToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  String _formatMinutes(int minutes) {
    final t = _minutesToTimeOfDay(minutes);
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = _minutesToTimeOfDay(isStart ? _startMinutes : _endMinutes);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isStart ? 'Shift start' : 'Shift end',
    );
    if (picked == null) return;
    final minutes = _timeOfDayToMinutes(picked);
    final store = ref.read(unperchDataStoreProvider);
    if (isStart) {
      setState(() => _startMinutes = minutes);
      await store.setShiftStartMinutes(minutes);
    } else {
      setState(() => _endMinutes = minutes);
      await store.setShiftEndMinutes(minutes);
    }
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
            'When does your shift start and end?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Reminders will only fire during your shift window.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.wb_sunny_outlined),
                    title: const Text('Shift Start'),
                    subtitle: Text(_formatMinutes(_startMinutes)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _pickTime(isStart: true),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.nights_stay_outlined),
                    title: const Text('Shift End'),
                    subtitle: Text(_formatMinutes(_endMinutes)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _pickTime(isStart: false),
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
