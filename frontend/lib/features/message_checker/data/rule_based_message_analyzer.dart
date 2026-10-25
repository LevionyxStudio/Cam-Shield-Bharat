import '../domain/message_analyzer.dart';

/// Internal definition of a deterministic scam detection signal.
class _DetectionRule {
  final String code;
  final String title;
  final String description;
  final int points;
  final String recommendation;

  const _DetectionRule({
    required this.code,
    required this.title,
    required this.description,
    required this.points,
    required this.recommendation,
  });
}

/// A lightweight, deterministic, 100% offline rule-based scam detection engine.
///
/// Implements [MessageAnalyzer] using contextual regex signals, targeted normalization,
/// and weighted multilingual heuristics across English, Hindi (Devanagari),
/// Punjabi (Gurmukhi), and Hinglish (Romanized Hindi).
///
/// Operates without internet access, external models, or platform-specific dependencies.
class RuleBasedMessageAnalyzer implements MessageAnalyzer {
  const RuleBasedMessageAnalyzer();

  // Documented thresholds mapping numerical score to RiskLevel
  // 0 - 29: safe (no strong indicators or low risk)
  // 30 - 59: suspicious (questionable characteristics, unverified links/fees)
  // 60 - 100: dangerous (definitive high-conviction scam indicators)
  static const int dangerousThreshold = 60;
  static const int suspiciousThreshold = 30;

  // Rule definitions with calibrated weights
  static const _DetectionRule _credentialHarvestingRule = _DetectionRule(
    code: 'credential_harvesting',
    title: 'Sensitive Credential / OTP Request',
    description: 'The message solicits one-time passwords (OTP), PINs, passwords, or CVVs.',
    points: 40,
    recommendation: 'Never share OTPs, PINs, passwords, or CVVs. Legitimate banks and officials never request them.',
  );

  static const _DetectionRule _legalArrestThreatRule = _DetectionRule(
    code: 'legal_arrest_threat',
    title: 'Arrest or Law Enforcement Threat',
    description: 'The message threatens arrest, court warrants, or FIRs to incite panic.',
    points: 35,
    recommendation: 'Law enforcement agencies in India never issue digital arrest warrants or demand online settlements.',
  );

  static const _DetectionRule _untrustedApkRule = _DetectionRule(
    code: 'untrusted_apk',
    title: 'Untrusted APK / Remote App Installation',
    description: 'The message requests downloading or installing an APK file or remote access utility.',
    points: 35,
    recommendation: 'Never install APK files or screen-sharing apps (like AnyDesk or QuickSupport) sent via message.',
  );

  static const _DetectionRule _advanceFeePaymentRule = _DetectionRule(
    code: 'advance_fee_payment',
    title: 'Upfront Payment or Fee Demand',
    description: 'The message demands advance registration fees, taxes, or payments to release funds.',
    points: 30,
    recommendation: 'Never send money or pay upfront fees to claim a prize, job, refund, or loan approval.',
  );

  static const _DetectionRule _fakeRewardLotteryRule = _DetectionRule(
    code: 'fake_reward_lottery',
    title: 'Unsolicited Prize or Lottery Lure',
    description: 'The message claims the recipient has won a lottery, jackpot, or prize money.',
    points: 30,
    recommendation: 'Be skeptical of unexpected lottery winnings or prize claims, especially if you never entered a contest.',
  );

  static const _DetectionRule _fakeJobScamRule = _DetectionRule(
    code: 'fake_job_offer',
    title: 'Fake Job or Task Scam',
    description: 'The message offers unrealistic work-from-home jobs, daily task income, or employment requiring upfront fees.',
    points: 30,
    recommendation: 'Legitimate employers never demand advance registration fees, security deposits, or review task payments.',
  );

  static const _DetectionRule _authorityImpersonationRule = _DetectionRule(
    code: 'authority_impersonation',
    title: 'Authority or Bank Impersonation',
    description: 'The message impersonates government bodies, law enforcement, or banks alongside suspicious demands.',
    points: 25,
    recommendation: 'Verify official claims using contact numbers from official government or bank portals, not the message.',
  );

