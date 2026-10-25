# ScamShield Bharat — Demo Scenarios & Testing Guide

This guide details the preset demo scenarios and live test cases used to evaluate and showcase ScamShield Bharat.

---

## 1. Six Preset Demo Scenarios (`app/services/demo_scenarios.py`)

These scenarios are hardcoded in the backend service and can be queried via `GET /api/demo/scenarios` or triggered live via `POST /api/demo/run/{scenario_id}`.

### 1. `digital_arrest` — Digital Arrest Scam
- **Category**: Digital Arrest Scam
- **Expected Level**: `CRITICAL` (Score: 80–100)
- **Input Text**:
  > *"This is CBI. Your bank account is linked to a money laundering case under investigation. You are under digital arrest. Stay on this video call and do not tell anyone. Transfer Rs 12,00,000 immediately to the secure government account to avoid arrest. Your Aadhaar is linked to illegal activity. If you disconnect, a warrant will be issued."*
- **Key Indicators**: CBI impersonation (+25), arrest warrant threat (+25), urgent fund transfer (+20), psychological coercion (+15), Aadhaar threat (+18).

### 2. `fake_bank_support` — Fake Bank KYC Support
- **Category**: Fake Bank Support
- **Expected Level**: `HIGH` / `CRITICAL` (Score: 70–90)
- **Input Text**:
  > *"Dear Customer, this is SBI Customer Care. Your account will be blocked within 24 hours due to incomplete KYC verification. Please share your Aadhaar number and OTP sent to your registered mobile number immediately to avoid account suspension."*
- **Key Indicators**: Bank customer care impersonation (+20), account blocking threat (+20), OTP credential request (+20).

### 3. `investment_scam` — Guaranteed Stock Returns Scam
- **Category**: Investment Scam
- **Expected Level**: `HIGH` (Score: 60–80)
- **Input Text**:
  > *"EXCLUSIVE OFFER! Join our premium stock trading group on Telegram. We guarantee 200% returns in just 30 days! Invest Rs 50,000 today and earn Rs 1,50,000. Zero risk, 100% profit guaranteed. Limited slots available."*
- **Key Indicators**: Guaranteed high returns (+20), zero risk claims (+20), Telegram trading group link.

### 4. `prepaid_task_scam` — YouTube / Review Task Job Scam
- **Category**: Prepaid Task / Job Scam
- **Expected Level**: `HIGH` (Score: 60–80)
- **Input Text**:
  > *"Hi! We have a simple work-from-home opportunity. Complete online rating tasks and earn Rs 1500 per task. Daily income up to Rs 15000! Pay registration fee of Rs 1999 to join our Telegram group."*
- **Key Indicators**: Upfront registration fee (+20), unrealistic pay for simple tasks (+20), Telegram group recruitment.

### 5. `phishing_sms` — Bank KYC Update Link Phishing
- **Category**: Phishing
- **Expected Level**: `HIGH` / `CRITICAL` (Score: 70–85)
- **Input Text**:
  > *"URGENT: Your SBI account has been suspended due to incomplete KYC. Click here immediately to verify: http://sbi-kyc-update.fake-link.com/verify"*
- **Key Indicators**: Malicious link (+15), bank impersonation (+20), urgency (+20).

### 6. `legitimate_message` — Casual Dinner Invitation
- **Category**: Legitimate
- **Expected Level**: `LOW` (Score: 0)
- **Input Text**:
  > *"Hey! Are we still on for dinner tonight at 8 PM? Let me know if that works for you."*
- **Key Indicators**: No threat, financial, or urgency signals. Evaluates to 0 points with 0 red flags.

---

## 2. Six Live Test Scenarios (`tests/run_scam_scenarios.py`)

These scenarios test the running backend via HTTP requests to `POST /api/analyze/message` and are validated by the test suite:

| # | ID | Scenario | Input Language | Expected Category | Expected Level | Verified Latency |
|---|---|---|:---:|---|:---:|:---:|
| 1 | `1_bank_otp` | HDFC Account Suspension + OTP | English | Phishing / Bank Support | `HIGH` (75) | ~6–16s |
| 2 | `2_kyc_link` | Expiring NetBanking + Fake URL | English | Phishing | `CRITICAL` (85) | ~8–10s |
| 3 | `3_lottery_fee` | KBC Lucky Draw + Advance UPI Fee | English | Lottery / Prize Scam | `HIGH` (75) | ~11–15s |
| 4 | `4_harmless_dinner` | Family Dinner Message | English | Legitimate | `LOW` (0) | ~6–11s |
| 5 | `5_hindi_hinglish` | Hinglish Account Freeze + OTP | Hinglish | Phishing / Bank Support | `HIGH` (75) | ~5–8s |
| 6 | `6_no_obvious_scam` | Sharing Presentation Slides | English | Legitimate | `LOW` (0) | ~9–12s |

