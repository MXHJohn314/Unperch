import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unperch/core/db/database_provider.dart';
import 'package:unperch/core/datastore/unperch_datastore.dart';
import 'package:unperch/core/enums/enums.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Tracks which month is currently displayed (year, month).
final _visibleMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime(DateTime.now().year, DateTime.now().month),
);

/// Loads OOO overrides for all dates visible in the current month grid.
///
/// Keyed on ISO date string → true if OOO.
final _oooMapProvider = FutureProvider.autoDispose<Map<String, bool>>(
  (ref) async {
    final month = ref.watch(_visibleMonthProvider);
    final shiftDao = ref.watch(shiftDaoProvider);

    // The grid shows up to 6 weeks, so pull 42 days from the first cell.
    final firstCell = _firstCellForMonth(month);
    final results = <String, bool>{};

    for (var i = 0; i < 42; i++) {
      final date = firstCell.add(Duration(days: i));
      final isoDate = _isoDate(date);
      final override = await shiftDao.getShiftForDay(isoDate);
      if (override != null && override.isOutOfOffice == 1) {
        results[isoDate] = true;
      }
    }
    return results;
  },
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _isoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime _firstCellForMonth(DateTime month) {
  // The first day of the given month.
  final firstDay = DateTime(month.year, month.month, 1);
  // How many days to step back so the grid starts on Sunday (weekday 7 → 0).
  final weekday = firstDay.weekday; // 1=Mon … 7=Sun
  final offset = weekday % 7; // 0 for Sunday, 1 for Monday, etc.
  return firstDay.subtract(Duration(days: offset));
}

DayOfWeek _dartWeekdayToDayOfWeek(int weekday) {
  // DateTime.weekday: 1=Mon … 7=Sun
  return switch (weekday) {
    1 => DayOfWeek.monday,
    2 => DayOfWeek.tuesday,
    3 => DayOfWeek.wednesday,
    4 => DayOfWeek.thursday,
    5 => DayOfWeek.friday,
    6 => DayOfWeek.saturday,
    _ => DayOfWeek.sunday,
  };
}

const _monthNames = [
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

const _weekdayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Monthly calendar view. Route: `/calendar`.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleMonth = ref.watch(_visibleMonthProvider);
    final oooMapAsync = ref.watch(_oooMapProvider);
    final dataStore = ref.watch(unperchDataStoreProvider);
    final workingDays = dataStore.workingDays;

    final oooMap = oooMapAsync.valueOrNull ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _MonthHeader(visibleMonth: visibleMonth),
          _WeekdayRow(),
          Expanded(
            child: _MonthGrid(
              visibleMonth: visibleMonth,
              workingDays: workingDays,
              oooMap: oooMap,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Month header (nav row)
// ---------------------------------------------------------------------------

class _MonthHeader extends ConsumerWidget {
  const _MonthHeader({required this.visibleMonth});

  final DateTime visibleMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous month',
            onPressed: () {
              ref.read(_visibleMonthProvider.notifier).state = DateTime(
                visibleMonth.year,
                visibleMonth.month - 1,
              );
            },
          ),
          Expanded(
            child: Text(
              '${_monthNames[visibleMonth.month]} ${visibleMonth.year}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next month',
            onPressed: () {
              ref.read(_visibleMonthProvider.notifier).state = DateTime(
                visibleMonth.year,
                visibleMonth.month + 1,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weekday label row
// ---------------------------------------------------------------------------

class _WeekdayRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: _weekdayLabels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Month grid
// ---------------------------------------------------------------------------

class _MonthGrid extends ConsumerWidget {
  const _MonthGrid({
    required this.visibleMonth,
    required this.workingDays,
    required this.oooMap,
  });

  final DateTime visibleMonth;
  final Set<DayOfWeek> workingDays;
  final Map<String, bool> oooMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstCell = _firstCellForMonth(visibleMonth);
    final today = DateTime.now();
    final todayIso = _isoDate(DateTime(today.year, today.month, today.day));

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final date = firstCell.add(Duration(days: index));
        final isoDate = _isoDate(date);
        final inMonth = date.month == visibleMonth.month;
        final dayOfWeek = _dartWeekdayToDayOfWeek(date.weekday);
        final isWorkDay = workingDays.contains(dayOfWeek);
        final isToday = isoDate == todayIso;
        final isOoo = oooMap[isoDate] == true;

        return _DayCell(
          date: date,
          isoDate: isoDate,
          inMonth: inMonth,
          isWorkDay: isWorkDay,
          isToday: isToday,
          isOoo: isOoo,
          onTap: () => context.push('/calendar/day/$isoDate'),
          onLongPress: isWorkDay && inMonth
              ? () => _toggleOoo(context, ref, isoDate, isOoo)
              : null,
        );
      },
    );
  }

  Future<void> _toggleOoo(
    BuildContext context,
    WidgetRef ref,
    String isoDate,
    bool currentlyOoo,
  ) async {
    final shiftDao = ref.read(shiftDaoProvider);
    await shiftDao.setOutOfOffice(isoDate, !currentlyOoo);
    // Invalidate to reload OOO map.
    ref.invalidate(_oooMapProvider);

    if (context.mounted) {
      final label = currentlyOoo ? 'Removed OOO for' : 'Marked OOO for';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label $isoDate')),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Individual day cell
// ---------------------------------------------------------------------------

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isoDate,
    required this.inMonth,
    required this.isWorkDay,
    required this.isToday,
    required this.isOoo,
    required this.onTap,
    this.onLongPress,
  });

  final DateTime date;
  final String isoDate;
  final bool inMonth;
  final bool isWorkDay;
  final bool isToday;
  final bool isOoo;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color? bgColor;
    if (isWorkDay && inMonth && !isOoo) {
      bgColor = colorScheme.primaryContainer.withValues(alpha: 0.35);
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: isToday
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '${date.day}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: inMonth
                      ? (isToday ? colorScheme.primary : null)
                      : colorScheme.onSurface.withValues(alpha: 0.35),
                  fontWeight: isToday ? FontWeight.bold : null,
                ),
              ),
              if (isOoo && inMonth)
                Positioned(
                  bottom: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'OOO',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 7,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
