import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unperch/core/db/app_database.dart';
import 'package:unperch/core/datastore/unperch_datastore.dart';
import 'package:unperch/core/enums/enums.dart';

// ---------------------------------------------------------------------------
// Timeframe enum
// ---------------------------------------------------------------------------

enum _Timeframe { today, last30Days, lastYear, allTime }

extension _TimeframeLabel on _Timeframe {
  String get label {
    switch (this) {
      case _Timeframe.today:
        return 'Today';
      case _Timeframe.last30Days:
        return 'Last 30 Days';
      case _Timeframe.lastYear:
        return 'Last Year';
      case _Timeframe.allTime:
        return 'All Time';
    }
  }
}

// ---------------------------------------------------------------------------
// Data model returned by the stats provider
// ---------------------------------------------------------------------------

class _OverviewStats {
  const _OverviewStats({
    required this.scheduled,
    required this.completed,
    required this.waterAcknowledged,
    required this.streakDays,
    required this.treadmillMinutes,
    required this.treadmillSteps,
    required this.mostSkippedExerciseId,
    required this.mostSkippedCount,
    required this.regionCounts,
  });

  final int scheduled;
  final int completed;
  final int waterAcknowledged;
  final int streakDays;
  final int treadmillMinutes;
  final int treadmillSteps;
  final String? mostSkippedExerciseId;
  final int mostSkippedCount;
  // Map from BodyRegion name string -> completed-exercise count
  final Map<String, int> regionCounts;

