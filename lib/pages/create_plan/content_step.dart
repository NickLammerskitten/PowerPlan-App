import 'package:flutter/cupertino.dart';
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
    // Make sure we have at least one week with one day
    if (widget.formModel.trainingWeeks.isEmpty) {
      widget.formModel.weeks = 1;
    }

    // Listen for changes in the form model
    widget.formModel.addListener(_handleFormModelChanges);
  }

  @override
  void dispose() {
    widget.formModel.removeListener(_handleFormModelChanges);
    super.dispose();
  }

  void _handleFormModelChanges() {
    // Make sure the selected week index is valid after weeks change
    if (_selectedWeekIndex >= widget.formModel.trainingWeeks.length) {
      setState(() {
        _selectedWeekIndex = widget.formModel.trainingWeeks.isEmpty ? 0 : widget.formModel.trainingWeeks.length - 1;
      });
    }
  }

  void _openExerciseSelection(int dayIndex) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => SelectExercisePage(
          exerciseApi: widget.exerciseApi,
          onExerciseSelected: (exercise) {
            // Add the selected exercise to the day
            final currentWeek = widget.formModel.trainingWeeks[_selectedWeekIndex];
            final day = currentWeek.trainingDays[dayIndex];
            // For now, just add the exercise (implementation will be expanded later)
            widget.formModel.addExerciseToDay(_selectedWeekIndex, dayIndex, exercise);
            setState(() {});
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Safety check to avoid index errors
    if (widget.formModel.trainingWeeks.isEmpty) {
      return const Center(
        child: Text(
          'Bitte fügen Sie mindestens eine Trainingswoche hinzu',
          style: TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 16,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week tabs
        _buildWeekTabs(),
        const SizedBox(height: 16),

        // Current week content
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
    // Additional safety check
    if (_selectedWeekIndex >= widget.formModel.trainingWeeks.length) {
      _selectedWeekIndex = widget.formModel.trainingWeeks.length - 1;
    }

    final currentWeek = widget.formModel.trainingWeeks[_selectedWeekIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Training days list
        ...currentWeek.trainingDays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          return _buildTrainingDayCard(day, index);
        }),

        // Add day button
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
          // Day header
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

          // Exercise list
          if (day.exercises.isEmpty)
            const Text(
              'Keine Übungen gefunden.',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Column(
              children: day.exercises.map((exercise) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CupertinoColors.systemGrey4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.trash, size: 20, color: CupertinoColors.systemRed),
                        onPressed: () {
                          widget.formModel.removeExerciseFromDay(_selectedWeekIndex, dayIndex, exercise);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 16),

          // Add exercise button
          CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: CupertinoColors.activeBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(CupertinoIcons.add, size: 16, color: CupertinoColors.activeBlue),
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

  void _showEditDayNameDialog(TrainingDay day) {
    final TextEditingController controller = TextEditingController(text: day.name);

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
