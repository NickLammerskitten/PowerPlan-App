import 'package:flutter/material.dart';
import 'package:power_plan_fe/model/exercise_list_item.dart';
import 'package:power_plan_fe/model/goal_scheme_type.dart';
import 'package:power_plan_fe/model/repetition_scheme_type.dart';

class PlanFormModel extends ChangeNotifier {
  String _name = '';
  int _weeks = 1;

  List<TrainingWeek> trainingWeeks = [];

  String? nameError;
  String? weeksError;

  PlanFormModel() {
    _updateTrainingWeeks();
  }

  String get name => _name;

  set name(String value) {
    _name = value;
    validateName();
    notifyListeners();
  }

  int get weeks => _weeks;

  set weeks(int value) {
    if (_weeks != value) {
      _weeks = value;
      _updateTrainingWeeks();
      validateWeeks();
      notifyListeners();
    }
  }

  // Initialize or update training weeks based on selected number
  void _updateTrainingWeeks() {
    // Keep existing weeks
    if (trainingWeeks.length < _weeks) {
      // Add new weeks
      for (int i = trainingWeeks.length; i < _weeks; i++) {
        trainingWeeks.add(TrainingWeek(index: i + 1));
      }
    } else if (trainingWeeks.length > _weeks) {
      // Remove excess weeks
      trainingWeeks = trainingWeeks.sublist(0, _weeks);
    }
  }

  // Validation methods
  bool validateName() {
    if (_name.trim().isEmpty) {
      nameError = 'Name ist erforderlich';
      return false;
    } else {
      nameError = null;
      return true;
    }
  }

  bool validateWeeks() {
    if (_weeks < 1 || _weeks > 18) {
      weeksError = 'Bitte wählen Sie zwischen 1 und 18 Wochen';
      return false;
    } else {
      weeksError = null;
      return true;
    }
  }

  bool validateMetadata() {
    return validateName() && validateWeeks();
  }

  void addTrainingDay(int weekIndex) {
    if (weekIndex >= 0 && weekIndex < trainingWeeks.length) {
      final week = trainingWeeks[weekIndex];
      final dayIndex = week.trainingDays.length + 1;
      week.trainingDays.add(
        TrainingDay(
          index: dayIndex,
          name: 'Tag $dayIndex',
          exerciseEntries: [],
        ),
      );
      notifyListeners();
    }
  }

  /// Moves a training day within a week from [oldIndex] to [newIndex].
  ///
  /// Indices follow the Flutter `ReorderableListView` convention where
  /// [newIndex] is the position the item should be inserted at after
  /// removing it from [oldIndex] (i.e. when moving downwards, callers
  /// typically pass `newIndex - 1`). This method handles both conventions
  /// transparently by clamping to valid bounds.
  void reorderTrainingDay(int weekIndex, int oldIndex, int newIndex) {
    if (weekIndex < 0 || weekIndex >= trainingWeeks.length) return;
    final days = trainingWeeks[weekIndex].trainingDays;
    if (oldIndex < 0 || oldIndex >= days.length) return;
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    if (target < 0) target = 0;
    if (target > days.length - 1) target = days.length - 1;
    if (target == oldIndex) return;
    final day = days.removeAt(oldIndex);
    days.insert(target, day);
    notifyListeners();
  }

  void addExerciseEntryToDay(
    int weekIndex,
    int dayIndex,
    ExerciseListItem exercise,
  ) {
    if (weekIndex >= 0 && weekIndex < trainingWeeks.length) {
      final week = trainingWeeks[weekIndex];
      if (dayIndex >= 0 && dayIndex < week.trainingDays.length) {
        week.trainingDays[dayIndex].exerciseEntries.add(
          ExerciseEntry(exercise: exercise, sets: []),
        );
        notifyListeners();
      }
    }
  }

  void removeExerciseEntryFromDay(
    int weekIndex,
    int dayIndex,
    ExerciseEntry exercise,
  ) {
    if (weekIndex >= 0 && weekIndex < trainingWeeks.length) {
      final week = trainingWeeks[weekIndex];
      if (dayIndex >= 0 && dayIndex < week.trainingDays.length) {
        week.trainingDays[dayIndex].exerciseEntries.removeWhere(
          (e) => e == exercise,
        );
        notifyListeners();
      }
    }
  }