  double get complianceRate =>
      scheduled == 0 ? 0.0 : (completed / scheduled).clamp(0.0, 1.0);
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

/// Holds the selected timeframe.
final _timeframeProvider =
    StateProvider<_Timeframe>((ref) => _Timeframe.today);

/// Computes [_OverviewStats] for the selected timeframe.
final _overviewStatsProvider =
    FutureProvider.autoDispose<_OverviewStats>((ref) async {
  final timeframe = ref.watch(_timeframeProvider);
  final db = ref.watch(_appDatabaseProvider);
  final store = ref.watch(unperchDataStoreProvider);
  return _computeStats(db, store, timeframe);
});

Future<_OverviewStats> _computeStats(
  AppDatabase db,
  UnperchDataStore store,
  _Timeframe timeframe,
) async {
  final now = DateTime.now();
  final DateTime start;
  switch (timeframe) {
    case _Timeframe.today:
      start = DateTime(now.year, now.month, now.day);
    case _Timeframe.last30Days:
      start = now.subtract(const Duration(days: 30));
    case _Timeframe.lastYear:
      start = DateTime(now.year - 1, now.month, now.day);
    case _Timeframe.allTime:
      start = DateTime(2000);
  }
  final end = now.add(const Duration(seconds: 1)); // inclusive of now

  // --- Reminder events in range -----------------------------------------
  final events = await db.reminderDao.getEventsInRange(start, end);

  // Exercise events only (non-null exerciseId)
  final exerciseEvents = events.where((e) => e.exerciseId != null).toList();
  final scheduled = exerciseEvents.length;
  final completed =
      exerciseEvents.where((e) => e.completed && !e.skipped).length;

  // Water events acknowledged (completed = true, type = water)
  final waterAcknowledged = events
      .where((e) => e.type == ReminderType.water.name && e.completed)
      .length;

  // --- Treadmill sessions -----------------------------------------------
  final sessions = await db.treadmillDao.getSessionsInRange(start, end);
  int treadmillSeconds = 0;
  int treadmillSteps = 0;
  for (final s in sessions) {
    treadmillSteps += s.steps;
    if (s.endTime != null) {
      treadmillSeconds += s.endTime!.difference(s.startTime).inSeconds;
    }
  }

  // --- Most-skipped exercise --------------------------------------------
  final allSkips = await db.skipDao.getSkipsInRange(start, end);
  String? mostSkippedId;
  int mostSkippedCount = 0;
  if (allSkips.isNotEmpty) {
    final counts = <String, int>{};
    for (final s in allSkips) {
      counts[s.exerciseId] = (counts[s.exerciseId] ?? 0) + 1;
    }
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    mostSkippedId = top.key;
    mostSkippedCount = top.value;
  }

  // --- Body region balance ---------------------------------------------
  // We use region from the exerciseId prefix convention: "upper_*", "core_*",
  // etc.  If no prefix matches we count under "none".
  final regionCounts = <String, int>{};
  for (final region in BodyRegion.values) {
    regionCounts[region.name] = 0;
  }
  for (final e in exerciseEvents) {
    if (!e.completed || e.skipped) continue;
    final exId = e.exerciseId ?? '';
    BodyRegion matched = BodyRegion.none;
    for (final region in BodyRegion.values) {
      if (exId.startsWith(region.name)) {
        matched = region;
        break;
      }
    }
    regionCounts[matched.name] = (regionCounts[matched.name] ?? 0) + 1;
  }

  // --- Active streak ----------------------------------------------------
  final threshold = store.complianceStreakThreshold;
  final workingDays = store.workingDays;
  final streakDays = await _computeStreak(
    db,
    threshold,
    workingDays,
    now,
  );

  return _OverviewStats(
    scheduled: scheduled,
    completed: completed,
    waterAcknowledged: waterAcknowledged,
    streakDays: streakDays,
    treadmillMinutes: treadmillSeconds ~/ 60,
    treadmillSteps: treadmillSteps,
    mostSkippedExerciseId: mostSkippedId,
    mostSkippedCount: mostSkippedCount,
    regionCounts: regionCounts,
  );
}

/// Walk backwards day-by-day until we find a working-day with compliance below
/// the threshold (or run out of data). Returns the streak length in shift-days.
Future<int> _computeStreak(
  AppDatabase db,
  double threshold,
  Set<DayOfWeek> workingDays,
  DateTime now,
) async {
  int streak = 0;
  // Check up to 365 days back.
  for (int i = 0; i < 365; i++) {
    final day = now.subtract(Duration(days: i));
    final dow = _dartWeekdayToDayOfWeek(day.weekday);
    if (!workingDays.contains(dow)) continue; // skip non-working days

    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final events = await db.reminderDao.getEventsInRange(start, end);
    final exerciseEvents = events.where((e) => e.exerciseId != null).toList();

    if (exerciseEvents.isEmpty) {
      // No data yet for today — don't break the streak on future/current day
      if (i == 0) continue;
      break;
    }

    final completedCount =
        exerciseEvents.where((e) => e.completed && !e.skipped).length;
    final rate = completedCount / exerciseEvents.length;
    if (rate >= threshold) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}

DayOfWeek _dartWeekdayToDayOfWeek(int weekday) {
  // DateTime.weekday: 1=Mon … 7=Sun
  switch (weekday) {
    case 1:
      return DayOfWeek.monday;
    case 2:
      return DayOfWeek.tuesday;
    case 3:
      return DayOfWeek.wednesday;
    case 4:
      return DayOfWeek.thursday;
    case 5:
      return DayOfWeek.friday;
    case 6:
      return DayOfWeek.saturday;
    case 7:
    default:
      return DayOfWeek.sunday;
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeframe = ref.watch(_timeframeProvider);
    final statsAsync = ref.watch(_overviewStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Overview')),
      body: Column(
        children: [
          _TimeframeSelector(selected: timeframe),
          Expanded(
            child: statsAsync.when(
              data: (stats) => _StatsList(stats: stats),
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
// Timeframe selector
// ---------------------------------------------------------------------------

class _TimeframeSelector extends ConsumerWidget {
  const _TimeframeSelector({required this.selected});

  final _Timeframe selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SegmentedButton<_Timeframe>(
        segments: _Timeframe.values
            .map(
              (t) => ButtonSegment<_Timeframe>(
                value: t,
                label: Text(t.label),
              ),
            )
            .toList(),
        selected: {selected},
        onSelectionChanged: (set) {
          if (set.isNotEmpty) {
            ref.read(_timeframeProvider.notifier).state = set.first;
          }
        },
        multiSelectionEnabled: false,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats list
// ---------------------------------------------------------------------------

class _StatsList extends StatelessWidget {
  const _StatsList({required this.stats});

  final _OverviewStats stats;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ComplianceCard(stats: stats),
        const SizedBox(height: 12),
        _WaterCard(count: stats.waterAcknowledged),
        const SizedBox(height: 12),
        _StreakCard(days: stats.streakDays),
        const SizedBox(height: 12),
        _TreadmillCard(
          minutes: stats.treadmillMinutes,
          steps: stats.treadmillSteps,
        ),
        const SizedBox(height: 12),
        _MostSkippedCard(
          exerciseId: stats.mostSkippedExerciseId,
          count: stats.mostSkippedCount,
        ),
        const SizedBox(height: 12),
        _BodyRegionCard(regionCounts: stats.regionCounts),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual stat cards
// ---------------------------------------------------------------------------

class _ComplianceCard extends StatelessWidget {
  const _ComplianceCard({required this.stats});

  final _OverviewStats stats;

  @override
  Widget build(BuildContext context) {
    final pct = (stats.complianceRate * 100).toStringAsFixed(0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compliance Rate',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Exercises completed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: stats.complianceRate,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$pct%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${stats.completed} of ${stats.scheduled} scheduled',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterCard extends StatelessWidget {
  const _WaterCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.water_drop_outlined, size: 32),
        title: const Text('Water Reminders'),
        subtitle: const Text('Acknowledged this period'),
        trailing: Text(
          '$count',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final label = days > 3 ? '$days days \u{1F525}' : '$days days';
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_fire_department_outlined, size: 32),
        title: const Text('Active Streak'),
        subtitle: const Text('Consecutive compliant shift-days'),
        trailing: Text(
          label,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}

class _TreadmillCard extends StatelessWidget {
  const _TreadmillCard({required this.minutes, required this.steps});

  final int minutes;
  final int steps;

  @override
  Widget build(BuildContext context) {
    final minLabel = minutes == 0 ? '— min' : '$minutes min';
    return Card(
      child: ListTile(
        leading: const Icon(Icons.directions_walk_outlined, size: 32),
        title: const Text('Treadmill Time'),
        subtitle: steps > 0 ? Text('$steps steps') : null,
        trailing: Text(
          minLabel,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}

class _MostSkippedCard extends StatelessWidget {
  const _MostSkippedCard({
    required this.exerciseId,
    required this.count,
  });

  final String? exerciseId;
  final int count;

  @override
  Widget build(BuildContext context) {
    final display = exerciseId == null ? 'None' : exerciseId!;
    final subtitle =
        exerciseId == null ? 'No skips recorded' : 'Skipped $count time(s)';
    return Card(
      child: ListTile(
        leading: const Icon(Icons.skip_next_outlined, size: 32),
        title: const Text('Most Skipped Exercise'),
        subtitle: Text(subtitle),
        trailing: Text(
          display,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _BodyRegionCard extends StatelessWidget {
  const _BodyRegionCard({required this.regionCounts});

  final Map<String, int> regionCounts;

  static const _regionColors = {
    'upper': Colors.blue,
    'core': Colors.green,
    'lower': Colors.orange,
    'full': Colors.purple,
    'none': Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final total = regionCounts.values.fold(0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Body Region Balance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Completed exercises by region',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            if (total == 0)
              Text(
                'No completed exercises in this period.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 20,
                  child: Row(
                    children: BodyRegion.values.map((region) {
                      final count = regionCounts[region.name] ?? 0;
                      if (count == 0) return const SizedBox.shrink();
                      final flex = count;
                      return Expanded(
                        flex: flex,
                        child: Container(
                          color: _regionColors[region.name] ?? Colors.grey,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: BodyRegion.values.map((region) {
                  final count = regionCounts[region.name] ?? 0;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _regionColors[region.name] ?? Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${region.name[0].toUpperCase()}${region.name.substring(1)}: $count',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
