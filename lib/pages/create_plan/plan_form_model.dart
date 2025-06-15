import 'package:flutter/material.dart';

class PlanFormModel extends ChangeNotifier {
  // Metadata fields
  String _name = '';
  int _weeks = 1;

  // Content fields
  List<TrainingWeek> trainingWeeks = [TrainingWeek(index: 0)];

  // Validation errors
  String? nameError;
  String? weeksError;

  // Getters and setters
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
        TrainingDay(index: dayIndex, name: 'Tag $dayIndex', exercises: []),
      );
      notifyListeners();
    }
  }

  Map<String, dynamic> toCreatePlanRequest() {
    return {
      'name': _name,
      'difficultyLevel': null, // TODO: add later
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
          trainingDays ?? [TrainingDay(index: 1, name: 'Tag 1', exercises: [])];

  Map<String, dynamic> toJson() {
    return {'trainingDays': trainingDays.map((day) => day.toJson()).toList()};
  }
}

class TrainingDay {
  final int index;
  String name;
  final List<dynamic> exercises; // TODO: Implement type

  TrainingDay({
    required this.index,
    required this.name,
    required this.exercises,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'exercises': exercises};
  }
}
