"""
FraudShield AI — Demo Scenarios
Preset scenarios for reliable demonstration during judging.
"""

from app.models.schemas import DemoScenario, InputType

DEMO_SCENARIOS = [
    DemoScenario(
        id="demo_digital_arrest",
        name="Digital Arrest Scam",
        description="Classic digital arrest scam — CBI impersonation with arrest threat and urgent money demand.",
        input_text=(
            "This is CBI. Your bank account is linked to a money laundering case under investigation. "
            "You are under digital arrest. Stay on this video call and do not tell anyone. "
            "Transfer ₹2,00,000 immediately to the secure government account to avoid arrest. "
            "Your Aadhaar is linked to illegal activity. If you disconnect, a warrant will be issued."
        ),
        input_type=InputType.CALL_TRANSCRIPT,
        expected_scam_type="Digital Arrest Scam",
        expected_risk_level="CRITICAL",
    ),
    DemoScenario(
        id="demo_fake_bank",
        name="Fake Bank Support",
        description="Fake bank customer care call demanding KYC update and OTP.",
        input_text=(
            "Dear Customer, this is SBI Customer Care. Your account will be blocked within 24 hours "
            "due to incomplete KYC verification. Please share your Aadhaar number and OTP sent to "
            "your registered mobile number immediately to avoid account suspension. "
            "Call us at 9876543210 for immediate resolution. Your account number ending in 4521."
        ),
        input_type=InputType.SMS,
        expected_scam_type="Fake Bank Support",
        expected_risk_level="CRITICAL",
    ),
    DemoScenario(
        id="demo_investment",
        name="Investment Scam",
        description="Crypto/stock trading scam with guaranteed returns promise.",
        input_text=(
            "🔥 EXCLUSIVE OFFER! Join our premium stock trading group on Telegram. "
            "We guarantee 200% returns in just 30 days! Invest ₹50,000 today and earn ₹1,50,000. "
            "Zero risk, 100% profit guaranteed. Limited slots available — act now! "
            "Our expert traders use AI to predict the market. Join now: t.me/faketrading"
        ),
        input_type=InputType.WHATSAPP,
        expected_scam_type="Investment Scam",
        expected_risk_level="HIGH",
    ),
    DemoScenario(
        id="demo_task_scam",
        name="Prepaid Task / Job Scam",
        description="Online task/job scam requiring registration fee.",
        input_text=(
            "Hi! We have a simple work-from-home opportunity. Complete online rating tasks and "
            "earn ₹500 per task. Daily income up to ₹5000! Just pay a one-time registration fee "
            "of ₹999 to join our Telegram group. Start earning immediately after registration. "
            "Pay via UPI to get instant access to tasks. Limited positions available!"
        ),
        input_type=InputType.WHATSAPP,
        expected_scam_type="Prepaid Task / Job Scam",
        expected_risk_level="HIGH",
    ),
    DemoScenario(
        id="demo_phishing",
        name="Phishing SMS",
        description="Classic phishing SMS with fake bank link.",
        input_text=(
            "URGENT: Your SBI account will be blocked today due to expired KYC. "
            "Verify your KYC immediately to avoid account suspension. "
            "Click here to update: http://sbi-kyc-update.fake-link.com/verify "
            "This is your last chance to prevent account deactivation."
        ),
        input_type=InputType.SMS,
        expected_scam_type="Phishing",
        expected_risk_level="HIGH",
    ),
    DemoScenario(
        id="demo_legitimate",
        name="Safe / Legitimate Message",
        description="A normal, legitimate message that should receive LOW risk.",
        input_text=(
            "Hey! Are we still on for dinner at 7 PM tonight? I was thinking we could try that "
            "new restaurant near Connaught Place. Let me know if the timing works for you. "
            "Also, don't forget to bring the book you borrowed last week!"
        ),
        input_type=InputType.TEXT,
        expected_scam_type="Legitimate",
        expected_risk_level="LOW",
    ),
]


def get_demo_scenarios():
    """Return all demo scenarios."""
    return DEMO_SCENARIOS


def get_demo_scenario_by_id(scenario_id: str):
    """Get a specific demo scenario by ID."""
    for scenario in DEMO_SCENARIOS:
        if scenario.id == scenario_id:
            return scenario
    return None
