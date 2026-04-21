import 'package:unperch/core/enums/enums.dart';

class Shift {
  const Shift({
    required this.day,
    required this.startMinutes,
    required this.endMinutes,
    this.isOutOfOffice = false,
  }) : assert(
          startMinutes >= 0 && startMinutes < 1440,
          'startMinutes must be in [0, 1440)',
        ),
       assert(
          endMinutes > 0 && endMinutes <= 1440,
          'endMinutes must be in (0, 1440]',
        );

  final DayOfWeek day;

  /// Minutes from midnight (0–1439) when the shift starts.
  final int startMinutes;

  /// Minutes from midnight (1–1440) when the shift ends.
  final int endMinutes;

  /// When true, all reminders are suspended for this day.
  final bool isOutOfOffice;

  int get durationMinutes => endMinutes - startMinutes;

  Shift copyWith({
    DayOfWeek? day,
    int? startMinutes,
    int? endMinutes,
    bool? isOutOfOffice,
  }) {
    return Shift(
      day: day ?? this.day,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      isOutOfOffice: isOutOfOffice ?? this.isOutOfOffice,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Shift &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          startMinutes == other.startMinutes &&
          endMinutes == other.endMinutes &&
          isOutOfOffice == other.isOutOfOffice;

  @override
  int get hashCode =>
      Object.hash(day, startMinutes, endMinutes, isOutOfOffice);

  @override
  String toString() => 'Shift('
      'day: $day, '
      'startMinutes: $startMinutes, '
      'endMinutes: $endMinutes, '
      'isOutOfOffice: $isOutOfOffice'
      ')';
}
