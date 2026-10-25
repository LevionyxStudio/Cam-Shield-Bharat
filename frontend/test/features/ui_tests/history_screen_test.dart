import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/core/theme/app_theme.dart';
import 'package:scamshield/features/history/history_screen.dart';
import 'package:scamshield/features/home/home_screen.dart';
import 'package:scamshield/features/message_checker/models/models.dart';

void main() {
  final sampleItems = [
    ScanHistoryItem(
      id: '1',
      messageText: 'Dear customer, your SBI account is locked. Update KYC at bit.ly/sbi-verify',
      timestamp: DateTime(2026, 10, 22, 9, 14),
      riskLevel: RiskLevel.dangerous,
      riskScore: 92,
      result: AnalysisResult(
        riskLevel: RiskLevel.dangerous,
        riskScore: 92,
        explanation: 'Strong scam indicators detected.',
        source: AnalysisSource.localRuleBased,
      ),
    ),
    ScanHistoryItem(
      id: '2',
      messageText: 'Congratulations! You have won a 10,00,000 prize. Click here to claim',
      timestamp: DateTime(2026, 10, 21, 17, 32),
      riskLevel: RiskLevel.suspicious,
      riskScore: 58,
      result: AnalysisResult(
        riskLevel: RiskLevel.suspicious,
        riskScore: 58,
        explanation: 'Some warning signs detected.',
        source: AnalysisSource.localRuleBased,
      ),
    ),
    ScanHistoryItem(
      id: '3',
      messageText: 'Your account statement for September is now available. Log in to view',
      timestamp: DateTime(2026, 10, 20, 11, 6),
      riskLevel: RiskLevel.safe,
      riskScore: 18,
      result: AnalysisResult(
        riskLevel: RiskLevel.safe,
        riskScore: 18,
        explanation: 'No clear scam indicators found.',
        source: AnalysisSource.localRuleBased,
      ),
    ),
  ];

  testWidgets('HistoryScreen renders truthful empty state matching mockup and handles Scan a Message action', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool checkedMessage = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: HistoryScreen(
          onCheckMessage: () {
            checkedMessage = true;
          },
        ),
      ),
    );

    // 1. Header: "Scan History" (NO second branding row, NO settings icon)
    expect(find.text('Scan History'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsNothing);

    // 2. Search Bar placeholder
    expect(find.text('Search previous scans...'), findsOneWidget);

    // 3. Filter tabs
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Dangerous'), findsOneWidget);
    expect(find.text('Suspicious'), findsOneWidget);
    expect(find.text('Low Risk'), findsOneWidget);

    // 4. Truthful Empty State
    expect(find.text('No scans yet'), findsOneWidget);
    expect(
      find.text('Messages you analyze will appear here so you can easily review them later.'),
      findsOneWidget,
    );
    expect(find.text('Scan a Message'), findsOneWidget);

    // 5. Tap Scan a Message button
    await tester.tap(find.text('Scan a Message'));
    await tester.pump();
    expect(checkedMessage, isTrue);
  });

  testWidgets('HistoryScreen renders flat history list with badges, scores, and formatted timestamps', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: HistoryScreen(initialItems: sampleItems),
      ),
    );

    // Header & Search
    expect(find.text('Scan History'), findsOneWidget);
    expect(find.text('Search previous scans...'), findsOneWidget);

    // Previews
    expect(find.textContaining('Dear customer, your SBI account is locked'), findsOneWidget);
    expect(find.textContaining('Congratulations! You have won'), findsOneWidget);
    expect(find.textContaining('Your account statement for September'), findsOneWidget);

    // Formatted timestamps
    expect(find.text('22 Oct 2026, 9:14 AM'), findsOneWidget);
    expect(find.text('21 Oct 2026, 5:32 PM'), findsOneWidget);
    expect(find.text('20 Oct 2026, 11:06 AM'), findsOneWidget);

    // Restrained Risk Labels
    expect(find.text('Dangerous'), findsWidgets); // Tab + badge
    expect(find.text('Suspicious'), findsWidgets); // Tab + badge
    expect(find.text('Low Risk'), findsWidgets); // Tab + badge

    // Scores
    expect(find.text('92'), findsOneWidget);
    expect(find.text('58'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text(' / 100'), findsNWidgets(3));

    // Chevrons
    expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(3));
  });

  testWidgets('HistoryScreen filters records correctly using risk tabs', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: HistoryScreen(initialItems: sampleItems),
      ),
    );

    // Tap "Dangerous" tab
    await tester.tap(find.text('Dangerous').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Dear customer, your SBI account is locked'), findsOneWidget);
    expect(find.textContaining('Congratulations! You have won'), findsNothing);
    expect(find.textContaining('Your account statement for September'), findsNothing);

    // Tap "Suspicious" tab
    await tester.tap(find.text('Suspicious').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Dear customer, your SBI account is locked'), findsNothing);
    expect(find.textContaining('Congratulations! You have won'), findsOneWidget);
    expect(find.textContaining('Your account statement for September'), findsNothing);

    // Tap "Low Risk" tab
    await tester.tap(find.text('Low Risk').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Dear customer, your SBI account is locked'), findsNothing);
    expect(find.textContaining('Congratulations! You have won'), findsNothing);
    expect(find.textContaining('Your account statement for September'), findsOneWidget);

    // Tap "All" tab to restore all items
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Dear customer, your SBI account is locked'), findsOneWidget);
    expect(find.textContaining('Congratulations! You have won'), findsOneWidget);
    expect(find.textContaining('Your account statement for September'), findsOneWidget);
  });

  testWidgets('HistoryScreen search updates dynamically and shows No matching scans when not found', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: HistoryScreen(initialItems: sampleItems),
      ),
    );

    // Search for "SBI"
    await tester.enterText(find.byType(TextField), 'sbi');
    await tester.pumpAndSettle();

    expect(find.textContaining('Dear customer, your SBI account is locked'), findsOneWidget);
    expect(find.textContaining('Congratulations! You have won'), findsNothing);
    expect(find.textContaining('Your account statement for September'), findsNothing);

    // Clear via 'x' icon
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.textContaining('Dear customer, your SBI account is locked'), findsOneWidget);
    expect(find.textContaining('Congratulations! You have won'), findsOneWidget);

    // Search for non-existent text
    await tester.enterText(find.byType(TextField), 'randomNonExistentMessage');
    await tester.pumpAndSettle();

    // Verify No matching scans empty state
    expect(find.text('No matching scans'), findsOneWidget);
    expect(find.text('Try another search or change the selected filter.'), findsOneWidget);
  });

  testWidgets('Tapping a history item opens AnalysisResultScreen with result and message', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: HistoryScreen(initialItems: sampleItems),
      ),
    );

    // Tap the first item (Dangerous SBI message)
    await tester.tap(find.textContaining('Dear customer, your SBI account is locked'));
    await tester.pumpAndSettle();

    // Verify AnalysisResultScreen opens
    expect(find.text('Analysis Result'), findsOneWidget);
    expect(find.text('Dangerous'), findsOneWidget);
    expect(find.text('92'), findsOneWidget);
    expect(find.textContaining('Dear customer, your SBI account is locked'), findsOneWidget);
  });

  testWidgets('HomeScreen shell hosts HistoryScreen at tab index 2 with fixed bottom navigation', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const HomeScreen(initialTabIndex: 2),
      ),
    );

    // Verify Scan History is shown
    expect(find.text('Scan History'), findsOneWidget);
    expect(find.text('No scans yet'), findsOneWidget);

    // Verify bottom navigation bar has History active
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Check'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
