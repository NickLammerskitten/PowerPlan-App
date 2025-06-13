import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:power_plan_fe/model/plan.dart';

class ApiService {
  // TODO: Env variables
  static const String baseUrl = 'http://localhost:8080';

  static const Duration timeout = Duration(seconds: 10);

  // TODO: Env variables
  static const String _authToken = 'TODO: ABSTRACT AUTHENTICATION';

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_authToken',
    };
  }

  Future<List<Plan>> fetchPlans() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/plans'), headers: _headers)
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Plan.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load plans: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plans: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Plan> fetchPlan(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/plans/$id'), headers: _headers)
          .timeout(timeout);

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        return Plan.fromJson(jsonData);
      } else {
        throw Exception('Failed to load plan: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plan: $e');
      throw Exception('Network error: $e');
    }
  }
}
