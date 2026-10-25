import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/core/storage/onboarding_preferences.dart';
import 'package:scamshield/core/theme/app_theme.dart';
import 'package:scamshield/features/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('SplashScreen defaults to 3500ms duration', () {
    const splash = SplashScreen();
    expect(splash.duration, const Duration(milliseconds: 3500));
  });

  testWidgets('SplashScreen renders logo, typography, tagline, and loading bar with Initializing label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const SplashScreen(autoNavigate: false),
      ),
    );

    // Visual brand elements
    expect(find.byType(ShieldWithCheckLogo), findsOneWidget);
    expect(find.text('ScamShield'), findsOneWidget);
    expect(find.text('Bharat'), findsOneWidget);
    expect(find.text('Stay alert. Stay safe.'), findsOneWidget);

    // Slim loading bar and initializing label
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Initializing...'), findsOneWidget);

    // Verify no circular spinner
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('SplashScreen animates loading bar progress smoothly from 0% to 100% over duration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        routes: {
          '/': (context) => const SplashScreen(
                duration: Duration(milliseconds: 1000),
                autoNavigate: true,
              ),
          '/onboarding': (context) => const Scaffold(body: Text('Onboarding Destination')),
        },
      ),
    );

    // Check initial progress is 0.0
    final initialIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(initialIndicator.value, 0.0);

    // Advance 500ms (halfway)
    await tester.pump(const Duration(milliseconds: 500));
    final midIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(midIndicator.value!, greaterThan(0.2));
    expect(midIndicator.value!, lessThan(0.8));

    // Settle remaining duration
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    expect(find.text('Onboarding Destination'), findsOneWidget);
  });

  testWidgets('SplashScreen navigates to /onboarding on first launch after 3.5s duration', (
    WidgetTester tester,
  ) async {
    final prefs = OnboardingPreferences();
    await prefs.setOnboardingCompleted(completed: false);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        routes: {
          '/': (context) => SplashScreen(
                duration: const Duration(milliseconds: 300),
                preferences: prefs,
              ),
          '/onboarding': (context) => const Scaffold(body: Text('Onboarding Loaded')),
          '/home': (context) => const Scaffold(body: Text('Home Loaded')),
        },
      ),
    );

    expect(find.text('ScamShield'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.text('Onboarding Loaded'), findsOneWidget);
  });

  testWidgets('SplashScreen navigates directly to /home for returning user after 3.5s duration', (
    WidgetTester tester,
  ) async {
    final prefs = OnboardingPreferences();
    await prefs.setOnboardingCompleted(completed: true);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        routes: {
          '/': (context) => SplashScreen(
                duration: const Duration(milliseconds: 300),
                preferences: prefs,
              ),
          '/onboarding': (context) => const Scaffold(body: Text('Onboarding Loaded')),
          '/home': (context) => const Scaffold(body: Text('Home Loaded')),
        },
      ),
    );

    expect(find.text('ScamShield'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.text('Home Loaded'), findsOneWidget);
  });
}
