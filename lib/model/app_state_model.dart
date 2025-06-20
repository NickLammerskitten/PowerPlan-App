import 'package:flutter/foundation.dart' as foundation;
import 'package:power_plan_fe/model/plan.dart';
import 'package:power_plan_fe/model/plan_list_item.dart';
import 'package:power_plan_fe/model/plan_repository.dart';

class AppStateModel extends foundation.ChangeNotifier {
  final PlanRepository _repository = PlanRepository();

  bool _isLoading = false;
  String? _error;

  List<PlanListItem> _plans = [];

  List<PlanListItem> getPlans() => _plans;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _plans = await _repository.getPlans();
      _error = null;
    } catch (e) {
      _error = 'Fehler beim Laden der Pläne: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Plan?> getPlan(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final plan = await _repository.getPlan(id);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return plan;
    } catch (e) {
      _error = 'Fehler beim Laden des Plans: $e';
      print(_error);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
