"""
FraudShield AI — Fallback Rule-Based Classifier
Works without any external AI API. Uses pattern matching and heuristics.
Clearly separated from production LLM logic.
"""

from typing import List
from app.models.schemas import AnalysisResult, RedFlag, RiskLevel, InputType
from app.scoring.risk_engine import calculate_risk_score, classify_scam_type
import re


# ── Red Flag Generators ──

SCAM_RED_FLAGS = {
    "Digital Arrest Scam": [
        RedFlag(indicator="Government / Law Enforcement Impersonation", description="The sender claims to be from CBI, police, or another government agency.", severity="critical"),
        RedFlag(indicator="Threat of Arrest", description="The message threatens arrest, legal action, or detention.", severity="critical"),
        RedFlag(indicator="Urgent Money Demand", description="Immediate payment is demanded to avoid consequences.", severity="high"),
        RedFlag(indicator="Psychological Coercion", description="Fear, secrecy, and pressure tactics are used to manipulate.", severity="high"),
    ],
    "Fake Bank Support": [
        RedFlag(indicator="Bank Impersonation", description="The sender claims to be from a bank's customer support.", severity="high"),
        RedFlag(indicator="Account Threat", description="Claims your account will be blocked or suspended.", severity="high"),
        RedFlag(indicator="KYC Urgency", description="Demands immediate KYC verification through unofficial channels.", severity="high"),
        RedFlag(indicator="Credential Request", description="Asks for OTP, PIN, card number, or other sensitive information.", severity="critical"),
    ],
    "Investment Scam": [
        RedFlag(indicator="Guaranteed Returns", description="Promises unrealistic guaranteed returns on investment.", severity="high"),
        RedFlag(indicator="Urgency", description="Pressures you to invest immediately before an opportunity closes.", severity="medium"),
        RedFlag(indicator="No Risk Claims", description="Claims the investment is risk-free, which is never true.", severity="high"),
        RedFlag(indicator="Unregistered Platform", description="Directs to unverified or unregistered investment platforms.", severity="high"),
    ],
    "Prepaid Task / Job Scam": [
        RedFlag(indicator="Upfront Payment Required", description="Requires a registration fee or deposit before starting work.", severity="high"),
        RedFlag(indicator="Too Good To Be True", description="Offers unusually high pay for simple tasks.", severity="medium"),
        RedFlag(indicator="Task-Based Earning", description="Describes simple rating/review tasks with monetary rewards.", severity="medium"),
        RedFlag(indicator="Group Recruitment", description="Directs to Telegram/WhatsApp groups for task assignments.", severity="medium"),
    ],
    "Phishing": [
        RedFlag(indicator="Suspicious Link", description="Contains a link to an unofficial or potentially malicious website.", severity="high"),
        RedFlag(indicator="Credential Harvesting", description="The link likely leads to a fake page designed to steal your login credentials.", severity="critical"),
        RedFlag(indicator="Urgency / Account Threat", description="Creates urgency by threatening account suspension.", severity="high"),
        RedFlag(indicator="Impersonation", description="Pretends to be from a trusted organization.", severity="high"),
    ],
    "UPI / Payment Scam": [
        RedFlag(indicator="Fake Payment Request", description="Sends a collect/payment request disguised as a refund.", severity="high"),
        RedFlag(indicator="QR Code Scam", description="Asks you to scan a QR code to 'receive' money (actually sends money).", severity="critical"),
        RedFlag(indicator="UPI PIN Request", description="Asks for your UPI PIN — never needed to receive money.", severity="critical"),
        RedFlag(indicator="Refund Pretext", description="Claims a refund but actually initiates a payment from your account.", severity="high"),
    ],
    "Government / Authority Impersonation": [
        RedFlag(indicator="Authority Impersonation", description="Claims to represent a government body or regulatory authority.", severity="high"),
        RedFlag(indicator="Official Language Misuse", description="Uses official-sounding language to appear legitimate.", severity="medium"),
        RedFlag(indicator="Aadhaar / Identity Threat", description="References Aadhaar misuse to create panic.", severity="high"),
        RedFlag(indicator="Demand for Action", description="Demands immediate compliance with unofficial instructions.", severity="high"),
    ],
    "Lottery / Prize Scam": [
        RedFlag(indicator="Unsolicited Prize", description="Claims you've won a lottery or prize you never entered.", severity="high"),
        RedFlag(indicator="Processing Fee", description="Asks for a fee to process or release the prize.", severity="high"),
        RedFlag(indicator="Too Good To Be True", description="The prize amount is unrealistically large.", severity="medium"),
        RedFlag(indicator="Personal Info Request", description="Asks for personal or financial information to claim the prize.", severity="high"),
    ],
}

