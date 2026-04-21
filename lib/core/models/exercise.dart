import 'package:unperch/core/enums/enums.dart';

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.bodyRegion,
    required this.equipment,
    required this.intensity,
    required this.durationSeconds,
    this.ttsScript,
  });

  final String id;
  final String name;
  final String description;
  final BodyRegion bodyRegion;
  final EquipmentTag equipment;
  final IntensityTier intensity;
  final int durationSeconds;

  /// Optional text the TTS service should speak when this exercise is prompted.
  final String? ttsScript;

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    BodyRegion? bodyRegion,
    EquipmentTag? equipment,
    IntensityTier? intensity,
    int? durationSeconds,
    String? ttsScript,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      bodyRegion: bodyRegion ?? this.bodyRegion,
      equipment: equipment ?? this.equipment,
      intensity: intensity ?? this.intensity,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      ttsScript: ttsScript ?? this.ttsScript,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exercise &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          bodyRegion == other.bodyRegion &&
          equipment == other.equipment &&
          intensity == other.intensity &&
          durationSeconds == other.durationSeconds &&
          ttsScript == other.ttsScript;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        bodyRegion,
        equipment,
        intensity,
        durationSeconds,
        ttsScript,
      );

  @override
  String toString() => 'Exercise('
      'id: $id, '
      'name: $name, '
      'bodyRegion: $bodyRegion, '
      'equipment: $equipment, '
      'intensity: $intensity, '
      'durationSeconds: $durationSeconds'
      ')';
}
