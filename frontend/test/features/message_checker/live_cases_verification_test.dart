import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/features/message_checker/data/rule_based_message_analyzer.dart';
import 'package:scamshield/features/message_checker/domain/message_analyzer.dart';

void main() {
  const analyzer = RuleBasedMessageAnalyzer();

  group('ScamShield Bharat — Six Known Live-App Cases Regression Tests', () {
    test('Case 1: SBI OTP scam is dangerous with credentials, account threat, and bank impersonation', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Your SBI account will be blocked today. Send your OTP immediately to avoid suspension.',
      ));

      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'credential_harvesting'), isTrue);
      expect(res.warningSigns.any((w) => w.code == 'urgent_account_action'), isTrue);
      expect(res.warningSigns.any((w) => w.code == 'authority_impersonation'), isTrue);
      expect(res.recommendations.any((r) => r.contains('Never share OTPs')), isTrue);
    });

    test('Case 2: Hindi digital-arrest scam is dangerous with legal threat and payment demand', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'आपके आधार कार्ड से गैरकानूनी गतिविधि हुई है। पुलिस कार्रवाई से बचने के लिए तुरंत कॉल करें और पैसे ट्रांसफर करें।',
      ));

      expect(res.riskLevel, isNot(RiskLevel.safe));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'legal_arrest_threat'), isTrue);
      expect(res.warningSigns.any((w) => w.code == 'advance_fee_payment'), isTrue);
      expect(res.warningSigns.any((w) => w.code == 'authority_impersonation'), isTrue);
      expect(res.recommendations.any((r) => r.contains('Law enforcement')), isTrue);
    });

    test('Case 3: Fake work-from-home job reports fee and job scam without unrelated lottery warning', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Congratulations! You are selected for a work-from-home job. Pay ₹2,999 registration fees now to receive ₹5,000 daily.',
      ));

      expect(res.riskLevel, isNot(RiskLevel.safe));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'advance_fee_payment'), isTrue);
      expect(res.warningSigns.any((w) => w.code == 'fake_job_offer'), isTrue);
      // Defect verification: Lottery lure must not appear on an unrelated job scam
      expect(res.warningSigns.any((w) => w.code == 'fake_reward_lottery'), isFalse);
      expect(res.explanation.contains('Lottery'), isFalse);
      expect(res.recommendations.any((r) => r.contains('Legitimate employers never demand')), isTrue);
    });

    test('Case 4: Legitimate bank notification is safe with zero false positive indicators', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Your bank account was credited with ₹2,000 on 24 October. Available balance is ₹8,500. Thank you for banking with us.',
      ));

      expect(res.riskLevel, RiskLevel.safe);
      expect(res.riskScore, lessThan(30));
      expect(res.warningSigns, isEmpty);
      expect(res.explanation.contains('score 0/100'), isTrue);
    });

    test('Case 5: Hinglish OTP scam is dangerous with credential harvesting and account threat', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Aapka bank account aaj block ho jayega. Abhi OTP share karo warna account band ho jayega.',
      ));

      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'credential_harvesting'), isTrue);
      expect(res.warningSigns.any((w) => w.code == 'urgent_account_action'), isTrue);
      expect(res.recommendations.any((r) => r.contains('Never share OTPs')), isTrue);
    });

    test('Case 6: Punjabi account scam is dangerous with credential harvesting and account threat', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'ਤੁਹਾਡਾ ਬੈਂਕ ਖਾਤਾ ਅੱਜ ਬੰਦ ਹੋ ਜਾਵੇਗਾ। ਖਾਤਾ ਚਾਲੂ ਰੱਖਣ ਲਈ ਆਪਣਾ OTP ਤੁਰੰਤ ਭੇਜੋ।',
      ));

      expect(res.riskLevel, isNot(RiskLevel.safe));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'credential_harvesting'), isTrue);
      expect(res.warningSigns.any((w) => w.code == 'urgent_account_action'), isTrue);
    });
  });
}
