"""
ScamShield Bharat — Live Integration Tests for Ollama and Fast API Backend.
These integration tests execute against the live Ollama service if available.
If Ollama is offline or uninstalled, tests skip gracefully with a clear notice.
"""

import os
import sys
import pytest
import httpx
from datetime import datetime

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from app.models.schemas import Verdict, RiskLevel, InputType
from app.ai.ollama_provider import OllamaProvider
from app.ai.engine import analyze_communication
from app.scoring.risk_engine import calculate_risk_score, classify_scam_type

def is_ollama_online() -> bool:
    """Check if Ollama is running and responsive."""
    try:
        r = httpx.get("http://localhost:11434/api/tags", timeout=1.5)
        return r.status_code == 200
    except Exception:
        return False

requires_ollama = pytest.mark.skipif(
    not is_ollama_online(),
    reason="Ollama service is not reachable at http://localhost:11434"
)


# ── 1. Health Endpoint Integration Test ──

@pytest.mark.asyncio
async def test_live_health_endpoint():
    """Verify backend health endpoint reports healthy with Ollama provider."""
    from app.main import app
    from httpx import AsyncClient, ASGITransport
    
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        resp = await ac.get("/health")
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "healthy"
        assert data["ai_provider"] in ("ollama", "fallback")


# ── 2. Real Model Inference Integration Test ──

@pytest.mark.asyncio
@requires_ollama
async def test_live_ollama_real_model_inference():
    """Verify real Ollama model produces structured output on synthetic SBI OTP message."""
    text = "Your SBI account will be blocked today. Send your OTP immediately to avoid suspension."
    provider = OllamaProvider()
    
    result = await provider.analyze(text, input_type="sms", language="en")
    assert result is not None
    assert result.ai_provider == "ollama"
    assert result.fallback_used is False
    assert result.model_name == "qwen2.5:1.5b"
    assert result.risk_score >= 50
    # Must NOT be classified as Digital Arrest
    assert result.scam_type in ("Fake Bank Support", "Phishing")
    assert len(result.red_flags) > 0
    assert len(result.recommended_actions) > 0


# ── 3. Rule-Based Fallback when Ollama Unavailable ──

@pytest.mark.asyncio
async def test_fallback_activated_when_ollama_unavailable():
    """Verify engine falls back transparently when Ollama endpoint is down."""
    offline_provider = OllamaProvider(base_url="http://127.0.0.1:59999", timeout=1.0)
    text = "Your SBI account will be blocked today. Send your OTP immediately to avoid suspension."
    
    # Offline provider returns None and sets last_error
    res = await offline_provider.analyze(text, "sms")
    assert res is None
    assert offline_provider.last_error is not None
    assert ("connect" in offline_provider.last_error.lower() or "timed out" in offline_provider.last_error.lower())


# ── 4. Model Timeout and Malformed Output Handled Gracefully ──

@pytest.mark.asyncio
async def test_malformed_json_fallback_handling():
    """Verify provider handles malformed non-JSON output and reports error."""
    provider = OllamaProvider()
    res = provider.parse_ollama_response("This is plain text without JSON", "dummy text", "text", "en")
    assert res is None
    assert provider.last_error is not None
    assert "Failed to parse" in provider.last_error


# ── 5. Scam-like Messages: Category and Risk Detection ──

@pytest.mark.asyncio
@requires_ollama
async def test_live_digital_arrest_scam():
    """Verify real model identifies genuine Digital Arrest impersonation."""
    text = "This is Inspector Sharma from CBI Delhi. A warrant has been issued against your Aadhaar. You are under digital arrest."
    provider = OllamaProvider()
    result = await provider.analyze(text, input_type="call_transcript", language="en")
    
    assert result is not None
    assert result.scam_type == "Digital Arrest Scam"
    assert result.risk_score >= 70
    assert result.verdict in (Verdict.LIKELY_SCAM.value, Verdict.SUSPICIOUS.value)


