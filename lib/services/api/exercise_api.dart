import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:power_plan_fe/model/exercise_list_item.dart';
import 'package:power_plan_fe/services/api_service.dart';

class ExerciseApi {
  final ApiService _apiService;

  ExerciseApi(this._apiService);

  Future<List<ExerciseListItem>> getExercises({
    required ExercisesQueryFilters filters,
  }) async {
    final queryParams = filters.toQueryParameters();

    final queryString = queryParams.entries
        .map((e) {
          if (e.value is List) {
            return (e.value as List).map((item) => '${e.key}=$item').join('&');
          }
          return '${e.key}=${e.value}';
        })
        .join('&');

    final url = '${_apiService.baseUrl}/exercises?$queryString';

    try {
      final response = await http
          .get(Uri.parse(url), headers: _apiService.headers)
          .timeout(_apiService.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ExerciseListItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load exercises: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load exercises: $e');
    }
  }
}
