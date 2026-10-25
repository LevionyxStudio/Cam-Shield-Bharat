import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/features/message_checker/data/rule_based_message_analyzer.dart';
import 'package:scamshield/features/message_checker/domain/message_analyzer.dart';

void main() {
  const analyzer = RuleBasedMessageAnalyzer();

  group('ScamShield Bharat — Multilingual Regression Tests (36 Evaluation Cases)', () {
    // 1. OTP Theft / Sensitive Credentials
    test('TC-01: English SBI netbanking OTP theft is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Dear customer, your SBI netbanking is blocked. Share your OTP immediately to verify your account: 981240.',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'credential_harvesting'), isTrue);
    });

    test('TC-02: Hinglish HDFC account freeze OTP demand is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Aapka HDFC account freeze ho gaya hai. Turant OTP bhejo verification ke liye nahi to khata band ho jayega.',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'credential_harvesting'), isTrue);
    });

    test('TC-03: Hindi Devanagari SBI account suspension and OTP demand is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'प्रिय ग्राहक, आपका एसबीआई खाता निलंबित कर दिया गया है। अपना ओटीपी साझा करें ताकि खाता तुरंत सक्रिय हो सके।',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'credential_harvesting'), isTrue);
    });

    test('TC-04: Punjabi Gurmukhi bank closure and OTP demand is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'ਪਿਆਰੇ ਗਾਹਕ, ਤੁਹਾਡਾ ਬੈਂਕ ਖਾਤਾ ਬੰਦ ਕਰ ਦਿੱਤਾ ਗਿਆ ਹੈ। ਤਸਦੀਕ ਕਰਨ ਲਈ ਤੁਰੰਤ ਆਪਣਾ OTP ਭੇਜੋ ਨਹੀਂ ਤਾਂ ਖਾਤਾ ਬੰਦ ਰਹੇਗਾ।',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'credential_harvesting'), isTrue);
    });

    test('TC-05: Obfuscated 0-T-P and P@ssword solicitation is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Urgent: Provide your 0-T-P or P@ssword to retain access to your netbanking wallet.',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'credential_harvesting'), isTrue);
    });

    // 2. UPI / Payment Traps
    test('TC-06: UPI QR refund trap in English is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'You have received a refund of Rs. 4,500. Scan the QR code and enter UPI PIN to receive money into your bank.',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'advance_fee_payment'), isTrue);
    });

    test('TC-07: Hinglish QR cashback reward trap is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Sir aapka Rs 3000 cashback pending hai. Ye QR code scan karein aur receive karein apna reward.',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'advance_fee_payment'), isTrue);
    });

    test('TC-08: Hindi Devanagari QR cashback PIN trap is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'बधाई हो! आपको ₹2,500 का कैशबैक मिला है। प्राप्त करने के लिए क्यूआर कोड स्कैन करें और अपना यूपीआई पिन दर्ज करें।',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'advance_fee_payment'), isTrue);
    });

    // 3. Fake KYC & Account Suspension
    test('TC-09: Airtel KYC SIM deactivation threat with bit.ly is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Dear customer, your KYC update pending. Your SIM card will be deactivated within 24 hours. Click http://bit.ly/kyc-airtel-update',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'suspicious_link'), isTrue);
      expect(res.warningSigns.any((w) => w.code == 'urgent_account_action'), isTrue);
    });

    test('TC-10: Hinglish PAN unlinked netbanking blocked with .xyz is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Aapka PAN card link nahi hai. Netbanking access block ho gaya hai. Turant link par click karein https://sbi-kyc-update.xyz',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'suspicious_link'), isTrue);
    });

    test('TC-11: Punjabi Gurmukhi KYC 12-hour ultimatum is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'ਤੁਹਾਡਾ ਕੇਵਾਈਸੀ ਅੱਪਡੇਟ ਬਾਕੀ ਹੈ। 12 ਘੰਟਿਆਂ ਦੇ ਅੰਦਰ ਆਪਣਾ ਪੈਨ ਕਾਰਡ ਲਿੰਕ ਕਰੋ ਨਹੀਂ ਤਾਂ ਖਾਤਾ ਬੰਦ ਕਰ ਦਿੱਤਾ ਜਾਵੇਗਾ।',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'urgent_account_action'), isTrue);
    });

    // 4. Digital Arrest & Legal Intimidation
    test('TC-12: English narcotics parcel digital arrest warrant is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Notice from Cyber Crime Police: A parcel in your name contains narcotics. Non-bailable arrest warrant issued. Digital arrest in progress.',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'legal_arrest_threat'), isTrue);
    });

    test('TC-13: Hinglish FIR registered and police dispatch is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'CBI Police notice: Aapke khilaf FIR registered ho chuki hai. Police bheji ja rahi hai. Case settle karne ke liye turant call karein.',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'legal_arrest_threat'), isTrue);
    });

    test('TC-14: Hindi Devanagari CBI arrest warrant is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'केंद्रीय जांच ब्यूरो (CBI) नोटिस: आपके खिलाफ गैर-जमानती वारंट जारी किया गया है। गिरफ्तारी से बचने के लिए तुरंत दिए गए नंबर पर संपर्क करें।',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'legal_arrest_threat'), isTrue);
    });

    // 5. Government Impersonation
    test('TC-15: PM Kisan advance fee and raw IP URL is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'PM Kisan Yojana: Rs 6,000 has been credited to your account. Deposit advance fee of Rs. 299 to release funds: http://192.168.1.10/claim',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'advance_fee_payment'), isTrue);
    });

    test('TC-16: Bijli vibhag power cut tonight extortion is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Bijli vibhag notice: Aaj raat 9:30 baje bijli kat jayegi kyunki bill update nahi hai. Turant contact karein 9876543210.',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'urgent_account_action'), isTrue);
    });

    // 6. Fake Jobs & Task Scams
    test('TC-17: Part time Google rating task with bit.ly is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Part time job offer: Earn daily Rs 3000 to 8000 per day by giving 5-star ratings on Google Maps. Contact HR on WhatsApp: bit.ly/easy-job-hr',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'fake_job_offer'), isTrue);
    });

    test('TC-18: Work from home daily pay with advance registration fee is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Ghar baithe kamayein: Work from home daily Rs 2500 per task. Join karne ke liye registration fee Rs 500 pehle jama karein.',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'advance_fee_payment'), isTrue);
    });

    // 7. Fake Rewards & Lottery
    test('TC-19: KBC lucky draw winner Rs 25,00,000 in English triggers lottery and authority lure', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Congratulations! You are the lucky draw winner of KBC lottery prize worth Rs 25,00,000. Call manager to claim.',
      ));
      expect(res.riskScore, greaterThanOrEqualTo(50));
      expect(res.warningSigns.any((w) => w.code == 'fake_reward_lottery'), isTrue);
      expect(res.warningSigns.any((w) => w.code == 'authority_impersonation'), isTrue);
    });

    test('TC-20: Hindi Devanagari KBC lottery 25 Lakh triggers lottery and authority lure', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'बधाई हो! आप कौन बनेगा करोड़पति लकी ड्रा के विजेता चुने गए हैं और आपने ₹25,00,000 की इनामी राशि जीती है। दावा करने के लिए संपर्क करें।',
      ));
      expect(res.riskScore, greaterThanOrEqualTo(50));
      expect(res.warningSigns.any((w) => w.code == 'fake_reward_lottery'), isTrue);
      expect(res.warningSigns.any((w) => w.code == 'authority_impersonation'), isTrue);
    });

    // 8. Malicious APK & Remote Access
    test('TC-21: Bank APK and AnyDesk remote installation is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Your bank KYC is incomplete. Install sbi_rewards_update.apk or download AnyDesk for remote verification with customer support.',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'untrusted_apk'), isTrue);
    });

    test('TC-22: Fast loan APK download in Hinglish is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Aapka loan pass ho gaya hai. Turant ye fast_loan.apk application download karein aur document upload karein.',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'untrusted_apk'), isTrue);
    });

    // 9. Suspicious URLs
    test('TC-23: India Post fake delivery address update with .top domain is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Your courier package is held at depot due to wrong address. Update address now: https://indiapost-parcel.top/track',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'suspicious_link'), isTrue);
    });

    test('TC-24: Free 50GB 5G recharge clickbait via tinyurl is suspicious', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Click here to claim free 50GB 5G recharge for all users: http://tinyurl.com/free-jio-5g',
      ));
      // Ground truth for TC-24 is suspicious
      expect(res.riskLevel, RiskLevel.suspicious);
      expect(res.riskScore, inInclusiveRange(30, 59));
      expect(res.warningSigns.any((w) => w.code == 'suspicious_link'), isTrue);
    });

    // 10. Legitimate Banking Alerts
    test('TC-25: Legitimate SWIGGY bank debit SMS is safe', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Rs 1,250.00 debited from A/c XX4092 on 24-Oct-26 at SWIGGY. UPI Ref 429810284910. If not done by you, call 1800112211.',
      ));
      expect(res.riskLevel, RiskLevel.safe);
      expect(res.riskScore, 0);
      expect(res.warningSigns, isEmpty);
    });

    test('TC-26: Legitimate Amazon OTP with bank security advisory is safe', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: '849102 is your OTP for purchase of Rs 850.00 at Amazon. Valid for 10 mins. Never share your OTP with anyone. Bank staff never calls to ask for OTP.',
      ));
      expect(res.riskLevel, RiskLevel.safe);
      expect(res.riskScore, 0);
      expect(res.warningSigns, isEmpty);
    });

    test('TC-27: Legitimate Hindi transaction debit notice is safe', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'प्रिय ग्राहक, आपके खाते से ₹500 का भुगतान सफल रहा। शेष राशि ₹12,450 है। किसी भी समस्या के लिए शाखा से संपर्क करें।',
      ));
      expect(res.riskLevel, RiskLevel.safe);
      expect(res.riskScore, 0);
      expect(res.warningSigns, isEmpty);
    });

    test('TC-28: Legitimate Punjabi account debit notification is safe', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'ਤੁਹਾਡੇ ਖਾਤੇ ਵਿੱਚੋਂ ₹1000 ਕੱਢੇ ਗਏ ਹਨ। ਮੌਜੂਦਾ ਬਕਾਇਆ ₹8500 ਹੈ। ਧੰਨਵਾਦ, ਪੰਜਾਬ ਨੈਸ਼ਨਲ ਬੈਂਕ।',
      ));
      expect(res.riskLevel, RiskLevel.safe);
      expect(res.riskScore, 0);
      expect(res.warningSigns, isEmpty);
    });

    // 11. Normal Personal & Conversational Messages
    test('TC-29: English coffee meeting plan is safe', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Hey Rohit, are we still meeting for coffee at 5 PM today? Let me know if you are running late.',
      ));
      expect(res.riskLevel, RiskLevel.safe);
      expect(res.riskScore, 0);
    });

    test('TC-30: Hinglish family grocery request is safe', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Bhai sun, sham ko ghar aate waqt bread aur doodh le aana please. Mummy bol rahi thi.',
      ));
      expect(res.riskLevel, RiskLevel.safe);
      expect(res.riskScore, 0);
    });

    test('TC-31: Hindi family visit plan is safe', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'नमस्ते अंकल, कल शाम को हम सब आपके घर आ रहे हैं। क्या आप घर पर मिलेंगे?',
      ));
      expect(res.riskLevel, RiskLevel.safe);
      expect(res.riskScore, 0);
    });

    test('TC-32: Punjabi friendly travel plan is safe', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'ਸਤਿ ਸ੍ਰੀ ਅਕਾਲ ਵੀਰ ਜੀ, ਅੱਜ ਸ਼ਾਮ ਨੂੰ ਪਿੰਡ ਜਾਣਾ ਹੈ। ਕੀ ਤੁਸੀਂ ਨਾਲ ਚੱਲੋਗੇ?',
      ));
      expect(res.riskLevel, RiskLevel.safe);
      expect(res.riskScore, 0);
    });

    // False Positive Traps & Advanced Scams
    test('TC-33: Friend asking for peer medicine transfer in emergency is safe', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Bhai emergency hai, please mere gpay pe transfer kar do Rs 500 medicine leni hai. Kal subah wapas de dunga.',
      ));
      expect(res.riskLevel, RiskLevel.safe);
      expect(res.riskScore, 0);
    });

    test('TC-34: Legitimate TechCorp job interview shortlisted is safe', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Interview invitation: Your application for Junior Flutter Developer at TechCorp has been shortlisted. Interview on Monday via Google Meet.',
      ));
      expect(res.riskLevel, RiskLevel.safe);
      expect(res.riskScore, 0);
    });

    test('TC-35: Obfuscated s-b-i a.c.c.o.u.n.t b.l.o.c.k.e.d is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Dear customer, your s-b-i a.c.c.o.u.n.t is b.l.o.c.k.e.d. Verify immediately to avoid permanent closure.',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
    });

    test('TC-36: Code-switching narcotics parcel arrest warrant is dangerous', () async {
      final res = await analyzer.analyze(AnalysisRequest(
        messageText: 'Police summons: Aapka parcel Mumbai airport pe pakda gaya hai with illegal contraband. Legal arrest warrant issued. Contact Cyber Crime branch immediately.',
      ));
      expect(res.riskLevel, RiskLevel.dangerous);
      expect(res.riskScore, greaterThanOrEqualTo(60));
      expect(res.warningSigns.any((w) => w.code == 'legal_arrest_threat'), isTrue);
    });
  });
}
