import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unperch/core/datastore/unperch_datastore.dart';
import 'package:unperch/core/enums/enums.dart';

class BodyExclusionsStep extends ConsumerStatefulWidget {
  const BodyExclusionsStep({super.key});

  @override
  ConsumerState<BodyExclusionsStep> createState() => _BodyExclusionsStepState();
}

class _BodyExclusionsStepState extends ConsumerState<BodyExclusionsStep> {
  late Set<BodyRegion> _excluded;

  static const _regions = [
    BodyRegion.upper,
    BodyRegion.core,
    BodyRegion.lower,
    BodyRegion.full,
  ];

  static const _labels = {
    BodyRegion.upper: 'Upper body',
    BodyRegion.core: 'Core',
    BodyRegion.lower: 'Lower body',
    BodyRegion.full: 'Full body',
  };

  static const _icons = {
    BodyRegion.upper: Icons.accessibility_new,
    BodyRegion.core: Icons.sports_gymnastics,
    BodyRegion.lower: Icons.directions_walk,
    BodyRegion.full: Icons.person,
  };

  @override
  void initState() {
    super.initState();
    _excluded = Set.of(ref.read(unperchDataStoreProvider).excludedBodyRegions);
  }

  Future<void> _toggle(BodyRegion region) async {
    final next = Set.of(_excluded);
    if (next.contains(region)) {
      next.remove(region);
    } else {
      next.add(region);
    }
    setState(() => _excluded = next);
    await ref.read(unperchDataStoreProvider).setExcludedBodyRegions(next);
  }

  Future<void> _clearAll() async {
    setState(() => _excluded = {});
    await ref.read(unperchDataStoreProvider).setExcludedBodyRegions({});
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
            'Any injuries or areas to avoid?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Optional — we will skip exercises that involve these regions.',
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _regions.map((region) {
                      final isSelected = _excluded.contains(region);
                      return FilterChip(
                        avatar: Icon(
                          _icons[region],
                          size: 18,
                          color: isSelected
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                        label: Text(_labels[region]!),
                        selected: isSelected,
                        onSelected: (_) => _toggle(region),
                      );
                    }).toList(),
                  ),
                  if (_excluded.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    TextButton.icon(
                      icon: const Icon(Icons.clear_all),
                      label: const Text('None — clear all'),
                      onPressed: _clearAll,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_excluded.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'No exclusions selected — all body regions are fair game.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
