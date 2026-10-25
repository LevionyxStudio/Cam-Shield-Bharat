# ScamShield Bharat (FraudShield AI) — Backend

ScamShield Bharat is an AI-powered scam detection and fraud intelligence backend built for India. It analyzes suspicious SMS messages, WhatsApp chats, and call transcripts in real time, detecting high-risk fraud patterns such as Digital Arrest threats, fake bank KYC suspensions, UPI collect requests, predatory task/job scams, and lottery fraud.

The backend is built with **FastAPI** and uses a hybrid intelligence pipeline combining local large language models via **Ollama** (`qwen2.5:1.5b`) with an offline, deterministic **Rule-Based Fallback Engine**.

> [!NOTE]
> **Project Scope & Technical Honesty**:
> This repository contains the **Python FastAPI backend service**. It analyzes user-submitted communications via REST API endpoints. It does **not** perform background Android system-level SMS or call interception, and does **not** run on-device inference directly inside an Android APK. A rebuilt Flutter client is planned as a separate frontend module.

---

## 1. Implemented Backend Features

- **Dual-Engine Scam Intelligence**:
  - **Primary**: Local LLM inference via Ollama (`qwen2.5:1.5b`) utilizing `/api/chat` with structured JSON output enforcement.
  - **Fallback**: Zero-dependency deterministic rule engine and pattern-matching classifier providing instant (~13 ms) analysis when Ollama is offline or unreachable.
- **Prompt Injection Defense & Heuristic Reconciliation**:
  - Analyzes messages as untrusted data using bounded XML tags.
  - Reconciles AI risk scores against deterministic security signals to prevent prompt injections from artificially suppressing scam scores.
  - Enforces minimum risk scores on severe threats (e.g. OTP credential harvesting, police impersonation).
  - Explicit casual-message filter prevents harmless personal and workplace communications (e.g. dinner plans, sharing presentation slides) from triggering false positives.
- **Multilingual Support**:
  - Handles **English**, **Hindi (हिन्दी)**, **Punjabi (ਪੰਜਾਬੀ / Roman Punjabi)**, and **Hinglish**.
  - Includes an automatic language detection heuristic (`auto`) based on Unicode script ranges (Devanagari, Gurmukhi) and conversational Hinglish stopwords.
- **RESTful Endpoints**:
  - Text and SMS message analysis (`POST /api/analyze/message`).
  - Call transcript analysis (`POST /api/analyze/transcript`).
  - Audio file upload and transcription check (`POST /api/analyze/audio`).
  - In-memory scan history and report retrieval (`GET /api/scans`, `GET /api/scans/{id}`, `POST /api/reports`, `GET /api/dashboard/stats`).
  - Preset demo scenarios for presentations (`GET /api/demo/scenarios`, `POST /api/demo/run/{id}`).
  - Service health check (`GET /health`).

---

## 2. Architecture Summary

The backend operates on a 4-stage processing pipeline:

```
[Untrusted Input] (SMS / WhatsApp / Call Transcript)
       │
       ▼
[Stage 1: DETECT] ──> Input normalization & language detection (en, hi, pa, hinglish)
       │
       ▼
[Stage 2: UNDERSTAND] ──> Context extraction & deterministic security signal mapping
       │
       ▼
[Stage 3: CLASSIFY] ──> Primary Ollama LLM (`qwen2.5:1.5b`)
       │                 └──> Automatic failover to Rule Fallback Classifier if offline
       ▼
[Stage 4: PROTECT] ──> Heuristic score reconciliation, red flags, & localized safety guidance
       │
       ▼
[Structured Response] ──> Standardized AnalysisResult JSON schema
```

