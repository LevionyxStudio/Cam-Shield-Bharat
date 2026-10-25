"""
FraudShield AI — Backend Tests
Tests for scam detection, risk scoring, API validation, and fallback mode.
"""

import pytest
import sys
import os

# Add backend to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from app.scoring.risk_engine import calculate_risk_score, classify_scam_type, RiskLevel
from app.ai.fallback_classifier import analyze_with_fallback
from app.services.demo_scenarios import get_demo_scenarios


class TestDigitalArrestDetection:
    """Test detection of digital arrest scams."""
    
    def test_cbi_impersonation_with_arrest_threat(self):
        text = "This is CBI. You are under investigation for money laundering. Transfer ₹2,00,000 immediately to avoid arrest."
        result = analyze_with_fallback(text)
        assert result.scam_type == "Digital Arrest Scam"
        assert result.risk_score >= 70
        assert result.risk_level in (RiskLevel.HIGH, RiskLevel.CRITICAL)
    
    def test_digital_arrest_full_scenario(self):
        text = (
            "This is CBI. Your bank account is linked to a money laundering case under investigation. "
            "You are under digital arrest. Stay on this video call and do not tell anyone. "
            "Transfer ₹2,00,000 immediately to the secure government account to avoid arrest."
        )
        result = analyze_with_fallback(text)
        assert result.scam_type == "Digital Arrest Scam"
        assert result.risk_score >= 80
        assert result.risk_level == RiskLevel.CRITICAL
        assert len(result.red_flags) > 0
        assert len(result.recommended_actions) > 0
    
    def test_aadhaar_linked_arrest_scam(self):
        text = "Your Aadhaar is linked to illegal activity. Pay now to avoid arrest. This is the police."
        result = analyze_with_fallback(text)
        assert result.risk_score >= 50
        assert result.risk_level in (RiskLevel.MEDIUM, RiskLevel.HIGH, RiskLevel.CRITICAL)


class TestPhishingDetection:
    """Test detection of phishing messages."""
    
    def test_bank_kyc_phishing_sms(self):
        text = "Your SBI account will be blocked today. Verify your KYC immediately at http://sbi-kyc-fake.com/verify"
        result = analyze_with_fallback(text, "sms")
        assert result.scam_type in ("Phishing", "Fake Bank Support")
        assert result.risk_score >= 50
    
    def test_link_with_urgency(self):
        text = "URGENT: Click here to update your account http://fake-link.com/update before it gets suspended."
        result = analyze_with_fallback(text)
        assert result.risk_score >= 15
        assert result.scam_type == "Phishing"
    
    def test_otp_phishing(self):
        text = "Please share your OTP 4521 sent to your mobile to verify your account."
        result = analyze_with_fallback(text)
        assert result.risk_score >= 20


class TestFakeBankSupport:
    """Test detection of fake bank support scams."""
    
    def test_fake_sbi_support(self):
        text = (
            "Dear Customer, this is SBI Customer Care. Your account will be blocked within 24 hours "
            "due to incomplete KYC verification. Share your Aadhaar number and OTP immediately."
        )
        result = analyze_with_fallback(text)
        assert result.risk_score >= 60
        assert result.scam_type in ("Fake Bank Support", "Phishing")
    
    def test_account_freeze_threat(self):
        text = "Your HDFC account will be frozen. Call customer care at 9876543210 and share your card details."
        result = analyze_with_fallback(text)
        assert result.risk_score >= 30


class TestInvestmentScam:
    """Test detection of investment scams."""
    
    def test_guaranteed_returns(self):
        text = "Invest ₹50,000 today and earn guaranteed returns of 200% in 30 days. Zero risk, 100% profit!"
        result = analyze_with_fallback(text)
        assert result.scam_type == "Investment Scam"
        assert result.risk_score >= 20
    
    def test_crypto_trading_scam(self):
        text = "Join our premium crypto trading group. Guaranteed 5x returns. No risk, invest now!"
        result = analyze_with_fallback(text)
        assert result.risk_score >= 20
        assert result.scam_type == "Investment Scam"


class TestTaskScam:
    """Test detection of prepaid task/job scams."""
    
    def test_task_with_registration_fee(self):
        text = "Simple work from home opportunity! Complete rating tasks and earn ₹500 per task. Pay registration fee of ₹999 to join."
        result = analyze_with_fallback(text)
        assert result.scam_type == "Prepaid Task / Job Scam"
        assert result.risk_score >= 30
    
    def test_telegram_task_group(self):
        text = "Join our Telegram group for daily earning tasks. Earn ₹5000 daily. Pay ₹500 to start."
        result = analyze_with_fallback(text)
        assert result.risk_score >= 30


