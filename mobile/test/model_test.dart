import 'package:flutter_test/flutter_test.dart';
import 'package:taskpilot_ai/models/plan.dart';

void main() {
  test('plan parses and calculates progress without rounding errors', () {
    final plan = PilotPlan.fromJson({
      'id': 'p1',
      'title': 'Interview',
      'summary': 'Prepare',
      'provider': 'local',
      'available_days': 3,
      'start_date': '2026-10-01',
      'tasks': [
        {
          'id': 't1',
          'title': 'Practice',
          'description': '',
          'priority': 'high',
          'category': 'Career',
          'estimated_minutes': 60,
          'suggested_day': 1,
          'subtasks': ['Mock interview'],
          'completed': true
        },
        {
          'id': 't2',
          'title': 'Review',
          'description': '',
          'priority': 'medium',
          'category': 'Career',
          'estimated_minutes': 30,
          'suggested_day': 2,
          'subtasks': ['Notes'],
          'completed': false
        }
      ]
    });
    expect(plan.progress, .5);
    expect(plan.done, 1);
    expect(plan.minutes, 90);
    expect(PilotPlan.fromJson(plan.toJson()).tasks.length, 2);
  });
}
