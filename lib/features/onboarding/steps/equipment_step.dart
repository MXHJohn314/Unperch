import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unperch/core/datastore/unperch_datastore.dart';
import 'package:unperch/core/enums/enums.dart';

class EquipmentStep extends ConsumerStatefulWidget {
  const EquipmentStep({super.key});

  @override
  ConsumerState<EquipmentStep> createState() => _EquipmentStepState();
}

class _EquipmentStepState extends ConsumerState<EquipmentStep> {
  late Set<EquipmentTag> _equipped;

  static const _optional = [
    EquipmentTag.kettlebell,
    EquipmentTag.dumbbell,
    EquipmentTag.resistanceBand,
    EquipmentTag.weightedVest,
    EquipmentTag.treadmill,
  ];

  static const _labels = {
    EquipmentTag.bodyweight: 'Bodyweight',
    EquipmentTag.kettlebell: 'Kettlebell',
    EquipmentTag.dumbbell: 'Dumbbell',
    EquipmentTag.resistanceBand: 'Resistance Band',
    EquipmentTag.weightedVest: 'Weighted Vest',
    EquipmentTag.treadmill: 'Under-desk Treadmill',
  };

  static const _icons = {
    EquipmentTag.bodyweight: Icons.accessibility_new,
    EquipmentTag.kettlebell: Icons.fitness_center,
    EquipmentTag.dumbbell: Icons.fitness_center,
    EquipmentTag.resistanceBand: Icons.sports_gymnastics,
    EquipmentTag.weightedVest: Icons.checkroom,
    EquipmentTag.treadmill: Icons.directions_walk,
  };

  @override
  void initState() {
    super.initState();
    _equipped = Set.of(ref.read(unperchDataStoreProvider).equippedItems)
      ..add(EquipmentTag.bodyweight);
  }

  Future<void> _toggle(EquipmentTag tag) async {
    final next = Set.of(_equipped);
    if (next.contains(tag)) {
      next.remove(tag);
    } else {
      next.add(tag);
    }
    next.add(EquipmentTag.bodyweight); // always present
    setState(() => _equipped = next);
    await ref.read(unperchDataStoreProvider).setEquippedItems(next);
  }

  Widget _buildTile(EquipmentTag tag, {required bool disabled}) {
    final isChecked = _equipped.contains(tag);
    return CheckboxListTile(
      value: isChecked,
      title: Text(_labels[tag]!),
      secondary: Icon(
        _icons[tag],
        color: disabled ? Theme.of(context).disabledColor : null,
      ),
      enabled: !disabled,
      onChanged: disabled ? null : (_) => _toggle(tag),
    );
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
            'What equipment do you have?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Exercises will be tailored to what you have available.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                _buildTile(EquipmentTag.bodyweight, disabled: true),
                const Divider(height: 1),
                ..._optional.expand((tag) => [
                      _buildTile(tag, disabled: false),
                      if (tag != _optional.last) const Divider(height: 1),
                    ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