  /// Moves an exercise entry within a training day from [oldIndex] to [newIndex].
  ///
  /// Follows the Flutter `ReorderableListView` index convention.
  void reorderExerciseEntry(
    int weekIndex,
    int dayIndex,
    int oldIndex,
    int newIndex,
  ) {
    if (weekIndex < 0 || weekIndex >= trainingWeeks.length) return;
    final week = trainingWeeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.trainingDays.length) return;
    final exercises = week.trainingDays[dayIndex].exerciseEntries;
    if (oldIndex < 0 || oldIndex >= exercises.length) return;
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    if (target < 0) target = 0;
    if (target > exercises.length - 1) target = exercises.length - 1;
    if (target == oldIndex) return;
    final exercise = exercises.removeAt(oldIndex);
    exercises.insert(target, exercise);
    notifyListeners();
  }

  void addSetToExerciseEntry(int weekIndex, int dayIndex, int exerciseIndex) {
    if (weekIndex >= 0 && weekIndex < trainingWeeks.length) {
      final week = trainingWeeks[weekIndex];
      if (dayIndex >= 0 && dayIndex < week.trainingDays.length) {
        final day = week.trainingDays[dayIndex];
        if (exerciseIndex >= 0 && exerciseIndex < day.exerciseEntries.length) {
          final exercise = day.exerciseEntries[exerciseIndex];

          // If there are existing sets, duplicate the last one
          if (exercise.sets.isNotEmpty) {
            final lastSet = exercise.sets.last;

            // Create a new set with the same properties as the last one
            final newSet = SetEntry(
              repetitionSchemeType: lastSet.repetitionSchemeType,
              fixedReps: lastSet.fixedReps,
              minReps: lastSet.minReps,
              maxReps: lastSet.maxReps,
              goalSchemeType: lastSet.goalSchemeType,
              rpe: lastSet.rpe,
              minRpe: lastSet.minRpe,
              maxRpe: lastSet.maxRpe,
              percent1RM: lastSet.percent1RM,
            );

            exercise.sets.add(newSet);
          } else {
            // If no existing sets, add a default one
            exercise.sets.add(SetEntry.defaultSet());
          }

          notifyListeners();
        }
      }
    }
  }

  void removeSetFromExerciseEntry(
    int weekIndex,
    int dayIndex,
    int exerciseIndex,
    int setIndex,
  ) {
    if (weekIndex >= 0 && weekIndex < trainingWeeks.length) {
      final week = trainingWeeks[weekIndex];
      if (dayIndex >= 0 && dayIndex < week.trainingDays.length) {
        final day = week.trainingDays[dayIndex];
        if (exerciseIndex >= 0 && exerciseIndex < day.exerciseEntries.length) {
          final exercise = day.exerciseEntries[exerciseIndex];
          if (setIndex >= 0 && setIndex < exercise.sets.length) {
            exercise.sets.removeAt(setIndex);
            notifyListeners();
          }
        }
      }
    }
  }

  void updateSetRepetitionSchemeType(
    int weekIndex,
    int dayIndex,
    int exerciseIndex,
    int setIndex,
    RepetitionSchemeType schemeType,
  ) {
    if (weekIndex >= 0 && weekIndex < trainingWeeks.length) {
      final week = trainingWeeks[weekIndex];
      if (dayIndex >= 0 && dayIndex < week.trainingDays.length) {
        final day = week.trainingDays[dayIndex];
        if (exerciseIndex >= 0 && exerciseIndex < day.exerciseEntries.length) {
          final exercise = day.exerciseEntries[exerciseIndex];
          if (setIndex >= 0 && setIndex < exercise.sets.length) {
            final set = exercise.sets[setIndex];
            set.repetitionSchemeType = schemeType;

            // Reset values based on new scheme type
            if (schemeType == RepetitionSchemeType.FIXED) {
              set.fixedReps = 8;
              set.minReps = null;
              set.maxReps = null;
            } else if (schemeType == RepetitionSchemeType.RANGE) {
              set.fixedReps = null;
              set.minReps = 8;
              set.maxReps = 12;
            } else if (schemeType == RepetitionSchemeType.AMRAP) {
              set.fixedReps = null;
              set.minReps = null;
              set.maxReps = null;
            }

            notifyListeners();
          }
        }
      }
    }
  }

  void updateSetGoalSchemeType(
    int weekIndex,
    int dayIndex,
    int exerciseIndex,
    int setIndex,
    GoalSchemeType schemeType,
  ) {
    if (weekIndex >= 0 && weekIndex < trainingWeeks.length) {
      final week = trainingWeeks[weekIndex];
      if (dayIndex >= 0 && dayIndex < week.trainingDays.length) {
        final day = week.trainingDays[dayIndex];
        if (exerciseIndex >= 0 && exerciseIndex < day.exerciseEntries.length) {
          final exercise = day.exerciseEntries[exerciseIndex];
          if (setIndex >= 0 && setIndex < exercise.sets.length) {
            final set = exercise.sets[setIndex];
            set.goalSchemeType = schemeType;

            // Reset values based on new scheme type
            if (schemeType == GoalSchemeType.RPE) {
              set.rpe = 8.0;
              set.minRpe = null;
              set.maxRpe = null;
              set.percent1RM = null;
            } else if (schemeType == GoalSchemeType.RPE_RANGE) {
              set.rpe = null;
              set.minRpe = 7.0;
              set.maxRpe = 8.0;
              set.percent1RM = null;
            } else if (schemeType == GoalSchemeType.PERCENT_OF_1RM) {
              set.rpe = null;
              set.minRpe = null;
              set.maxRpe = null;
              set.percent1RM = 0.75; // 75%
            }

            notifyListeners();
          }
        }
      }
    }
  }

  void updateSetValue(
    int weekIndex,
    int dayIndex,
    int exerciseIndex,
    int setIndex,
    String valueType,
    dynamic value,
  ) {
    if (weekIndex >= 0 && weekIndex < trainingWeeks.length) {
      final week = trainingWeeks[weekIndex];
      if (dayIndex >= 0 && dayIndex < week.trainingDays.length) {
        final day = week.trainingDays[dayIndex];
        if (exerciseIndex >= 0 && exerciseIndex < day.exerciseEntries.length) {
          final exercise = day.exerciseEntries[exerciseIndex];
          if (setIndex >= 0 && setIndex < exercise.sets.length) {
            final set = exercise.sets[setIndex];

            switch (valueType) {
              case 'fixedReps':
                set.fixedReps = value as int?;
              case 'minReps':
                set.minReps = value as int?;
              case 'maxReps':
                set.maxReps = value as int?;
              case 'rpe':
                set.rpe = value as double?;
              case 'minRpe':
                set.minRpe = value as double?;
              case 'maxRpe':
                set.maxRpe = value as double?;
              case 'percent1RM':
                set.percent1RM = value as double?;
            }

            notifyListeners();
          }
        }
      }
    }
  }

  Map<String, dynamic> toCreatePlanRequest() {
    return {
      'name': _name,
      'difficultyLevel': null,
      'classifications': <String>[], // TODO: add later
      'weeks': trainingWeeks.map((week) => week.toJson()).toList(),
    };
  }
}

