import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Material;
import 'package:power_plan_fe/model/goal_scheme_type.dart';
import 'package:power_plan_fe/model/repetition_scheme_type.dart';
import 'package:power_plan_fe/model/set_entry_draft.dart';

/// Reusable editor widget for a single [SetEntryDraft].
///
/// The widget lets the user pick a [RepetitionSchemeType] and a
/// [GoalSchemeType] and edit the corresponding values. The parent must
/// trigger a rebuild after [onChanged] is invoked – typically by calling
/// `setState` or via a `ChangeNotifier`.
class SetEditor extends StatelessWidget {
  final int setIndex;
  final SetEntryDraft draft;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const SetEditor({
    Key? key,
    required this.setIndex,
    required this.draft,
    required this.onChanged,
    required this.onDelete,
  }) : super(key: key);

  static String repetitionSchemeTypeLabel(RepetitionSchemeType type) {
    switch (type) {
      case RepetitionSchemeType.FIXED:
        return 'Fixed';
      case RepetitionSchemeType.RANGE:
        return 'Range';
      case RepetitionSchemeType.AMRAP:
        return 'AMRAP';
    }
  }

  static String goalSchemeTypeLabel(GoalSchemeType type) {
    switch (type) {
      case GoalSchemeType.RPE:
        return 'RPE';
      case GoalSchemeType.RPE_RANGE:
        return 'RPE Range';
      case GoalSchemeType.PERCENT_OF_1RM:
        return '% 1RM';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Text(
                'Set ${setIndex + 1}:',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onDelete,
                child: const Icon(
                  CupertinoIcons.trash,
                  size: 16,
                  color: CupertinoColors.systemRed,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            children: [
              const Text('Reps: ', style: TextStyle(fontSize: 14)),
              _buildSchemeDropdown<RepetitionSchemeType>(
                context: context,
                current: draft.repetitionSchemeType,
                options: RepetitionSchemeType.values,
                labelFor: repetitionSchemeTypeLabel,
                onSelected: (t) {
                  draft.setRepetitionSchemeType(t);
                  onChanged();
                },
              ),
              const SizedBox(width: 8),
              _buildRepetitionValueFields(),
            ],
          ),
        ),
        Row(
          children: [
            const Text('Goal: ', style: TextStyle(fontSize: 14)),
            _buildSchemeDropdown<GoalSchemeType>(
              context: context,
              current: draft.goalSchemeType,
              options: GoalSchemeType.values,
              labelFor: goalSchemeTypeLabel,
              onSelected: (t) {
                draft.setGoalSchemeType(t);
                onChanged();
              },
            ),
            const SizedBox(width: 8),
            _buildGoalValueFields(),
          ],
        ),
      ],
    );
  }

  Widget _buildRepetitionValueFields() {
    switch (draft.repetitionSchemeType) {
      case RepetitionSchemeType.FIXED:
        return _intField(
          width: 50,
          placeholder: '8',
          value: draft.fixedReps,
          onChanged: (v) {
            draft.fixedReps = v;
            onChanged();
          },
        );
      case RepetitionSchemeType.RANGE:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _intField(
              width: 40,
              placeholder: '8',
              value: draft.minReps,
              onChanged: (v) {
                draft.minReps = v;
                onChanged();
              },
            ),
            const Text(' - '),
            _intField(
              width: 40,
              placeholder: '12',
              value: draft.maxReps,
              onChanged: (v) {
                draft.maxReps = v;
                onChanged();
              },
            ),
          ],
        );
      case RepetitionSchemeType.AMRAP:
        return const Text('AMRAP', style: TextStyle(fontSize: 14));
    }
  }

  Widget _buildGoalValueFields() {
    switch (draft.goalSchemeType) {
      case GoalSchemeType.RPE:
        return _doubleField(
          width: 50,
          placeholder: '8.0',
          value: draft.rpe,
          onChanged: (v) {
            draft.rpe = v;
            onChanged();
          },
        );
      case GoalSchemeType.RPE_RANGE:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _doubleField(
              width: 40,
              placeholder: '7.0',
              value: draft.minRpe,
              onChanged: (v) {
                draft.minRpe = v;
                onChanged();
              },
            ),
            const Text(' - '),
            _doubleField(
              width: 40,
              placeholder: '8.0',
              value: draft.maxRpe,
              onChanged: (v) {
                draft.maxRpe = v;
                onChanged();
              },
            ),
          ],
        );
      case GoalSchemeType.PERCENT_OF_1RM:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _doubleField(
              width: 50,
              placeholder: '75',
              value: draft.percent1RM != null ? draft.percent1RM! * 100 : null,
              onChanged: (v) {
                draft.percent1RM = v == null ? null : v / 100;
                onChanged();
              },
            ),
            const Text('%'),
          ],
        );
    }
  }

  Widget _intField({
    required double width,
    required String placeholder,
    required int? value,
    required ValueChanged<int?> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: CupertinoTextField(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        placeholder: placeholder,
        keyboardType: TextInputType.number,
        controller: TextEditingController(text: value?.toString() ?? ''),
        onChanged: (s) => onChanged(int.tryParse(s)),
      ),
    );
  }

  Widget _doubleField({
    required double width,
    required String placeholder,
    required double? value,
    required ValueChanged<double?> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: CupertinoTextField(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        placeholder: placeholder,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        controller: TextEditingController(text: value?.toString() ?? ''),
        onChanged: (s) => onChanged(double.tryParse(s)),
      ),
    );
  }

  Widget _buildSchemeDropdown<T>({
    required BuildContext context,
    required T current,
    required List<T> options,
    required String Function(T) labelFor,
    required ValueChanged<T> onSelected,
  }) {
    return GestureDetector(
      onTap: () => _showPicker<T>(
        context: context,
        current: current,
        options: options,
        labelFor: labelFor,
        onSelected: onSelected,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: CupertinoColors.systemGrey4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(labelFor(current), style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            const Icon(CupertinoIcons.chevron_down, size: 12),
          ],
        ),
      ),
    );
  }

  void _showPicker<T>({
    required BuildContext context,
    required T current,
    required List<T> options,
    required String Function(T) labelFor,
    required ValueChanged<T> onSelected,
  }) {
    int selectedIndex = options.indexOf(current);
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
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Fertig'),
                      onPressed: () {
                        onSelected(options[selectedIndex]);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: CupertinoPicker(
                    itemExtent: 32,
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedIndex,
                    ),
                    onSelectedItemChanged: (i) => selectedIndex = i,
                    children: options
                        .map((o) => Center(child: Text(labelFor(o))))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
