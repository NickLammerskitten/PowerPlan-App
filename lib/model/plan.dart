// plan.dart
import 'package:power_plan_fe/model/goal_scheme_type.dart';
import 'package:power_plan_fe/model/repetition_scheme_type.dart';

class Plan {
  final String id;
  final String name;
  final String? difficultyLevel;
  final List<String> classifications;
  final List<WeekView> weeks;
  final String? status;
  final bool template;

  Plan({
    required this.id,
    required this.name,
    this.difficultyLevel,
    this.classifications = const [],
    this.weeks = const [],
    this.status,
    this.template = false,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as String,
      name: json['name'] as String,
      difficultyLevel: json['difficultyLevel'] as String?,
      classifications: (json['classifications'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      weeks: (json['weeks'] as List?)
              ?.map((e) => WeekView.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      status: json['status'] as String?,
      template: json['template'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'difficultyLevel': difficultyLevel,
      'classifications': classifications,
      'weeks': weeks.map((w) => w.toJson()).toList(),
      'status': status,
      'template': template,
    };
  }
}

class WeekView {
  final String id;
  final String index;
  final List<TrainingDayView> trainingDays;

  WeekView({
    required this.id,
    required this.index,
    this.trainingDays = const [],
  });

  factory WeekView.fromJson(Map<String, dynamic> json) {
    return WeekView(
      id: json['id'] as String,
      index: (json['index'] ?? '').toString(),
      trainingDays: (json['trainingDays'] as List?)
              ?.map(
                  (e) => TrainingDayView.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'index': index,
        'trainingDays': trainingDays.map((d) => d.toJson()).toList(),
      };
}

class TrainingDayView {
  final String id;
  final String index;
  final String name;
  final List<ExerciseEntryView> exerciseEntries;
  final String? type;

  TrainingDayView({
    required this.id,
    required this.index,
    required this.name,
    this.exerciseEntries = const [],
    this.type,
  });

  factory TrainingDayView.fromJson(Map<String, dynamic> json) {
    return TrainingDayView(
      id: json['id'] as String,
      index: (json['index'] ?? '').toString(),
      name: (json['name'] ?? '') as String,
      exerciseEntries: (json['exerciseEntries'] as List?)
              ?.map(
                  (e) => ExerciseEntryView.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'index': index,
        'name': name,
        'exerciseEntries':
            exerciseEntries.map((e) => e.toJson()).toList(),
        'type': type,
      };
}

class ExerciseEntryView {
  final String id;
  final String index;
  final ExerciseRef exercise;
  final List<SetEntryView> sets;

  ExerciseEntryView({
    required this.id,
    required this.index,
    required this.exercise,
    this.sets = const [],
  });

  factory ExerciseEntryView.fromJson(Map<String, dynamic> json) {
    return ExerciseEntryView(
      id: json['id'] as String,
      index: (json['index'] ?? '').toString(),
      exercise:
          ExerciseRef.fromJson(json['exercise'] as Map<String, dynamic>),
      sets: (json['sets'] as List?)
              ?.map((e) => SetEntryView.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'index': index,
        'exercise': exercise.toJson(),
        'sets': sets.map((s) => s.toJson()).toList(),
      };
}

class ExerciseRef {
  final String id;
  final String name;

  ExerciseRef({required this.id, required this.name});

  factory ExerciseRef.fromJson(Map<String, dynamic> json) {
    return ExerciseRef(
      id: json['id'] as String,
      name: (json['name'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

/// View representation of a Set as returned by the backend.
///
/// The backend's [SetEntryView] schema does not include the explicit
/// [RepetitionSchemeType] / [GoalSchemeType] discriminators – instead the
/// scheme can be derived from which of the optional value fields are
/// populated. See the business rules in `RepetitionScheme` / `GoalScheme`.
class SetEntryView {
  final String id;
  final String index;
  final int? reps;
  final int? minReps;
  final int? maxReps;
  final double? rpe;
  final double? minRpe;
  final double? maxRpe;
  final double? percent1RM;

  SetEntryView({
    required this.id,
    required this.index,
    this.reps,
    this.minReps,
    this.maxReps,
    this.rpe,
    this.minRpe,
    this.maxRpe,
    this.percent1RM,
  });

  factory SetEntryView.fromJson(Map<String, dynamic> json) {
    return SetEntryView(
      id: json['id'] as String,
      index: (json['index'] ?? '').toString(),
      reps: json['reps'] as int?,
      minReps: json['minReps'] as int?,
      maxReps: json['maxReps'] as int?,
      rpe: (json['rpe'] as num?)?.toDouble(),
      minRpe: (json['minRpe'] as num?)?.toDouble(),
      maxRpe: (json['maxRpe'] as num?)?.toDouble(),
      percent1RM: (json['percent1RM'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'index': index,
        'reps': reps,
        'minReps': minReps,
        'maxReps': maxReps,
        'rpe': rpe,
        'minRpe': minRpe,
        'maxRpe': maxRpe,
        'percent1RM': percent1RM,
      };

  RepetitionSchemeType get repetitionSchemeType {
    if (reps != null) return RepetitionSchemeType.FIXED;
    if (minReps != null || maxReps != null) return RepetitionSchemeType.RANGE;
    return RepetitionSchemeType.AMRAP;
  }

  GoalSchemeType get goalSchemeType {
    if (rpe != null) return GoalSchemeType.RPE;
    if (minRpe != null || maxRpe != null) return GoalSchemeType.RPE_RANGE;
    return GoalSchemeType.PERCENT_OF_1RM;
  }
}