class TrainingWeek {
  final int index;
  final List<TrainingDay> trainingDays;

  TrainingWeek({required this.index, List<TrainingDay>? trainingDays})
    : trainingDays =
          trainingDays ??
          [TrainingDay(index: 1, name: 'Tag 1', exerciseEntries: [])];

  Map<String, dynamic> toJson() {
    return {'trainingDays': trainingDays.map((day) => day.toJson()).toList()};
  }
}

class TrainingDay {
  final int index;
  String name;
  final List<ExerciseEntry> exerciseEntries;

  TrainingDay({
    required this.index,
    required this.name,
    required this.exerciseEntries,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'exercises': exerciseEntries
          .map((exercise) => exercise.toJson())
          .toList(),
    };
  }
}

class ExerciseEntry {
  final ExerciseListItem exercise;
  final List<SetEntry> sets;

  ExerciseEntry({required this.exercise, List<SetEntry>? sets})
    : sets = sets ?? [];

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exercise.id,
      'sets': sets.map((set) => set.toJson()).toList(),
    };
  }
}

class SetEntry {
  RepetitionSchemeType repetitionSchemeType;
  int? fixedReps;
  int? minReps;
  int? maxReps;

  GoalSchemeType goalSchemeType;
  double? rpe;
  double? minRpe;
  double? maxRpe;
  double? percent1RM;

  SetEntry({
    this.repetitionSchemeType = RepetitionSchemeType.FIXED,
    this.fixedReps = 8,
    this.minReps,
    this.maxReps,
    this.goalSchemeType = GoalSchemeType.RPE,
    this.rpe = 8.0,
    this.minRpe,
    this.maxRpe,
    this.percent1RM,
  });

  // Factory constructor for creating default set
  factory SetEntry.defaultSet() {
    return SetEntry(
      repetitionSchemeType: RepetitionSchemeType.FIXED,
      fixedReps: 8,
      goalSchemeType: GoalSchemeType.RPE,
      rpe: 8.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'repetitionSchemeType': repetitionSchemeType.toString().split('.').last,
      'fixedReps': fixedReps,
      'minReps': minReps,
      'maxReps': maxReps,
      'goalSchemeType': goalSchemeType.toString().split('.').last,
      'rpe': rpe,
      'minRpe': minRpe,
      'maxRpe': maxRpe,
      'percent1RM': percent1RM,
    };
  }

  bool validateRepetitionSchemeType() {
    if (repetitionSchemeType == RepetitionSchemeType.FIXED) {
      return fixedReps != null && minReps == null && maxReps == null;
    } else if (repetitionSchemeType == RepetitionSchemeType.AMRAP) {
      return fixedReps == null && minReps == null && maxReps == null;
    } else if (repetitionSchemeType == RepetitionSchemeType.RANGE) {
      return fixedReps == null && minReps != null && maxReps != null;
    } else {
      return false;
    }
  }

  bool validateGoalSchemeType() {
    if (goalSchemeType == GoalSchemeType.RPE) {
      return rpe != null &&
          minRpe == null &&
          maxRpe == null &&
          percent1RM == null;
    } else if (goalSchemeType == GoalSchemeType.RPE_RANGE) {
      return rpe == null &&
          minRpe != null &&
          maxRpe != null &&
          percent1RM == null;
    } else if (goalSchemeType == GoalSchemeType.PERCENT_OF_1RM) {
      return rpe == null &&
          minRpe == null &&
          maxRpe == null &&
          percent1RM != null;
    } else {
      return false;
    }
  }

  bool isValid() {
    return validateRepetitionSchemeType() && validateGoalSchemeType();
  }
}
