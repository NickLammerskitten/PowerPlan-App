import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:power_plan_fe/model/plan_list_item.dart';
import 'package:power_plan_fe/services/api_service.dart';

class PlanApi {

  final ApiService _apiService;

  PlanApi(this._apiService);

  Future<List<PlanListItem>> fetchPlans() async {
    try {
      final response = await http
          .get(Uri.parse('${_apiService.baseUrl}/plans'), headers: _apiService.headers)
          .timeout(_apiService.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => PlanListItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load plans: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plans: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<PlanListItem> fetchPlan(String id) async {
    try {
      final response = await http
          .get(Uri.parse('${_apiService.baseUrl}/plans/$id'), headers: _apiService.headers)
          .timeout(_apiService.timeout);

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        return PlanListItem.fromJson(jsonData);
      } else {
        throw Exception('Failed to load plan: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plan: $e');
      throw Exception('Network error: $e');
    }
  }
}