import 'package:flutter_test/flutter_test.dart';
import 'package:power_plan_fe/model/goal_scheme_type.dart';
import 'package:power_plan_fe/model/plan.dart';
import 'package:power_plan_fe/model/repetition_scheme_type.dart';

void main() {
  group('Plan.fromJson', () {
    test('parses a plan with weeks, days, exercises and sets', () {
      final json = {
        'id': 'p1',
        'name': 'My Plan',
        'difficultyLevel': 'INTERMEDIATE',
        'classifications': ['POWERLIFTING'],
        'status': 'TEMPLATE',
        'template': true,
        'weeks': [
          {
            'id': 'w1',
            'index': '0',
            'trainingDays': [
              {
                'id': 'd1',
                'index': '0',
                'name': 'Day A',
                'type': 'STRENGTH',
                'exerciseEntries': [
                  {
                    'id': 'e1',
                    'index': '0',
                    'exercise': {'id': 'ex1', 'name': 'Squat'},
                    'sets': [
                      {
                        'id': 's1',
                        'index': '0',
                        'reps': 5,
                        'rpe': 8.0,
                      },
                      {
                        'id': 's2',
                        'index': '1',
                        'minReps': 6,
                        'maxReps': 10,
                        'minRpe': 7.0,
                        'maxRpe': 8.5,
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ],
      };

      final plan = Plan.fromJson(json);

      expect(plan.id, 'p1');
      expect(plan.name, 'My Plan');
      expect(plan.template, isTrue);
      expect(plan.classifications, ['POWERLIFTING']);
      expect(plan.weeks, hasLength(1));

      final day = plan.weeks.first.trainingDays.first;
      expect(day.name, 'Day A');
      expect(day.exerciseEntries, hasLength(1));

      final entry = day.exerciseEntries.first;
      expect(entry.exercise.name, 'Squat');
      expect(entry.sets, hasLength(2));

      final set1 = entry.sets[0];
      expect(set1.reps, 5);
      expect(set1.rpe, 8.0);
      expect(set1.repetitionSchemeType, RepetitionSchemeType.FIXED);
      expect(set1.goalSchemeType, GoalSchemeType.RPE);

      final set2 = entry.sets[1];
      expect(set2.minReps, 6);
      expect(set2.maxReps, 10);
      expect(set2.repetitionSchemeType, RepetitionSchemeType.RANGE);
      expect(set2.goalSchemeType, GoalSchemeType.RPE_RANGE);
    });

    test('handles missing optional collections gracefully', () {
      final plan = Plan.fromJson({'id': 'p1', 'name': 'Empty'});
      expect(plan.weeks, isEmpty);
      expect(plan.classifications, isEmpty);
      expect(plan.template, isFalse);
    });
  });
}
