import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskpilot_ai/models/plan.dart';
import 'package:taskpilot_ai/widgets/components.dart';

void main() {
  testWidgets('task card exposes priority, effort, day and expandable subtasks',
      (tester) async {
    final task = PilotTask.fromJson({
      'id': '1',
      'title': 'Mock interview',
      'description': 'Practice aloud',
      'priority': 'high',
      'category': 'Career',
      'estimated_minutes': 60,
      'suggested_day': 1,
      'subtasks': ['Record answers'],
      'completed': false
    });
    bool toggled = false;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: TaskCard(task, onToggle: () => toggled = true)))));
    expect(find.text('HIGH'), findsOneWidget);
    expect(find.text('60 min'), findsOneWidget);
    expect(find.text('Day 1'), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    expect(toggled, isTrue);
    await tester.tap(find.text('1 steps'));
    await tester.pumpAndSettle();
    expect(find.text('Record answers'), findsOneWidget);
  });
}
