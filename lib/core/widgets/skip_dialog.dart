import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unperch/core/db/app_database.dart';
import 'package:unperch/core/enums/enums.dart';
import 'package:unperch/core/models/reminder_event.dart';
import 'package:unperch/core/models/skip_record.dart';
import 'package:unperch/core/services/reminder_scheduler.dart';

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

/// Shows a two-step bottom-sheet that lets the user choose a [SkipScope].
///
/// - Step 1: scope picker (all four options).
/// - Step 2 (only for [SkipScope.untilDate]): preset chips + date picker.
///
/// On confirm, inserts a [SkipRecordData] via [SkipDao], marks the event
/// skipped via [ReminderDao], dismisses the sheet, and returns the newly
/// created [SkipRecord] to the caller.
///
/// [event] is optional for backward-compatibility; when omitted the dialog
/// still shows the scope picker but no DB writes are performed.
///
/// Returns [null] if the user dismisses without confirming.
Future<SkipRecord?> showSkipDialog(
  BuildContext context, [
  ReminderEvent? event,
]) {
  return showModalBottomSheet<SkipRecord>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => Padding(
      // Lift the sheet above the keyboard if a date picker opens.
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(ctx).bottom,
      ),
      child: _SkipDialogSheet(event: event),
    ),
  );
}

// ---------------------------------------------------------------------------
// Internal StatefulWidget — two-step flow
// ---------------------------------------------------------------------------

/// Internal widget that manages the two-step skip dialog state.
class _SkipDialogSheet extends ConsumerStatefulWidget {
  const _SkipDialogSheet({required this.event});

  final ReminderEvent? event;

  @override
  ConsumerState<_SkipDialogSheet> createState() => _SkipDialogSheetState();
}

class _SkipDialogSheetState extends ConsumerState<_SkipDialogSheet> {
  // ---- State ----
  /// Whether we are showing step 2 (date picker) vs step 1 (scope picker).
  bool _showDateStep = false;

  SkipScope _scope = SkipScope.thisInstance;

  /// Set after the user picks a date in step 2.
  DateTime? _untilDate;

  bool _saving = false;

  // ---- Preset definitions ----
  static const _presets = [
    ('Tomorrow', 1),
    ('This week', 7),
    ('2 weeks', 14),
    ('1 month', 30),
    ('3 months', 90),
    ('6 months', 180),
    ('1 year', 365),
  ];

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null && mounted) {
      setState(() => _untilDate = picked);
    }
  }

  Future<void> _confirm() async {
    if (_scope == SkipScope.untilDate && _untilDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a date first.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final now = DateTime.now();

      // For "today" scope the expiry is end of today.
      DateTime? expiresAt;
      if (_scope == SkipScope.today) {
        expiresAt = DateTime(now.year, now.month, now.day, 23, 59, 59);
      } else if (_scope == SkipScope.untilDate && _untilDate != null) {
        // Expire at the end of the chosen day.
        expiresAt = DateTime(
          _untilDate!.year,
          _untilDate!.month,
          _untilDate!.day,
          23,
          59,
          59,
        );
      }
      // thisInstance and indefinitely → expiresAt stays null.

      if (widget.event != null) {
        final db = ref.read(appDatabaseProvider);
        final event = widget.event!;

        // Build the unique ID from the event + timestamp to ensure uniqueness.
        final skipId = '${event.id}_skip_${now.millisecondsSinceEpoch}';
        final exerciseId = event.exerciseId ?? event.id;

        // Persist skip record.
        await db.skipDao.insertSkip(
          SkipRecordsCompanion.insert(
            id: skipId,
            exerciseId: exerciseId,
            scope: _scope.name,
            createdAt: now,
            expiresAt: Value(expiresAt),
          ),
        );

        // Mark the event as skipped.
        await db.reminderDao.markSkipped(event.id);

        final record = SkipRecord(
          id: skipId,
          exerciseId: exerciseId,
          scope: _scope,
          createdAt: now,
          expiresAt: expiresAt,
        );

        if (mounted) Navigator.of(context).pop(record);
      } else {
        // No event provided — just pop with a placeholder record.
        if (mounted) Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: _showDateStep ? _buildDateStep(context) : _buildScopeStep(context),
      ),
    );
  }

  Widget _buildScopeStep(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Skip reminder',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Step 1: four scope options.
          _ScopeTile(
            icon: Icons.skip_next,
            label: 'Just this one',
            onTap: () {
              setState(() => _scope = SkipScope.thisInstance);
              _confirm();
            },
          ),
          _ScopeTile(
            icon: Icons.today,
            label: 'Rest of today',
            onTap: () {
              setState(() => _scope = SkipScope.today);
              _confirm();
            },
          ),
          _ScopeTile(
            icon: Icons.calendar_month,
            label: 'Until a date…',
            onTap: () {
              setState(() {
                _scope = SkipScope.untilDate;
                _showDateStep = true;
              });
            },
          ),
          _ScopeTile(
            icon: Icons.block,
            label: 'Indefinitely',
            onTap: () {
              setState(() => _scope = SkipScope.indefinitely);
              _confirm();
            },
          ),

          const SizedBox(height: 4),
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStep(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _showDateStep = false;
                  _untilDate = null;
                }),
              ),
              Expanded(
                child: Text(
                  'Skip until when?',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              // Spacer to balance the back button.
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),

          // Preset chips.
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final (label, days) in _presets)
                ChoiceChip(
                  label: Text(label),
                  selected: _untilDate != null &&
                      _sameDay(_untilDate!, now.add(Duration(days: days))),
                  onSelected: (_) {
                    setState(() => _untilDate = now.add(Duration(days: days)));
                  },
                ),
              ActionChip(
                label: const Text('Pick a date…'),
                avatar: const Icon(Icons.date_range, size: 16),
                onPressed: _pickCustomDate,
              ),
            ],
          ),

          if (_untilDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Skipping until: ${_formatDate(_untilDate!)}',
              style: theme.textTheme.bodySmall,
            ),
          ],

          const SizedBox(height: 16),
          FilledButton(
            onPressed: (_saving || _untilDate == null) ? null : _confirm,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Confirm'),
          ),
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // ---- Utilities ----

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

// ---------------------------------------------------------------------------
// Helper tile widget for step 1
// ---------------------------------------------------------------------------

class _ScopeTile extends StatelessWidget {
  const _ScopeTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
      dense: true,
    );
  }
}

