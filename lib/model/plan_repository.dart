import 'package:power_plan_fe/model/plan.dart';

class PlanRepository {
  Plan getPlan(String id) {
    // TODO: Fetch from backend
    return Plan(id: id);
  }

  List<Plan> getPlans() {
    return [
      Plan(id: 'plan1'),
      Plan(id: 'plan2'),
      Plan(id: 'plan3'),
    ];
  }
}