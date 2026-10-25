import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/app.dart';
import 'package:scamshield/core/storage/onboarding_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'has_completed_onboarding_v2': true,
    });
  });

  testWidgets('ScamShieldApp smoke test displays branding and navigation for returning user', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final prefs = OnboardingPreferences();
    await prefs.setOnboardingCompleted(completed: true);

    await tester.pumpWidget(
      ScamShieldApp(onboardingPreferences: prefs),
    );

    // Initial Splash Screen
    expect(find.text('ScamShield'), findsOneWidget);
    expect(find.text('Bharat'), findsOneWidget);
    expect(find.text('Stay alert. Stay safe.'), findsOneWidget);
    expect(find.text('Initializing...'), findsOneWidget);

    // Fast-forward past splash duration
    await tester.pumpAndSettle(const Duration(milliseconds: 3700));

    // Now in HomeScreen Dashboard
    expect(find.text('Stay safe, always.'), findsOneWidget);

    // Switch to Check tab
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    // In Message Checker Screen
    expect(find.text('Check a Message'), findsOneWidget);
    expect(find.text('Analyze message'), findsOneWidget);

    // Switch to History tab
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    // In History Screen
    expect(find.text('No scans yet'), findsOneWidget);

    // Switch to Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // In Settings Screen
    expect(find.text('Settings'), findsNWidgets(2)); // Header + Navigation tab
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Data Privacy'), findsOneWidget);
    expect(find.text('About ScamShield Bharat'), findsOneWidget);
  });
}