### Deterministic Risk Signals (`risk_engine.py`)
Deterministic signals provide explainable baseline scores and guardrails:
- Government / Law Enforcement Impersonation: **+25 points**
- Arrest / Legal Threat: **+25 points**
- Urgent Payment / Money Request: **+20 points**
- OTP / PIN / Password Request: **+20 points**
- Fear / Psychological Coercion: **+15 points**
- Suspicious Link / URL: **+15 points**
- Investment / Guaranteed Returns: **+20 points**
- Prepaid Task / Job Fraud: **+20 points**
- Bank / KYC Impersonation: **+20 points**
- Lottery / Prize / Reward Scam: **+18 points**
- Aadhaar / Identity Threat: **+18 points**
- UPI / Payment Fraud: **+18 points**

#### Score Ranges & Levels
- **0–29**: `LOW` Risk
- **30–59**: `MEDIUM` Risk
- **60–79**: `HIGH` Risk
- **80–100**: `CRITICAL` Risk

---

## 3. Technology Stack

- **Framework**: Python 3.10+ (tested with Python 3.13), FastAPI 0.115+, Uvicorn 0.34+
- **Data Validation**: Pydantic v2
- **HTTP Client**: HTTPX (async client with connection pooling)
- **Local AI Provider**: Ollama REST API (`/api/chat`)
- **Default AI Model**: `qwen2.5:1.5b`
- **Testing**: Pytest, Pytest-AsyncIO, AnyIO

---

## 4. Prerequisites & Setup (Windows PowerShell)

