import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, Colors, Divider;
import 'package:power_plan_fe/model/goal_scheme_type.dart';
import 'package:power_plan_fe/model/repetition_scheme_type.dart';
import 'package:power_plan_fe/pages/create_plan/plan_form_model.dart';
import 'package:power_plan_fe/pages/select_exercise_page.dart';

import '../../services/api/exercise_api.dart';

class ContentStep extends StatefulWidget {
  final PlanFormModel formModel;
  final ExerciseApi exerciseApi;

  const ContentStep({
    Key? key,
    required this.formModel,
    required this.exerciseApi,
  }) : super(key: key);

  @override
  _ContentStepState createState() => _ContentStepState();
}

class _ContentStepState extends State<ContentStep> {
  int _selectedWeekIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.formModel.trainingWeeks.isEmpty) {
      widget.formModel.weeks = 1;
    }
    widget.formModel.addListener(_handleFormModelChanges);
  }

  @override
  void dispose() {
    widget.formModel.removeListener(_handleFormModelChanges);
    super.dispose();
  }

  void _handleFormModelChanges() {
    if (_selectedWeekIndex >= widget.formModel.trainingWeeks.length) {
      setState(() {
        _selectedWeekIndex = widget.formModel.trainingWeeks.isEmpty
            ? 0
            : widget.formModel.trainingWeeks.length - 1;
      });
    }
  }

  void _openExerciseSelection(int dayIndex) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => SelectExercisePage(
          exerciseApi: widget.exerciseApi,
          onExerciseSelected: (exercise) {
            final currentWeek =
                widget.formModel.trainingWeeks[_selectedWeekIndex];
            final day = currentWeek.trainingDays[dayIndex];

            // TODO For now, just add the exercise (implementation will be expanded later)
            widget.formModel.addExerciseEntryToDay(
              _selectedWeekIndex,
              dayIndex,
              exercise,
            );
            setState(() {});
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.formModel.trainingWeeks.isEmpty) {
      return const Center(
        child: Text(
          'Bitte fügen Sie mindestens eine Trainingswoche hinzu',
          style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWeekTabs(),
        const SizedBox(height: 16),

        _buildWeekContent(),
      ],
    );
  }

  Widget _buildWeekTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.formModel.trainingWeeks.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedWeekIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedWeekIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? CupertinoColors.activeBlue
                    : CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                'Woche ${index + 1}',
                style: TextStyle(
                  color: isSelected
                      ? CupertinoColors.white
                      : CupertinoColors.label,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeekContent() {
    if (_selectedWeekIndex >= widget.formModel.trainingWeeks.length) {
      _selectedWeekIndex = widget.formModel.trainingWeeks.length - 1;
    }

    final currentWeek = widget.formModel.trainingWeeks[_selectedWeekIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...currentWeek.trainingDays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          return _buildTrainingDayCard(day, index);
        }),

        const SizedBox(height: 16),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(CupertinoIcons.add, size: 16),
              SizedBox(width: 8),
              Text('Tag hinzufügen'),
            ],
          ),
          onPressed: () {
            widget.formModel.addTrainingDay(_selectedWeekIndex);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildTrainingDayCard(TrainingDay day, int dayIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                day.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.pencil, size: 20),
                onPressed: () {
                  _showEditDayNameDialog(day);
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (day.exerciseEntries.isEmpty)
            const Text(
              'Keine Übungen gefunden.',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Column(
              children: day.exerciseEntries.asMap().entries.map((
                exerciseEntry,
              ) {
                final exerciseIndex = exerciseEntry.key;
                final exercise = exerciseEntry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CupertinoColors.systemGrey4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.exercise.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Icon(
                              CupertinoIcons.trash,
                              size: 20,
                              color: CupertinoColors.systemRed,
                            ),
                            onPressed: () {
                              widget.formModel.removeExerciseEntryFromDay(
                                _selectedWeekIndex,
                                dayIndex,
                                exercise,
                              );
                              setState(() {});
                            },
                          ),
                        ],
                      ),

                      if (exercise.sets.isNotEmpty) const Divider(height: 16),

                      // Display sets in a more compact layout
                      ...exercise.sets.asMap().entries.map((setEntry) {
                        final setIndex = setEntry.key;
                        final set = setEntry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                children: [
                                  // Set number
                                  Text(
                                    'Set ${setIndex + 1}:',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Delete button
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    child: const Icon(
                                      CupertinoIcons.trash,
                                      size: 16,
                                      color: CupertinoColors.systemRed,
                                    ),
                                    onPressed: () {
                                      widget.formModel
                                          .removeSetFromExerciseEntry(
                                            _selectedWeekIndex,
                                            dayIndex,
                                            exerciseIndex,
                                            setIndex,
                                          );
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // First row: Repetition scheme
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                children: [
                                  const Text(
                                    "Reps: ",
                                    style: TextStyle(fontSize: 14),
                                  ),

                                  // Custom Cupertino "dropdown"
                                  GestureDetector(
                                    onTap: () {
                                      _showRepetitionSchemePicker(
                                        context,
                                        set.repetitionSchemeType,
                                        (RepetitionSchemeType type) {
                                          widget.formModel
                                              .updateSetRepetitionSchemeType(
                                                _selectedWeekIndex,
                                                dayIndex,
                                                exerciseIndex,
                                                setIndex,
                                                type,
                                              );
                                          setState(() {});
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.systemGrey6,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: CupertinoColors.systemGrey4,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _getRepetitionSchemeTypeLabel(
                                              set.repetitionSchemeType,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            CupertinoIcons.chevron_down,
                                            size: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Repetition Scheme Value(s)
                                  if (set.repetitionSchemeType ==
                                      RepetitionSchemeType.FIXED)
                                    SizedBox(
                                      width: 50,
                                      child: CupertinoTextField(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 6,
                                        ),
                                        placeholder: '8',
                                        keyboardType: TextInputType.number,
                                        controller: TextEditingController(
                                          text: set.fixedReps?.toString() ?? '',
                                        ),
                                        onChanged: (value) {
                                          final reps = int.tryParse(value);
                                          widget.formModel.updateSetValue(
                                            _selectedWeekIndex,
                                            dayIndex,
                                            exerciseIndex,
                                            setIndex,
                                            'fixedReps',
                                            reps,
                                          );
                                        },
                                      ),
                                    )
                                  else if (set.repetitionSchemeType ==
                                      RepetitionSchemeType.RANGE)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 40,
                                          child: CupertinoTextField(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 6,
                                            ),
                                            placeholder: '8',
                                            keyboardType: TextInputType.number,
                                            controller: TextEditingController(
                                              text:
                                                  set.minReps?.toString() ?? '',
                                            ),
                                            onChanged: (value) {
                                              final reps = int.tryParse(value);
                                              widget.formModel.updateSetValue(
                                                _selectedWeekIndex,
                                                dayIndex,
                                                exerciseIndex,
                                                setIndex,
                                                'minReps',
                                                reps,
                                              );
                                            },
                                          ),
                                        ),
                                        const Text(' - '),
                                        SizedBox(
                                          width: 40,
                                          child: CupertinoTextField(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 6,
                                            ),
                                            placeholder: '12',
                                            keyboardType: TextInputType.number,
                                            controller: TextEditingController(
                                              text:
                                                  set.maxReps?.toString() ?? '',
                                            ),
                                            onChanged: (value) {
                                              final reps = int.tryParse(value);
                                              widget.formModel.updateSetValue(
                                                _selectedWeekIndex,
                                                dayIndex,
                                                exerciseIndex,
                                                setIndex,
                                                'maxReps',
                                                reps,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  else if (set.repetitionSchemeType ==
                                      RepetitionSchemeType.AMRAP)
                                    const Text(
                                      'AMRAP',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                ],
                              ),
                            ),

                            // Second row: Goal scheme
                            Row(
                              children: [
                                const Text(
                                  "Goal: ",
                                  style: TextStyle(fontSize: 14),
                                ),

                                // Custom Cupertino "dropdown"
                                GestureDetector(
                                  onTap: () {
                                    _showGoalSchemePicker(
                                      context,
                                      set.goalSchemeType,
                                      (GoalSchemeType type) {
                                        widget.formModel
                                            .updateSetGoalSchemeType(
                                              _selectedWeekIndex,
                                              dayIndex,
                                              exerciseIndex,
                                              setIndex,
                                              type,
                                            );
                                        setState(() {});
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.systemGrey6,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: CupertinoColors.systemGrey4,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _getGoalSchemeTypeLabel(
                                            set.goalSchemeType,
                                          ),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          CupertinoIcons.chevron_down,
                                          size: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Goal Scheme Value(s)
                                if (set.goalSchemeType == GoalSchemeType.RPE)
                                  SizedBox(
                                    width: 50,
                                    child: CupertinoTextField(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 6,
                                      ),
                                      placeholder: '8.0',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      controller: TextEditingController(
                                        text: set.rpe?.toString() ?? '',
                                      ),
                                      onChanged: (value) {
                                        final rpe = double.tryParse(value);
                                        widget.formModel.updateSetValue(
                                          _selectedWeekIndex,
                                          dayIndex,
                                          exerciseIndex,
                                          setIndex,
                                          'rpe',
                                          rpe,
                                        );
                                      },
                                    ),
                                  )
                                else if (set.goalSchemeType ==
                                    GoalSchemeType.RPE_RANGE)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        child: CupertinoTextField(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 6,
                                          ),
                                          placeholder: '7.0',
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          controller: TextEditingController(
                                            text: set.minRpe?.toString() ?? '',
                                          ),
                                          onChanged: (value) {
                                            final rpe = double.tryParse(value);
                                            widget.formModel.updateSetValue(
                                              _selectedWeekIndex,
                                              dayIndex,
                                              exerciseIndex,
                                              setIndex,
                                              'minRpe',
                                              rpe,
                                            );
                                          },
                                        ),
                                      ),
                                      const Text(' - '),
                                      SizedBox(
                                        width: 40,
                                        child: CupertinoTextField(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 6,
                                          ),
                                          placeholder: '8.0',
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          controller: TextEditingController(
                                            text: set.maxRpe?.toString() ?? '',
                                          ),
                                          onChanged: (value) {
                                            final rpe = double.tryParse(value);
                                            widget.formModel.updateSetValue(
                                              _selectedWeekIndex,
                                              dayIndex,
                                              exerciseIndex,
                                              setIndex,
                                              'maxRpe',
                                              rpe,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                else if (set.goalSchemeType ==
                                    GoalSchemeType.PERCENT_OF_1RM)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        child: CupertinoTextField(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 6,
                                          ),
                                          placeholder: '75',
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          controller: TextEditingController(
                                            text: set.percent1RM != null
                                                ? (set.percent1RM! * 100)
                                                      .toString()
                                                : '',
                                          ),
                                          onChanged: (value) {
                                            final percent = double.tryParse(
                                              value,
                                            );
                                            if (percent != null) {
                                              widget.formModel.updateSetValue(
                                                _selectedWeekIndex,
                                                dayIndex,
                                                exerciseIndex,
                                                setIndex,
                                                'percent1RM',
                                                percent / 100,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      const Text('%'),
                                    ],
                                  ),
                              ],
                            ),
                            if (setIndex < exercise.sets.length - 1)
                              const Divider(height: 16),
                          ],
                        );
                      }).toList(),

                      // Add set button
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 10,
                          ),
                          color: CupertinoColors.activeBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                CupertinoIcons.add,
                                size: 14,
                                color: CupertinoColors.activeBlue,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Set hinzufügen',
                                style: TextStyle(
                                  color: CupertinoColors.activeBlue,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            widget.formModel.addSetToExerciseEntry(
                              _selectedWeekIndex,
                              dayIndex,
                              exerciseIndex,
                            );
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 16),

          CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: CupertinoColors.activeBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  CupertinoIcons.add,
                  size: 16,
                  color: CupertinoColors.activeBlue,
                ),
                SizedBox(width: 8),
                Text(
                  'Übung hinzufügen',
                  style: TextStyle(color: CupertinoColors.activeBlue),
                ),
              ],
            ),
            onPressed: () => _openExerciseSelection(dayIndex),
          ),
        ],
      ),
    );
  }

  // Helper method to get a string label for RepetitionSchemeType
  String _getRepetitionSchemeTypeLabel(RepetitionSchemeType type) {
    switch (type) {
      case RepetitionSchemeType.FIXED:
        return 'Fixed';
      case RepetitionSchemeType.RANGE:
        return 'Range';
      case RepetitionSchemeType.AMRAP:
        return 'AMRAP';
    }
  }

  // Helper method to get a string label for GoalSchemeType
  String _getGoalSchemeTypeLabel(GoalSchemeType type) {
    switch (type) {
      case GoalSchemeType.RPE:
        return 'RPE';
      case GoalSchemeType.RPE_RANGE:
        return 'RPE Range';
      case GoalSchemeType.PERCENT_OF_1RM:
        return '% 1RM';
    }
  }

  // Show a Cupertino-style picker for repetition scheme
  void _showRepetitionSchemePicker(
    BuildContext context,
    RepetitionSchemeType currentValue,
    Function(RepetitionSchemeType) onChanged,
  ) {
    final List<RepetitionSchemeType> options = RepetitionSchemeType.values;
    int selectedIndex = options.indexOf(currentValue);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: CupertinoColors.systemBackground,
          child: Column(
            children: [
              Container(
                height: 40,
                color: CupertinoColors.systemGrey6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Abbrechen'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Fertig'),
                      onPressed: () {
                        onChanged(options[selectedIndex]);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Material(
                  // We still need Material here for better performance with CupertinoPicker
                  color: Colors.transparent,
                  child: CupertinoPicker(
                    itemExtent: 32,
                    onSelectedItemChanged: (int index) {
                      selectedIndex = index;
                    },
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedIndex,
                    ),
                    children: options.map((type) {
                      return Center(
                        child: Text(_getRepetitionSchemeTypeLabel(type)),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Show a Cupertino-style picker for goal scheme
  void _showGoalSchemePicker(
    BuildContext context,
    GoalSchemeType currentValue,
    Function(GoalSchemeType) onChanged,
  ) {
    final List<GoalSchemeType> options = GoalSchemeType.values;
    int selectedIndex = options.indexOf(currentValue);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: CupertinoColors.systemBackground,
          child: Column(
            children: [
              Container(
                height: 40,
                color: CupertinoColors.systemGrey6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Abbrechen'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Fertig'),
                      onPressed: () {
                        onChanged(options[selectedIndex]);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Material(
                  // We still need Material here for better performance with CupertinoPicker
                  color: Colors.transparent,
                  child: CupertinoPicker(
                    itemExtent: 32,
                    onSelectedItemChanged: (int index) {
                      selectedIndex = index;
                    },
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedIndex,
                    ),
                    children: options.map((type) {
                      return Center(child: Text(_getGoalSchemeTypeLabel(type)));
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDayNameDialog(TrainingDay day) {
    final TextEditingController controller = TextEditingController(
      text: day.name,
    );

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Tag umbenennen'),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
            placeholder: 'Neuer Name',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Abbrechen'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text('Speichern'),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  day.name = controller.text;
                });
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
