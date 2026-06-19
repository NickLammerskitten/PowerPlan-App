import 'package:flutter_test/flutter_test.dart';
import 'package:power_plan_fe/model/goal_scheme_type.dart';
import 'package:power_plan_fe/model/plan.dart';
import 'package:power_plan_fe/model/repetition_scheme_type.dart';
import 'package:power_plan_fe/model/set_entry_draft.dart';

void main() {
  group('SetEntryDraft defaults', () {
    test('default set is a valid FIXED/RPE set with reps=8 and rpe=8.0', () {
      final draft = SetEntryDraft.defaultSet();
      expect(draft.repetitionSchemeType, RepetitionSchemeType.FIXED);
      expect(draft.fixedReps, 8);
      expect(draft.minReps, isNull);
      expect(draft.maxReps, isNull);
      expect(draft.goalSchemeType, GoalSchemeType.RPE);
      expect(draft.rpe, 8.0);
      expect(draft.isValid(), isTrue);
    });
  });

  group('Repetition scheme switching', () {
    test('switching to RANGE clears fixedReps and sets sensible defaults', () {
      final draft = SetEntryDraft.defaultSet();
      draft.setRepetitionSchemeType(RepetitionSchemeType.RANGE);
      expect(draft.fixedReps, isNull);
      expect(draft.minReps, 8);
      expect(draft.maxReps, 12);
      expect(draft.validateRepetitionScheme(), isTrue);
    });

    test('switching to AMRAP clears all rep values', () {
      final draft = SetEntryDraft.defaultSet();
      draft.setRepetitionSchemeType(RepetitionSchemeType.AMRAP);
      expect(draft.fixedReps, isNull);
      expect(draft.minReps, isNull);
      expect(draft.maxReps, isNull);
      expect(draft.validateRepetitionScheme(), isTrue);
    });

    test('RANGE with min > max is invalid', () {
      final draft = SetEntryDraft.defaultSet();
      draft.setRepetitionSchemeType(RepetitionSchemeType.RANGE);
      draft.minReps = 10;
      draft.maxReps = 5;
      expect(draft.validateRepetitionScheme(), isFalse);
      expect(draft.isValid(), isFalse);
    });
  });

  group('Goal scheme switching', () {
    test('switching to RPE_RANGE clears rpe and sets sensible defaults', () {
      final draft = SetEntryDraft.defaultSet();
      draft.setGoalSchemeType(GoalSchemeType.RPE_RANGE);
      expect(draft.rpe, isNull);
      expect(draft.minRpe, 7.0);
      expect(draft.maxRpe, 8.0);
      expect(draft.validateGoalScheme(), isTrue);
    });

    test('switching to PERCENT_OF_1RM clears rpe values and sets default', () {
      final draft = SetEntryDraft.defaultSet();
      draft.setGoalSchemeType(GoalSchemeType.PERCENT_OF_1RM);
      expect(draft.rpe, isNull);
      expect(draft.minRpe, isNull);
      expect(draft.maxRpe, isNull);
      expect(draft.percent1RM, 0.75);
      expect(draft.validateGoalScheme(), isTrue);
    });

    test('RPE outside 3..10 is invalid', () {
      final draft = SetEntryDraft.defaultSet();
      draft.rpe = 2.5;
      expect(draft.validateGoalScheme(), isFalse);

      draft.rpe = 11.0;
      expect(draft.validateGoalScheme(), isFalse);
    });

    test('PERCENT_OF_1RM outside 0.01..1.0 is invalid', () {
      final draft = SetEntryDraft.defaultSet();
      draft.setGoalSchemeType(GoalSchemeType.PERCENT_OF_1RM);
      draft.percent1RM = 0.0;
      expect(draft.validateGoalScheme(), isFalse);

      draft.percent1RM = 1.5;
      expect(draft.validateGoalScheme(), isFalse);
    });
  });

  group('Serialization', () {
    test('toEditRequest for FIXED/RPE only sets relevant fields', () {
      final draft = SetEntryDraft.defaultSet();
      final json = draft.toEditRequest();

      expect(json['repetitionSchemeType'], 'FIXED');
      expect(json['fixedReps'], 8);
      expect(json['minReps'], isNull);
      expect(json['maxReps'], isNull);
      expect(json['goalSchemeType'], 'RPE');
      expect(json['rpe'], 8.0);
      expect(json['minRpe'], isNull);
      expect(json['maxRpe'], isNull);
      expect(json['percent1RM'], isNull);
    });

    test('toCreateRequest contains the exercise entry id', () {
      final draft = SetEntryDraft.defaultSet();
      final json = draft.toCreateRequest('entry-123');

      expect(json['exerciseId'], 'entry-123');
      expect(json['repetitionSchemeType'], 'FIXED');
      expect(json['goalSchemeType'], 'RPE');
    });

    test('toEditRequest for RANGE/PERCENT_OF_1RM serialises correctly', () {
      final draft = SetEntryDraft.defaultSet();
      draft.setRepetitionSchemeType(RepetitionSchemeType.RANGE);
      draft.minReps = 5;
      draft.maxReps = 8;
      draft.setGoalSchemeType(GoalSchemeType.PERCENT_OF_1RM);
      draft.percent1RM = 0.8;

      final json = draft.toEditRequest();
      expect(json['repetitionSchemeType'], 'RANGE');
      expect(json['fixedReps'], isNull);
      expect(json['minReps'], 5);
      expect(json['maxReps'], 8);
      expect(json['goalSchemeType'], 'PERCENT_OF_1RM');
      expect(json['rpe'], isNull);
      expect(json['percent1RM'], 0.8);
    });
  });

  group('SetEntryDraft.fromView', () {
    test('derives FIXED/RPE from populated reps and rpe', () {
      final view = SetEntryView(id: 's1', index: '0', reps: 5, rpe: 9.0);
      final draft = SetEntryDraft.fromView(view);

      expect(draft.repetitionSchemeType, RepetitionSchemeType.FIXED);
      expect(draft.fixedReps, 5);
      expect(draft.goalSchemeType, GoalSchemeType.RPE);
      expect(draft.rpe, 9.0);
      expect(draft.isValid(), isTrue);
    });

    test('derives RANGE/RPE_RANGE from populated min/max fields', () {
      final view = SetEntryView(
        id: 's1',
        index: '0',
        minReps: 6,
        maxReps: 10,
        minRpe: 7.0,
        maxRpe: 9.0,
      );
      final draft = SetEntryDraft.fromView(view);

      expect(draft.repetitionSchemeType, RepetitionSchemeType.RANGE);
      expect(draft.minReps, 6);
      expect(draft.maxReps, 10);
      expect(draft.goalSchemeType, GoalSchemeType.RPE_RANGE);
      expect(draft.minRpe, 7.0);
      expect(draft.maxRpe, 9.0);
      expect(draft.isValid(), isTrue);
    });

    test('derives AMRAP/PERCENT_OF_1RM from empty reps and only percent1RM',
        () {
      final view = SetEntryView(
        id: 's1',
        index: '0',
        percent1RM: 0.6,
      );
      final draft = SetEntryDraft.fromView(view);

      expect(draft.repetitionSchemeType, RepetitionSchemeType.AMRAP);
      expect(draft.goalSchemeType, GoalSchemeType.PERCENT_OF_1RM);
      expect(draft.percent1RM, 0.6);
      expect(draft.isValid(), isTrue);
    });
  });
}
