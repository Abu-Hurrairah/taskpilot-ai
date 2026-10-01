import 'package:flutter_test/flutter_test.dart';
import 'package:taskpilot_ai/core/config.dart';
import 'package:taskpilot_ai/state/app_state.dart';

void main() {
  test('free quota blocks generation; preview is distinct from an entitlement',
      () async {
    final state = AppState();
    state.generations = AppConfig.freeLimit;
    expect(state.canGenerate, isFalse);
    await expectLater(state.generate('Build my app', 7), throwsException);
    expect(state.revenue.entitled, isFalse);
    state.revenue.setPreview(true);
    expect(state.pro, isTrue);
    expect(state.canGenerate, isTrue);
    expect(state.revenue.entitled, isFalse);
    state.revenue.setPreview(false);
    expect(state.pro, isFalse);
    state.dispose();
  });
}
