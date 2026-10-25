import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/features/message_checker/data/rule_based_message_analyzer.dart';
import 'package:scamshield/features/message_checker/domain/message_analyzer.dart';

void main() {
  const analyzer = RuleBasedMessageAnalyzer();

  group('ScamShield Bharat — Comprehensive Audit Test Matrix', () {
    // Category A: Credential and OTP Theft
    group('Category A: Credential & OTP Theft', () {
      test('A1a: Standalone immediate OTP request flags suspicious with credential harvesting', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Your account is under review. Send your OTP immediately to verify your identity: 654321.',
        ));
        expect(res.riskLevel, RiskLevel.suspicious);
        expect(res.riskScore, 40);
        expect(res.warningSigns.any((w) => w.code == 'credential_harvesting'), isTrue);
      });

      test('A1b: Bank account closure threat combined with OTP request is dangerous', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Your bank account will be blocked today. Send your OTP immediately to avoid suspension.',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.riskScore, greaterThanOrEqualTo(60));
        expect(res.warningSigns.any((w) => w.code == 'credential_harvesting'), isTrue);
        expect(res.warningSigns.any((w) => w.code == 'urgent_account_action'), isTrue);
      });

      test('A2: Obfuscated 0-T-P and P@ssword with unblock demand is dangerous', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Security Notice: Share your 0-T-P or P@ssword to unblock your netbanking access.',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.riskScore, greaterThanOrEqualTo(60));
        expect(res.warningSigns.any((w) => w.code == 'credential_harvesting'), isTrue);
      });

      test('A3: UPI PIN solicitation disguised as refund', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Refund of Rs 2,000 approved. Scan the QR code and enter UPI PIN to receive money.',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'advance_fee_payment'), isTrue);
      });
    });

    // Category B: Account & KYC Threats
    group('Category B: Account & KYC Threats', () {
      test('B1: SIM card deactivation threat within 24 hours', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Airtel alert: Your SIM card will be deactivated within 24 hours due to missing KYC. Click http://bit.ly/airtel-sim-kyc',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'urgent_account_action'), isTrue);
        expect(res.warningSigns.any((w) => w.code == 'suspicious_link'), isTrue);
      });

      test('B2: PAN card not linked netbanking blocked', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Dear customer, your PAN card not linked to SBI account. Netbanking access blocked. Update now: https://sbi-pan-kyc.xyz',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'urgent_account_action'), isTrue);
        expect(res.warningSigns.any((w) => w.code == 'authority_impersonation'), isTrue);
      });
    });

    // Category C: Digital Arrest & Legal Threats
    group('Category C: Digital Arrest & Legal Threats', () {
      test('C1: Fake CBI narcotics parcel arrest warrant', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'CBI Crime Branch: Narcotics parcel intercepted at customs under your name. Non-bailable arrest warrant issued. Digital arrest in progress.',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'legal_arrest_threat'), isTrue);
        expect(res.warningSigns.any((w) => w.code == 'authority_impersonation'), isTrue);
      });

      test('C2: Hindi Aadhaar illegal activity and police threat (Live Case 2)', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'आपके आधार कार्ड से गैरकानूनी गतिविधि हुई है। पुलिस कार्रवाई से बचने के लिए तुरंत कॉल करें और पैसे ट्रांसफर करें।',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'legal_arrest_threat'), isTrue);
        expect(res.warningSigns.any((w) => w.code == 'advance_fee_payment'), isTrue);
      });
    });

    // Category D: Advance-Payment and Job Scams
    group('Category D: Advance-Payment & Job Scams', () {
      test('D1: Work from home job requiring registration fees (Live Case 3)', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Congratulations! You are selected for a work-from-home job. Pay ₹2,999 registration fees now to receive ₹5,000 daily.',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'fake_job_offer'), isTrue);
        expect(res.warningSigns.any((w) => w.code == 'advance_fee_payment'), isTrue);
        expect(res.warningSigns.any((w) => w.code == 'fake_reward_lottery'), isFalse);
      });

      test('D2: Task scam with advance deposit to release earnings', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Work from home daily Rs 2500 per task. Join karne ke liye registration fee Rs 500 pehle jama karein.',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'advance_fee_payment'), isTrue);
      });
    });

    // Category E: Prize, Lottery, and Giveaway Scams
    group('Category E: Prize & Lottery Scams', () {
      test('E1: KBC lucky draw requiring processing fee', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Congrats! You have won Rs 25,00,000 in KBC Lucky Draw. Deposit advance fee of Rs 2,500 to claim your prize money.',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'fake_reward_lottery'), isTrue);
        expect(res.warningSigns.any((w) => w.code == 'advance_fee_payment'), isTrue);
      });

      test('E2: Prize claim without fee flags suspicious with lottery warning', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Congratulations! You are the lucky draw winner of KBC lottery prize worth Rs 25,00,000. Call manager to claim.',
        ));
        expect(res.riskLevel, RiskLevel.suspicious);
        expect(res.warningSigns.any((w) => w.code == 'fake_reward_lottery'), isTrue);
      });
    });

    // Category F: Suspicious Links and Downloads
    group('Category F: Suspicious Links & Downloads', () {
      test('F1: Untrusted APK download combined with power cutoff threat', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Electricity bill unpaid. Power will be cut off tonight. Download bijli-update.apk to verify.',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'untrusted_apk'), isTrue);
        expect(res.warningSigns.any((w) => w.code == 'urgent_account_action'), isTrue);
      });

      test('F2: AnyDesk remote support installation request', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Your bank KYC is incomplete. Download AnyDesk for remote verification with customer support.',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'untrusted_apk'), isTrue);
      });
    });

    // Category G: Impersonation & Social Engineering
    group('Category G: Impersonation & Social Engineering', () {
      test('G1: India Post depot parcel held at unverified link', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'India Post: Your parcel is held at depot due to wrong address. Update address: https://indiapost-parcel.top/track',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'authority_impersonation'), isTrue);
        expect(res.warningSigns.any((w) => w.code == 'suspicious_link'), isTrue);
      });
    });

    // Category H: Hindi — Devanagari
    group('Category H: Hindi Devanagari Detection', () {
      test('H1: Hindi SBI account suspension and OTP demand', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'प्रिय ग्राहक, आपका एसबीआई खाता निलंबित कर दिया गया है। अपना ओटीपी साझा करें ताकि खाता तुरंत सक्रिय हो सके।',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'credential_harvesting'), isTrue);
        expect(res.warningSigns.any((w) => w.code == 'urgent_account_action'), isTrue);
      });

      test('H2: Hindi CBI non-bailable arrest warrant', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'केंद्रीय जांच ब्यूरो (CBI) नोटिस: आपके खिलाफ गैर-जमानती वारंट जारी किया गया है। गिरफ्तारी से बचने के लिए तुरंत दिए गए नंबर पर संपर्क करें।',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'legal_arrest_threat'), isTrue);
      });
    });

    // Category I: Punjabi — Gurmukhi
    group('Category I: Punjabi Gurmukhi Detection', () {
      test('I1: Punjabi bank account closure and OTP demand (Live Case 6)', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'ਤੁਹਾਡਾ ਬੈਂਕ ਖਾਤਾ ਅੱਜ ਬੰਦ ਹੋ ਜਾਵੇਗਾ। ਖਾਤਾ ਚਾਲੂ ਰੱਖਣ ਲਈ ਆਪਣਾ OTP ਤੁਰੰਤ ਭੇਜੋ।',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'credential_harvesting'), isTrue);
        expect(res.warningSigns.any((w) => w.code == 'urgent_account_action'), isTrue);
      });

      test('I2: Punjabi KYC 12-hour ultimatum', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'ਤੁਹਾਡਾ ਕੇਵਾਈਸੀ ਅੱਪਡੇਟ ਬਾਕੀ ਹੈ। 12 ਘੰਟਿਆਂ ਦੇ ਅੰਦਰ ਆਪਣਾ ਪੈਨ ਕਾਰਡ ਲਿੰਕ ਕਰੋ ਨਹੀਂ ਤਾਂ ਖਾਤਾ ਬੰਦ ਕਰ ਦਿੱਤਾ ਜਾਵੇਗਾ।',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'urgent_account_action'), isTrue);
      });
    });

    // Category J: Hinglish Code-Switching
    group('Category J: Hinglish Detection', () {
      test('J1: Hinglish account block and OTP share demand (Live Case 5)', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Aapka bank account aaj block ho jayega. Abhi OTP share karo warna account band ho jayega.',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'credential_harvesting'), isTrue);
        expect(res.warningSigns.any((w) => w.code == 'urgent_account_action'), isTrue);
      });

      test('J2: Hinglish FIR registered and police dispatch threat', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'CBI Police notice: Aapke khilaf FIR registered ho chuki hai. Police bheji ja rahi hai. Case settle karne ke liye turant call karein.',
        ));
        expect(res.riskLevel, RiskLevel.dangerous);
        expect(res.warningSigns.any((w) => w.code == 'legal_arrest_threat'), isTrue);
      });
    });

    // Category K: Legitimate Messages & False Positive Protection
    group('Category K: Legitimate Safeguards', () {
      test('K1: Legitimate bank credit alert (Live Case 4)', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Your bank account was credited with ₹2,000 on 24 October. Available balance is ₹8,500. Thank you for banking with us.',
        ));
        expect(res.riskLevel, RiskLevel.safe);
        expect(res.riskScore, 0);
        expect(res.warningSigns, isEmpty);
      });

      test('K2: Legitimate debit SMS with advisory', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Rs 1,250.00 debited from A/c XX4092 on 24-Oct-26 at SWIGGY. UPI Ref 429810284910. If not done by you, call 1800112211.',
        ));
        expect(res.riskLevel, RiskLevel.safe);
        expect(res.riskScore, 0);
      });

      test('K3: Legitimate OTP delivery with bank safety advisory', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: '849102 is your OTP for purchase of Rs 850.00 at Amazon. Valid for 10 mins. Never share your OTP with anyone. Bank staff never calls to ask for OTP.',
        ));
        expect(res.riskLevel, RiskLevel.safe);
        expect(res.riskScore, 0);
        expect(res.warningSigns, isEmpty);
      });

      test('K4: Legitimate Hindi debit notification', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'प्रिय ग्राहक, आपके खाते से ₹500 का भुगतान सफल रहा। शेष राशि ₹12,450 है। किसी भी समस्या के लिए शाखा से संपर्क करें।',
        ));
        expect(res.riskLevel, RiskLevel.safe);
        expect(res.riskScore, 0);
      });

      test('K5: Normal personal chat without scam signals', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Hey Rohit, are we still meeting for coffee at 5 PM today? Let me know if you are running late.',
        ));
        expect(res.riskLevel, RiskLevel.safe);
        expect(res.riskScore, 0);
      });

      test('K6: Emergency peer money request between friends', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Bhai emergency hai, please mere gpay pe transfer kar do Rs 500 medicine leni hai. Kal subah wapas de dunga.',
        ));
        expect(res.riskLevel, RiskLevel.safe);
        expect(res.riskScore, 0);
      });
    });

    // Category L: Boundary and Robustness Tests
    group('Category L: Robustness & Boundary Tests', () {
      test('L1: Empty and whitespace strings throw ArgumentError', () {
        expect(() => AnalysisRequest(messageText: ''), throwsArgumentError);
        expect(() => AnalysisRequest(messageText: '   \n\t  '), throwsArgumentError);
      });

      test('L2: Repeated scam indicators do not inflate score beyond single rule weight', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'Share OTP now. Please share OTP. Send OTP right away. OTP is required.',
        ));
        expect(res.riskScore, 40); // exactly credential_harvesting weight
        expect(res.warningSigns.where((w) => w.code == 'credential_harvesting').length, 1);
      });

      test('L3: Monster multi-indicator scam caps at 100', () async {
        final res = await analyzer.analyze(AnalysisRequest(
          messageText: 'CBI Police arrest warrant. Account blocked. Click bit.ly/kyc and install app.apk to pay Rs 500 fee. Send OTP immediately.',
        ));
        expect(res.riskScore, 100);
        expect(res.riskLevel, RiskLevel.dangerous);
      });

      test('L4: Deterministic identical output across repeated runs', () async {
        const text = 'Notice from Cyber Crime Police: Non-bailable arrest warrant issued. Digital arrest in progress.';
        final res1 = await analyzer.analyze(AnalysisRequest(messageText: text));
        final res2 = await analyzer.analyze(AnalysisRequest(messageText: text));

        expect(res1.riskScore, res2.riskScore);
        expect(res1.riskLevel, res2.riskLevel);
        expect(res1.explanation, res2.explanation);
        expect(res1.warningSigns.length, res2.warningSigns.length);
        expect(res1.recommendations, equals(res2.recommendations));
      });
    });
  });
}
