# ScamShield Bharat — Backend Architecture

This document describes the actual architecture, module interactions, and request lifecycle of the ScamShield Bharat FastAPI backend.

---

## 1. System Architecture Overview

```
                      ┌────────────────────────────────────────┐
                      │             CLIENT LAYER               │
                      │  - Web Demo (HTML5 / JS at /demo/)     │
                      │  - HTTP Clients / Swagger UI (/docs)   │
                      │  - Future Flutter Android Application  │
                      └───────────────────┬────────────────────┘
                                          │ HTTP / REST
                                          ▼
┌───────────────────────────────────────────────────────────────────────────────────┐
│                           FASTAPI APPLICATION ENTRYPOINT                          │
│                                (backend/app/main.py)                              │
│  - Middleware: CORSMiddleware (allow_origins=origins, allow_credentials=True)     │
│  - Static Mounts: /demo/ -> demo-web/ (if present)                                │
│  - Health Check: GET /health -> HealthResponse                                    │
│  - Root Redirect: GET / -> /demo/                                                 │
└─────────────────────────────────────────┬─────────────────────────────────────────┘
                                          │
                                          ▼
┌───────────────────────────────────────────────────────────────────────────────────┐
│                                   API ROUTER                                      │
│                               (backend/app/api/routes.py)                         │
│  - POST /api/analyze/message       - GET  /api/scans                              │
│  - POST /api/analyze/transcript    - GET  /api/scans/{id}                         │
│  - POST /api/analyze/audio         - POST /api/reports                            │
│  - GET  /api/demo/scenarios        - GET  /api/dashboard/stats                    │
│  - POST /api/demo/run/{id}                                                        │
└─────────────────────────────────────────┬─────────────────────────────────────────┘
                                          │
                                          ▼
┌───────────────────────────────────────────────────────────────────────────────────┐
│                            AI PIPELINE ORCHESTRATOR                               │
│                                (backend/app/ai/engine.py)                         │
│  - Stage 1: DETECT    -> Input normalization & language detection (auto/en/hi/pa) │
│  - Stage 2: UNDERSTAND-> Context extraction & heuristic signal detection          │
│  - Stage 3: CLASSIFY  -> Routes to primary LLM or fallback                        │
│  - Stage 4: PROTECT   -> Score reconciliation, red flags & safe recommendations   │
└───────────────────┬───────────────────────────────────────────┬───────────────────┘
                    │                                           │
         Primary Path                               Failover / Fallback Path
                    ▼                                           ▼
┌────────────────────────────────────────┐  ┌───────────────────────────────────────┐
│          OLLAMA PROVIDER               │  │       RULE FALLBACK CLASSIFIER        │
│    (backend/app/ai/ollama_provider.py) │  │ (backend/app/ai/fallback_classifier.py│
│  - REST Client -> /api/chat            │  │  - Zero external dependencies         │
│  - Model: qwen2.5:1.5b                 │  │  - Pattern matching & heuristics      │
│  - Prompt-injection defense            │  │  - Deterministic risk scoring         │
│  - Token budgeting (550 tokens)        │  │  - Native Hindi, Punjabi, Hinglish    │
│  - Lenient JSON repair parser          │  │    safety recommendations             │
│  - Heuristic score reconciliation      │  │  - Instant execution (~13 ms)         │
└───────────────────┬────────────────────┘  └───────────────────┬───────────────────┘
                    │                                           │
                    └─────────────────────┬─────────────────────┘
                                          │
                                          ▼
┌───────────────────────────────────────────────────────────────────────────────────┐
│                             DETERMINISTIC RISK ENGINE                             │
│                           (backend/app/scoring/risk_engine.py)                    │
│  - 12 Weighted Security Signals (Impersonation, Arrest, OTP, Links, Tasks, etc.)  │
│  - Risk Level Mapping: LOW (0-29), MEDIUM (30-59), HIGH (60-79), CRITICAL (80-100)│
│  - Casual message heuristic (is_pure_casual)                                      │
└─────────────────────────────────────────┬─────────────────────────────────────────┘
                                          │
                                          ▼
┌───────────────────────────────────────────────────────────────────────────────────┐
│                                  SERVICES LAYER                                   │
│  - ScanStore (app/services/scan_store.py): In-memory dicts (Firestore optional)   │
│  - SpeechToText (app/services/stt_service.py): Demo mode guidance                 │
│  - DemoScenarios (app/services/demo_scenarios.py): 6 Preset showcase scenarios    │
└───────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Request Lifecycle: The 4-Stage AI Pipeline

When a message is received at `POST /api/analyze/message`:

### Stage 1: DETECT (Input Normalization & Language Resolution)
- **Whitespace & Control Stripping**: Cleans up formatting while preserving message semantics.
- **Minimum Length Check**: Messages with fewer than 3 characters immediately return an empty `AnalysisResult` with `risk_score = 0` and `fallback_reason = "Input too short"`.
- **Language Detection**: If `language="auto"` or omitted:
  - Scans for Gurmukhi script characters (`\u0A00-\u0A7F`) -> resolves to `"pa"`.
  - Scans for Devanagari script characters (`\u0900-\u097F`) -> resolves to `"hi"`.
  - Scans for Romanized Hindi keywords (e.g. *karein*, *turant*, *paisa*, *khata*) -> resolves to `"hinglish"`.
  - Defaults to `"en"`.

### Stage 2: UNDERSTAND (Signal Extraction)
- Runs `calculate_risk_score(text)` from `app/scoring/risk_engine.py`.
- Evaluates regex patterns against 12 security categories:
  - Impersonation (CBI, Police, ED, Bank, KYC).
  - Coercion & Urgency (Arrest threats, legal warrants, account blocking).
  - Credential & Financial Demands (OTP requests, PIN requests, UPI collect, deposit fees).
- Generates a `score_breakdown` list with individual signal points.

### Stage 3: CLASSIFY (AI Provider Selection & Inference)
- `LLMProvider` inspects `os.getenv("AI_PROVIDER", "ollama")`:
  - **`AI_PROVIDER=ollama`**:
    - Constructs system prompt with anti-injection framing and 10 fraud categories.
    - Sends POST to `{OLLAMA_BASE_URL}/api/chat` with `temperature=0.1`, `num_predict=550`, and `keep_alive=15m`.
    - Parses JSON output using lenient regex token repair.
    - If Ollama is unreachable (`httpx.ConnectError`), times out (`httpx.TimeoutException`), or returns HTTP 404, the exception is caught, recorded in `fallback_reason`, and execution seamlessly branches to the rule fallback.
  - **`AI_PROVIDER=fallback`**:
    - Skips LLM calls entirely and executes `analyze_with_fallback()`.

### Stage 4: PROTECT (Heuristic Reconciliation & Guardrails)
- **Prompt Injection Defense**: If deterministic rule signals detect high-risk patterns (points >= 25, total >= 50) but the AI returns a score under 30, the score is reconciled to `max(ai_score, 60)` with a `Discrepancy Warning` red flag.
- **Category Alignment**: Prevents bank OTP threats from misclassifying as Digital Arrest.
- **Casual Message Filter**: If `rule_score == 0` and personal/colleague keywords (e.g. *dinner*, *office*, *slides*, *presentation*, *meeting*) are present without any financial/threat indicators, the message is locked to `Legitimate`, `risk_score = 0`, `risk_level = LOW`, and `red_flags = []`.
- **Localized Recommendations**: Attaches actionable steps in the user's requested language (referencing the Cyber Crime Helpline **1930** and **cybercrime.gov.in**).

---

## 3. Storage Layer: In-Memory vs. Firebase

The storage layer is encapsulated in [`app/services/scan_store.py`](file:///c:/Users/Naman%20Kamboj/Desktop/Cam%20Shield%20Bharat/backend/app/services/scan_store.py):

- **In-Memory Store (Active Default)**:
  - All scans and incident reports are stored in Python dictionaries (`self._scans` and `self._reports`).
  - **Limitation**: All data is transient and resets whenever the backend server restarts.
- **Firebase Firestore (Optional)**:
  - Enabled when `FIREBASE_ENABLED=true` in `.env`.
  - Consumes `FIREBASE_CREDENTIALS_PATH` and `FIREBASE_PROJECT_ID`.
  - Persists records to `scans` and `reports` collections.
  - If credentials are missing or the connection fails, `ScanStore` catches the exception and falls back to in-memory mode without crashing the server.

---

## 4. Speech-to-Text Architecture

Implemented in [`app/services/stt_service.py`](file:///c:/Users/Naman%20Kamboj/Desktop/Cam%20Shield%20Bharat/backend/app/services/stt_service.py):

- The `/api/analyze/audio` endpoint accepts audio uploads via multipart form data.
- Controlled by `STT_PROVIDER=demo`:
  - `_demo_response()` returns structured JSON indicating demo mode and instructs manual transcript submission.
- Code for Google Cloud Speech-to-Text is present in `_transcribe_google()`, but the required SDK (`google-cloud-speech`) is omitted from `requirements.txt` to keep the backend lightweight and hackathon-compliant.

---

## 5. Implemented vs. Proposed Future Architecture

| Feature Component | Current Implementation Status | Notes |
|---|---|---|
| **FastAPI REST API** | **Fully Implemented** | All 10 routes active, tested, and validated. |
| **Ollama Local LLM** | **Fully Implemented** | Uses `/api/chat` with `qwen2.5:1.5b` and JSON repair. |
| **Deterministic Fallback** | **Fully Implemented** | Instant (~13 ms) rule-based classification. |
| **Multilingual NLP** | **Fully Implemented** | English, Hindi, Punjabi, Hinglish support. |
| **In-Memory History** | **Fully Implemented** | Transient storage for scans and reports. |
| **Firebase Persistence** | **Partially Implemented** | Code complete; requires credentials and SDK. |
| **Speech-to-Text** | **Demo Mode** | Returns structured prompt for manual transcript entry. |
| **Flutter Mobile App** | **Future Work / Separate** | Exists as separate client codebase; not run in backend. |
| **On-Device Android AI** | **Proposed Future Work** | On-device NPU/TFLite models are future enhancements. |
| **Call/SMS Interception** | **Proposed Future Work** | Background OS-level Android interception is future work. |
| **API Key Authentication** | **Not Implemented** | Endpoints are currently open. |
