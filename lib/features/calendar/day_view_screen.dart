import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unperch/core/datastore/unperch_datastore.dart';
import 'package:unperch/core/db/app_database.dart';
import 'package:unperch/core/db/database_provider.dart';
import 'package:unperch/core/enums/enums.dart';
import 'package:unperch/core/models/reminder_event.dart';
import 'package:unperch/core/widgets/skip_dialog.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Watches all [ReminderEventData] rows for the given [isoDate].
///
/// Uses [AppDatabase] directly so it works for any day, not just today.
final _dayEventsProvider = StreamProvider.autoDispose
    .family<List<ReminderEvent>, String>((ref, isoDate) {
  final db = ref.watch(appDatabaseProvider);
  final date = DateTime.parse(isoDate);
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return (db.select(db.reminderEvents)
        ..where(
          (tbl) =>
              tbl.scheduledAt.isBiggerOrEqualValue(startOfDay) &
              tbl.scheduledAt.isSmallerThanValue(endOfDay),
        )
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.scheduledAt)]))
      .watch()
      .map(
        (rows) => rows
            .map(
              (r) => ReminderEvent(
                id: r.id,
                type: ReminderType.values.firstWhere((e) => e.name == r.type),
                scheduledAt: r.scheduledAt,
                completed: r.completed,
                skipped: r.skipped,
                exerciseId: r.exerciseId,
              ),
            )
            .toList(),
      );
});

