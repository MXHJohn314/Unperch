import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unperch/core/datastore/unperch_datastore.dart';
import 'package:unperch/core/enums/enums.dart';

class WorkingDaysStep extends ConsumerStatefulWidget {
  const WorkingDaysStep({super.key});

  @override
  ConsumerState<WorkingDaysStep> createState() => _WorkingDaysStepState();
}

class _WorkingDaysStepState extends ConsumerState<WorkingDaysStep> {
  late Set<DayOfWeek> _selected;

  static const _ordered = [
    DayOfWeek.monday,
    DayOfWeek.tuesday,
    DayOfWeek.wednesday,
    DayOfWeek.thursday,
    DayOfWeek.friday,
    DayOfWeek.saturday,
    DayOfWeek.sunday,
  ];

  static const _labels = {
    DayOfWeek.monday: 'Mon',
    DayOfWeek.tuesday: 'Tue',
    DayOfWeek.wednesday: 'Wed',
    DayOfWeek.thursday: 'Thu',
    DayOfWeek.friday: 'Fri',
    DayOfWeek.saturday: 'Sat',
    DayOfWeek.sunday: 'Sun',
  };

  @override
  void initState() {
    super.initState();
    _selected = Set.of(ref.read(unperchDataStoreProvider).workingDays);
  }

  Future<void> _toggle(DayOfWeek day) async {
    final next = Set.of(_selected);
    if (next.contains(day)) {
      if (next.length == 1) return; // enforce min 1
      next.remove(day);
    } else {
      next.add(day);
    }
    setState(() => _selected = next);
    await ref.read(unperchDataStoreProvider).setWorkingDays(next);
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
            'Which days do you work?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Reminders are only sent on your working days.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _ordered.map((day) {
                  final isSelected = _selected.contains(day);
                  return FilterChip(
                    label: Text(_labels[day]!),
                    selected: isSelected,
                    onSelected: (_) => _toggle(day),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
