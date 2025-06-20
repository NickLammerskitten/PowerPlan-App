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
        TrainingDay(index: dayIndex, name: 'Tag $dayIndex', exerciseEntries: []),
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
        week.trainingDays[dayIndex].exerciseEntries.removeWhere((e) => e == exercise);
        notifyListeners();
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
          trainingDays ?? [TrainingDay(index: 1, name: 'Tag 1', exerciseEntries: [])];

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
      'exercises': exerciseEntries.map((exercise) => exercise.toJson()).toList(),
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
  final RepetitionSchemeType repetitionSchemeType = RepetitionSchemeType.FIXED;
  int? fixedReps;
  int? minReps;
  int? maxReps;

  final GoalSchemeType goalSchemeType = GoalSchemeType.RPE;
  double? rpe;
  double? minRpe;
  double? maxRpe;
  double? percent1RM;

  Map<String, dynamic> toJson() {
    return {
      'repetitionSchemeType': repetitionSchemeType,
      'fixedReps': fixedReps,
      'minReps': minReps,
      'maxReps': maxReps,
      'goalSchemeType': goalSchemeType,
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
}