@pytest.mark.asyncio
@requires_ollama
async def test_live_upi_collect_request_scam():
    """Verify real model identifies UPI QR / collect PIN scam."""
    text = "I am sending you Rs 15000 on Google Pay. Please scan this QR code and enter your UPI PIN to claim money."
    provider = OllamaProvider()
    result = await provider.analyze(text, input_type="whatsapp", language="en")
    
    assert result is not None
    assert result.scam_type == "UPI / Payment Scam"
    assert result.risk_score >= 60


# ── 6. Genuine-Looking Messages ──

@pytest.mark.asyncio
@requires_ollama
async def test_live_genuine_casual_message():
    """Verify legitimate casual message is not falsely flagged as a scam."""
    text = "Hey Dad, the train is on time. I should reach New Delhi railway station by 6:30 PM."
    provider = OllamaProvider()
    result = await provider.analyze(text, input_type="sms", language="en")
    
    assert result is not None
    assert result.scam_type == "Legitimate"
    assert result.risk_score < 25
    assert result.verdict == Verdict.LIKELY_LEGITIMATE.value


def test_rule_engine_genuine_bank_otp_alert():
    """Verify rule engine does not classify a genuine transactional OTP warning as phishing."""
    text = "HDFC Bank: OTP for txn of INR 450.00 at Swiggy is 849201. NEVER share your OTP with anyone. Bank never calls for OTP."
    score, level, breakdown = calculate_risk_score(text)
    scam_type = classify_scam_type(text, breakdown)
    
    # Must be recognized as legitimate notification
    assert scam_type == "Legitimate"
    assert score == 0


# ── 7. Ambiguous Messages with Low Evidence ──

@pytest.mark.asyncio
@requires_ollama
async def test_ambiguous_low_evidence_message():
    """Verify ambiguous message without clear proof yields uncertain or cautious verdict."""
    text = "Your package 4921 could not be delivered. Please call back."
    provider = OllamaProvider()
    result = await provider.analyze(text, input_type="sms", language="en")
    
    assert result is not None
    # Ambiguous message should not be classified as high-confidence critical arrest
    assert result.risk_score < 80
    assert result.verdict in (Verdict.UNCERTAIN.value, Verdict.SUSPICIOUS.value, Verdict.LIKELY_LEGITIMATE.value)


# ── 8. Multilingual Inputs: Hindi, Punjabi, Hinglish ──

@pytest.mark.asyncio
@requires_ollama
async def test_hindi_electricity_scam():
    """Verify analysis of Hindi Devanagari electricity bill threat."""
    text = "प्रिय उपभोक्ता, आपकी बिजली आज रात 9:30 बजे काट दी जाएगी क्योंकि आपका पिछला बिल अपडेट नहीं हुआ है। तुरंत 9876543210 पर कॉल करें।"
    provider = OllamaProvider()
    result = await provider.analyze(text, input_type="sms", language="hi")
    
    assert result is not None
    assert result.risk_score >= 60
    assert result.scam_type in ("Government / Authority Impersonation", "Phishing", "Fake Bank Support")


@pytest.mark.asyncio
@requires_ollama
async def test_punjabi_lottery_scam():
    """Verify analysis of Roman Punjabi lottery scam."""
    text = "Mubarak ho! Tuhada number 25 lakh di KBC lottery vich select hoya hai. Prize claim karan layi 12000 rupaye processing fee transfer karo."
    provider = OllamaProvider()
    result = await provider.analyze(text, input_type="sms", language="pa")
    
    assert result is not None
    assert result.scam_type == "Lottery / Prize Scam"
    assert result.risk_score >= 70


@pytest.mark.asyncio
@requires_ollama
async def test_hinglish_card_blocked_scam():
    """Verify analysis of Hinglish credit card blocking threat."""
    text = "Aapka HDFC credit card block ho gaya hai. Turant unblock karne ke liye customer care executive ko apna 6-digit OTP share karein."
    provider = OllamaProvider()
    result = await provider.analyze(text, input_type="sms", language="hinglish")
    
    assert result is not None
    assert result.scam_type in ("Fake Bank Support", "Phishing")
    assert result.risk_score >= 60
