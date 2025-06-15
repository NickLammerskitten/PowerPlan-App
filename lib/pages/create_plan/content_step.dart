import 'package:flutter/cupertino.dart';
import 'package:power_plan_fe/pages/create_plan/plan_form_model.dart';

class ContentStep extends StatefulWidget {
  final PlanFormModel formModel;

  const ContentStep({Key? key, required this.formModel}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    // Safety check to avoid index errors
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
        ...currentWeek.trainingDays.map((day) => _buildTrainingDayCard(day)),

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

  Widget _buildTrainingDayCard(TrainingDay day) {
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

          // Exercise list placeholder (will be implemented later)
          const Text(
            'Noch keine Übungen hinzugefügt',
            style: TextStyle(
              color: CupertinoColors.systemGrey,
              fontStyle: FontStyle.italic,
            ),
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
            onPressed: () {
              // To be implemented later
            },
          ),
        ],
      ),
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