class TestLegitimateMessage:
    """Test that legitimate messages receive LOW risk."""
    
    def test_normal_dinner_message(self):
        text = "Hey! Are we still on for dinner at 7 PM tonight? Don't forget to bring the book."
        result = analyze_with_fallback(text)
        assert result.scam_type == "Legitimate"
        assert result.risk_score < 30
        assert result.risk_level == RiskLevel.LOW
    
    def test_normal_greeting(self):
        text = "Good morning! Hope you have a great day ahead."
        result = analyze_with_fallback(text)
        assert result.scam_type == "Legitimate"
        assert result.risk_score < 15
    
    def test_normal_work_message(self):
        text = "The meeting has been rescheduled to 3 PM. Please update your calendar."
        result = analyze_with_fallback(text)
        assert result.scam_type == "Legitimate"
        assert result.risk_score < 15


class TestRiskScoring:
    """Test the deterministic risk scoring engine."""
    
    def test_score_normalization(self):
        """Score should be 0-100."""
        text = "CBI arrest transfer money OTP password immediately"
        score, level, breakdown = calculate_risk_score(text)
        assert 0 <= score <= 100
    
    def test_risk_levels(self):
        """Test risk level thresholds."""
        from app.scoring.risk_engine import get_risk_level_from_score
        assert get_risk_level_from_score(10) == RiskLevel.LOW
        assert get_risk_level_from_score(45) == RiskLevel.MEDIUM
        assert get_risk_level_from_score(70) == RiskLevel.HIGH
        assert get_risk_level_from_score(90) == RiskLevel.CRITICAL
    
    def test_breakdown_provided(self):
        """Score breakdown should list detected signals."""
        text = "This is CBI. Transfer money immediately to avoid arrest."
        score, level, breakdown = calculate_risk_score(text)
        assert len(breakdown) > 0
        assert all(b.points > 0 for b in breakdown)
    
    def test_empty_input_zero_score(self):
        score, level, breakdown = calculate_risk_score("")
        assert score == 0
        assert level == RiskLevel.LOW
        assert len(breakdown) == 0


class TestDemoScenarios:
    """Test that all demo scenarios produce expected results."""
    
    def test_all_scenarios_run(self):
        scenarios = get_demo_scenarios()
        assert len(scenarios) >= 6
        
        for scenario in scenarios:
            result = analyze_with_fallback(scenario.input_text, scenario.input_type.value)
            assert result is not None
            assert result.risk_score >= 0
            assert result.risk_score <= 100
    
    def test_digital_arrest_scenario(self):
        scenarios = get_demo_scenarios()
        da = [s for s in scenarios if s.id == "demo_digital_arrest"][0]
        result = analyze_with_fallback(da.input_text, da.input_type.value)
        assert result.scam_type == "Digital Arrest Scam"
        assert result.risk_level == RiskLevel.CRITICAL
    
    def test_legitimate_scenario(self):
        scenarios = get_demo_scenarios()
        legit = [s for s in scenarios if s.id == "demo_legitimate"][0]
        result = analyze_with_fallback(legit.input_text, legit.input_type.value)
        assert result.scam_type == "Legitimate"
        assert result.risk_level == RiskLevel.LOW


class TestInvalidInput:
    """Test handling of invalid/edge-case inputs."""
    
    def test_very_short_input(self):
        result = analyze_with_fallback("hi")
        assert result.risk_score < 15
    
    def test_empty_characters(self):
        result = analyze_with_fallback("   ")
        assert result.risk_score < 15
    
    def test_unicode_input(self):
        result = analyze_with_fallback("नमस्ते, आज का मौसम अच्छा है।")
        assert result is not None
        assert result.risk_score >= 0


class TestAnalysisResultStructure:
    """Test that analysis results match the expected schema."""
    
    def test_result_has_all_fields(self):
        text = "This is CBI. Transfer money to avoid arrest."
        result = analyze_with_fallback(text)
        
        assert result.id is not None
        assert result.scam_type is not None
        assert 0 <= result.risk_score <= 100
        assert result.risk_level in RiskLevel
        assert 0.0 <= result.confidence <= 1.0
        assert result.summary != ""
        assert result.explanation != ""
        assert isinstance(result.red_flags, list)
        assert isinstance(result.recommended_actions, list)
        assert isinstance(result.detected_entities, list)
        assert isinstance(result.score_breakdown, list)
        assert result.ai_provider == "fallback"
        assert result.disclaimer != ""
    
    def test_legitimate_result_structure(self):
        result = analyze_with_fallback("Have a good day!")
        assert result.scam_type == "Legitimate"
        assert result.risk_score < 15
        assert len(result.recommended_actions) > 0


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