---

## 3. Multilingual Test Cases (`tests/test_integration_ollama.py`)

The automated test suite verifies cross-language detection:

1. **Hindi (Devanagari)** — Electricity Disconnection Scam:
   - *Input*: `"प्रिय उपभोक्ता, आपकी बिजली आज रात 9:30 बजे काट दी जाएगी क्योंकि आपका पिछला बिल अपडेट नहीं हुआ है। तुरंत संपर्क करें 9876543210 पर।"`
   - *Expected*: Government / Authority Impersonation or Phishing (`HIGH` / `CRITICAL`).
2. **Punjabi (Gurmukhi)** — Lottery Reward Scam:
   - *Input*: `"ਵਧਾਈ ਹੋਵੇ! ਤੁਸੀਂ 25 ਲੱਖ ਰੁਪਏ ਦੀ ਲਾਟਰੀ ਜਿੱਤੀ ਹੈ। ਇਨਾਮ ਲੈਣ ਲਈ ਰਜਿਸਟ੍ਰੇਸ਼ਨ ਫੀਸ 5000 ਰੁਪਏ ਜਮ੍ਹਾਂ ਕਰੋ।"`
   - *Expected*: Lottery / Prize Scam (`HIGH` / `CRITICAL`).
3. **Hinglish** — Credit Card Block Scam:
   - *Input*: `"Aapka credit card block ho gaya hai. Card activate karne ke liye apna 16-digit card number aur CVV share karein."`
   - *Expected*: Fake Bank Support / Phishing (`HIGH` / `CRITICAL`).

---

## 4. How to Execute the Scenarios

### Method A: Running the Scenario Script
Ensure the backend server is running on `127.0.0.1:8000`, then run:
```powershell
cd backend
.\venv\Scripts\python.exe tests/run_scam_scenarios.py
```
Output results will be printed to the terminal and exported to `backend/tests_output/scam_detection_results.json`.

### Method B: Via cURL / HTTP Request
```powershell
curl -X POST "http://127.0.0.1:8000/api/analyze/message" `
  -H "Content-Type: application/json" `
  -d '{"message": "Your account has been blocked. Share OTP immediately.", "input_type": "sms", "language": "en"}'
```

### Method C: Via Preset Demo Endpoints
```powershell
curl -X POST "http://127.0.0.1:8000/api/demo/run/digital_arrest"
```

---

## 5. How to Interpret Results

When reviewing scenario outputs:
- **`scam_type`**: The normalized fraud classification.
- **`risk_score`** (0–100): Calculated by combining AI inference and deterministic rule signals.
- **`risk_level`**:
  - `0–29`: **LOW** (Safe or personal communication).
  - `30–59`: **MEDIUM** (Unusual request requiring caution).
  - `60–79`: **HIGH** (Clear fraud indicators present).
  - `80–100`: **CRITICAL** (Impersonation, arrest threat, or credential harvesting).
- **`verdict`**: High-level verdict (`likely_scam`, `suspicious`, `likely_legitimate`, `uncertain`).
- **`fallback_used`**:
  - `false`: Live Ollama inference evaluated the text.
  - `true`: Rule fallback engine produced the result (Ollama was offline or unreachable).
- **`red_flags`**: Explicit reasons explaining why the message is considered dangerous.
- **`recommended_actions`**: Steps to protect the user (e.g. *"Call the National Cyber Crime Helpline at 1930"*).

---

## 6. Known Limitations & Edge Cases

1. **Subtle / Conversational Pretexts**: Messages with no financial keywords, no links, and subtle coercion may receive a lower risk score or `uncertain` verdict.
2. **Security Keywords in Benign Contexts**: Legitimate messages discussing scams (e.g. *"Police visited our school today to talk about cyber crime"*) are tested to avoid false positives, but highly unusual wording may occasionally score in the `MEDIUM` bracket.
3. **Small LLM (1.5B) Variance**: `qwen2.5:1.5b` running locally on 4GB VRAM may occasionally format JSON slightly differently; the backend includes regex repair logic, but extreme token truncations will fall back to the rule engine.
