# ScamShield Bharat — API Documentation

This document describes all verified REST endpoints provided by the ScamShield Bharat FastAPI backend.

## Base URLs
- **Local desktop**: `http://127.0.0.1:8000`
- **Android emulator loopback**: `http://10.0.2.2:8000`
- **Network / Physical phone**: `http://<HOST_IP>:8000`

## Interactive Documentation
- **Swagger UI**: `http://127.0.0.1:8000/docs`
- **ReDoc**: `http://127.0.0.1:8000/redoc`

---

## Authentication & Security
- **API Key**: Unauthenticated. While `API_KEY` is listed in `.env.example`, no endpoint in `app/api/routes.py` enforces API key headers or authentication guards.
- **CORS**: Enabled via `CORSMiddleware` in `app/main.py`. Defaults to `allow_origins=["*"]` with `allow_credentials=True`.

---

## Endpoints

### 1. Health Check

#### `GET /health`
Returns the operational health and active component configuration.

- **Query Parameters**: None
- **Request Body**: None
- **External Dependencies**: None
- **Response** (`200 OK`):
```json
{
  "status": "healthy",
  "service": "FraudShield AI Backend",
  "version": "1.0.0",
  "ai_provider": "ollama",
  "stt_provider": "demo",
  "firebase_enabled": false
}
```

---

### 2. Message Analysis

#### `POST /api/analyze/message`
Submits an SMS, WhatsApp message, or raw text communication for AI-powered scam analysis. Automatically persists the resulting scan in the scan history.

- **External Dependencies**: Uses Ollama (`qwen2.5:1.5b`) if available; falls back to deterministic rule engine if unreachable.
- **Request Headers**: `Content-Type: application/json`
- **Request Body** (`AnalyzeMessageRequest`):
  | Field | Type | Required | Description |
  |---|---|:---:|---|
  | `message` | string | **Yes** | Message text to analyze (1 to 5000 characters). |
  | `input_type` | string | No | Source channel: `"text"`, `"sms"`, `"whatsapp"`, `"call_transcript"`, `"audio"`. Default: `"text"`. |
  | `source_info` | string | No | Optional identifier (e.g. sender phone number or sender ID). Default: `null`. |
  | `language` | string | No | Desired response language: `"en"`, `"hi"`, `"pa"`, `"hinglish"`, `"auto"`. Default: `"en"`. |

- **Example Request**:
```json
{
  "message": "Your HDFC bank account has been suspended due to unverified KYC. Send your 6-digit OTP immediately to unlock your account.",
  "input_type": "sms",
  "source_info": "+919876543210",
  "language": "en"
}
```

- **Example Response** (`200 OK` - `AnalysisResult`):
```json
{
  "id": "91fe0e2f-bb96-4ac8-a9a6-6b4cfe9a26a1",
  "scam_type": "Phishing",
  "risk_score": 75,
  "risk_level": "HIGH",
  "confidence": 0.85,
  "summary": "Suspicious message from an unverified source claiming to suspend a bank account due to KYC issues and requiring immediate OTP verification.",
  "explanation": "The text is suspicious as it appears to be phishing for personal information, specifically the OTP required to unlock a suspended HDFC bank account.",
  "red_flags": [
    {
      "indicator": "Credential Request",
      "description": "Demands 6-digit OTP credential.",
      "severity": "high"
    }
  ],
  "recommended_actions": [
    "Do NOT transfer any money or share OTP / PIN credentials.",
    "Verify the sender's identity through official authorized contact details.",
    "Report suspected fraud to the National Cyber Crime Helpline at 1930 or cybercrime.gov.in."
  ],
  "detected_entities": [],
  "score_breakdown": [
    {
      "signal": "Urgent Payment / Money Request",
      "points": 20,
      "description": "The message demands urgent money transfer."
    },
    {
      "signal": "OTP / PIN / Password Request",
      "points": 20,
      "description": "The message asks for sensitive credentials like OTP, PIN, or passwords."
    },
    {
      "signal": "Bank / KYC Impersonation",
      "points": 20,
      "description": "The message impersonates a bank or financial institution."
    }
  ],
  "input_type": "sms",
  "input_text": "Your HDFC bank account has been suspended due to unverified KYC. Send your 6-digit OTP immediately to unlock your account.",
  "ai_provider": "ollama",
  "verdict": "suspicious",
  "evidence": [],
  "model_name": "qwen2.5:1.5b",
  "language": "en",
  "fallback_used": false,
  "fallback_reason": null,
  "created_at": "2026-10-24T16:09:06.019100+00:00",
  "disclaimer": "AI-generated risk assessment. Verify critical decisions through official channels."
}
```

