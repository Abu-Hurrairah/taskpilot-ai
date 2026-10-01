import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../models/plan.dart';

class ApiService {
  Future<dynamic> request(String method, String path,
      [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final req = http.Request(method, uri);
    req.headers['Content-Type'] = 'application/json';
    if (body != null) {
      req.body = jsonEncode(body);
    }
    try {
      final response = await http.Response.fromStream(
          await req.send().timeout(const Duration(seconds: 25)));
      if (response.statusCode >= 400) {
        throw Exception(
            'Request failed (${response.statusCode}). Check your input and try again.');
      }
      return response.body.isEmpty ? null : jsonDecode(response.body);
    } on http.ClientException {
      throw Exception(
          'Cannot reach TaskPilot backend. Start FastAPI and check API_BASE_URL.');
    }
  }

  Future<PilotPlan> generate(String goal, int days, bool advanced) async =>
      PilotPlan.fromJson(Map<String, dynamic>.from(await request(
              'POST',
              '/api/plans/generate',
              {'goal': goal, 'available_days': days, 'advanced': advanced})
          as Map));
  Future<List<PilotPlan>> list() async =>
      (await request('GET', '/api/plans') as List)
          .map((j) => PilotPlan.fromJson(Map<String, dynamic>.from(j as Map)))
          .toList();
  Future<PilotPlan> save(PilotPlan draft, String goal) async =>
      PilotPlan.fromJson(
          Map<String, dynamic>.from(await request('POST', '/api/plans', {
        ...draft.toDraftJson(),
        'source_goal': goal,
        'start_date': DateTime.now().toIso8601String().substring(0, 10)
      }) as Map));
  Future<void> toggle(PilotTask task) async {
    await request(
        'PATCH', '/api/tasks/${task.id}', {'completed': !task.completed});
  }

  Future<void> edit(PilotTask task, String title) async {
    await request('PATCH', '/api/tasks/${task.id}', {'title': title});
  }

  Future<void> delete(PilotPlan plan) async {
    await request('DELETE', '/api/plans/${plan.id}');
  }
}
