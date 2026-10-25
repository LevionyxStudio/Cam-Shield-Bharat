"""
FraudShield AI — Pydantic Models & Schemas
Structured data models for scam analysis pipeline.
"""

from pydantic import BaseModel, Field
from typing import List, Optional
from enum import Enum
from datetime import datetime, timezone
import uuid


class InputType(str, Enum):
    SMS = "sms"
    WHATSAPP = "whatsapp"
    CALL_TRANSCRIPT = "call_transcript"
    AUDIO = "audio"
    TEXT = "text"


class RiskLevel(str, Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"


class ScamType(str, Enum):
    DIGITAL_ARREST = "Digital Arrest Scam"
    FAKE_BANK_SUPPORT = "Fake Bank Support"
    INVESTMENT_SCAM = "Investment Scam"
    PREPAID_TASK_SCAM = "Prepaid Task / Job Scam"
    PHISHING = "Phishing"
    UPI_PAYMENT_SCAM = "UPI / Payment Scam"
    GOVERNMENT_IMPERSONATION = "Government / Authority Impersonation"
    LOTTERY_PRIZE_SCAM = "Lottery / Prize Scam"
    UNKNOWN = "Unknown Scam Type"
    LEGITIMATE = "Legitimate"


class Verdict(str, Enum):
    LIKELY_SCAM = "likely_scam"
    SUSPICIOUS = "suspicious"
    LIKELY_LEGITIMATE = "likely_legitimate"
    UNCERTAIN = "uncertain"


class ResponseLanguage(str, Enum):
    ENGLISH = "en"
    HINDI = "hi"
    PUNJABI = "pa"
    HINGLISH = "hinglish"
    AUTO = "auto"


# ── Request Models ──

class AnalyzeMessageRequest(BaseModel):
    """Request to analyze a text message for scam indicators."""
    message: str = Field(..., min_length=1, max_length=5000, description="The suspicious message text to analyze")
    input_type: InputType = Field(default=InputType.TEXT, description="Source of the message")
    source_info: Optional[str] = Field(default=None, description="Optional source identifier (e.g., phone number placeholder)")
    language: Optional[str] = Field(default="en", description="Desired response language: en, hi, pa, hinglish, or auto")


class AnalyzeTranscriptRequest(BaseModel):
    """Request to analyze a call transcript."""
    transcript: str = Field(..., min_length=1, max_length=10000, description="Call transcript text")
    source_info: Optional[str] = Field(default=None, description="Optional source identifier")
    language: Optional[str] = Field(default="en", description="Desired response language: en, hi, pa, hinglish, or auto")


class ReportRequest(BaseModel):
    """Request to report a scam incident."""
    scan_id: str = Field(..., description="ID of the related scan")
    scam_type: str = Field(..., description="Type of scam")
    risk_score: int = Field(..., ge=0, le=100, description="Risk score from analysis")
    description: Optional[str] = Field(default=None, description="User's description of the incident")
    communication_source: Optional[str] = Field(default=None, description="Where the communication came from")


# ── Response Models ──

class RedFlag(BaseModel):
    """A detected red flag in the communication."""
    indicator: str = Field(..., description="The red flag category")
    description: str = Field(..., description="Explanation of why this is a red flag")
    severity: str = Field(default="high", description="Severity: low, medium, high, critical")


class RiskScoreBreakdown(BaseModel):
    """Breakdown of how the risk score was calculated."""
    signal: str = Field(..., description="The risk signal detected")
    points: int = Field(..., description="Points contributed by this signal")
    description: str = Field(..., description="Why this signal is significant")


class AnalysisResult(BaseModel):
    """Complete scam analysis result — the core output of FraudShield AI / ScamShield Bharat."""
    model_config = {"protected_namespaces": ()}

    id: str = Field(default_factory=lambda: str(uuid.uuid4()), description="Unique scan ID")
    scam_type: str = Field(..., description="Classified scam type")
    risk_score: int = Field(..., ge=0, le=100, description="Overall risk score 0-100")
    risk_level: RiskLevel = Field(..., description="Risk level category")
    confidence: float = Field(..., ge=0.0, le=1.0, description="AI confidence in classification")
    summary: str = Field(..., description="Brief summary of the analysis")
    explanation: str = Field(..., description="Plain-language explanation of why this is dangerous")
    red_flags: List[RedFlag] = Field(default_factory=list, description="Detected red flags")
    recommended_actions: List[str] = Field(default_factory=list, description="Safety recommendations")
    detected_entities: List[str] = Field(default_factory=list, description="Entities detected in the message")
    score_breakdown: List[RiskScoreBreakdown] = Field(default_factory=list, description="Risk score breakdown")
    input_type: InputType = Field(default=InputType.TEXT, description="Type of input analyzed")
    input_text: str = Field(default="", description="The analyzed text")
    ai_provider: str = Field(default="fallback", description="Which AI provider was used")
    verdict: Optional[str] = Field(default=None, description="Contextual verdict: likely_scam, suspicious, likely_legitimate, uncertain")
    evidence: List[str] = Field(default_factory=list, description="Specific evidence grounded in submitted text")
    model_name: Optional[str] = Field(default=None, description="Specific AI model name used for analysis")
    language: Optional[str] = Field(default="en", description="Response language: en, hi, pa, hinglish")
    fallback_used: bool = Field(default=False, description="Whether fallback engine was used")
    fallback_reason: Optional[str] = Field(default=None, description="Reason fallback was triggered, if applicable")
    created_at: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat(), description="Timestamp")
    disclaimer: str = Field(
        default="AI-generated risk assessment. Verify critical decisions through official channels.",
        description="Legal disclaimer"
    )


class ScanRecord(BaseModel):
    """Summary record for scan history."""
    id: str
    scam_type: str
    risk_score: int
    risk_level: RiskLevel
    input_type: InputType
    summary: str
    created_at: str


class ReportResponse(BaseModel):
    """Response after submitting an incident report."""
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    status: str = Field(default="submitted")
    message: str = Field(default="Report submitted. For immediate help, contact the National Cyber Crime Helpline at 1930.")
    scan_id: str
    created_at: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())


class DemoScenario(BaseModel):
    """A preset demo scenario for demonstration."""
    id: str
    name: str
    description: str
    input_text: str
    input_type: InputType
    expected_scam_type: str
    expected_risk_level: str


class HealthResponse(BaseModel):
    """Health check response."""
    status: str = "healthy"
    service: str = "FraudShield AI Backend"
    version: str = "1.0.0"
    ai_provider: str = "fallback"
    stt_provider: str = "demo"
    firebase_enabled: bool = False
