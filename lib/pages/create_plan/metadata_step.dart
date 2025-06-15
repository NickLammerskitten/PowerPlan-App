import 'package:flutter/cupertino.dart';
import 'package:power_plan_fe/pages/create_plan/plan_form_model.dart';

class MetadataStep extends StatefulWidget {
  final PlanFormModel formModel;

  const MetadataStep({Key? key, required this.formModel}) : super(key: key);

  @override
  _MetadataStepState createState() => _MetadataStepState();
}

class _MetadataStepState extends State<MetadataStep> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.formModel.name;
    _nameController.addListener(_updateName);
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateName);
    _nameController.dispose();
    super.dispose();
  }

  void _updateName() {
    widget.formModel.name = _nameController.text;
    setState(() {}); // Refresh UI to show validation errors
  }

  void _showWeeksPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Abbrechen'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: const Text('Fertig'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {}); // Refresh to show validation
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoPicker(
                    magnification: 1.22,
                    squeeze: 1.2,
                    useMagnifier: true,
                    itemExtent: 32,
                    scrollController: FixedExtentScrollController(
                      initialItem: widget.formModel.weeks - 1,
                    ),
                    onSelectedItemChanged: (int selectedItem) {
                      widget.formModel.weeks = selectedItem + 1;
                      setState(() {}); // Refresh to show updated value
                    },
                    children: List<Widget>.generate(18, (int index) {
                      return Center(
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(fontSize: 22),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Planname', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: _nameController,
            placeholder: 'Name des Trainingsplans',
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.formModel.nameError != null
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemGrey4,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          if (widget.formModel.nameError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                widget.formModel.nameError!,
                style: const TextStyle(
                  color: CupertinoColors.systemRed,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 16),

          const Text('Wochen', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.formModel.weeksError != null
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemGrey4,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${widget.formModel.weeks}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.chevron_down),
                  onPressed: _showWeeksPicker,
                ),
              ],
            ),
          ),
          if (widget.formModel.weeksError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                widget.formModel.weeksError!,
                style: const TextStyle(
                  color: CupertinoColors.systemRed,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