SAFETY_RECOMMENDATIONS = {
    "Digital Arrest Scam": [
        "No Indian law-enforcement agency conducts arrests through phone or video calls.",
        "Do NOT transfer any money.",
        "Disconnect the call immediately.",
        "Do not share any personal information, OTP, or PIN.",
        "Save screenshots and evidence.",
        "Report to the National Cyber Crime Helpline: 1930",
        "File a complaint at cybercrime.gov.in",
    ],
    "Fake Bank Support": [
        "Banks never ask for OTP, PIN, or passwords over phone/SMS.",
        "Do NOT share your OTP, CVV, or card details.",
        "Hang up and call your bank's official number from their website.",
        "Do not click any links in the message.",
        "Report the number to your bank.",
        "Report to the National Cyber Crime Helpline: 1930",
    ],
    "Investment Scam": [
        "No legitimate investment guarantees fixed returns.",
        "Do NOT invest money based on unsolicited messages.",
        "Verify the platform with SEBI's registered intermediary list.",
        "Do not join unknown Telegram/WhatsApp investment groups.",
        "If already invested, stop sending more money immediately.",
        "Report to the National Cyber Crime Helpline: 1930",
    ],
    "Prepaid Task / Job Scam": [
        "Legitimate employers never ask for money upfront.",
        "Do NOT pay any registration or joining fee.",
        "Verify job offers through official company websites.",
        "Do not share banking details for 'salary setup' with unknown parties.",
        "Leave suspicious Telegram/WhatsApp task groups immediately.",
        "Report to the National Cyber Crime Helpline: 1930",
    ],
    "Phishing": [
        "Do NOT click any links in the message.",
        "Do not enter your credentials on unfamiliar websites.",
        "Check the URL carefully — scam sites mimic real ones.",
        "Contact the organization directly through their official website.",
        "Enable two-factor authentication on your accounts.",
        "Report to the National Cyber Crime Helpline: 1930",
    ],
    "UPI / Payment Scam": [
        "You NEVER need to enter your UPI PIN to receive money.",
        "Do NOT accept collect requests from unknown numbers.",
        "Do not scan QR codes sent by strangers claiming refunds.",
        "Verify transactions only through your bank's official app.",
        "Report suspicious UPI IDs to your bank.",
        "Report to the National Cyber Crime Helpline: 1930",
    ],
    "Government / Authority Impersonation": [
        "Government agencies do not conduct official business over WhatsApp or phone.",
        "Do NOT share personal documents or Aadhaar details.",
        "Verify any claim by visiting the official government website.",
        "Do not transfer money to any individual claiming to be a government official.",
        "Report to the National Cyber Crime Helpline: 1930",
    ],
    "Lottery / Prize Scam": [
        "You cannot win a lottery you never entered.",
        "Do NOT pay any processing or claim fees.",
        "Do not share bank account details to 'receive' a prize.",
        "Block and report the sender.",
        "Report to the National Cyber Crime Helpline: 1930",
    ],
}


