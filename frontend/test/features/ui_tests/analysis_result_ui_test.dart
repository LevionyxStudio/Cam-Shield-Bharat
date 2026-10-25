import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/core/theme/app_theme.dart';
import 'package:scamshield/features/message_checker/analysis_result_screen.dart';
import 'package:scamshield/features/message_checker/models/models.dart';

void main() {
  testWidgets('AnalysisResultScreen renders Dangerous state matching approved mockup without duplicate explanations', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final dangerousResult = AnalysisResult(
      riskLevel: RiskLevel.dangerous,
      riskScore: 92,
      explanation:
          'This message triggered multiple high-risk checks. Avoid interacting with it and verify through an official channel.',
      warningSigns: const [
        WarningSign(
          code: 'bank_impersonation',
          title: 'Impersonates a bank (SBI)',
          description: 'Claims to represent State Bank of India without verified domain.',
        ),
        WarningSign(
          code: 'urgency_coercion',
          title: 'Creates a sense of urgency',
          description: 'Pressure to act immediately under threat of service suspension.',
        ),
        WarningSign(
          code: 'credential_harvesting',
          title: 'Asks for OTP / sensitive information',
          description: 'Explicitly requests one-time password or credentials.',
        ),
        WarningSign(
          code: 'threat_suspension',
          title: 'Threatens account suspension',
          description: 'Threatens to block or freeze your account if no response.',
        ),
      ],
      recommendations: const [
        'Do not share any personal information',
        'Do not click on any links',
        'Verify directly through the official bank app or website',
        'Report and block the sender',
      ],
      source: AnalysisSource.localRuleBased,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: AnalysisResultScreen(
          result: dangerousResult,
          originalMessage:
              'Your SBI account will be blocked today. Send your OTP immediately to avoid suspension.',
        ),
      ),
    );

    // 1. Header & Branding (NO Settings icon in header)
    expect(find.textContaining('ScamShield'), findsOneWidget);
    expect(find.textContaining('Bharat'), findsOneWidget);
    expect(find.text('Analysis Result'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);

    // 2. Dangerous Status Card - Concise verdict, NOT duplicate explanation
    expect(find.text('Dangerous'), findsOneWidget);
    expect(find.text('Strong scam indicators detected.'), findsOneWidget);

    // 3. Risk Score section & Circular Gauge with distinct explanation
    expect(find.text('Risk Score'), findsOneWidget);
    expect(find.text('92'), findsOneWidget);
    expect(find.text('/ 100'), findsOneWidget);
    // Verified that explanation is rendered exactly once (no duplicate)
    expect(
      find.text(
        'This message triggered multiple high-risk checks. Avoid interacting with it and verify through an official channel.',
      ),
      findsOneWidget,
    );

    // 4. Analyzed Message Card
    expect(find.text('Analyzed Message'), findsOneWidget);
    expect(
      find.text(
        'Your SBI account will be blocked today. Send your OTP immediately to avoid suspension.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.copy_rounded), findsOneWidget);

    // 5. Detected Warning Signs Card
    expect(find.text('Detected Warning Signs'), findsOneWidget);
    expect(find.text('Impersonates a bank (SBI)'), findsOneWidget);
    expect(find.text('Creates a sense of urgency'), findsOneWidget);
    expect(find.text('Asks for OTP / sensitive information'), findsOneWidget);
    expect(find.text('Threatens account suspension'), findsOneWidget);

    // 6. Recommended Actions Card
    expect(find.text('Recommended Actions'), findsOneWidget);
    expect(find.text('Do not share any personal information'), findsOneWidget);
    expect(find.text('Do not click on any links'), findsOneWidget);
    expect(
      find.text('Verify directly through the official bank app or website'),
      findsOneWidget,
    );
    expect(find.text('Report and block the sender'), findsOneWidget);

    // 7. Bottom Actions
    expect(find.text('Scan Another Message'), findsOneWidget);
    expect(find.text('View in History'), findsOneWidget);

    // 8. Bottom Navigation Bar with Check active
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Check'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('AnalysisResultScreen renders Suspicious state with concise verdict and single explanation', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final suspiciousResult = AnalysisResult(
      riskLevel: RiskLevel.suspicious,
      riskScore: 58,
      explanation:
          'Several patterns deserve caution. Verify the sender and any requests independently.',
      warningSigns: const [
        WarningSign(
          code: 'unrealistic_prize',
          title: 'Unrealistic prize or reward',
        ),
        WarningSign(
          code: 'suspicious_link',
          title: 'Suspicious link',
        ),
      ],
      recommendations: const [
        'Do not click on the link',
        'Do not share personal or financial information',
      ],
      source: AnalysisSource.localRuleBased,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: AnalysisResultScreen(
          result: suspiciousResult,
          originalMessage:
              'Congratulations! You have won a 10,00,000 prize. Click here to claim now: http://lottery-prize.com',
        ),
      ),
    );

    // Concise top status
    expect(find.text('Suspicious'), findsOneWidget);
    expect(find.text('Some warning signs detected.'), findsOneWidget);

    // Single interpretation
    expect(find.text('58'), findsOneWidget);
    expect(find.text('/ 100'), findsOneWidget);
    expect(
      find.text('Several patterns deserve caution. Verify the sender and any requests independently.'),
      findsOneWidget,
    );

    expect(find.text('Detected Warning Signs'), findsOneWidget);
    expect(find.text('Unrealistic prize or reward'), findsOneWidget);
    expect(find.text('Suspicious link'), findsOneWidget);
    expect(find.text('Recommended Actions'), findsOneWidget);
    expect(find.text('Do not click on the link'), findsOneWidget);
  });

  testWidgets('AnalysisResultScreen renders Safe state with concise verdict and single safety nuance', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final safeResult = AnalysisResult(
      riskLevel: RiskLevel.safe,
      riskScore: 18,
      explanation:
          'The current checks found few warning signs, but automated analysis can miss scams.',
      warningSigns: const [
        WarningSign(
          code: 'regular_notification',
          title: 'Looks like a regular bank notification',
        ),
        WarningSign(
          code: 'no_urgent_action',
          title: 'No urgent action required',
        ),
        WarningSign(
          code: 'no_suspicious_links',
          title: 'No suspicious links detected',
        ),
        WarningSign(
          code: 'no_sensitive_request',
          title: 'No request for sensitive information',
        ),
      ],
      recommendations: const [
        'If this was expected, you can proceed normally',
        'Still verify through the official app or website if unsure',
        'Do not share personal information',
        'Report if you notice anything unusual',
      ],
      source: AnalysisSource.localRuleBased,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: AnalysisResultScreen(
          result: safeResult,
          originalMessage:
              'Your account statement for September is now available. Please log in to your banking app to view it.',
        ),
      ),
    );

    // Concise top status
    expect(find.text('No strong indicators detected'), findsOneWidget);
    expect(find.text('No clear scam indicators found.'), findsOneWidget);

    // Score & single explanation
    expect(find.text('18'), findsOneWidget);
    expect(find.text('/ 100'), findsOneWidget);
    expect(
      find.text('The current checks found few warning signs, but automated analysis can miss scams.'),
      findsOneWidget,
    );

    expect(find.text('Detected Information'), findsOneWidget);
    expect(find.text('Looks like a regular bank notification'), findsOneWidget);
    expect(find.text('No urgent action required'), findsOneWidget);
    expect(find.text('No suspicious links detected'), findsOneWidget);
    expect(find.text('No request for sensitive information'), findsOneWidget);
    expect(find.text('Recommended Actions'), findsOneWidget);
    expect(find.text('If this was expected, you can proceed normally'), findsOneWidget);
  });

  testWidgets('AnalysisResultScreen strictly prevents duplicate explanation rendering', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    const uniqueExplanation = 'Custom unique assessment from live engine.';
    final result = AnalysisResult(
      riskLevel: RiskLevel.dangerous,
      riskScore: 78,
      explanation: uniqueExplanation,
      source: AnalysisSource.localRuleBased,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: AnalysisResultScreen(result: result),
      ),
    );

    // Top status has its own concise category verdict
    expect(find.text('Strong scam indicators detected.'), findsOneWidget);

    // Custom explanation appears in exactly one place (below Risk Score)
    expect(find.text(uniqueExplanation), findsOneWidget);
  });

  testWidgets('AnalysisResultScreen handles empty warning signs, recommendations, and message text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final emptyResult = AnalysisResult(
      riskLevel: RiskLevel.safe,
      riskScore: 0,
      explanation: 'No indicators detected.',
      warningSigns: const [],
      recommendations: const [],
      source: AnalysisSource.localRuleBased,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: AnalysisResultScreen(result: emptyResult),
      ),
    );

    expect(find.text('(No message text supplied)'), findsOneWidget);
    expect(find.text('No specific warning signs identified in this message.'), findsOneWidget);
    expect(find.text('No additional recommendations.'), findsOneWidget);
  });

  testWidgets('AnalysisResultScreen triggers scan another callback and copy message', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool scannedAnother = false;

    final testResult = AnalysisResult(
      riskLevel: RiskLevel.dangerous,
      riskScore: 90,
      explanation: 'Scam alert.',
      source: AnalysisSource.localRuleBased,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: AnalysisResultScreen(
          result: testResult,
          originalMessage: 'Test message for clipboard copying',
          onScanAnother: () {
            scannedAnother = true;
          },
        ),
      ),
    );

    // Tap copy button
    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();
    expect(find.text('Message copied to clipboard'), findsOneWidget);

    // Tap Scan Another Message button
    await tester.tap(find.text('Scan Another Message'));
    await tester.pump();
    expect(scannedAnother, isTrue);
  });
}
