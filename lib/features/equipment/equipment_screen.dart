import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unperch/core/datastore/unperch_datastore.dart';
import 'package:unperch/core/enums/enums.dart';

// ---------------------------------------------------------------------------
// Equipment Checklist Screen
// ---------------------------------------------------------------------------

/// Persistent equipment checklist — allows the user to update which equipment
/// they have available at their workstation at any time (not just onboarding).
class EquipmentScreen extends ConsumerStatefulWidget {
  const EquipmentScreen({super.key});

  @override
  ConsumerState<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends ConsumerState<EquipmentScreen> {
  late Set<EquipmentTag> _selected;
  bool _treadmillExpanded = false;

  @override
  void initState() {
    super.initState();
    final store = ref.read(unperchDataStoreProvider);
    _selected = Set<EquipmentTag>.from(store.equippedItems);
  }

  void _toggle(EquipmentTag tag, bool? checked) {
    if (tag == EquipmentTag.bodyweight) return; // always on
    final isOn = checked ?? false;
    setState(() {
      if (isOn) {
        _selected.add(tag);
      } else {
        _selected.remove(tag);
      }
      if (tag == EquipmentTag.treadmill) {
        _treadmillExpanded = isOn;
      }
    });
  }

  Future<void> _save() async {
    final store = ref.read(unperchDataStoreProvider);
    // Bodyweight is always included.
    final toSave = {EquipmentTag.bodyweight, ..._selected};
    await store.setEquippedItems(toSave);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equipment updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Equipment')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        icon: const Icon(Icons.save_outlined),
        label: const Text('Save'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          // Subtitle card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Check the equipment you have available at your workstation. '
                  'This determines which exercises Unperch can suggest.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),

          // Bodyweight — always on, disabled
          CheckboxListTile(
            value: true,
            onChanged: null, // disabled
            title: const Text('Bodyweight'),
            secondary: const Text(
              '\u{1F9CD}', // 🧍
              style: TextStyle(fontSize: 24),
            ),
            subtitle: const Text('Always available'),
          ),

          // Kettlebell
          CheckboxListTile(
            value: _selected.contains(EquipmentTag.kettlebell),
            onChanged: (v) => _toggle(EquipmentTag.kettlebell, v),
            title: const Text('Kettlebell'),
            secondary: const Text(
              '\u{1F514}', // 🔔
              style: TextStyle(fontSize: 24),
            ),
          ),

          // Dumbbell
          CheckboxListTile(
            value: _selected.contains(EquipmentTag.dumbbell),
            onChanged: (v) => _toggle(EquipmentTag.dumbbell, v),
            title: const Text('Dumbbell'),
            secondary: const Text(
              '\u{1F4AA}', // 💪
              style: TextStyle(fontSize: 24),
            ),
          ),

          // Resistance Band
          CheckboxListTile(
            value: _selected.contains(EquipmentTag.resistanceBand),
            onChanged: (v) => _toggle(EquipmentTag.resistanceBand, v),
            title: const Text('Resistance Band'),
            secondary: const Text(
              '\u{3030}️', // 〰️
              style: TextStyle(fontSize: 24),
            ),
          ),

          // Weighted Vest
          CheckboxListTile(
            value: _selected.contains(EquipmentTag.weightedVest),
            onChanged: (v) => _toggle(EquipmentTag.weightedVest, v),
            title: const Text('Weighted Vest'),
            secondary: const Text(
              '\u{1F9BA}', // 🦺
              style: TextStyle(fontSize: 24),
            ),
          ),

          // Under-desk Treadmill
          CheckboxListTile(
            value: _selected.contains(EquipmentTag.treadmill),
            onChanged: (v) => _toggle(EquipmentTag.treadmill, v),
            title: const Text('Under-desk Treadmill'),
            secondary: const Text(
              '\u{1F6B6}', // 🚶
              style: TextStyle(fontSize: 24),
            ),
          ),

          // Inline expandable card for treadmill BLE link
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => SizeTransition(
              sizeFactor: animation,
              child: child,
            ),
            child: _treadmillExpanded
                ? Padding(
                    key: const ValueKey('treadmill-card'),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Connect your treadmill on the Treadmill screen',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push('/treadmill'),
                              child: const Text('Go'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('treadmill-card-hidden')),
          ),
        ],
      ),
    );
  }
}
