"""
FraudShield AI — Risk Scoring Engine
Deterministic, explainable risk scoring based on detected signals.
Works alongside AI classification — does NOT rely blindly on LLM-generated numbers.
"""

import re
from typing import List, Tuple
from app.models.schemas import RiskScoreBreakdown, RiskLevel


# ── Risk Signal Definitions ──
# Each signal has: (name, points, patterns, description)

RISK_SIGNALS = [
    {
        "signal": "Government / Law Enforcement Impersonation",
        "points": 25,
        "patterns": [
            r"\b(cbi|police|customs|narcotics|enforcement|directorate|ministry|government|ncrb|rbi|sebi|income\s*tax|ed\b|nia\b)\b",
            r"\b(officer|inspector|commissioner|superintendent|magistrate|judge|authority)\b",
            r"\b(this is|i am|we are|calling from)\s+(the\s+)?(cbi|police|customs|cyber\s*cell|crime\s*branch)\b",
        ],
        "description": "The message impersonates a government or law-enforcement authority."
    },
    {
        "signal": "Arrest / Legal Threat",
        "points": 25,
        "patterns": [
            r"\b(arrest|warrant|jail|prison|custody|detained|legal\s*action|court\s*order|fir|criminal\s*case)\b",
            r"\b(under\s+investigation|money\s*laundering|illegal\s*activity|criminal\s*offense)\b",
            r"\b(you\s+will\s+be\s+arrested|avoid\s+arrest|prevent\s+arrest|face\s+arrest)\b",
            r"\b(digital\s+arrest|cyber\s*crime\s*case|linked\s+to\s+.*\s*case)\b",
        ],
        "description": "The message threatens arrest or legal action to create fear."
    },
    {
        "signal": "Urgent Payment / Money Request",
        "points": 20,
        "patterns": [
            r"\b(transfer|send|pay|deposit|payment)\s+(money|funds|amount|₹|\$|rs\.?|rupees?|inr)\b",
            r"\b(₹|rs\.?)\s*[\d,]+",
            r"\b(immediately|urgently|right\s*now|within\s+\d+\s*(hour|minute|day))\b",
            r"\b(transfer\s+funds|send\s+money|make\s+payment)\b",
            r"\b(fine|penalty|fee|charge|deposit)\s+(of\s+)?(₹|rs\.?)\b",
        ],
        "description": "The message demands urgent money transfer."
    },
    {
        "signal": "OTP / PIN / Password Request",
        "points": 20,
        "patterns": [
            r"\b(share|provide|send|enter|tell|forward|submit|input)\s+(your\s+)?(otp|pin|password|cvv|mpin|upi\s*pin)\b",
            r"\b(share|send|provide)\s+.*(otp|verification\s*code|security\s*code)\b",
            r"\b(verification\s*code|security\s*code|otp)\s+.*(share|send|provide|tell)\b",
            r"\b(ask(ing)?\s+for|demands?)\s+(your\s+)?(otp|pin|password|cvv)\b",
            r"\b(enter|update)\s+(your\s+)?(card\s*number|account\s*number|cvv|expiry)\b",
            r"\b(otp|pin)\s+(required|needed)\s+to\s+(unblock|verify|activate|avoid)\b",
        ],
        "description": "The message asks for sensitive credentials like OTP, PIN, or passwords."
    },
    {
        "signal": "Fear / Psychological Coercion",
        "points": 15,
        "patterns": [
            r"\b(do\s+not\s+tell\s+anyone|don'?t\s+tell|keep\s+this\s+secret|confidential)\b",
            r"\b(stay\s+on\s+(the\s+)?(call|video\s*call|line)|do\s+not\s+disconnect|don'?t\s+hang\s*up)\b",
            r"\b(your\s+family|your\s+life|consequences|serious\s+trouble|big\s+problem)\b",
            r"\b(account\s+will\s+be\s+(frozen|blocked|suspended|closed)|freeze\s+your\s+account)\b",
            r"\b(last\s+chance|final\s+warning|no\s+other\s+option|only\s+way)\b",
            r"\b(urgent|immediately|right\s*now|before\s+it\s+gets|act\s+now|hurry)\b",
            r"\b(suspended|deactivat|blocked)\b",
        ],
        "description": "The message uses fear, secrecy, urgency, or coercion to manipulate the victim."
    },
    {
        "signal": "Suspicious Link / URL",
        "points": 15,
        "patterns": [
            r"https?://[^\s]+",
            r"\b(click\s+(here|this|the\s+link)|visit|open|verify\s+at|update\s+at)\b.*\b(link|url|website)\b",
            r"\b(bit\.ly|tinyurl|goo\.gl|short\.url|t\.co)\b",
            r"\bhttp://\b",  # Non-HTTPS links
        ],
        "description": "The message contains suspicious or potentially malicious links."
    },
    {
        "signal": "Investment / Returns Guarantee",
        "points": 20,
        "patterns": [
            r"\b(guaranteed?\s+returns?|double\s+your\s+money|100%\s+profit|high\s+returns?)\b",
            r"\b(invest|investment)\s+(now|today|immediately|₹|rs)\b",
            r"\b(earn\s+₹|earn\s+rs|make\s+money|passive\s+income|daily\s+income)\b",
            r"\b(crypto|bitcoin|trading|forex|stock\s*market)\s+(invest|opportunity|profit|group|trading)\b",
            r"\b(no\s+risk|risk\s*free|zero\s+risk)\b",
            r"\b(guaranteed|200%|300%|5x|10x|100%)\b.*\b(return|profit|earn)\b",
            r"\b(earn|profit|return)\b.*\b(guaranteed|100%|200%)\b",
        ],
        "description": "The message promises guaranteed investment returns, which is a classic scam indicator."
    },
    {
        "signal": "Prepaid Task / Job Fraud",
        "points": 20,
        "patterns": [
            r"\b(work\s+from\s+home|part\s*time\s+job|online\s+job|simple\s+task)\b",
            r"\b(complete\s+task|do\s+task|finish\s+task|rating\s+task|review\s+task)\b",
            r"\b(registration\s+fee|joining\s+fee|advance\s+payment|pay\s+first|deposit\s+first)\b",
            r"\b(telegram\s+group|whatsapp\s+group|join\s+.*group)\b.*\b(earn|money|task)\b",
            r"(₹\s*\d+\s*per\s*(task|review|order|click))",
            r"\b(earn\s+₹|₹\s*\d+.*per\s+task)\b",
            r"\b(rating\s+task|review\s+task|simple\s+task|online\s+task)\b",
            r"\b(registration\s+fee|joining\s+fee)\b",
        ],
        "description": "The message describes a task/job scam requiring upfront payment."
    },
    {
        "signal": "Bank / KYC Impersonation",
        "points": 20,
        "patterns": [
            r"\b(sbi|hdfc|icici|axis|pnb|bob|kotak|yes\s*bank|rbl|idbi|canara|bank)\b.*\b(block\w*|suspend\w*|clos\w*|verif\w*|kyc|updat\w*)\b",
            r"\b(kyc|know\s+your\s+customer)\s+(update|verify|expire|expir|pending|mandatory)\b",
            r"\b(your\s+account\s+will\s+be\s+(blocked|closed|suspended)|account\s+.*deactivat)\b",
            r"\b(bank\s+manager|bank\s+officer|customer\s+(care|support|service))\b",
            r"\b(pan\s*card|aadhaar|aadhar)\s+(link|verify|update|expire)\b",
        ],
        "description": "The message impersonates a bank or financial institution."
    },
    {
        "signal": "Lottery / Prize / Reward Scam",
        "points": 18,
        "patterns": [
            r"\b(congratulations|congrats|winner|won|selected|chosen)\b",
            r"\b(lottery|prize|reward|gift\s*card|lucky\s*draw|jackpot)\b",
            r"\b(claim\s+your|collect\s+your|redeem\s+your)\s+(prize|reward|gift|money|winning)\b",
            r"\b(processing\s+fee|claim\s+fee|tax\s+fee)\b",
        ],
        "description": "The message claims the user has won a lottery or prize."
    },
    {
        "signal": "Aadhaar / Identity Fraud",
        "points": 18,
        "patterns": [
            r"\b(aadhaar|aadhar)\s+(number|card|linked|misuse|illegal|fraud)\b",
            r"\b(your\s+aadhaar|your\s+aadhar)\s+(is|has\s+been|was)\s+(linked|used|misused|involved)\b",
            r"\b(identity\s+theft|identity\s+fraud|sim\s+swap|sim\s+clone)\b",
        ],
        "description": "The message references Aadhaar misuse to create panic."
    },
    {
        "signal": "UPI / Payment Fraud",
        "points": 18,
        "patterns": [
            r"\b(upi|paytm|phonepe|gpay|google\s*pay|bhim)\s+(pin|id|request|collect|payment)\b",
            r"\b(collect\s+request|payment\s+request|money\s+request)\b",
            r"\b(scan\s+(this\s+)?qr|qr\s+code)\b.*\b(pay|receive|money)\b",
            r"\b(refund|cashback)\s+(of\s+)?(₹|rs)\b",
        ],
        "description": "The message involves a UPI or digital payment scam."
    },
    {
        "signal": "Utility / Electricity Bill Threat",
        "points": 25,
        "patterns": [
            r"\b(electricity|power|bijli|bijlee)\b.*\b(disconnect|cut|block|suspend)\b",
            r"\b(bill\s*(update|pending|due|overdue|unpaid))\b",
            r"(बिजली|विद्युत).*(काट|बंद|डिसकनेक्ट)",
            r"(बिल\s*अपडेट|पिछला\s*बिल)",
        ],
        "description": "The message threatens disconnection of electricity or essential utilities."
    },
]