/// Loads the OOO flag for a single date.
final _dayOooProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, isoDate) async {
  final shiftDao = ref.watch(shiftDaoProvider);
  final override = await shiftDao.getShiftForDay(isoDate);
  return override != null && override.isOutOfOffice == 1;
});

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _formatAppBarDate(String isoDate) {
  final d = DateTime.parse(isoDate);
  const weekdays = [
    '',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${weekdays[d.weekday]}, ${months[d.month]} ${d.day}';
}

String _formatTime(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $period';
}

String _formatMinutesToTime(int minutes) {
  final h = minutes ~/ 60;
  final m = (minutes % 60).toString().padLeft(2, '0');
  final period = h < 12 ? 'AM' : 'PM';
  final hour12 = h % 12 == 0 ? 12 : h % 12;
  return '$hour12:$m $period';
}

IconData _iconForType(ReminderType type) => switch (type) {
      ReminderType.water => Icons.water_drop,
      ReminderType.exercise => Icons.directions_run,
      ReminderType.treadmill => Icons.directions_walk,
      ReminderType.stretch => Icons.self_improvement,
    };

String _labelForType(ReminderType type) => switch (type) {
      ReminderType.water => 'Water',
      ReminderType.exercise => 'Exercise',
      ReminderType.treadmill => 'Treadmill',
      ReminderType.stretch => 'Stretch',
    };

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Day drill-down view. Route: `/calendar/day/:isoDate`.
class DayViewScreen extends ConsumerWidget {
  const DayViewScreen({super.key, required this.isoDate});

  final String isoDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(_dayEventsProvider(isoDate));
    final oooAsync = ref.watch(_dayOooProvider(isoDate));
    final dataStore = ref.watch(unperchDataStoreProvider);

    final isOoo = oooAsync.valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(_formatAppBarDate(isoDate))),
      body: Column(
        children: [
          // Shift time bar
          _ShiftTimeBar(dataStore: dataStore),

          // OOO banner
          if (isOoo)
            _OooBanner(
              isoDate: isoDate,
              onToggle: () async {
                await ref.read(shiftDaoProvider).setOutOfOffice(isoDate, false);
                ref.invalidate(_dayOooProvider(isoDate));
              },
            ),

          // Events list
          Expanded(
            child: eventsAsync.when(
              data: (events) => events.isEmpty
                  ? const Center(child: Text('No reminders scheduled.'))
                  : _EventsList(events: events),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shift time bar
// ---------------------------------------------------------------------------

class _ShiftTimeBar extends StatefulWidget {
  const _ShiftTimeBar({required this.dataStore});

  final UnperchDataStore dataStore;

  @override
  State<_ShiftTimeBar> createState() => _ShiftTimeBarState();
}

class _ShiftTimeBarState extends State<_ShiftTimeBar> {
  bool _editing = false;

  /// Shift slider base: 6 AM = 360 min.  Range shown: 6 AM–10 PM (960 min).
  static const _sliderMin = 360.0; // 06:00
  static const _sliderMax = 1320.0; // 22:00
  static const _divisions = 64; // 16 hours × 4 per hour

  late double _startVal;
  late double _endVal;

  @override
  void initState() {
    super.initState();
    _startVal = widget.dataStore.shiftStartMinutes.toDouble();
    _endVal = widget.dataStore.shiftEndMinutes.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Shift: ${_formatMinutesToTime(_startVal.round())} – '
                    '${_formatMinutesToTime(_endVal.round())}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                IconButton(
                  icon: Icon(_editing ? Icons.check : Icons.edit),
                  tooltip: _editing ? 'Save shift' : 'Edit shift',
                  onPressed: () async {
                    if (_editing) {
                      await widget.dataStore.setShiftStartMinutes(
                        _startVal.round(),
                      );
                      await widget.dataStore.setShiftEndMinutes(
                        _endVal.round(),
                      );
                    }
                    setState(() => _editing = !_editing);
                  },
                ),
              ],
            ),
            if (_editing) ...[
              const SizedBox(height: 4),
              RangeSlider(
                min: _sliderMin,
                max: _sliderMax,
                divisions: _divisions,
                values: RangeValues(_startVal, _endVal),
                labels: RangeLabels(
                  _formatMinutesToTime(_startVal.round()),
                  _formatMinutesToTime(_endVal.round()),
                ),
                onChanged: (values) {
                  if (values.end - values.start >= 60) {
                    setState(() {
                      _startVal = values.start;
                      _endVal = values.end;
                    });
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('6 AM', style: theme.textTheme.labelSmall),
                    Text('10 PM', style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// OOO banner
// ---------------------------------------------------------------------------

class _OooBanner extends StatelessWidget {
  const _OooBanner({required this.isoDate, required this.onToggle});

  final String isoDate;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.beach_access, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Out of office — no reminders today',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: onToggle,
            child: const Text('Re-enable'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Events list grouped by hour
// ---------------------------------------------------------------------------

class _EventsList extends StatelessWidget {
  const _EventsList({required this.events});

  final List<ReminderEvent> events;

  @override
  Widget build(BuildContext context) {
    // Group by hour.
    final groups = <int, List<ReminderEvent>>{};
    for (final event in events) {
      (groups[event.scheduledAt.hour] ??= []).add(event);
    }
    final hours = groups.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: hours.length,
      itemBuilder: (context, index) {
        final hour = hours[index];
        final hourEvents = groups[hour]!;
        return _HourGroup(hour: hour, events: hourEvents);
      },
    );
  }
}

class _HourGroup extends StatelessWidget {
  const _HourGroup({required this.hour, required this.events});

  final int hour;
  final List<ReminderEvent> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '$h $period',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ...events.map((e) => _EventTile(event: e)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Event tile
// ---------------------------------------------------------------------------

class _EventTile extends ConsumerWidget {
  const _EventTile({required this.event});

  final ReminderEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    Widget statusChip;
    if (event.completed) {
      statusChip = _chip('Done', Colors.green);
    } else if (event.skipped) {
      statusChip = _chip('Skipped', Colors.grey);
    } else {
      statusChip = _chip('Pending', theme.colorScheme.primary);
    }

    final isPending = !event.completed && !event.skipped;

    return ListTile(
      leading: Icon(_iconForType(event.type)),
      title: Text(_labelForType(event.type)),
      subtitle: Text(_formatTime(event.scheduledAt)),
      trailing: statusChip,
      onTap: isPending
          ? () => _showActionSheet(context, ref)
          : null,
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _showActionSheet(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _labelForType(event.type),
                style: Theme.of(ctx).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Mark complete'),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await ref.read(reminderDaoProvider).markCompleted(event.id);
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.skip_next),
                label: const Text('Skip'),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  if (context.mounted) {
                    // showSkipDialog persists the skip record and marks
                    // the event skipped internally — no extra DAO call needed.
                    await showSkipDialog(context, event);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
