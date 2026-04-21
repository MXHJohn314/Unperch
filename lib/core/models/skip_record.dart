import 'package:unperch/core/enums/enums.dart';

class SkipRecord {
  const SkipRecord({
    required this.id,
    required this.exerciseId,
    required this.scope,
    required this.createdAt,
    this.expiresAt,
  });

  final String id;
  final String exerciseId;
  final SkipScope scope;
  final DateTime createdAt;

  /// Null unless [scope] is [SkipScope.untilDate].
  final DateTime? expiresAt;

  bool get isActive {
    if (scope == SkipScope.indefinitely) return true;
    if (scope == SkipScope.untilDate) {
      return expiresAt != null && DateTime.now().isBefore(expiresAt!);
    }
    return true;
  }

  SkipRecord copyWith({
    String? id,
    String? exerciseId,
    SkipScope? scope,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return SkipRecord(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      scope: scope ?? this.scope,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkipRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          exerciseId == other.exerciseId &&
          scope == other.scope &&
          createdAt == other.createdAt &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode =>
      Object.hash(id, exerciseId, scope, createdAt, expiresAt);

  @override
  String toString() => 'SkipRecord('
      'id: $id, '
      'exerciseId: $exerciseId, '
      'scope: $scope, '
      'createdAt: $createdAt, '
      'expiresAt: $expiresAt'
      ')';
}