def calculate_risk_score(text: str) -> Tuple[int, RiskLevel, List[RiskScoreBreakdown]]:
    """
    Calculate a deterministic, explainable risk score from the input text.
    
    Returns:
        Tuple of (score, risk_level, breakdown)
    """
    text_lower = text.lower()
    total_score = 0
    breakdown = []
    
    has_safety_warning = bool(re.search(
        r"\b(never\s+share|do\s+not\s+share|don'?t\s+share|bank\s+never\s+asks|never\s+ask\s+for\s+otp|bank\s+never\s+calls)\b",
        text_lower
    ))
    has_solicitation = bool(re.search(
        r"\b(send|submit|forward|enter|tell|reply\s+with)\s+(your\s+)?(otp|pin|password|cvv)\b",
        text_lower
    ))

    for signal_def in RISK_SIGNALS:
        if signal_def["signal"] == "OTP / PIN / Password Request" and has_safety_warning and not has_solicitation:
            continue
        matched = False
        for pattern in signal_def["patterns"]:
            if re.search(pattern, text_lower, re.IGNORECASE):
                matched = True
                break
        
        if matched:
            total_score += signal_def["points"]
            breakdown.append(RiskScoreBreakdown(
                signal=signal_def["signal"],
                points=signal_def["points"],
                description=signal_def["description"]
            ))
    
    # Legitimate security notification dampener:
    # If the message explicitly warns NEVER to share OTP/PIN, and has NO harvesting solicitation, links, or arrest threats:
    is_security_warning = bool(re.search(
        r"\b(never\s+share|do\s+not\s+share|don'?t\s+share|bank\s+never\s+asks|never\s+ask\s+for\s+otp)\b",
        text_lower
    ))
    has_harvesting = any(b.signal == "OTP / PIN / Password Request" for b in breakdown)
    has_suspicious_link = any(b.signal == "Suspicious Link / URL" for b in breakdown)
    has_arrest_threat = any(b.signal in ("Arrest / Legal Threat", "Government / Law Enforcement Impersonation") for b in breakdown)
    
    if is_security_warning and not has_harvesting and not has_suspicious_link and not has_arrest_threat:
        total_score = 0
        breakdown = []

    # Normalize to 0-100
    score = min(total_score, 100)
    
    # Determine risk level
    if score >= 80:
        risk_level = RiskLevel.CRITICAL
    elif score >= 60:
        risk_level = RiskLevel.HIGH
    elif score >= 30:
        risk_level = RiskLevel.MEDIUM
    else:
        risk_level = RiskLevel.LOW
    
    return score, risk_level, breakdown


