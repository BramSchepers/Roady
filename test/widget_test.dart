// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roady/main.dart';
import 'package:roady/auth/auth_state.dart';

// Mock AuthState since we don't want to initialize Firebase in tests
class FakeAuthState extends ChangeNotifier implements AuthState {
  @override
  bool get isLoggedIn => false;

  @override
  User? get user => null;
}

void main() {
  testWidgets('App starts at Splash Screen smoke test',
      (WidgetTester tester) async {
    // #region agent log
    try {
      final file = File(r'c:\Users\brams\Desktop\Roady\.cursor\debug.log');
      file.writeAsStringSync(
          '{"id":"log_${DateTime.now().millisecondsSinceEpoch}","timestamp":${DateTime.now().millisecondsSinceEpoch},"location":"test/widget_test.dart:main","message":"Test starting","data":{},"sessionId":"debug-session","runId":"run1","hypothesisId":"h1-compilation-fix"}\n',
          mode: FileMode.append);
    } catch (e) {
      debugPrint('Log failed: $e');
    }
    // #endregion

    // Build our app and trigger a frame.
    await tester.pumpWidget(RoadyApp(authState: FakeAuthState()));

    // #region agent log
    try {
      final file = File(r'c:\Users\brams\Desktop\Roady\.cursor\debug.log');
      file.writeAsStringSync(
          '{"id":"log_${DateTime.now().millisecondsSinceEpoch}_pump","timestamp":${DateTime.now().millisecondsSinceEpoch},"location":"test/widget_test.dart:main","message":"Pumped widget","data":{},"sessionId":"debug-session","runId":"run1","hypothesisId":"h1-compilation-fix"}\n',
          mode: FileMode.append);
    } catch (e) {
      // ignore
    }
    // #endregion

    // Verify that our splash screen text is present
    expect(find.text('Welkom bij Roady'), findsOneWidget);

    // #region agent log
    try {
      final file = File(r'c:\Users\brams\Desktop\Roady\.cursor\debug.log');
      file.writeAsStringSync(
          '{"id":"log_${DateTime.now().millisecondsSinceEpoch}_verify","timestamp":${DateTime.now().millisecondsSinceEpoch},"location":"test/widget_test.dart:main","message":"Verified text","data":{},"sessionId":"debug-session","runId":"run1","hypothesisId":"h1-compilation-fix"}\n',
          mode: FileMode.append);
    } catch (e) {
      // ignore
    }
    // #endregion
  });
}
