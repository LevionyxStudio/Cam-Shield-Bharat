import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/app.dart';
import 'package:scamshield/core/storage/onboarding_preferences.dart';
import 'package:scamshield/features/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Onboarding & First-Launch Navigation Flow', () {
    testWidgets('First launch: Splash transitions to Onboarding 1, Next to Onboarding 2, and Get started to Home', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final prefs = OnboardingPreferences();
      await prefs.setOnboardingCompleted(completed: false);

      await tester.pumpWidget(ScamShieldApp(onboardingPreferences: prefs));

      // 1. Splash Screen
      expect(find.text('ScamShield'), findsOneWidget);
      expect(find.text('Bharat'), findsOneWidget);
      expect(find.text('Stay alert. Stay safe.'), findsOneWidget);

      // Settle splash timer
      await tester.pumpAndSettle(const Duration(milliseconds: 3700));

      // 2. Onboarding Screen 1
      expect(find.textContaining('Check before'), findsOneWidget);
      expect(find.textContaining('Detect suspicious messages'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Advance to Screen 2 using "Next"
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // 3. Onboarding Screen 2
      expect(find.textContaining('Your privacy'), findsOneWidget);
      expect(
        find.textContaining('offline rule-based'),
        findsOneWidget,
      );
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      // Test "Back" button returns to Screen 1
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Check before'), findsOneWidget);

      // Advance to Screen 2 again
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Tap "Get started" to finish onboarding and open Home
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      // 4. Home Dashboard
      expect(find.text('Stay safe, always.'), findsOneWidget);
      expect(find.textContaining('Be aware.'), findsOneWidget);

      // Verify persistence flag is set
      final isCompleted = await prefs.isOnboardingCompleted();
      expect(isCompleted, isTrue);
    });

    testWidgets('Onboarding Screen 1: Skip button immediately marks complete and opens Home', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final prefs = OnboardingPreferences();
      await prefs.setOnboardingCompleted(completed: false);

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (context) => OnboardingScreen(preferences: prefs),
            '/home': (context) => const Scaffold(body: Text('Home Dashboard Screen')),
          },
        ),
      );

      expect(find.textContaining('Check before'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Tap "Skip"
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Directly on Home
      expect(find.text('Home Dashboard Screen'), findsOneWidget);

      final isCompleted = await prefs.isOnboardingCompleted();
      expect(isCompleted, isTrue);
    });

    testWidgets('Subsequent launch: Returning user transitions directly from Splash to Home', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final prefs = OnboardingPreferences();
      await prefs.setOnboardingCompleted(completed: true);

      await tester.pumpWidget(ScamShieldApp(onboardingPreferences: prefs));

      // Splash visible initially
      expect(find.text('ScamShield'), findsOneWidget);

      // Settle timer
      await tester.pumpAndSettle(const Duration(milliseconds: 3700));

      // Bypassed onboarding directly to Home
      expect(find.text('Stay safe, always.'), findsOneWidget);
      expect(find.textContaining('Check before'), findsNothing);
    });
  });
}