def classify_scam_type(text: str, breakdown: List[RiskScoreBreakdown]) -> str:
    """
    Classify the scam type based on detected signals.
    Uses priority ordering — the most specific/dangerous type wins.
    """
    text_lower = text.lower()
    signal_names = {b.signal for b in breakdown}
    
    # Priority-ordered classification
    # Digital Arrest: government impersonation + arrest threat
    if "Government / Law Enforcement Impersonation" in signal_names and "Arrest / Legal Threat" in signal_names:
        return "Digital Arrest Scam"
    
    # Government impersonation without arrest = Authority Impersonation
    if "Government / Law Enforcement Impersonation" in signal_names:
        if "Urgent Payment / Money Request" in signal_names:
            return "Digital Arrest Scam"
        return "Government / Authority Impersonation"
    
    # Phishing: suspicious links + bank/KYC
    if "Suspicious Link / URL" in signal_names and "Bank / KYC Impersonation" in signal_names:
        return "Phishing"
    
    if "Bank / KYC Impersonation" in signal_names:
        if "Suspicious Link / URL" in signal_names or "OTP / PIN / Password Request" in signal_names:
            return "Phishing"
        return "Fake Bank Support"
    
    # Task scam takes priority when both task and investment signals present
    if "Prepaid Task / Job Fraud" in signal_names:
        return "Prepaid Task / Job Scam"
    
    if "Investment / Returns Guarantee" in signal_names:
        return "Investment Scam"
    
    if "UPI / Payment Fraud" in signal_names:
        return "UPI / Payment Scam"
    
    if "Lottery / Prize / Reward Scam" in signal_names:
        return "Lottery / Prize Scam"
    
    if "Utility / Electricity Bill Threat" in signal_names:
        return "Phishing"
    
    if "Suspicious Link / URL" in signal_names:
        return "Phishing"
    
    if "OTP / PIN / Password Request" in signal_names:
        return "Phishing"
    
    if "Arrest / Legal Threat" in signal_names:
        return "Digital Arrest Scam"
    
    if "Aadhaar / Identity Fraud" in signal_names:
        return "Government / Authority Impersonation"
    
    if len(breakdown) > 0:
        return "Unknown Scam Type"
    
    return "Legitimate"


def get_risk_level_from_score(score: int) -> RiskLevel:
    """Convert a numeric score to a risk level."""
    if score >= 80:
        return RiskLevel.CRITICAL
    elif score >= 60:
        return RiskLevel.HIGH
    elif score >= 30:
        return RiskLevel.MEDIUM
    else:
        return RiskLevel.LOW
