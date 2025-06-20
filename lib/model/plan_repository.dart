import 'package:power_plan_fe/model/plan.dart';
import 'package:power_plan_fe/model/plan_list_item.dart';
import 'package:power_plan_fe/services/api/plan_api.dart';
import 'package:power_plan_fe/services/api_service.dart';

class PlanRepository {
  final PlanApi _api = PlanApi(ApiService());

  List<PlanListItem>? _cachedPlans;

  Future<Plan?> getPlan(String id) async {
    try {
      return await _api.fetchPlan(id);
    } catch (e) {
      print('Error in repository getting plan: $e');

      return null;
    }
  }

  Future<List<PlanListItem>> getPlans() async {
    try {
      final plans = await _api.fetchPlans();

      _cachedPlans = plans;
      return plans;
    } catch (e) {
      print('Error in repository getting plans: $e');
      if (_cachedPlans != null) {
        return _cachedPlans!;
      }

      return [];
    }
  }

}