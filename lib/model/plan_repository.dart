import 'package:power_plan_fe/model/plan.dart';
import 'package:power_plan_fe/services/api_service.dart';

class PlanRepository {
  final ApiService _apiService = ApiService();

  List<Plan>? _cachedPlans;

  Future<Plan?> getPlan(String id) async {
    try {
      return await _apiService.fetchPlan(id);
    } catch (e) {
      print('Error in repository getting plan: $e');
      if (_cachedPlans != null) {
        final cachedPlan = _cachedPlans!.firstWhere(
              (plan) => plan.id == id,
          orElse: () => Plan(id: id),
        );
        return cachedPlan;
      }

      return null;
    }
  }

  Future<List<Plan>> getPlans() async {
    try {
      final plans = await _apiService.fetchPlans();

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