def generate_explanation(scam_type: str, red_flags: List[RedFlag], risk_score: int) -> str:
    """Generate a plain-language explanation of the analysis."""
    explanations = {
        "Digital Arrest Scam": (
            "This communication impersonates a law-enforcement authority and uses threats of arrest "
            "to pressure the victim into transferring money immediately. This is a classic 'digital arrest' scam. "
            "No Indian law-enforcement agency conducts arrests through phone or video calls, "
            "and no legitimate authority will demand money transfers to avoid legal action."
        ),
        "Fake Bank Support": (
            "This communication pretends to be from a bank's customer support team and attempts to obtain "
            "sensitive financial information such as OTP, PIN, or card details. Legitimate banks never "
            "request such information through unsolicited calls or messages."
        ),
        "Investment Scam": (
            "This communication promotes an investment opportunity with unrealistic guaranteed returns. "
            "No legitimate investment can guarantee fixed returns. This is designed to lure victims into "
            "sending money to fraudulent platforms."
        ),
        "Prepaid Task / Job Scam": (
            "This communication describes a job or task opportunity that requires upfront payment. "
            "Legitimate employers never ask candidates to pay money for job opportunities. "
            "This is designed to collect registration fees from multiple victims."
        ),
        "Phishing": (
            "This communication contains suspicious links designed to steal your credentials or personal information. "
            "The links likely lead to fake websites that mimic legitimate organizations. "
            "Never enter personal information on unverified websites."
        ),
        "UPI / Payment Scam": (
            "This communication attempts to trick you into making a UPI payment under false pretenses. "
            "Remember: you never need to enter your UPI PIN to receive money. "
            "Collect requests from unknown numbers are a common scam tactic."
        ),
        "Government / Authority Impersonation": (
            "This communication falsely claims to be from a government authority to intimidate the victim. "
            "Government agencies do not conduct official business through unsolicited phone calls, "
            "WhatsApp messages, or video calls."
        ),
        "Lottery / Prize Scam": (
            "This communication claims you have won a lottery or prize, but requires you to pay a fee to claim it. "
            "You cannot win a lottery you never entered. This is designed to collect 'processing fees' from victims."
        ),
    }
    
    base = explanations.get(scam_type, 
        "This communication contains multiple suspicious indicators that suggest it may be a scam attempt. "
        "Exercise caution and verify through official channels before taking any action."
    )
    
    if risk_score >= 80:
        return f"⚠️ CRITICAL THREAT: {base}"
    elif risk_score >= 60:
        return f"⚠️ HIGH RISK: {base}"
    elif risk_score >= 30:
        return f"⚠ MODERATE RISK: {base}"
    else:
        return base


def generate_summary(scam_type: str, risk_score: int, risk_level: str) -> str:
    """Generate a brief summary of the scan result."""
    if scam_type == "Legitimate":
        return "No significant scam indicators detected. The communication appears to be legitimate."
    return (
        f"FraudShield AI has classified this communication as a potential {scam_type} "
        f"with a risk score of {risk_score}/100 ({risk_level}). "
        f"Review the red flags and safety recommendations below."
    )


LOCALIZED_RECOMMENDATIONS = {
    "hi": [
        "किसी भी अज्ञात व्यक्ति या लिंक पर पैसे ट्रांसफर न करें।",
        "अपना OTP, UPI PIN, पासवर्ड या बैंक विवरण कभी साझा न करें।",
        "कोई भी भारतीय सरकारी एजेंसी फोन या वीडियो कॉल पर डिजिटल गिरफ्तारी नहीं करती।",
        "तुरंत राष्ट्रीय साइबर अपराध हेल्पलाइन 1930 पर संपर्क करें या cybercrime.gov.in पर शिकायत दर्ज करें।"
    ],
    "pa": [
        "ਕਿਸੇ ਵੀ ਅਣਜਾਣ ਵਿਅਕਤੀ ਜਾਂ ਲਿੰਕ 'ਤੇ ਪੈਸੇ ਟ੍ਰਾਂਸਫਰ ਨਾ ਕਰੋ।",
        "ਆਪਣਾ OTP, UPI PIN, ਪਾਸਵਰਡ ਜਾਂ ਬੈਂਕ ਵੇਰਵੇ ਕਿਸੇ ਨਾਲ ਸਾਂਝਾ ਨਾ ਕਰੋ।",
        "ਕੋਈ ਵੀ ਭਾਰਤੀ ਸਰਕਾਰੀ ਏਜੰਸੀ ਫ਼ੋਨ ਜਾਂ ਵੀਡੀਓ ਕਾਲ 'ਤੇ ਡਿਜੀਟਲ ਗ੍ਰਿਫ਼ਤਾਰੀ ਨਹੀਂ ਕਰਦੀ।",
        "ਤੁਰੰਤ ਰਾਸ਼ਟਰੀ ਸਾਈਬਰ ਕ੍ਰਾਈਮ ਹੈਲਪਲਾਈਨ 1930 'ਤੇ ਰਿਪੋਰਟ ਕਰੋ ਜਾਂ cybercrime.gov.in 'ਤੇ ਸ਼ਿਕਾਇਤ ਕਰੋ।"
    ],
    "hinglish": [
        "Kisi bhi unknown person ya link par paise transfer na karein.",
        "Apna OTP, UPI PIN, password ya bank details kabhi kisi ke sath share na karein.",
        "Koi bhi Indian government agency phone ya video call par digital arrest nahi karti.",
        "Turant National Cyber Crime Helpline 1930 par call karein ya cybercrime.gov.in par report darj karein."
    ]
}