- **Validation Errors** (`422 Unprocessable Entity`):
  Occurs if `message` is empty (`""`) or exceeds 5000 characters.

---

### 3. Call Transcript Analysis

#### `POST /api/analyze/transcript`
Submits a phone call conversation transcript for scam pattern analysis.

- **External Dependencies**: Uses Ollama (`qwen2.5:1.5b`) or rule fallback.
- **Request Body** (`AnalyzeTranscriptRequest`):
  | Field | Type | Required | Description |
  |---|---|:---:|---|
  | `transcript` | string | **Yes** | Call transcript text (1 to 10000 characters). |
  | `source_info` | string | No | Optional caller ID or context. Default: `null`. |
  | `language` | string | No | Language code: `"en"`, `"hi"`, `"pa"`, `"hinglish"`, `"auto"`. Default: `"en"`. |

- **Example Request**:
```json
{
  "transcript": "Caller: This is Inspector Sharma from Delhi Police Cyber Cell. Your Aadhaar is linked to money laundering in Mumbai. Stay on this line or an arrest warrant will be issued immediately.",
  "source_info": "Unknown Landline",
  "language": "en"
}
```

- **Response** (`200 OK`): Returns `AnalysisResult` (same schema as `/api/analyze/message`, with `input_type: "call_transcript"`).

---

### 4. Audio Analysis

#### `POST /api/analyze/audio`
Accepts an audio file upload for Speech-to-Text (STT) transcription and scam analysis.

- **Request Format**: `multipart/form-data`
  - Field: `file` (Binary audio data)
- **Verified Implementation Behavior**:
  - `STT_PROVIDER=demo` (default): Returns demo status prompting manual transcript input.
  - `STT_PROVIDER=google`: Code attempts Google Cloud Speech call; however, `google-cloud-speech` is not installed, so it falls back to demo response.
- **Example Response** (`200 OK` in demo mode):
```json
{
  "status": "demo_mode",
  "message": "Speech-to-Text is in demo mode. Please paste the call transcript manually or configure an STT provider.",
  "provider": "demo",
  "transcript": "",
  "analysis": null
}
```

---

### 5. Scan History

#### `GET /api/scans`
Retrieves a list of all historical scan records in reverse chronological order.

- **Query Parameters**: None
- **Storage**: In-memory by default (lost on server restart). Stored in Firestore if `FIREBASE_ENABLED=true`.
- **Response** (`200 OK` - `List[ScanRecord]`):
```json
[
  {
    "id": "91fe0e2f-bb96-4ac8-a9a6-6b4cfe9a26a1",
    "scam_type": "Phishing",
    "risk_score": 75,
    "risk_level": "HIGH",
    "input_type": "sms",
    "summary": "Suspicious message from an unverified source claiming to suspend a bank account...",
    "created_at": "2026-10-24T16:09:06.019100+00:00"
  }
]
```

#### `GET /api/scans/{scan_id}`
Retrieves the complete `AnalysisResult` for a previous scan.

- **Path Parameters**:
  - `scan_id` (string, UUID): The scan identifier.
- **Response** (`200 OK`): Full `AnalysisResult` object.
- **Errors**:
  - `404 Not Found`:
    ```json
    { "detail": "Scan result not found" }
    ```

---

### 6. Incident Reporting

#### `POST /api/reports`
Submits an incident report linked to a detected scam scan.

- **Request Body** (`ReportRequest`):
  | Field | Type | Required | Description |
  |---|---|:---:|---|
  | `scan_id` | string | **Yes** | ID of an existing scan record in the store. |
  | `scam_type` | string | **Yes** | Scam category name. |
  | `risk_score` | integer | **Yes** | Risk score (0 to 100). |
  | `description` | string | No | User's incident notes. Default: `null`. |
  | `communication_source` | string | No | Source channel/number. Default: `null`. |

- **Example Request**:
```json
{
  "scan_id": "91fe0e2f-bb96-4ac8-a9a6-6b4cfe9a26a1",
  "scam_type": "Phishing",
  "risk_score": 75,
  "description": "Received threatening SMS demanding OTP to unlock account.",
  "communication_source": "SMS from +919876543210"
}
```

- **Example Response** (`200 OK` - `ReportResponse`):
```json
{
  "id": "f5b2d71c-34d1-419b-a31d-b873523fa541",
  "status": "submitted",
  "message": "Report submitted. For immediate help, contact the National Cyber Crime Helpline at 1930.",
  "scan_id": "91fe0e2f-bb96-4ac8-a9a6-6b4cfe9a26a1",
  "created_at": "2026-10-24T17:15:00.123456+00:00"
}
```

