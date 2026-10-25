import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/core/theme/app_theme.dart';
import 'package:scamshield/features/message_checker/data/rule_based_message_analyzer.dart';
import 'package:scamshield/features/message_checker/domain/message_analyzer.dart';
import 'package:scamshield/features/message_checker/message_checker_screen.dart';

/// Test helper that throws an AnalyzerException to verify graceful error handling.
class _FailingAnalyzer implements MessageAnalyzer {
  final String errorMessage;
  _FailingAnalyzer(this.errorMessage);

  @override
  Future<AnalysisResult> analyze(AnalysisRequest request) async {
    throw AnalyzerException(errorMessage);
  }
}

/// Test helper that delays response to test duplicate submission prevention.
class _DelayedAnalyzer implements MessageAnalyzer {
  int callCount = 0;
  final Duration delay;
  _DelayedAnalyzer([this.delay = const Duration(milliseconds: 100)]);

  @override
  Future<AnalysisResult> analyze(AnalysisRequest request) async {
    callCount++;
    await Future.delayed(delay);
    return const RuleBasedMessageAnalyzer().analyze(request);
  }
}

void main() {
  group('MessageCheckerScreen — Real Analyzer Integration', () {
    testWidgets('MessageCheckerScreen renders branding, guidance banner, input card, and privacy card', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MessageCheckerScreen(),
        ),
      );

      // 1. Header & Title
      expect(find.textContaining('ScamShield'), findsOneWidget);
      expect(find.textContaining('Bharat'), findsOneWidget);
      expect(find.text('Check a Message'), findsOneWidget);
      expect(find.textContaining('Scan suspicious SMS'), findsOneWidget);

      // 2. Guidance Banner
      expect(find.text("Not sure if it's a scam?"), findsOneWidget);
      expect(find.textContaining('Paste the message below'), findsOneWidget);

      // 3. Input Card elements
      expect(find.text('Enter message text'), findsOneWidget);
      expect(find.text('Paste'), findsOneWidget);
      expect(find.text('0/2000'), findsOneWidget);
      expect(find.text('Try an example'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
      expect(find.text('Analyze message'), findsOneWidget);

      // 4. Privacy Card
      expect(find.text('Your privacy matters'), findsOneWidget);
      expect(find.textContaining('All scans run privately on your device'), findsOneWidget);
    });

    testWidgets('Empty input is handled safely without triggering analysis or navigating', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MessageCheckerScreen(),
        ),
      );

      // Tap Analyze message with empty text field
      await tester.tap(find.text('Analyze message'));
      await tester.pump();

      // Verify empty-input validation message appears
      expect(find.text('Please enter or paste a message to analyze.'), findsOneWidget);

      // Verify no navigation occurred
      expect(find.text('Analysis Result'), findsNothing);

      // Open Try an example modal
      await tester.tap(find.text('Try an example'));
      await tester.pumpAndSettle();

      // Verify demonstration options appear
      expect(find.text('Select a Demonstration Message'), findsOneWidget);
      expect(find.text('Bank KYC Account Suspension'), findsOneWidget);

      // Tap the Bank KYC example
      await tester.tap(find.text('Bank KYC Account Suspension'));
      await tester.pumpAndSettle();

      // Error message should disappear, text field should contain example text
      expect(find.text('Please enter or paste a message to analyze.'), findsNothing);
      expect(find.textContaining('Dear customer, your SBI account is locked'), findsOneWidget);

      // Clear text field
      await tester.tap(find.text('Clear'));
      await tester.pump();

      expect(find.textContaining('Dear customer, your SBI account is locked'), findsNothing);
      expect(find.text('0/2000'), findsOneWidget);
    });

    testWidgets('Message input has subtle #F7F9FC background, no unfocused border, and active blue focus border', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MessageCheckerScreen(),
        ),
      );

      final containerFinder = find.byType(AnimatedContainer);
      expect(containerFinder, findsOneWidget);

      final unfocusedContainer = tester.widget<AnimatedContainer>(containerFinder);
      final unfocusedDecoration = unfocusedContainer.decoration as BoxDecoration;

      // 1. Verify subtle #F7F9FC background
      expect(unfocusedDecoration.color, const Color(0xFFF7F9FC));

      // 2. Verify unfocused border is transparent
      final unfocusedBorder = unfocusedDecoration.border as Border;
      expect(unfocusedBorder.top.color, Colors.transparent);

      // 3. Tap to focus
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // 4. Verify focused border is primary blue #2563EB
      final focusedContainer = tester.widget<AnimatedContainer>(containerFinder);
      final focusedDecoration = focusedContainer.decoration as BoxDecoration;
      final focusedBorder = focusedDecoration.border as Border;
      expect(focusedBorder.top.color, const Color(0xFF2563EB));

      // 5. Verify TextField has borderless InputBorder.none decoration
      final textField = tester.widget<TextField>(find.byType(TextField));
      final inputDecoration = textField.decoration;
      expect(inputDecoration?.border, InputBorder.none);
      expect(inputDecoration?.enabledBorder, InputBorder.none);
      expect(inputDecoration?.focusedBorder, InputBorder.none);
    });

    testWidgets('Benign message produces genuine Safe result from RuleBasedMessageAnalyzer without demo selector', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MessageCheckerScreen(),
        ),
      );

      const benignMessage = 'Hey, are you free for lunch at 1 PM today near the office?';

      await tester.enterText(find.byType(TextField), benignMessage);
      await tester.pump();

      // Tap Analyze message
      await tester.tap(find.text('Analyze message'));
      await tester.pumpAndSettle();

      // CRITICAL REQUIREMENT: Demo selector modal must NOT appear
      expect(find.text('Preview Analysis Result'), findsNothing);
      expect(find.text('Demo • 92/100'), findsNothing);

      // Navigated to AnalysisResultScreen
      expect(find.text('Analysis Result'), findsOneWidget);

      // Status card reflects real analyzer result (Safe: 0 score)
      expect(find.text('No strong indicators detected'), findsOneWidget);
      expect(find.text('No clear scam indicators found.'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('/ 100'), findsOneWidget);

      // Rule-based disclaimer
      expect(
        find.text('Rule-based heuristic assessment • Not a guarantee of safety'),
        findsOneWidget,
      );

      // Original message reaches results screen
      expect(find.text('Analyzed Message'), findsOneWidget);
      expect(find.text(benignMessage), findsOneWidget);

      // Return back to Message Checker
      await tester.tap(find.text('Scan Another Message'));
      await tester.pumpAndSettle();

      expect(find.text('Check a Message'), findsOneWidget);
    });

    testWidgets('OTP-theft message produces genuine Dangerous result from RuleBasedMessageAnalyzer', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MessageCheckerScreen(),
        ),
      );

      const otpTheftMessage =
          'Dear customer, your SBI account is locked. Share your OTP immediately to verify: 948210';

      await tester.enterText(find.byType(TextField), otpTheftMessage);
      await tester.pump();

      await tester.tap(find.text('Analyze message'));
      await tester.pumpAndSettle();

      // Demo selector must NOT appear
      expect(find.text('Preview Analysis Result'), findsNothing);

      // Real analyzer output
      expect(find.text('Analysis Result'), findsOneWidget);
      expect(find.text('Dangerous'), findsOneWidget);
      expect(find.text('Strong scam indicators detected.'), findsOneWidget);

      // Score should be high (>= 60)
      expect(find.text('/ 100'), findsOneWidget);

      // Warning signs from RuleBasedMessageAnalyzer
      expect(find.text('Detected Warning Signs'), findsOneWidget);
      expect(find.text('Sensitive Credential / OTP Request'), findsOneWidget);

      // Recommendations from RuleBasedMessageAnalyzer
      expect(find.text('Recommended Actions'), findsOneWidget);
      expect(
        find.textContaining('Never share OTPs, PINs, passwords, or CVVs'),
        findsOneWidget,
      );

      // Original message reaches results screen
      expect(find.text(otpTheftMessage), findsOneWidget);
    });

    testWidgets('Suspicious-link message produces genuine Suspicious result from RuleBasedMessageAnalyzer', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MessageCheckerScreen(),
        ),
      );

      const suspiciousMessage =
          'Congratulations! You won Rs 50,000 lottery reward. Claim your prize at bit.ly/win-prize today!';

      await tester.enterText(find.byType(TextField), suspiciousMessage);
      await tester.pump();

      await tester.tap(find.text('Analyze message'));
      await tester.pumpAndSettle();

      // Demo selector must NOT appear
      expect(find.text('Preview Analysis Result'), findsNothing);

      // Real analyzer output
      expect(find.text('Analysis Result'), findsOneWidget);
      expect(find.text('Suspicious'), findsOneWidget);
      expect(find.text('Some warning signs detected.'), findsOneWidget);

      // Warning signs from RuleBasedMessageAnalyzer
      expect(find.text('Detected Warning Signs'), findsOneWidget);
      expect(find.text('Unsolicited Prize or Lottery Lure'), findsOneWidget);
      expect(find.text('Suspicious Link or URL Shortener'), findsOneWidget);

      // Original message reaches results screen
      expect(find.text(suspiciousMessage), findsOneWidget);
    });

    testWidgets('Analyzer errors do not crash the app, display error feedback, and allow retry', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final failingAnalyzer = _FailingAnalyzer('Offline heuristic engine encountered a parsing failure.');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MessageCheckerScreen(analyzer: failingAnalyzer),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Some test message that fails analyzer');
      await tester.pump();

      await tester.tap(find.text('Analyze message'));
      await tester.pumpAndSettle();

      // Error message is displayed in the UI
      expect(
        find.text('Offline heuristic engine encountered a parsing failure.'),
        findsOneWidget,
      );

      // Did not navigate to results screen
      expect(find.text('Analysis Result'), findsNothing);

      // User can retry or edit message
      await tester.enterText(find.byType(TextField), 'Another message text');
      await tester.pump();

      // Error disappears as user edits
      expect(
        find.text('Offline heuristic engine encountered a parsing failure.'),
        findsNothing,
      );
    });

    testWidgets('Duplicate submissions are prevented while analysis is running', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final delayedAnalyzer = _DelayedAnalyzer(const Duration(milliseconds: 200));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MessageCheckerScreen(analyzer: delayedAnalyzer),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello testing duplicate submission');
      await tester.pump();

      // First tap begins analysis
      await tester.tap(find.text('Analyze message'));
      await tester.pump();

      // Button enters loading state
      expect(find.text('Analyzing message...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Second tap while analyzing should be ignored
      await tester.tap(find.byKey(const Key('analyze_message_button')));
      await tester.pump();

      // Advance clock past the delay to finish analysis
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Analyzer was called exactly once
      expect(delayedAnalyzer.callCount, 1);
      expect(find.text('Analysis Result'), findsOneWidget);
    });
  });
}
