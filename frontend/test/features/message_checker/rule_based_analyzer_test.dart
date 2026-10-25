import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/features/message_checker/data/rule_based_message_analyzer.dart';
import 'package:scamshield/features/message_checker/domain/message_analyzer.dart';

void main() {
  late RuleBasedMessageAnalyzer analyzer;

  setUp(() {
    analyzer = const RuleBasedMessageAnalyzer();
  });

  group('RuleBasedMessageAnalyzer — Scam Scenarios', () {
    test('detects obvious OTP theft in English as dangerous', () async {
      final request = AnalysisRequest(
        messageText: 'Dear SBI customer, your netbanking access is locked. Please share your OTP immediately to verify your account.',
        sender: 'SBI-ALERT',
      );

      final result = await analyzer.analyze(request);

      expect(result.source, AnalysisSource.localRuleBased);
      expect(result.riskLevel, RiskLevel.dangerous);
      expect(result.riskScore, greaterThanOrEqualTo(RuleBasedMessageAnalyzer.dangerousThreshold));
      expect(result.warningSigns.any((w) => w.code == 'credential_harvesting'), isTrue);
      expect(result.recommendations.any((r) => r.contains('Never share OTPs')), isTrue);
    });

    test('detects common Hinglish account-blocking scam as dangerous', () async {
      final request = AnalysisRequest(
        messageText: 'Aapka bank khata block kar diya gaya hai. Turant diye gaye link par click karein aur KYC update karein http://bit.ly/sbi-kyc-update',
        sender: '+919988776655',
      );

      final result = await analyzer.analyze(request);

      expect(result.riskLevel, RiskLevel.dangerous);
      expect(result.riskScore, greaterThanOrEqualTo(RuleBasedMessageAnalyzer.dangerousThreshold));
      expect(result.warningSigns.any((w) => w.code == 'suspicious_link'), isTrue);
      expect(result.warningSigns.any((w) => w.code == 'urgent_account_action'), isTrue);
      expect(result.warningSigns.any((w) => w.code == 'authority_impersonation'), isTrue);
    });

    test('detects suspicious payment link and advance fee request', () async {
      final request = AnalysisRequest(
        messageText: 'Congratulations! Selected for Amazon part time job. Pay registration fee of Rs 499 at http://shorturl.at/pay-now to activate task earnings.',
      );

      final result = await analyzer.analyze(request);

      expect(result.riskLevel, RiskLevel.dangerous);
      expect(result.warningSigns.any((w) => w.code == 'advance_fee_payment'), isTrue);
      expect(result.warningSigns.any((w) => w.code == 'suspicious_link'), isTrue);
      expect(result.warningSigns.any((w) => w.code == 'fake_job_offer'), isTrue);
    });

    test('detects fake lottery prize demanding processing fee', () async {
      final request = AnalysisRequest(
        messageText: 'Congrats! You have won Rs 25,00,000 in KBC Lucky Draw. Deposit advance fee of Rs 2,500 to claim your prize money.',
      );

      final result = await analyzer.analyze(request);

      expect(result.riskLevel, RiskLevel.dangerous);
      expect(result.warningSigns.any((w) => w.code == 'fake_reward_lottery'), isTrue);
      expect(result.warningSigns.any((w) => w.code == 'advance_fee_payment'), isTrue);
    });

    test('detects APK installation request from unknown link', () async {
      final request = AnalysisRequest(
        messageText: 'Electricity bill unpaid. Power will be cut off tonight at 9 PM. Immediately download and install bijli-update.apk from http://192.168.1.1/app.apk',
      );

      final result = await analyzer.analyze(request);

      expect(result.riskLevel, RiskLevel.dangerous);
      expect(result.warningSigns.any((w) => w.code == 'untrusted_apk'), isTrue);
      expect(result.warningSigns.any((w) => w.code == 'urgent_account_action'), isTrue);
      expect(result.warningSigns.any((w) => w.code == 'suspicious_link'), isTrue);
    });

    test('detects digital arrest CBI legal threat as dangerous', () async {
      final request = AnalysisRequest(
        messageText: 'This is CBI Crime Branch. A digital arrest warrant has been issued against your Aadhaar for illegal money laundering. Do not disconnect the call.',
      );

      final result = await analyzer.analyze(request);

      expect(result.riskLevel, RiskLevel.dangerous);
      expect(result.warningSigns.any((w) => w.code == 'legal_arrest_threat'), isTrue);
      expect(result.warningSigns.any((w) => w.code == 'authority_impersonation'), isTrue);
    });
  });

  group('RuleBasedMessageAnalyzer — Benign Counterexamples', () {
    test('classifies legitimate bank transaction alert without harvesting as safe', () async {
      final request = AnalysisRequest(
        messageText: 'Your SBI account XX1234 has been credited with INR 15,000.00 on 24-Oct-26. Available balance is INR 42,500. Never share your OTP with anyone.',
        sender: 'SBIINB',
      );

      final result = await analyzer.analyze(request);

      expect(result.riskLevel, RiskLevel.safe);
      expect(result.riskScore, 0);
      expect(result.warningSigns, isEmpty);
      expect(result.explanation.contains('score 0/100'), isTrue);
    });

    test('classifies ordinary personal chat as safe', () async {
      final request = AnalysisRequest(
        messageText: 'Hey Rohit, let us catch up for dinner this Saturday at the restaurant near Cyber Hub.',
        sender: 'Rohit',
      );

      final result = await analyzer.analyze(request);

      expect(result.riskLevel, RiskLevel.safe);
      expect(result.riskScore, 0);
      expect(result.warningSigns, isEmpty);
    });

    test('classifies urgent workplace request without scam signals as safe', () async {
      final request = AnalysisRequest(
        messageText: 'Hi team, please review the attached quarterly slide deck urgently before the 5 PM client presentation.',
      );

      final result = await analyzer.analyze(request);

      expect(result.riskLevel, RiskLevel.safe);
      expect(result.riskScore, 0);
      expect(result.warningSigns, isEmpty);
    });

    test('classifies educational authority context without threat as safe', () async {
      final request = AnalysisRequest(
        messageText: 'A police officer visited our school today to give a talk on road safety rules.',
      );

      final result = await analyzer.analyze(request);

      expect(result.riskLevel, RiskLevel.safe);
      expect(result.riskScore, 0);
    });
  });

  group('RuleBasedMessageAnalyzer — Architecture & Boundaries', () {
    test('prevents duplicate matches from inflating score repeatedly', () async {
      // Message repeats OTP and PIN multiple times
      final request = AnalysisRequest(
        messageText: 'Share your OTP. Enter your OTP. Tell me your OTP and PIN right now.',
      );

      final result = await analyzer.analyze(request);

      // credential_harvesting points is 40; should only be counted once
      expect(result.riskScore, 40);
      expect(result.warningSigns.where((w) => w.code == 'credential_harvesting').length, 1);
    });

    test('enforces risk score boundaries between 0 and 100', () async {
      // Multi-scam monster text matching every single rule
      final request = AnalysisRequest(
        messageText: 'CBI Police arrest warrant issued. Account blocked. Click bit.ly/kyc and install app.apk to pay Rs 500 fee and claim KBC prize. Share OTP now.',
      );

      final result = await analyzer.analyze(request);

      expect(result.riskScore, lessThanOrEqualTo(100));
      expect(result.riskScore, greaterThanOrEqualTo(0));
      expect(result.riskLevel, RiskLevel.dangerous);
    });

    test('produces deterministic identical output for repeated calls', () async {
      final request = AnalysisRequest(
        messageText: 'Urgent: Electricity power disconnect tonight. Download bijli.apk to verify.',
      );

      final result1 = await analyzer.analyze(request);
      final result2 = await analyzer.analyze(request);

      expect(result1.riskScore, result2.riskScore);
      expect(result1.riskLevel, result2.riskLevel);
      expect(result1.explanation, result2.explanation);
      expect(result1.warningSigns.length, result2.warningSigns.length);
      expect(result1.recommendations, equals(result2.recommendations));
      expect(result1.source, AnalysisSource.localRuleBased);
    });

    test('throws ArgumentError on empty or blank request', () {
      expect(() => AnalysisRequest(messageText: ''), throwsArgumentError);
      expect(() => AnalysisRequest(messageText: '   '), throwsArgumentError);
    });
  });
}