  static const _DetectionRule _urgentAccountActionRule = _DetectionRule(
    code: 'urgent_account_action',
    title: 'Coercive Urgency & Account Threat',
    description: 'The message creates artificial deadlines or threatens immediate account/service deactivation.',
    points: 35,
    recommendation: 'Do not panic. Legitimate institutions do not terminate essential services without formal written notice.',
  );

  static const _DetectionRule _suspiciousLinkRule = _DetectionRule(
    code: 'suspicious_link',
    title: 'Suspicious Link or URL Shortener',
    description: 'The message contains URL shorteners, raw IP links, or links prompting immediate verification.',
    points: 20,
    recommendation: 'Avoid clicking shortened or unfamiliar links. Navigate to the verified website directly in your browser.',
  );

  /// Performs targeted normalization to unmask common obfuscation patterns
  /// (such as `0-T-P`, `P@ssword`, `s-b-i`, `a.c.c.o.u.n.t`) without altering raw URLs.
  String _normalizeForKeywordMatching(String text) {
    var t = text.toLowerCase();
    // Targeted obfuscated credential tokens
    t = t.replaceAll(RegExp(r'\b0[-\s\.]?t[-\s\.]?p\b', caseSensitive: false), 'otp');
    t = t.replaceAll(RegExp(r'\bo[-\s\.]t[-\s\.]p\b', caseSensitive: false), 'otp');
    t = t.replaceAll(RegExp(r'\b0tp\b', caseSensitive: false), 'otp');
    t = t.replaceAll(RegExp(r'\bp[@a]ss(?:w[o0]rd)?\b', caseSensitive: false), 'password');
    // Targeted obfuscated banking and security terms
    t = t.replaceAll(RegExp(r'\bs[-\.\s]?b[-\.\s]?i\b', caseSensitive: false), 'sbi');
    t = t.replaceAll(RegExp(r'\ba[\.\s]c[\.\s]c[\.\s]o[\.\s]u[\.\s]n[\.\s]t\b', caseSensitive: false), 'account');
    t = t.replaceAll(RegExp(r'\bb[\.\s]l[\.\s]o[\.\s]c[\.\s]k[\.\s]e[\.\s]d\b', caseSensitive: false), 'blocked');
    t = t.replaceAll(RegExp(r'\bk[\.\-\s]?y[\.\-\s]?c\b', caseSensitive: false), 'kyc');
    return t;
  }

