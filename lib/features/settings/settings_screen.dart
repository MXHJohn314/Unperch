import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unperch/core/datastore/unperch_datastore.dart';
import 'package:unperch/core/enums/enums.dart';
import 'package:unperch/core/services/tts/tts_service.dart';

// ---------------------------------------------------------------------------
// Theme preference provider (StateProvider so app.dart can watch it)
// ---------------------------------------------------------------------------

/// Holds the user's current [ThemePreference].
/// [app.dart] should watch this provider and derive [ThemeMode] from it.
final themePreferenceProvider = StateProvider<ThemePreference>((ref) {
  final store = ref.read(unperchDataStoreProvider);
  return store.theme;
});

// ---------------------------------------------------------------------------
// Settings screen
// ---------------------------------------------------------------------------

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // ---- local state mirrors (written immediately to DataStore) ----
  late int _startMinutes;
  late int _endMinutes;
  late Set<DayOfWeek> _workingDays;
  late int _waterInterval;
  late int _exerciseInterval;
  late Set<EquipmentTag> _equippedItems;
  late Set<BodyRegion> _excludedRegions;
  late String? _ttsVoice;
  late double _ttsSpeed;
  late double _ttsPitch;
  late List<String> _availableVoices;

  @override
  void initState() {
    super.initState();
    final store = ref.read(unperchDataStoreProvider);
    _startMinutes = store.shiftStartMinutes;
    _endMinutes = store.shiftEndMinutes;
    _workingDays = Set.from(store.workingDays);
    _waterInterval = store.waterIntervalMinutes;
    _exerciseInterval = store.exerciseIntervalMinutes;
    _equippedItems = Set.from(store.equippedItems);
    _excludedRegions = Set.from(store.excludedBodyRegions);
    _ttsVoice = store.ttsVoice;
    _ttsSpeed = store.ttsSpeed;
    _ttsPitch = store.ttsPitch;
    _availableVoices = [];
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    final tts = ref.read(ttsServiceProvider);
    final voices = await tts.availableVoices();
    if (mounted) setState(() => _availableVoices = voices);
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  String _formatMinutes(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final t = TimeOfDay(hour: hour, minute: minute);
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _sectionHeader(context, 'Schedule'),
          _shiftHoursSection(),
          _workingDaysSection(),
          _sectionHeader(context, 'Reminders'),
          _waterIntervalTile(),
          _exerciseIntervalTile(),
          _sectionHeader(context, 'Equipment'),
          _equipmentSection(),
          _sectionHeader(context, 'Body Exclusions'),
          _bodyExclusionsSection(),
          _sectionHeader(context, 'Text-to-Speech'),
          _ttsSection(),
          _sectionHeader(context, 'Appearance'),
          _appearanceSection(),
          _sectionHeader(context, 'About'),
          _aboutSection(),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Section: Schedule
  // -------------------------------------------------------------------------

  Widget _shiftHoursSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.wb_sunny_outlined),
            title: const Text('Shift hours'),
            subtitle: Text(
              '${_formatMinutes(_startMinutes)} – ${_formatMinutes(_endMinutes)}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showShiftEditorSheet(),
          ),
        ],
      ),
    );
  }

  void _showShiftEditorSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _ShiftEditorSheet(
        startMinutes: _startMinutes,
        endMinutes: _endMinutes,
        onChanged: (start, end) async {
          setState(() {
            _startMinutes = start;
            _endMinutes = end;
          });
          final store = ref.read(unperchDataStoreProvider);
          await store.setShiftStartMinutes(start);
          await store.setShiftEndMinutes(end);
        },
      ),
    );
  }

  Widget _workingDaysSection() {
    const days = DayOfWeek.values;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Working days',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Wrap(
            spacing: 8,
            children: days.map((day) {
              final selected = _workingDays.contains(day);
              return FilterChip(
                label: Text(_dayAbbrev(day)),
                selected: selected,
                onSelected: (on) async {
                  setState(() {
                    if (on) {
                      _workingDays.add(day);
                    } else {
                      _workingDays.remove(day);
                    }
                  });
                  final store = ref.read(unperchDataStoreProvider);
                  await store.setWorkingDays(_workingDays);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _dayAbbrev(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.monday:
        return 'Mon';
      case DayOfWeek.tuesday:
        return 'Tue';
      case DayOfWeek.wednesday:
        return 'Wed';
      case DayOfWeek.thursday:
        return 'Thu';
      case DayOfWeek.friday:
        return 'Fri';
      case DayOfWeek.saturday:
        return 'Sat';
      case DayOfWeek.sunday:
        return 'Sun';
    }
  }

  // -------------------------------------------------------------------------
  // Section: Reminders
  // -------------------------------------------------------------------------

  Widget _waterIntervalTile() {
    return _IntervalSliderTile(
      icon: Icons.water_drop_outlined,
      title: 'Water interval',
      value: _waterInterval,
      onChanged: (v) async {
        setState(() => _waterInterval = v);
        await ref.read(unperchDataStoreProvider).setWaterIntervalMinutes(v);
      },
    );
  }

  Widget _exerciseIntervalTile() {
    return _IntervalSliderTile(
      icon: Icons.fitness_center_outlined,
      title: 'Exercise interval',
      value: _exerciseInterval,
      onChanged: (v) async {
        setState(() => _exerciseInterval = v);
        await ref.read(unperchDataStoreProvider).setExerciseIntervalMinutes(v);
      },
    );
  }

  // -------------------------------------------------------------------------
  // Section: Equipment
  // -------------------------------------------------------------------------

  Widget _equipmentSection() {
    const tags = EquipmentTag.values;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 8,
        children: tags.map((tag) {
          final isBodyweight = tag == EquipmentTag.bodyweight;
          final selected = _equippedItems.contains(tag);
          return FilterChip(
            label: Text(_equipLabel(tag)),
            selected: selected,
            onSelected: isBodyweight
                ? null // bodyweight always on
                : (on) async {
                    setState(() {
                      if (on) {
                        _equippedItems.add(tag);
                      } else {
                        _equippedItems.remove(tag);
                      }
                    });
                    await ref
                        .read(unperchDataStoreProvider)
                        .setEquippedItems(_equippedItems);
                  },
          );
        }).toList(),
      ),
    );
  }

  String _equipLabel(EquipmentTag tag) {
    switch (tag) {
      case EquipmentTag.bodyweight:
        return 'Bodyweight';
      case EquipmentTag.kettlebell:
        return 'Kettlebell';
      case EquipmentTag.dumbbell:
        return 'Dumbbell';
      case EquipmentTag.resistanceBand:
        return 'Resistance Band';
      case EquipmentTag.weightedVest:
        return 'Weighted Vest';
      case EquipmentTag.treadmill:
        return 'Under-desk Treadmill';
    }
  }

  // -------------------------------------------------------------------------
  // Section: Body Exclusions
  // -------------------------------------------------------------------------

  Widget _bodyExclusionsSection() {
    const regions = BodyRegion.values;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 8,
        children: regions
            .where((r) => r != BodyRegion.none)
            .map((region) {
              final selected = _excludedRegions.contains(region);
              return FilterChip(
                label: Text(
                  '${region.name[0].toUpperCase()}${region.name.substring(1)}',
                ),
                selected: selected,
                selectedColor:
                    Theme.of(context).colorScheme.errorContainer,
                checkmarkColor:
                    Theme.of(context).colorScheme.onErrorContainer,
                onSelected: (on) async {
                  setState(() {
                    if (on) {
                      _excludedRegions.add(region);
                    } else {
                      _excludedRegions.remove(region);
                    }
                  });
                  await ref
                      .read(unperchDataStoreProvider)
                      .setExcludedBodyRegions(_excludedRegions);
                },
              );
            })
            .toList(),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Section: TTS
  // -------------------------------------------------------------------------

  Widget _ttsSection() {
    return Column(
      children: [
        // Voice dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonFormField<String?>(
            value:
                (_availableVoices.contains(_ttsVoice)) ? _ttsVoice : null,
            decoration: const InputDecoration(
              labelText: 'Voice',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('System default'),
              ),
              ..._availableVoices.map(
                (v) => DropdownMenuItem<String?>(value: v, child: Text(v)),
              ),
            ],
            onChanged: (v) async {
              setState(() => _ttsVoice = v);
              await ref.read(unperchDataStoreProvider).setTtsVoice(v ?? '');
              await ref.read(ttsServiceProvider).setVoice(v);
            },
          ),
        ),
        // Speed
        _LabeledSlider(
          label: 'Speed',
          value: _ttsSpeed,
          min: 0.25,
          max: 2.0,
          divisions: 7,
          format: (v) => '${v.toStringAsFixed(2)}×',
          onChanged: (v) async {
            setState(() => _ttsSpeed = v);
            await ref.read(unperchDataStoreProvider).setTtsSpeed(v);
            await ref.read(ttsServiceProvider).setSpeed(v);
          },
        ),
        // Pitch
        _LabeledSlider(
          label: 'Pitch',
          value: _ttsPitch,
          min: 0.5,
          max: 2.0,
          divisions: 6,
          format: (v) => '${v.toStringAsFixed(2)}×',
          onChanged: (v) async {
            setState(() => _ttsPitch = v);
            await ref.read(unperchDataStoreProvider).setTtsPitch(v);
            await ref.read(ttsServiceProvider).setPitch(v);
          },
        ),
        // Preview
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FilledButton.icon(
            icon: const Icon(Icons.play_arrow_outlined),
            label: const Text('Preview'),
            onPressed: () async {
              await ref
                  .read(ttsServiceProvider)
                  .speak('Hello, this is a preview of your TTS settings.');
            },
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Section: Appearance
  // -------------------------------------------------------------------------

  Widget _appearanceSection() {
    final currentTheme = ref.watch(themePreferenceProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<ThemePreference>(
            segments: const [
              ButtonSegment(
                value: ThemePreference.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemePreference.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
              ButtonSegment(
                value: ThemePreference.highContrast,
                label: Text('High Contrast'),
                icon: Icon(Icons.contrast_outlined),
              ),
              ButtonSegment(
                value: ThemePreference.system,
                label: Text('System'),
                icon: Icon(Icons.settings_suggest_outlined),
              ),
            ],
            selected: {currentTheme},
            onSelectionChanged: (set) async {
              if (set.isEmpty) return;
              final pref = set.first;
              ref.read(themePreferenceProvider.notifier).state = pref;
              await ref.read(unperchDataStoreProvider).setTheme(pref);
            },
            multiSelectionEnabled: false,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Section: About
  // -------------------------------------------------------------------------

  Widget _aboutSection() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.replay_outlined),
          title: const Text('Run setup wizard again'),
          onTap: () => context.go('/onboarding'),
        ),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('App version'),
          trailing: Text('1.0.0'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Unperch is free and open-source software (GPL-3.0)',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section header helper
// ---------------------------------------------------------------------------

Widget _sectionHeader(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Interval slider tile
// ---------------------------------------------------------------------------

class _IntervalSliderTile extends StatelessWidget {
  const _IntervalSliderTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final int value;
  final Future<void> Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon),
            title: Text(title),
            trailing: Text('$value min'),
          ),
          Slider(
            value: value.toDouble(),
            min: 15,
            max: 120,
            divisions: 7, // 15, 30, 45, 60, 75, 90, 105, 120
            label: '$value min',
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Labeled slider helper
// ---------------------------------------------------------------------------

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.format,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) format;
  final Future<void> Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: format(value),
              onChanged: (v) => onChanged(v),
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              format(value),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shift editor bottom sheet (RangeSlider approach)
// ---------------------------------------------------------------------------

class _ShiftEditorSheet extends StatefulWidget {
  const _ShiftEditorSheet({
    required this.startMinutes,
    required this.endMinutes,
    required this.onChanged,
  });

  final int startMinutes;
  final int endMinutes;
  final Future<void> Function(int start, int end) onChanged;

  @override
  State<_ShiftEditorSheet> createState() => _ShiftEditorSheetState();
}

class _ShiftEditorSheetState extends State<_ShiftEditorSheet> {
  late RangeValues _range;

  @override
  void initState() {
    super.initState();
    _range = RangeValues(
      widget.startMinutes.toDouble(),
      widget.endMinutes.toDouble(),
    );
  }

  String _fmt(double minutes) {
    final h = minutes.toInt() ~/ 60;
    final m = minutes.toInt() % 60;
    final t = TimeOfDay(hour: h, minute: m);
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Shift Hours',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${_fmt(_range.start)} – ${_fmt(_range.end)}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          RangeSlider(
            values: _range,
            min: 0,
            max: 1440,
            divisions: 96, // 15-minute steps
            labels: RangeLabels(_fmt(_range.start), _fmt(_range.end)),
            onChanged: (v) => setState(() => _range = v),
            onChangeEnd: (v) async {
              await widget.onChanged(v.start.round(), v.end.round());
            },
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