### Prerequisites
1. Python 3.10 or higher installed and added to `PATH`.
2. Git.
3. (Optional but recommended) [Ollama](https://ollama.com/) installed for local LLM inference.

### Installation Steps

1. Open **Windows PowerShell** and navigate to the backend directory:
   ```powershell
   cd "C:\Users\Naman Kamboj\Desktop\Cam Shield Bharat\backend"
   ```

2. Create a virtual environment:
   ```powershell
   python -m venv venv
   ```

3. Activate the virtual environment:
   ```powershell
   .\venv\Scripts\Activate.ps1
   ```
   *(If script execution is disabled, run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` first).*

4. Install dependencies:
   ```powershell
   pip install -r requirements.txt
   ```

---

## 5. Environment Configuration

Create a `.env` file in the `backend/` folder based on `.env.example`:

```powershell
Copy-Item .env.example .env
```

### Verified `.env` Configuration Table

| Variable | Default in Code | Purpose | Verified Implementation Behavior |
|---|---|---|---|
| `AI_PROVIDER` | `ollama` | Primary AI provider | Supports `ollama` or `fallback`. Raises `ValueError` if set to prohibited providers (`gemini`, `openai`). |
| `OLLAMA_BASE_URL` | `http://localhost:11434` | Ollama service URL | Used to reach Ollama's `/api/chat` endpoint. |
| `OLLAMA_MODEL` | `qwen2.5:1.5b` | LLM model identifier | Sent in Ollama JSON payload. Alias: `AI_MODEL`. |
| `OLLAMA_TIMEOUT` | `30.0` | Ollama HTTP timeout (s) | Applied to HTTPX client. If exceeded, triggers rule fallback. |
| `OLLAMA_KEEP_ALIVE` | `15m` | Model VRAM residency | Keeps model weights loaded in memory between requests. |
| `OLLAMA_NUM_CTX` | `2048` | Context window size | Configures Ollama request context limit. |
| `OLLAMA_NUM_PREDICT` | `550` | Max generated tokens | Ensures complete responses across Indic languages. |
| `STT_PROVIDER` | `demo` | Speech-to-Text provider | `demo` returns structured guidance. `google` code exists but library is uninstalled. |
| `FIREBASE_ENABLED` | `false` | Firestore persistence | If `false`, uses in-memory dictionary storage. |
| `FIREBASE_CREDENTIALS_PATH` | `""` | Service account JSON | Path to Firebase credentials (conditional on `FIREBASE_ENABLED=true`). |
| `FIREBASE_PROJECT_ID` | `""` | Firebase project ID | Project identifier (conditional on `FIREBASE_ENABLED=true`). |
| `CORS_ORIGINS` | `*` | Allowed CORS origins | Comma-separated list of origins for `CORSMiddleware`. |
| `HOST` | `None` *(advisory)* | Server bind host | Not read by code. Controlled via Uvicorn CLI flags. |
| `PORT` | `None` *(advisory)* | Server port | Not read by code. Controlled via Uvicorn CLI flags. |
| `DEBUG` | `None` *(advisory)* | Debug mode toggle | Not read by code. Logger level is statically set to `INFO`. |
| `API_KEY` | `None` *(unused)* | API key security | Not enforced. All endpoints are currently public. |

---

## 6. Running the Backend Server

With the virtual environment activated:

### Local Development (Desktop / Same Machine)
```powershell
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

### Network Access (Android Emulator or Physical Device on Wi-Fi)
```powershell
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
- **Android Emulator Base URL**: `http://10.0.2.2:8000`
- **Physical Phone Base URL**: `http://<YOUR_PC_LAN_IP>:8000` (e.g. `http://192.168.29.201:8000`)

### Interactive API Documentation
Once running, open your browser:
- **Swagger UI**: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
- **ReDoc**: [http://127.0.0.1:8000/redoc](http://127.0.0.1:8000/redoc)
- **Health Check**: [http://127.0.0.1:8000/health](http://127.0.0.1:8000/health)

---

## 7. Configuring and Running Ollama

If you wish to run live LLM inference:

1. **Install Ollama**: Download from [ollama.com](https://ollama.com/) for Windows.
2. **Start the Ollama Daemon**: Ensure Ollama is running in the background (listen port `11434`).
3. **Pull the Model**:
   ```powershell
   ollama pull qwen2.5:1.5b
   ```
4. **Verify Ollama is Responding**:
   ```powershell
   curl http://localhost:11434/api/tags
   ```
5. Ensure `backend/.env` has:
   ```env
   AI_PROVIDER=ollama
   OLLAMA_BASE_URL=http://localhost:11434
   OLLAMA_MODEL=qwen2.5:1.5b
   ```

### Fallback Behavior when Ollama is Unavailable
If Ollama is stopped, times out, or the model is not found:
- The backend logs a warning explaining the failure.
- The request automatically fails over to the **Rule-Based Fallback Engine**.
- The endpoint returns HTTP 200 with `fallback_used: true`, `ai_provider: "fallback"`, and `model_name: "rule_engine"`.
- Response structure, risk scores, red flags, and recommendations remain 100% compatible with the client schema.

---

## 8. Running Automated Tests

The backend includes a comprehensive automated test suite.

From the `backend/` directory:

```powershell
.\venv\Scripts\python.exe -m pytest tests/ -v
```

### Test Suites Included:
- **`tests/test_analysis.py`** (27 tests): Tests individual scam categories (Digital Arrest, Fake Bank Support, Investment Scams, Phishing, Task Scams), deterministic risk scoring, input sanitization, and edge cases.
- **`tests/test_ollama_and_multilingual.py`** (26 tests): Tests provider selection, configuration errors, HTTP error recovery, prompt injection defenses, JSON sanitizer, and multilingual outputs.
- **`tests/test_integration_ollama.py`** (12 tests): End-to-end integration tests. When Ollama is offline, live model tests are automatically skipped while offline fallback tests are executed and validated.

### Running Live Scam Scenarios
To run the 6 representative Indian scam scenarios against a running server:
```powershell
.\venv\Scripts\python.exe tests/run_scam_scenarios.py
```

---

## 9. Current Limitations & Technical Notes

1. **Transient Storage**: In-memory storage is active by default (`FIREBASE_ENABLED=false`). Scan history and incident reports reset when the server process terminates.
2. **Authentication**: `API_KEY` is currently not enforced on any endpoint. The backend operates as an open API for local development and hackathon evaluation.
3. **Audio Transcription**: `STT_PROVIDER=demo` does not perform speech transcription. It returns structured metadata prompting manual transcript entry.
4. **CORS Setting**: `allow_origins=["*"]` is active for testing flexibility.
5. **Future Work**: On-device Android AI models, production Firebase persistence, and a native Flutter interface are planned for future phases.