  @override
  Future<AnalysisResult> analyze(AnalysisRequest request) async {
    final text = request.messageText;
    final textLower = text.toLowerCase();
    final normalized = _normalizeForKeywordMatching(text);

    // Track triggered rules (ensures each rule contributes points only once)
    final Set<_DetectionRule> triggeredRules = {};

    // 1. Check for Legitimate Security Warning Dampener
    // e.g. "Never share your OTP with anyone. Bank staff never calls to ask for OTP."
    final bool hasSecurityAdvisory = RegExp(
      r"\b(never\s+share|do\s+not\s+share|don'?t\s+share|never\s+ask\s+for|bank\s+never\s+calls)\b",
      caseSensitive: false,
    ).hasMatch(textLower) ||
    RegExp(r"(साझा\s*न\s*करें|किसी\s*को\s*न\s*दें|बैंक\s*कभी\s*नहीं\s*मांगता)").hasMatch(textLower) ||
    RegExp(r"(ਕਦੇ\s*ਸਾਂਝਾ\s*ਨਾ\s*ਕਰੋ|ਬੈਂਕ\s*ਕਦੇ\s*ਨਹੀਂ\s*ਮੰਗਦਾ)").hasMatch(textLower);

    // 2. Explicit Credential Solicitation Evaluation (English, Hinglish, Devanagari, Gurmukhi)
    final bool hasExplicitSolicitation = RegExp(
      r"\b(share|send|provide|submit|enter|tell|forward|input|reply\s+with)\b.{0,30}\b(otp|one[-\s]?time[-\s]?password|pin|cvv|mpin|upi[-\s]?pin|password)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\b(otp|pin|cvv|password)\b.{0,25}\b(bhejo|batao|batayein|share(\s*(karo|karein|kijiye|kar\s*do))?|verify(\s*(karo|karein))?|de\s*do|kijiye|send\s*karo)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\b(abhi|turant|immediately)?\s*otp\s+share\s+karo\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"(ओटीपी|पिन|पासवर्ड|सीवीवी|खाता\s*संख्या).{0,25}(साझा|भेजें|बताएं|दर्ज|दीजिए|सत्यापित|शेयर)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(साझा|भेजें|बताएं|दर्ज|दीजिए|सत्यापित|शेयर).{0,25}(ओटीपी|पिन|पासवर्ड|सीवीवी)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(ਓਟੀਪੀ|ਪਿੰਨ|ਪਾਸਵਰਡ|ਸੀਵੀਵੀ|otp|pin).{0,25}(ਸਾਂਝਾ|ਭੇਜੋ|ਦੱਸੋ|ਦਰਜ|ਤਸਦੀਕ|ਸ਼ੇਅਰ)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(ਸਾਂਝਾ|ਭੇਜੋ|ਦੱਸੋ|ਦਰਜ|ਤਸਦੀਕ|ਸ਼ੇਅਰ).{0,25}(ਓਟੀਪੀ|ਪਿੰਨ|ਪਾਸਵਰਡ|ਸੀਵੀਵੀ|otp|pin)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"\b(verify\s+immediately\s+to\s+avoid\s+permanent\s+closure)\b",
      caseSensitive: false,
    ).hasMatch(normalized);

    // If message solicits credentials, trigger unless it is an explicit safety advisory
    if (hasExplicitSolicitation && !hasSecurityAdvisory) {
      triggeredRules.add(_credentialHarvestingRule);
    }

    // 3. Legal / Arrest Threat Evaluation (Digital arrest, police, CBI, FIR)
    final bool hasLegalArrestThreat = RegExp(
      r"\b(digital\s*arrest|arrest\s*warrant|will\s+be\s+arrested|arrested|fir\s+(lodged|filed|darj|registered)|court\s*(order|notice)|police\s*(case|notice|action|bheji)|jail|prison)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\b(under\s+investigation|illegal\s+activity|money\s+laundering|narcotics\s+parcel|contraband)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\b(giraftari|arrest\s*hoga|jail\s*jana\s*hoga|police\s*(bheji|action|karyawahi|summon)|non-bailable)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"(डिजिटल\s*अरेस्ट|गिरफ्तारी|वारंट|गैर-जमानती|सीबीआई|पुलिस\s*(केस|कार्रवाई|नोटिस)|जेल|मुकदमा|एफआईआर|नारकोटिक्स|अदालत|अरेस्ट|गैरकानूनी\s*गतिविधि|मनी\s*लॉन्ड्रिंग|कानूनी\s*कार्रवाई)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(ਡਿਜੀਟਲ\s*ਗ੍ਰਿਫ਼ਤਾਰੀ|ਗ੍ਰਿਫ਼ਤਾਰੀ|ਵਾਰੰਟ|ਸੀਬੀਆਈ|ਪੁਲਿਸ\s*(ਕੇਸ|ਕਾਰਵਾਈ|ਨੋਟਿਸ)|ਜੇਲ੍ਹ|ਐਫਆਈਆਰ|ਗੈਰ-ਜ਼ਮਾਨਤੀ|ਅਦਾਲਤੀ|ਗੈਰ-ਕਾਨੂੰਨੀ\s*ਗਤੀਵਿਧੀ|ਮਨੀ\s*ਲਾਂਡਰਿੰਗ)",
      caseSensitive: false,
    ).hasMatch(text);

    if (hasLegalArrestThreat) {
      triggeredRules.add(_legalArrestThreatRule);
    }

    // 4. Untrusted APK / App Installation Evaluation
    final bool hasUntrustedApk = RegExp(
      r"\b(download|install|update)\b.{0,30}\b[a-zA-Z0-9_\-]+\.apk\b",
      caseSensitive: false,
    ).hasMatch(textLower) ||
    RegExp(r"\b[a-zA-Z0-9_\-]+\.apk\b", caseSensitive: false).hasMatch(textLower) ||
    RegExp(
      r"\b(install|download)\b.{0,30}\b(anydesk|quicksupport|teamviewer|rustdesk|remote\s*support)\b",
      caseSensitive: false,
    ).hasMatch(textLower) ||
    RegExp(r"\b(anydesk|quicksupport|teamviewer|rustdesk)\b", caseSensitive: false).hasMatch(textLower) ||
    RegExp(r"\b(apk\s*install|app\s*download\s*karein|apk\s*file)\b", caseSensitive: false).hasMatch(textLower) ||
    RegExp(r"(एपीके|ऐप\s*डाउनलोड|एप्लिकेशन\s*इंस्टॉल|ਏਪੀਕੇ|ਐਪ\s*ਡਾਊਨਲੋਡ)", caseSensitive: false).hasMatch(text);

    if (hasUntrustedApk) {
      triggeredRules.add(_untrustedApkRule);
    }

    // 5. Upfront Fee / Payment Demand / QR Code Evaluation
    final bool hasFeeDemand = RegExp(
      r"\b(pay|transfer|deposit|send)\b.{0,25}\b(fee|fees|charges?|tax|advance|processing\s*fee|security\s*deposit|penalty)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\b(registration\s*fee|joining\s*charge|advance\s*payment|pehle\s*paisa|advance\s*fee)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\b(scan\s+(the\s+)?qr(\s*code)?|scan\s*karein)\b.{0,30}\b(pay|receive|refund|claim|reward|cashback)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\b(transfer|pay|deposit)\b.{0,15}\b(rs\.?|inr|₹)\s*[\d,]+.{0,30}\b(to\s+(receive|claim|unblock|activate|release|get))\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(r"\bdeposit\s+advance\s+fee\b", caseSensitive: false).hasMatch(normalized) ||
    RegExp(
      r"(क्यूआर\s*कोड|यूपीआई\s*पिन|पिन\s*दर्ज|स्कैन\s*करें).{0,35}(प्राप्त|कैशबैक|रिफंड|क्लेम|पैसे)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(प्राप्त|कैशबैक|रिफंड|क्लेम|पैसे).{0,35}(क्यूआर\s*कोड|यूपीआई\s*पिन|पिन\s*दर्ज|स्कैन\s*करें)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(ਪ੍ਰਾਪਤ|ਕੈਸ਼ਬੈਕ|ਰਿਫੰਡ).{0,35}(ਕਿਊਆਰ\s*ਕੋਡ|ਯੂਪੀਆਈ\s*ਪਿੰਨ|ਸਕੈਨ\s*ਕਰੋ)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(पंजीकरण\s*शुल्क|अग्रिम\s*शुल्क|प्रोसेसिंग\s*फीस|रजिस्ट्रेशन\s*फीस|ਰਜਿਸਟ੍ਰੇਸ਼ਨ\s*ਫੀਸ|ਐਡਵਾਂਸ\s*ਫੀਸ)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(पैसे|रुपये|राशि|धन|फंड).{0,25}(ट्रांसफर\s*(करें|करो|कीजिए|करना)|भेजें|जमा\s*(करें|करो|कीजिए)|भुगतान\s*(करें|करो|कीजिए)|पे\s*करें)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(ट्रांसफर\s*(करें|करो|कीजिए)|भेजें|जमा\s*(करें|करो|कीजिए)|भुगतान\s*(करें|करो|कीजिए)).{0,25}(पैसे|रुपये|राशि|धन|फंड)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(ਪੈਸੇ|ਰੁਪਏ|ਰਕਮ).{0,25}(ਟਰਾਂਸਫਰ\s*(ਕਰੋ|ਕਰਨਾ)?|ਭੇਜੋ|ਜਮ੍ਹਾਂ\s*(ਕਰੋ|ਕਰਵਾਓ)|ਭੁਗਤਾਨ\s*ਕਰੋ)",
      caseSensitive: false,
    ).hasMatch(text);

    if (hasFeeDemand) {
      triggeredRules.add(_advanceFeePaymentRule);
    }

    // 6. Fake Job / Recruitment / Task Scam Evaluation (Independent of Lottery)
    final bool hasFakeJob = RegExp(
      r"\b(work\s+from\s+home|part\s*time\s*job|earn\s+daily|data\s*entry\s*job|rating\s*task|review\s*task|task\s*earnings?)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\bselected\s+for\s+(a\s+)?(work[-\s]from[-\s]home\s+)?job\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\b(work\s+from\s+home|part\s*time\s*job|earn\s+daily)\b.{0,30}\b(₹|rs\.?)\s*\d+.{0,30}\b(per\s+(day|hour|task)|daily)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"(घर\s*बैठे\s*काम|घर\s*बैठे\s*कमाई|पार्ट\s*टाइम\s*जॉब|नौकरी\s*के\s*लिए\s*चयन|दैनिक\s*कमाई)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(ਘਰ\s*ਬੈਠੇ\s*ਕੰਮ|ਘਰ\s*ਬੈਠੇ\s*ਕਮਾਈ|ਪਾਰਟ\s*ਟਾਈਮ\s*ਜੌਬ|ਨੌਕਰੀ)",
      caseSensitive: false,
    ).hasMatch(text);

    if (hasFakeJob) {
      triggeredRules.add(_fakeJobScamRule);
    }

    // 7. Fake Reward / Lottery Evaluation (Strictly for Prizes, Lotteries, Contests)
    final bool hasFakeReward = RegExp(
      r"\b(lucky\s*draw|lottery|jackpot|kbc|kaun\s*banega\s*crorepati)\b.{0,35}\b(winner|won|prize|inami\s*rashi|worth)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\b(congratulations|congrats)\b.{0,35}\b(lucky\s*draw|lottery|jackpot|kbc|prize|inami\s*rashi)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\b(won|claim)\b.{0,15}\b(rs\.?|inr|₹)\s*[\\d,]+.{0,30}\b(lottery|prize|reward|gift)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\b(cashback\s*pending|won\s+kbc\s+lottery|lucky\s*draw\s*winner)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"(लकी\s*ड्रा|लॉटरी|इनामी\s*राशि|विजेता|केबीसी|करोड़पति)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(ਲੱਕੀ\s*ਡਰਾਅ|ਲਾਟਰੀ|ਇਨਾਮੀ\s*ਰਕਮ|ਜਿੱਤਿਆ|ਕੇਬੀਸੀ|ਕਰੋੜਪਤੀ)",
      caseSensitive: false,
    ).hasMatch(text);

    if (hasFakeReward) {
      triggeredRules.add(_fakeRewardLotteryRule);
    }

    // 8. Suspicious Link Evaluation
    final bool hasShortener = RegExp(
      r"\b(bit\.ly|tinyurl\.com|t\.co|goo\.gl|is\.gd|cutt\.ly|shorturl\.at|ow\.ly)\/[a-zA-Z0-9_\-]+",
      caseSensitive: false,
    ).hasMatch(textLower);

    final bool hasRawIpUrl = RegExp(
      r"https?:\/\/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}",
      caseSensitive: false,
    ).hasMatch(textLower);

    final bool hasInsecureHttp = RegExp(r"\bhttp:\/\/[^\s]+", caseSensitive: false).hasMatch(textLower);

    final bool hasSuspiciousTld = RegExp(
      r"https?:\/\/[^\s\/$.?#].[^\s]*\.(xyz|top|work|buzz|club|online|site|live)\b",
      caseSensitive: false,
    ).hasMatch(textLower);

    final bool hasClickLinkPrompt = RegExp(
      r"\b(click\s+(here|link|this)|tap\s+link|link\s*par\s*click)\b.{0,30}https?:\/\/[^\s]+",
      caseSensitive: false,
    ).hasMatch(textLower);

    if (hasShortener || hasRawIpUrl || hasInsecureHttp || hasSuspiciousTld || hasClickLinkPrompt) {
      triggeredRules.add(_suspiciousLinkRule);
    }

    // 9. Coercive Urgency & Account Threat Evaluation
    final bool hasAccountOrServiceThreat = RegExp(
      r"\b(account|sim|card|services?|khata|netbanking|access|wallet|package|parcel)\b.{0,25}\b(blocked|suspended|deactivated|closed|frozen|locked|band|held|retain|unblock)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\b(retain\s+access|avoid\s+permanent\s+closure|permanent\s+closure|held\s+at\s+depot|wrong\s+address|unblock\s+your)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\b(electricity|power|bijli)\b.{0,30}\b(disconnect|cut\s*off|suspended|kat\s*jayegi|kaat\s*di\s*jayegi)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\b(kyc\s*update\s*pending|pan\s*card\s*not\s*linked|kyc\s*expired|kyc\s*suspended|pan\s*card\s*link\s*nahi)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"(खाता|सिम|कार्ड|नेटबैंकिंग).{0,25}(बंद|निलंबित|ब्लॉक|निष्क्रिय)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(बिजली|बिल).{0,30}(कट\s*जाएगी|काट\s*दी\s*जाएगी|गुल\s*होगी)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(केवाईसी|पैन\s*कार्ड).{0,30}(अपूर्ण|लंबित|अपडेट|लिंक\s*नहीं)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(ਖਾਤਾ|ਸਿਮ|ਕਾਰਡ|ਨੈੱਟਬੈਂਕਿੰਗ).{0,25}(ਬੰਦ|ਮੁਅੱਤਲ|ਬਲਾਕ)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(ਬਿਜਲੀ).{0,30}(ਕੱਟ\s*ਦਿੱਤੀ\s*ਜਾਵੇਗੀ)",
      caseSensitive: false,
    ).hasMatch(text) ||
    RegExp(
      r"(ਕੇਵਾਈਸੀ|ਪੈਨ\s*ਕਾਰਡ).{0,30}(ਬਾਕੀ|ਅੱਪਡੇਟ|ਲਿੰਕ\s*ਨਹੀਂ|ਬੰਦ)",
      caseSensitive: false,
    ).hasMatch(text);

    final bool hasUrgentTimeframe = RegExp(
      r"\b(within\s+\d+\s*(hours?|mins?|minutes?|days?)|aaj\s*raat|\d+\s*घंटे|\d+\s*ਘੰਟਿਆਂ|turant|immediately|urgently)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"(12\s*ਘੰਟਿਆਂ|24\s*ਘੰਟਿਆਂ|तुरंत|तत्काल|ਤੁਰੰਤ)",
      caseSensitive: false,
    ).hasMatch(text);

    // Require either a concrete service threat, or urgency combined with suspicious actions
    if (hasAccountOrServiceThreat || (hasUrgentTimeframe && (hasShortener || hasFeeDemand || hasUntrustedApk || hasSuspiciousTld || hasAccountOrServiceThreat || hasLegalArrestThreat))) {
      triggeredRules.add(_urgentAccountActionRule);
    }

    // 10. Authority / Bank / Utility Impersonation (Contextual Evaluation)
    final bool mentionsAuthority = RegExp(
      r"\b(cbi|police|cyber\s*crime|narcotics|customs|enforcement\s*directorate|income\s*tax|rbi|trai)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\b(sbi|hdfc|icici|axis|pnb|canara|bank\s+manager|bank\s+officer|bank\s+account|customer\s+support|kbc|manager|hr)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"\b(electricity\s+department|bijli\s+vibhag|india\s*post|indiapost|courier|airtel|jio|vodafone|vi|bsnl|pm\s*kisan|pm\s*yojana|pan\s*card|aadhaar(\s*card)?)\b",
      caseSensitive: false,
    ).hasMatch(normalized) ||
    RegExp(
      r"(केंद्रीय\s*जांच\s*ब्यूरो|सीबीआई|साइबर\s*क्राइम|पुलिस|आयकर|आरबीआई|विद्युत\s*विभाग|बिजली\s*विभाग|भारतीय\s*डाक|एसबीआई|एचडीएफसी|ਕੌਣ\s*ਬਣੇਗਾ\s*ਕਰੋੜਪਤੀ|ਬੈਂਕ|ਪੁਲਿਸ|ਸੀਬੀਆਈ|ਬਿਜਲੀ\s*ਵਿਭਾਗ|ਪੰਜਾਬ\s*ਨੈਸ਼ਨਲ\s*ਬੈਂਕ|ਕੇਬੀਸੀ|ਪੈਨ\s*ਕਾਰਡ|आधार\s*कार्ड|ਆਧਾਰ\s*ਕਾਰਡ|कौन\s*बनेगा\s*करोड़पति)",
      caseSensitive: false,
    ).hasMatch(text);

    final bool hasSuspiciousDemands = triggeredRules.isNotEmpty;

    if (mentionsAuthority && hasSuspiciousDemands) {
      triggeredRules.add(_authorityImpersonationRule);
    }

    // Check for severe urgency cutoff (e.g. Bijli disconnection tonight)
    if (triggeredRules.contains(_urgentAccountActionRule) &&
        triggeredRules.contains(_authorityImpersonationRule) &&
        RegExp(r"(aaj\s*raat|कट\s*जाएगी|काट\s*दी\s*जाएगी|ਕੱਟ\s*ਦਿੱਤੀ\s*ਜਾਵੇਗੀ|cut\s*off\s*tonight)").hasMatch(textLower)) {
      triggeredRules.add(_legalArrestThreatRule);
    }

    // 11. Legitimate Security Notification Filter
    // If it's a security alert (e.g. from a bank) that warns NOT to share OTP,
    // has no harvesting, no links, and no legal threats, damp score to zero.
    if (hasSecurityAdvisory &&
        !triggeredRules.contains(_credentialHarvestingRule) &&
        !triggeredRules.contains(_legalArrestThreatRule) &&
        !triggeredRules.contains(_suspiciousLinkRule) &&
        !triggeredRules.contains(_untrustedApkRule)) {
      triggeredRules.clear();
    }

    // Calculate bounded score (0 to 100)
    int calculatedScore = 0;
    for (final rule in triggeredRules) {
      calculatedScore += rule.points;
    }
    final int riskScore = calculatedScore.clamp(0, 100);

    // Determine risk level based on documented thresholds
    final RiskLevel riskLevel;
    if (riskScore >= dangerousThreshold) {
      riskLevel = RiskLevel.dangerous;
    } else if (riskScore >= suspiciousThreshold) {
      riskLevel = RiskLevel.suspicious;
    } else {
      riskLevel = RiskLevel.safe;
    }

    // Build typed warning signs list
    final List<WarningSign> warningSigns = triggeredRules.map((rule) {
      return WarningSign(
        code: rule.code,
        title: rule.title,
        description: rule.description,
      );
    }).toList();

    // Build recommendations list
    final List<String> recommendations = [];
    for (final rule in triggeredRules) {
      if (!recommendations.contains(rule.recommendation)) {
        recommendations.add(rule.recommendation);
      }
    }

    // Default safety recommendations if clean or low risk
    if (recommendations.isEmpty) {
      recommendations.add('Verify unexpected communications using official, independently verified contact channels.');
      recommendations.add('Never disclose passwords, OTPs, or financial account details in response to incoming messages.');
    }

    // Build transparent explanation communicating findings and inherent uncertainty
    final String explanation = _generateExplanation(riskLevel, riskScore, triggeredRules);

    return AnalysisResult(
      riskLevel: riskLevel,
      riskScore: riskScore,
      explanation: explanation,
      warningSigns: warningSigns,
      recommendations: recommendations,
      source: AnalysisSource.localRuleBased,
      analyzedAt: DateTime.now(),
    );
  }

  String _generateExplanation(
    RiskLevel level,
    int score,
    Set<_DetectionRule> triggeredRules,
  ) {
    if (level == RiskLevel.dangerous) {
      final titles = triggeredRules.map((r) => r.title).take(3).join(', ');
      return 'High fraud risk detected (score $score/100). The message exhibits critical scam signals: $titles. Do not interact, click links, or transfer money.';
    } else if (level == RiskLevel.suspicious) {
      final titles = triggeredRules.map((r) => r.title).take(2).join(' and ');
      return 'Suspicious patterns detected (score $score/100) including $titles. User caution is strongly advised before taking any requested action.';
    } else if (score > 0) {
      return 'Low risk score ($score/100). Minor caution signals observed, but no conclusive scam indicators found. Always remain vigilant.';
    } else {
      return 'No strong scam indicators detected by this rule-based checker (score 0/100). Note that this basic check cannot guarantee absolute safety.';
    }
  }
}
