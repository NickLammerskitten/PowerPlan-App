import 'package:flutter_test/flutter_test.dart';
import 'package:power_plan_fe/model/exercise_list_item.dart';
import 'package:power_plan_fe/pages/create_plan/plan_form_model.dart';

void main() {
  group('PlanFormModel.reorderTrainingDay', () {
    PlanFormModel buildModelWithDays(int dayCount) {
      final model = PlanFormModel();
      model.weeks = 1;
      // Ensure exactly `dayCount` training days exist in week 0.
      model.trainingWeeks[0].trainingDays.clear();
      while (model.trainingWeeks[0].trainingDays.length < dayCount) {
        model.addTrainingDay(0);
      }
      for (var i = 0; i < model.trainingWeeks[0].trainingDays.length; i++) {
        model.trainingWeeks[0].trainingDays[i].name = 'D${i + 1}';
      }
      return model;
    }

    test('moves a day downwards (ReorderableListView semantics)', () {
      final model = buildModelWithDays(3);
      // Move first day to the end => oldIndex=0, newIndex=3 (Flutter convention)
      model.reorderTrainingDay(0, 0, 3);
      expect(
        model.trainingWeeks[0].trainingDays.map((d) => d.name).toList(),
        ['D2', 'D3', 'D1'],
      );
    });

    test('moves a day upwards', () {
      final model = buildModelWithDays(3);
      // Move last day to the front => oldIndex=2, newIndex=0
      model.reorderTrainingDay(0, 2, 0);
      expect(
        model.trainingWeeks[0].trainingDays.map((d) => d.name).toList(),
        ['D3', 'D1', 'D2'],
      );
    });

    test('no-op for invalid week index', () {
      final model = buildModelWithDays(2);
      model.reorderTrainingDay(5, 0, 1);
      expect(
        model.trainingWeeks[0].trainingDays.map((d) => d.name).toList(),
        ['D1', 'D2'],
      );
    });

    test('clamps out-of-range indices', () {
      final model = buildModelWithDays(2);
      // newIndex beyond list length should be clamped to the last position
      model.reorderTrainingDay(0, 0, 99);
      expect(
        model.trainingWeeks[0].trainingDays.map((d) => d.name).toList(),
        ['D2', 'D1'],
      );
    });
  });

  group('PlanFormModel.reorderExerciseEntry', () {
    PlanFormModel buildModelWithExercises(int exerciseCount) {
      final model = PlanFormModel();
      model.weeks = 1;
      model.trainingWeeks[0].trainingDays.clear();
      model.addTrainingDay(0);
      for (var i = 0; i < exerciseCount; i++) {
        model.addExerciseEntryToDay(
          0,
          0,
          ExerciseListItem(id: 'e${i + 1}', name: 'E${i + 1}'),
        );
      }
      return model;
    }

    List<String> namesOf(PlanFormModel model) => model
        .trainingWeeks[0]
        .trainingDays[0]
        .exerciseEntries
        .map((e) => e.exercise.name)
        .toList();

    test('moves an exercise downwards (ReorderableListView semantics)', () {
      final model = buildModelWithExercises(3);
      // Move first exercise to the end => oldIndex=0, newIndex=3
      model.reorderExerciseEntry(0, 0, 0, 3);
      expect(namesOf(model), ['E2', 'E3', 'E1']);
    });

    test('moves an exercise upwards', () {
      final model = buildModelWithExercises(3);
      // Move last exercise to the front => oldIndex=2, newIndex=0
      model.reorderExerciseEntry(0, 0, 2, 0);
      expect(namesOf(model), ['E3', 'E1', 'E2']);
    });

    test('no-op for invalid week index', () {
      final model = buildModelWithExercises(2);
      model.reorderExerciseEntry(5, 0, 0, 1);
      expect(namesOf(model), ['E1', 'E2']);
    });

    test('no-op for invalid day index', () {
      final model = buildModelWithExercises(2);
      model.reorderExerciseEntry(0, 5, 0, 1);
      expect(namesOf(model), ['E1', 'E2']);
    });

    test('clamps out-of-range indices', () {
      final model = buildModelWithExercises(2);
      model.reorderExerciseEntry(0, 0, 0, 99);
      expect(namesOf(model), ['E2', 'E1']);
    });
  });
}
