import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:power_plan_fe/model/plan.dart';
import 'package:power_plan_fe/model/plan_list_item.dart';
import 'package:power_plan_fe/model/set_entry_draft.dart';
import 'package:power_plan_fe/pages/create_plan/plan_form_model.dart';
import 'package:power_plan_fe/services/api_service.dart';

class PlanApi {
  final ApiService _apiService;

  PlanApi(this._apiService);

  Future<List<PlanListItem>> fetchPlans() async {
    try {
      final response = await http
          .get(
            Uri.parse('${_apiService.baseUrl}/plans'),
            headers: _apiService.headers,
          )
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

  Future<Plan> fetchPlan(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('${_apiService.baseUrl}/plans/$id'),
            headers: _apiService.headers,
          )
          .timeout(_apiService.timeout);

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

  Future<String?> createPlan(PlanFormModel plan) async {
    final createPlanRequestContent = plan.toCreatePlanRequest();
    final createPlanRequest = json.encode(createPlanRequestContent);

    print(createPlanRequest);

    try {
      final response = await http
          .post(
            Uri.parse('${_apiService.baseUrl}/plans'),
            headers: _apiService.headers,
            body: createPlanRequest,
          )
          .timeout(_apiService.timeout);

      if (response.statusCode == 200) {
        // TODO return planView
        return json.decode(response.body)['id'] as String?;
      } else {
        throw Exception('Failed to create plan: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating plan: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Adds a new set to an exercise entry of the given plan.
  ///
  /// `exerciseEntryId` is the id of the `ExerciseEntryView` (called
  /// `exerciseId` in the OpenAPI `CreateSetEntryRequest` schema – it refers
  /// to the plan exercise entry, not to the master exercise).
  Future<void> addSet(
    String planId,
    String exerciseEntryId,
    SetEntryDraft draft,
  ) async {
    final body = json.encode(draft.toCreateRequest(exerciseEntryId));
    final response = await http
        .post(
          Uri.parse('${_apiService.baseUrl}/plans/$planId/set'),
          headers: _apiService.headers,
          body: body,
        )
        .timeout(_apiService.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to add set: ${response.statusCode}');
    }
  }

  /// Updates an existing set of a plan.
  Future<void> editSet(
    String planId,
    String setId,
    SetEntryDraft draft,
  ) async {
    final body = json.encode(draft.toEditRequest());
    final response = await http
        .post(
          Uri.parse('${_apiService.baseUrl}/plans/$planId/set/$setId'),
          headers: _apiService.headers,
          body: body,
        )
        .timeout(_apiService.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to edit set: ${response.statusCode}');
    }
  }

  /// Removes a set from a plan.
  Future<void> removeSet(String planId, String setId) async {
    final response = await http
        .delete(
          Uri.parse('${_apiService.baseUrl}/plans/$planId/set/$setId'),
          headers: _apiService.headers,
        )
        .timeout(_apiService.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to remove set: ${response.statusCode}');
    }
  }

  /// Adds a new (empty) week to the plan.
  Future<void> addWeek(String planId) async {
    final response = await http
        .post(
          Uri.parse('${_apiService.baseUrl}/plans/$planId/week'),
          headers: _apiService.headers,
        )
        .timeout(_apiService.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to add week: ${response.statusCode}');
    }
  }

  /// Removes the week with the given id from the plan.
  Future<void> removeWeek(String planId, String weekId) async {
    final response = await http
        .delete(
          Uri.parse('${_apiService.baseUrl}/plans/$planId/week/$weekId'),
          headers: _apiService.headers,
        )
        .timeout(_apiService.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to remove week: ${response.statusCode}');
    }
  }

  /// Adds a new training day to the given week of the plan.
  Future<void> addDay(String planId, String weekId, String name) async {
    final body = json.encode({'weekId': weekId, 'name': name});
    final response = await http
        .post(
          Uri.parse('${_apiService.baseUrl}/plans/$planId/day'),
          headers: _apiService.headers,
          body: body,
        )
        .timeout(_apiService.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to add day: ${response.statusCode}');
    }
  }

  /// Edits a training day (e.g. renames it).
  Future<void> editDay(
    String planId,
    String dayId, {
    required String weekId,
    required String name,
  }) async {
    final body = json.encode({'weekId': weekId, 'name': name});
    final response = await http
        .post(
          Uri.parse('${_apiService.baseUrl}/plans/$planId/day/$dayId'),
          headers: _apiService.headers,
          body: body,
        )
        .timeout(_apiService.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to edit day: ${response.statusCode}');
    }
  }

  /// Removes a training day from the plan.
  Future<void> removeDay(String planId, String dayId) async {
    final response = await http
        .delete(
          Uri.parse('${_apiService.baseUrl}/plans/$planId/day/$dayId'),
          headers: _apiService.headers,
        )
        .timeout(_apiService.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to remove day: ${response.statusCode}');
    }
  }

  /// Moves a training day to a new position within its week.
  ///
  /// `dayIdBefore` is the id of the day after which the moved day should be
  /// inserted. If `null`, the day is moved to the beginning.
  Future<void> moveDay(
    String planId,
    String dayId, {
    String? dayIdBefore,
  }) async {
    final query = dayIdBefore == null ? '' : '?dayIdBefore=$dayIdBefore';
    final response = await http
        .post(
          Uri.parse('${_apiService.baseUrl}/plans/$planId/day/$dayId/move$query'),
          headers: _apiService.headers,
        )
        .timeout(_apiService.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to move day: ${response.statusCode}');
    }
  }

  /// Adds an exercise entry to a training day.
  Future<void> addExercise(
    String planId, {
    required String trainingDayId,
    required String exerciseId,
  }) async {
    final body = json.encode({
      'trainingDayId': trainingDayId,
      'exerciseId': exerciseId,
    });
    final response = await http
        .post(
          Uri.parse('${_apiService.baseUrl}/plans/$planId/exercise'),
          headers: _apiService.headers,
          body: body,
        )
        .timeout(_apiService.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to add exercise: ${response.statusCode}');
    }
  }

  /// Removes an exercise entry from the plan.
  Future<void> removeExercise(String planId, String exerciseEntryId) async {
    final response = await http
        .delete(
          Uri.parse(
            '${_apiService.baseUrl}/plans/$planId/exercise/$exerciseEntryId',
          ),
          headers: _apiService.headers,
        )
        .timeout(_apiService.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to remove exercise: ${response.statusCode}');
    }
  }

  /// Moves an exercise entry to a new position within its day.
  ///
  /// `exerciseIdBefore` is the id of the exercise entry after which the moved
  /// entry should be inserted. If `null`, the entry is moved to the beginning.
  Future<void> moveExercise(
    String planId,
    String exerciseEntryId, {
    String? exerciseIdBefore,
  }) async {
    final query =
        exerciseIdBefore == null ? '' : '?exerciseIdBefore=$exerciseIdBefore';
    final response = await http
        .post(
          Uri.parse(
            '${_apiService.baseUrl}/plans/$planId/exercise/$exerciseEntryId/move$query',
          ),
          headers: _apiService.headers,
        )
        .timeout(_apiService.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to move exercise: ${response.statusCode}');
    }
  }
}
