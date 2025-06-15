
import 'package:flutter/material.dart';

class PlanFormModel extends ChangeNotifier {
  // Metadata fields
  String _name = '';
  int _weeks = 1;

  // Validation errors
  String? nameError;
  String? weeksError;

  // Getters and setters
  String get name => _name;
  set name(String value) {
    _name = value;
    validateName();
    notifyListeners();
  }

  int get weeks => _weeks;
  set weeks(int value) {
    _weeks = value;
    validateWeeks();
    notifyListeners();
  }

  // Validation methods
  bool validateName() {
    if (_name.trim().isEmpty) {
      nameError = 'Name ist erforderlich';
      return false;
    } else {
      nameError = null;
      return true;
    }
  }

  bool validateWeeks() {
    if (_weeks < 1 || _weeks > 18) {
      weeksError = 'Bitte wählen Sie zwischen 1 und 18 Wochen';
      return false;
    } else {
      weeksError = null;
      return true;
    }
  }

  bool validateMetadata() {
    return validateName() && validateWeeks();
  }
}