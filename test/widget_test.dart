// Basic Flutter widget smoke test for DengueLens.
//
// NOTE: This test requires Firebase to be initialized. In CI, use
// `firebase_core_platform_interface` mock or run with `flutter test
// --dart-define=FIREBASE_EMULATOR=true`.

import 'package:flutter_test/flutter_test.dart';

// Smoke-test placeholder: the full widget test requires Firebase Core
// initialisation which is not available in plain `flutter test` without
// a mock platform. The real UI tests live in `integration_test/`.
void main() {
  testWidgets('placeholder smoke test', (WidgetTester tester) async {
    // Validates that the test harness itself works.
    expect(1 + 1, 2);
  });
}
