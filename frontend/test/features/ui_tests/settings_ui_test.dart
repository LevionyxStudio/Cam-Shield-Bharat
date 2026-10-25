import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/core/theme/theme_controller.dart';
import 'package:scamshield/features/home/home_screen.dart';
import 'package:scamshield/features/settings/settings_screen.dart';
import 'package:scamshield/features/splash/splash_screen.dart';

void main() {
  group('SettingsScreen V2 UI & Interaction Tests', () {
    testWidgets('renders simple header, four grouped sections, and rows matching approved mockup', (
      WidgetTester tester,
    ) async {
      final controller = ThemeController(initialMode: ThemeMode.light);

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(themeController: controller),
        ),
      );

      // 1. Simple centered title: "Settings"
      expect(find.text('Settings'), findsOneWidget);

      // 2. Section headers
      expect(find.text('App Preferences'), findsOneWidget);
      expect(find.text('Privacy & Security'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('App Info'), findsOneWidget);

      // 3. Row titles
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Data Privacy'), findsOneWidget);
      expect(find.text('Permissions'), findsOneWidget);
      expect(find.text('About ScamShield Bharat'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);

      // 4. Subtitles
      expect(find.text('Light mode'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Your data stays on your device'), findsOneWidget);
      expect(find.text('Manage app permissions'), findsOneWidget);
      expect(find.text('Our mission and how it works'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
    });

    testWidgets('Appearance controls open theme modal and update ThemeController dynamically', (
      WidgetTester tester,
    ) async {
      final controller = ThemeController(initialMode: ThemeMode.light);

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(themeController: controller),
        ),
      );

      expect(controller.themeMode, ThemeMode.light);
      expect(find.text('Light mode'), findsOneWidget);

      // Tap Appearance tile
      await tester.tap(find.byKey(const Key('settings_appearance_tile')));
      await tester.pumpAndSettle();

      // Modal options should be visible
      expect(find.text('Choose your preferred display theme.'), findsOneWidget);
      expect(find.text('Dark mode'), findsOneWidget);
      expect(find.text('System default'), findsOneWidget);

      // Select Dark mode
      await tester.tap(find.byKey(const Key('theme_option_dark')));
      await tester.pumpAndSettle();

      expect(controller.themeMode, ThemeMode.dark);
      expect(find.text('Dark mode'), findsOneWidget);

      // Tap Appearance tile again to select System default
      await tester.tap(find.byKey(const Key('settings_appearance_tile')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('theme_option_system')));
      await tester.pumpAndSettle();

      expect(controller.themeMode, ThemeMode.system);
      expect(find.text('System default'), findsOneWidget);
    });

    testWidgets('Language row opens honest dialog explaining current English and future regional languages', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Tap Language tile
      await tester.tap(find.byKey(const Key('settings_language_tile')));
      await tester.pumpAndSettle();

      // Dialog contents
      expect(find.text('Language Support'), findsOneWidget);
      expect(find.text('English (Currently Active)'), findsOneWidget);
      expect(find.textContaining('Multi-language support for regional Indian languages'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.text('Language Support'), findsNothing);
    });

    testWidgets('Version row opens version details dialog displaying configured version 1.0.0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Scroll into view for narrow test viewport
      await tester.ensureVisible(find.byKey(const Key('settings_version_tile')));
      await tester.pumpAndSettle();

      // Tap Version tile
      await tester.tap(find.byKey(const Key('settings_version_tile')));
      await tester.pumpAndSettle();

      expect(find.text('Version 1.0.0 (Build 1)'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Version 1.0.0 (Build 1)'), findsNothing);
    });

    testWidgets('About ScamShield Bharat row navigates to dedicated About screen matching mockup and returns', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Tap About ScamShield Bharat
      await tester.ensureVisible(find.byKey(const Key('settings_about_tile')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings_about_tile')));
      await tester.pumpAndSettle();

      // Verify About Screen elements matching Mockup 2
      expect(find.text('About ScamShield Bharat'), findsOneWidget);
      expect(find.byType(ShieldWithCheckLogo), findsOneWidget);
      expect(find.text('Safer Messages. A Safer India.'), findsOneWidget);

      // Section 1: Our Mission
      expect(find.text('Our Mission'), findsOneWidget);
      expect(
        find.text(
          'ScamShield Bharat helps you identify and avoid scam messages using on-device AI. Our goal is to make digital communication safer for everyone in India.',
        ),
        findsOneWidget,
      );

      // Section 2: How It Works
      expect(find.text('How It Works'), findsOneWidget);
      expect(find.text('You enter or paste a message'), findsOneWidget);
      expect(find.text('The app analyzes it using on-device AI'), findsOneWidget);
      expect(find.text('You get a clear risk assessment'), findsOneWidget);

      // Section 3: Privacy First
      expect(find.text('Privacy First'), findsOneWidget);
      expect(
        find.text(
          'Your messages are analyzed on your device. They are not sent to any external server, keeping your information private and secure.',
        ),
        findsOneWidget,
      );

      // Tap back button
      await tester.tap(find.byKey(const Key('about_back_button')));
      await tester.pumpAndSettle();

      // Verified back on Settings main view
      expect(find.text('App Preferences'), findsOneWidget);
      expect(find.text('App Info'), findsOneWidget);
    });

    testWidgets('Data Privacy row navigates to Data Privacy screen and back button returns', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.ensureVisible(find.byKey(const Key('settings_data_privacy_tile')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings_data_privacy_tile')));
      await tester.pumpAndSettle();

      expect(find.text('Data Privacy'), findsOneWidget);
      expect(find.text('Your Data Stays on Your Device'), findsOneWidget);
      expect(find.text('100% Offline Heuristics'), findsOneWidget);
      expect(find.text('Zero Server Data Transmission'), findsOneWidget);
      expect(find.text('Session-Only Memory Storage'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      expect(find.text('App Preferences'), findsOneWidget);
    });

    testWidgets('Permissions row navigates to Permissions screen and back button returns', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.ensureVisible(find.byKey(const Key('settings_permissions_tile')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings_permissions_tile')));
      await tester.pumpAndSettle();

      expect(find.text('Permissions'), findsOneWidget);
      expect(find.text('Device Permissions'), findsOneWidget);
      expect(find.text('Clipboard Access'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Internet Access'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      expect(find.text('App Preferences'), findsOneWidget);
    });

    testWidgets('Terms of Service and Privacy Policy rows navigate to informational screens and back', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // 1. Terms of Service
      await tester.ensureVisible(find.byKey(const Key('settings_terms_tile')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings_terms_tile')));
      await tester.pumpAndSettle();

      expect(find.text('Terms of Service'), findsNWidgets(2)); // Header + title card
      expect(find.text('Informational Risk Scoring'), findsOneWidget);
      expect(find.text('Detection Scope & Limitations'), findsOneWidget);
      expect(find.text('User Responsibility & Reporting'), findsOneWidget);

      // Back to settings
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      // 2. Privacy Policy
      await tester.ensureVisible(find.byKey(const Key('settings_privacy_policy_tile')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings_privacy_policy_tile')));
      await tester.pumpAndSettle();

      expect(find.text('Privacy Policy'), findsNWidgets(2)); // Header + title card
      expect(find.text('1. No Account or Personal Identity Required'), findsOneWidget);
      expect(find.text('2. Local Message Processing'), findsOneWidget);

      // Back to settings
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      expect(find.text('App Preferences'), findsOneWidget);
    });

    testWidgets('HomeScreen shell keeps fixed bottom navigation bar visible on Settings and About subpage', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(initialTabIndex: 3), // Tab 3: Settings
        ),
      );

      // Navigation bar destinations present
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Check'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Settings'), findsNWidgets(2)); // Header + Navigation tab

      // Open About ScamShield Bharat subpage
      await tester.ensureVisible(find.byKey(const Key('settings_about_tile')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings_about_tile')));
      await tester.pumpAndSettle();

      // About page is displayed
      expect(find.text('About ScamShield Bharat'), findsOneWidget);

      // Bottom navigation bar remains fixed and visible!
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Check'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byKey(const Key('about_back_button')));
      await tester.pumpAndSettle();

      // Back on Settings main view
      expect(find.text('App Preferences'), findsOneWidget);
      expect(find.text('Settings'), findsNWidgets(2));
    });
  });
}
