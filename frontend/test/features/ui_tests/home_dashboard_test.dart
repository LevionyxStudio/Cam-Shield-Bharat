import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/app.dart';
import 'package:scamshield/core/storage/onboarding_preferences.dart';
import 'package:scamshield/features/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'has_completed_onboarding_v2': true,
    });
  });

  testWidgets('Home Dashboard renders branding without top Settings icon, banner, quick actions, and empty scans', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final prefs = OnboardingPreferences();
    await prefs.setOnboardingCompleted(completed: true);

    await tester.pumpWidget(ScamShieldApp(onboardingPreferences: prefs));
    await tester.pumpAndSettle(const Duration(milliseconds: 3700));

    // 1. Header Branding & Logo
    expect(find.byType(ShieldWithCheckLogo), findsWidgets);
    expect(find.textContaining('ScamShield'), findsWidgets);
    expect(find.textContaining('Bharat'), findsWidgets);

    // 2. Critical Requirement: NO Settings icon in the header
    // The only settings icon is in the NavigationRail / BottomNavigation
    expect(find.text('Settings'), findsOneWidget);

    // 3. Hero Section
    expect(find.text('Stay safe, always.'), findsOneWidget);
    expect(
      find.text('Check suspicious messages, links, and offers before you act. All scans run privately on your device.'),
      findsOneWidget,
    );

    // 4. Safety Banner ("Be aware. Be safer.")
    expect(find.textContaining('Be aware.'), findsOneWidget);
    expect(find.textContaining('Be safer.'), findsOneWidget);
    expect(
      find.text('Detect scams, fake offers and risky links in seconds.'),
      findsOneWidget,
    );

    // 5. Quick Actions Section & Cards
    expect(find.textContaining('Quick action'), findsOneWidget);
    expect(find.text('Check Message'), findsWidgets);
    expect(find.text('Scan SMS & chat text'), findsOneWidget);
    expect(find.text('Scan Link'), findsOneWidget);
    expect(find.text('Verify suspicious URLs'), findsOneWidget);
    expect(find.text('Scam Alerts'), findsOneWidget);
    expect(find.text('Trending fraud alerts'), findsOneWidget);
    expect(find.text('Safety Tips'), findsOneWidget);
    expect(find.text('Citizen cyber guide'), findsOneWidget);

    // 6. Recent Scans truthful empty state
    expect(find.text('Recent Scans'), findsOneWidget);
    expect(find.text('View all'), findsOneWidget);
    expect(find.text('No recent scans yet'), findsOneWidget);
    expect(
      find.text('Messages and links you analyze will appear here for reference.'),
      findsOneWidget,
    );
  });
}
