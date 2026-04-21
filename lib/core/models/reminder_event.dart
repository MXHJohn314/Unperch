import 'package:unperch/core/enums/enums.dart';

class ReminderEvent {
  const ReminderEvent({
    required this.id,
    required this.type,
    required this.scheduledAt,
    required this.completed,
    required this.skipped,
    this.exerciseId,
  });

  final String id;
  final ReminderType type;
  final DateTime scheduledAt;
  final bool completed;
  final bool skipped;

  /// Null for water reminders; points to [Exercise.id] for exercise reminders.
  final String? exerciseId;

  ReminderEvent copyWith({
    String? id,
    ReminderType? type,
    DateTime? scheduledAt,
    bool? completed,
    bool? skipped,
    String? exerciseId,
  }) {
    return ReminderEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completed: completed ?? this.completed,
      skipped: skipped ?? this.skipped,
      exerciseId: exerciseId ?? this.exerciseId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          scheduledAt == other.scheduledAt &&
          completed == other.completed &&
          skipped == other.skipped &&
          exerciseId == other.exerciseId;

  @override
  int get hashCode =>
      Object.hash(id, type, scheduledAt, completed, skipped, exerciseId);

  @override
  String toString() => 'ReminderEvent('
      'id: $id, '
      'type: $type, '
      'scheduledAt: $scheduledAt, '
      'completed: $completed, '
      'skipped: $skipped, '
      'exerciseId: $exerciseId'
      ')';
}
