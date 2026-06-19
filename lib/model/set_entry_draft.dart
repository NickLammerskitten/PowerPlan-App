import 'package:power_plan_fe/model/goal_scheme_type.dart';
import 'package:power_plan_fe/model/plan.dart';
import 'package:power_plan_fe/model/repetition_scheme_type.dart';

/// Editable working copy of a single set entry.
///
/// Used both during plan creation (in `PlanFormModel`) and when editing an
/// existing plan via the `PlanEditPage`. The class enforces the same
/// invariants as the backend `RepetitionScheme` / `GoalScheme` business
/// logic: at any time only the fields belonging to the currently selected
/// scheme type are populated.
class SetEntryDraft {
  RepetitionSchemeType repetitionSchemeType;
  int? fixedReps;
  int? minReps;
  int? maxReps;

  GoalSchemeType goalSchemeType;
  double? rpe;
  double? minRpe;
  double? maxRpe;
  double? percent1RM;

  SetEntryDraft({
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

  factory SetEntryDraft.defaultSet() => SetEntryDraft();

  /// Build a draft from a backend [SetEntryView].
  factory SetEntryDraft.fromView(SetEntryView view) {
    return SetEntryDraft(
      repetitionSchemeType: view.repetitionSchemeType,
      fixedReps: view.reps,
      minReps: view.minReps,
      maxReps: view.maxReps,
      goalSchemeType: view.goalSchemeType,
      rpe: view.rpe,
      minRpe: view.minRpe,
      maxRpe: view.maxRpe,
      percent1RM: view.percent1RM,
    );
  }

  void setRepetitionSchemeType(RepetitionSchemeType type) {
    repetitionSchemeType = type;
    switch (type) {
      case RepetitionSchemeType.FIXED:
        fixedReps = fixedReps ?? 8;
        minReps = null;
        maxReps = null;
      case RepetitionSchemeType.RANGE:
        fixedReps = null;
        minReps = minReps ?? 8;
        maxReps = maxReps ?? 12;
      case RepetitionSchemeType.AMRAP:
        fixedReps = null;
        minReps = null;
        maxReps = null;
    }
  }

  void setGoalSchemeType(GoalSchemeType type) {
    goalSchemeType = type;
    switch (type) {
      case GoalSchemeType.RPE:
        rpe = rpe ?? 8.0;
        minRpe = null;
        maxRpe = null;
        percent1RM = null;
      case GoalSchemeType.RPE_RANGE:
        rpe = null;
        minRpe = minRpe ?? 7.0;
        maxRpe = maxRpe ?? 8.0;
        percent1RM = null;
      case GoalSchemeType.PERCENT_OF_1RM:
        rpe = null;
        minRpe = null;
        maxRpe = null;
        percent1RM = percent1RM ?? 0.75;
    }
  }

  bool validateRepetitionScheme() {
    switch (repetitionSchemeType) {
      case RepetitionSchemeType.FIXED:
        return fixedReps != null &&
            fixedReps! >= 0 &&
            minReps == null &&
            maxReps == null;
      case RepetitionSchemeType.RANGE:
        return fixedReps == null &&
            minReps != null &&
            maxReps != null &&
            minReps! >= 0 &&
            minReps! <= maxReps!;
      case RepetitionSchemeType.AMRAP:
        return fixedReps == null && minReps == null && maxReps == null;
    }
  }

  bool validateGoalScheme() {
    switch (goalSchemeType) {
      case GoalSchemeType.RPE:
        return rpe != null &&
            rpe! >= 3.0 &&
            rpe! <= 10.0 &&
            minRpe == null &&
            maxRpe == null &&
            percent1RM == null;
      case GoalSchemeType.RPE_RANGE:
        return rpe == null &&
            minRpe != null &&
            maxRpe != null &&
            minRpe! >= 3.0 &&
            minRpe! <= 10.0 &&
            maxRpe! >= 3.0 &&
            maxRpe! <= 10.0 &&
            minRpe! <= maxRpe! &&
            percent1RM == null;
      case GoalSchemeType.PERCENT_OF_1RM:
        return rpe == null &&
            minRpe == null &&
            maxRpe == null &&
            percent1RM != null &&
            percent1RM! >= 0.01 &&
            percent1RM! <= 1.0;
    }
  }

  bool isValid() => validateRepetitionScheme() && validateGoalScheme();

  /// Serialize the draft as an `EditSetEntryRequest` payload.
  Map<String, dynamic> toEditRequest() => {
        'repetitionSchemeType':
            repetitionSchemeType.toString().split('.').last,
        'fixedReps': fixedReps,
        'minReps': minReps,
        'maxReps': maxReps,
        'goalSchemeType': goalSchemeType.toString().split('.').last,
        'rpe': rpe,
        'minRpe': minRpe,
        'maxRpe': maxRpe,
        'percent1RM': percent1RM,
      };

  /// Serialize the draft as a `CreateSetEntryRequest` payload for the given
  /// exercise entry.
  Map<String, dynamic> toCreateRequest(String exerciseEntryId) => {
        'exerciseId': exerciseEntryId,
        ...toEditRequest(),
      };
}