def analyze_with_fallback(text: str, input_type: str = "text", language: str = "en") -> AnalysisResult:
    """
    Rule-based fallback classifier.
    Uses deterministic pattern matching — no external API required.
    """
    from app.models.schemas import Verdict

    # Step 1: Calculate risk score with breakdown
    risk_score, risk_level, score_breakdown = calculate_risk_score(text)
    
    # Step 2: Classify scam type
    scam_type = classify_scam_type(text, score_breakdown)
    
    # Step 3: Get red flags for this scam type
    red_flags = SCAM_RED_FLAGS.get(scam_type, [])
    
    # If we detected signals but don't have specific red flags, build from breakdown
    if not red_flags and score_breakdown:
        red_flags = [
            RedFlag(
                indicator=b.signal,
                description=b.description,
                severity="high" if b.points >= 20 else "medium"
            )
            for b in score_breakdown
        ]
    
    # Step 4: Get safety recommendations
    base_recommendations = SAFETY_RECOMMENDATIONS.get(scam_type, [
        "Exercise caution with this communication.",
        "Do not share personal or financial information.",
        "Verify the sender's identity through official channels.",
        "Report suspicious activity to the National Cyber Crime Helpline: 1930",
    ])
    
    if language in LOCALIZED_RECOMMENDATIONS and scam_type != "Legitimate":
        recommendations = LOCALIZED_RECOMMENDATIONS[language] + base_recommendations[:2]
    else:
        recommendations = list(base_recommendations)
    
    # Step 5: Generate explanation
    explanation = generate_explanation(scam_type, red_flags, risk_score)
    
    # Step 6: Generate summary
    summary = generate_summary(scam_type, risk_score, risk_level.value)
    
    # Step 7: Extract detected entities & evidence
    entities = [b.signal for b in score_breakdown]
    evidence = [f"{b.signal}: {b.description}" for b in score_breakdown]
    
    # Step 8: Calculate confidence & verdict
    if risk_score >= 80:
        confidence = 0.92
        verdict = Verdict.LIKELY_SCAM.value
    elif risk_score >= 60:
        confidence = 0.85
        verdict = Verdict.LIKELY_SCAM.value
    elif risk_score >= 30:
        confidence = 0.72
        verdict = Verdict.SUSPICIOUS.value
    elif risk_score > 0:
        confidence = 0.55
        verdict = Verdict.UNCERTAIN.value
    else:
        confidence = 0.95  # High confidence it's legitimate
        verdict = Verdict.LIKELY_LEGITIMATE.value
    
    # Handle legitimate messages
    if scam_type == "Legitimate":
        red_flags = []
        recommendations = [
            "This communication appears to be safe.",
            "No immediate action is required.",
            "Always remain vigilant about unsolicited communications.",
        ]
        explanation = (
            "FraudShield AI did not detect significant scam indicators in this communication. "
            "The message appears to be legitimate. However, always exercise caution with "
            "unsolicited communications and never share sensitive information."
        )
        verdict = Verdict.LIKELY_LEGITIMATE.value
    
    return AnalysisResult(
        scam_type=scam_type,
        risk_score=risk_score,
        risk_level=risk_level,
        confidence=confidence,
        summary=summary,
        explanation=explanation,
        red_flags=red_flags,
        recommended_actions=recommendations,
        detected_entities=entities,
        score_breakdown=score_breakdown,
        input_type=InputType(input_type) if input_type in [e.value for e in InputType] else InputType.TEXT,
        input_text=text,
        ai_provider="fallback",
        verdict=verdict,
        evidence=evidence,
        model_name="rule_engine",
        language=language,
        fallback_used=True,
        fallback_reason=None,
    )
