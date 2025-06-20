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
                break;
              case 'minReps':
                set.minReps = value as int?;
                break;
              case 'maxReps':
                set.maxReps = value as int?;
                break;
              case 'rpe':
                set.rpe = value as double?;
                break;
              case 'minRpe':
                set.minRpe = value as double?;
                break;
              case 'maxRpe':
                set.maxRpe = value as double?;
                break;
              case 'percent1RM':
                set.percent1RM = value as double?;
                break;
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
