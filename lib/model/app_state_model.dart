import 'package:flutter/foundation.dart' as foundation;
import 'package:power_plan_fe/model/plan.dart';
import 'package:power_plan_fe/model/plan_repository.dart';

class AppStateModel extends foundation.ChangeNotifier {
  late List<Plan> _plans;

  List<Plan> getPlans() {
    return _plans;
  }

  void loadPlans() {
    _plans = PlanRepository().getPlans();
    notifyListeners();
    return;
  }
}