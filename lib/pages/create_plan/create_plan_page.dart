
import 'package:flutter/cupertino.dart';
import 'package:power_plan_fe/pages/create_plan/metadata_step.dart';
import 'package:power_plan_fe/pages/create_plan/content_step.dart';
import 'package:power_plan_fe/pages/create_plan/plan_form_model.dart';

class CreatePlanPage extends StatefulWidget {
  const CreatePlanPage({Key? key}) : super(key: key);

  @override
  _CreatePlanPageState createState() => _CreatePlanPageState();
}

class _CreatePlanPageState extends State<CreatePlanPage> {
  final PlanFormModel _formModel = PlanFormModel();
  int _currentStep = 0;
  String? _errorMessage;

  void _nextStep() {
    // Validate current step
    bool isValid = false;

    if (_currentStep == 0) {
      isValid = _formModel.validateMetadata();
      if (!isValid) {
        setState(() {
          _errorMessage = 'Bitte korrigieren Sie die Fehler in den Eingabefeldern';
        });
        return;
      }
    }

    setState(() {
      _errorMessage = null;
      _currentStep++;
    });
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Plan Erstellen'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Zurück'),
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Step indicator
            _buildStepIndicator(),
            const SizedBox(height: 24),

            // Error message
            if (_errorMessage != null)
              _buildErrorMessage(),

            // Current step content
            _currentStep == 0
                ? MetadataStep(formModel: _formModel)
                : ContendStep(),

            const SizedBox(height: 24),

            // Next/Finish button
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _currentStep >= 1
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.systemGrey4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: CupertinoColors.systemRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: CupertinoColors.systemRed),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (_currentStep == 0) {
      return SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          color: CupertinoColors.activeBlue,
          onPressed: _nextStep,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: const Text(
            'Weiter',
            style: TextStyle(color: CupertinoColors.white),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          color: CupertinoColors.activeBlue,
          onPressed: () {
            // TODO: Implement plan saving logic
            Navigator.of(context).pop();
          },
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: const Text(
            'Plan Erstellen',
            style: TextStyle(color: CupertinoColors.white),
          ),
        ),
      );
    }
  }
}