- **Errors**:
  - `404 Not Found`:
    ```json
    { "detail": "Referenced scan not found" }
    ```

---

### 7. Dashboard Metrics

#### `GET /api/dashboard/stats`
Returns aggregate statistics derived from recorded scans.

- **Response** (`200 OK`):
```json
{
  "total_scans": 6,
  "threats_detected": 4,
  "high_risk_alerts": 4,
  "critical_alerts": 1,
  "protection_status": "active"
}
```
*Note: `threats_detected` counts scans with score >= 30; `high_risk_alerts` counts score >= 60; `critical_alerts` counts score >= 80.*

---

### 8. Demo Scenarios

#### `GET /api/demo/scenarios`
Lists the 6 preset demo scenarios packaged in the backend.

- **Response** (`200 OK` - `List[DemoScenario]`):
```json
[
  {
    "id": "digital_arrest",
    "name": "Digital Arrest Scam",
    "description": "Fake CBI officer threatening arrest over video call",
    "input_text": "This is CBI. Your bank account is linked to a money laundering case under investigation...",
    "input_type": "call_transcript",
    "expected_scam_type": "Digital Arrest Scam",
    "expected_risk_level": "CRITICAL"
  }
]
```

#### `POST /api/demo/run/{scenario_id}`
Executes a preset demo scenario directly through the live analysis pipeline and returns the resulting `AnalysisResult`.

- **Path Parameters**:
  - `scenario_id` (string): One of `"digital_arrest"`, `"fake_bank_support"`, `"investment_scam"`, `"prepaid_task_scam"`, `"phishing_sms"`, `"legitimate_message"`.
- **Response** (`200 OK`): Full `AnalysisResult` object.
- **Errors**:
  - `404 Not Found`:
    ```json
    { "detail": "Demo scenario 'invalid_id' not found" }
    ```

---

## Complete Response Model: `AnalysisResult`

Every analysis request (`POST /api/analyze/message`, `POST /api/analyze/transcript`, `POST /api/demo/run/{id}`) returns an `AnalysisResult` object with all 22 fields:

| Field | Type | Description |
|---|---|---|
| `id` | `string` | Unique UUID4 scan identifier. |
| `scam_type` | `string` | Classified category (e.g. `"Phishing"`, `"Digital Arrest Scam"`, `"Fake Bank Support"`, `"Legitimate"`). |
| `risk_score` | `integer` | Score from `0` to `100`. |
| `risk_level` | `string` | `"LOW"`, `"MEDIUM"`, `"HIGH"`, or `"CRITICAL"`. |
| `confidence` | `float` | AI confidence from `0.0` to `1.0`. |
| `summary` | `string` | One-sentence summary in requested language. |
| `explanation` | `string` | 1–2 sentence plain-language danger explanation. |
| `red_flags` | `list[RedFlag]` | Detected indicators with `indicator`, `description`, `severity` (`"low"`, `"medium"`, `"high"`, `"critical"`). |
| `recommended_actions` | `list[string]` | Actionable safety steps (e.g., call 1930, do not share OTP). |
| `detected_entities` | `list[string]` | Key numbers, entities, or amounts detected. |
| `score_breakdown` | `list[RiskScoreBreakdown]` | Individual signal points detected by the rule engine (`signal`, `points`, `description`). |
| `input_type` | `string` | `"text"`, `"sms"`, `"whatsapp"`, `"call_transcript"`, or `"audio"`. |
| `input_text` | `string` | The analyzed raw message text. |
| `ai_provider` | `string` | `"ollama"`, `"fallback"`, or `"none"`. |
| `verdict` | `string | null` | Contextual verdict: `"likely_scam"`, `"suspicious"`, `"likely_legitimate"`, `"uncertain"`. |
| `evidence` | `list[string]` | Extracted quotes or direct facts from the text. |
| `model_name` | `string | null` | Model name (e.g. `"qwen2.5:1.5b"` or `"rule_engine"`). |
| `language` | `string` | Response language code (`"en"`, `"hi"`, `"pa"`, `"hinglish"`). |
| `fallback_used` | `boolean` | `true` if rule-based fallback was activated; `false` if live Ollama responded. |
| `fallback_reason` | `string | null` | Explanation if fallback was triggered; `null` otherwise. |
| `created_at` | `string` | ISO 8601 UTC timestamp. |
| `disclaimer` | `string` | Advisory legal disclaimer. |
