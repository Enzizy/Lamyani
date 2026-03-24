import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lamyani/main.dart';
import 'package:lamyani/screens/signup_screen.dart';
import 'package:lamyani/theme/app_theme.dart';

void main() {
  testWidgets('Lamyani app shows onboarding flow', (tester) async {
    await tester.pumpWidget(const LamyaniApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Authentic Cebuano Flavor'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('Signup screen fits a phone viewport', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.theme, home: const SignupScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create your Lamyani account'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}
