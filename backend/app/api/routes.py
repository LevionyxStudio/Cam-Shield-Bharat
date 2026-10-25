"""
FraudShield AI — API Routes
All REST endpoints for the scam analysis platform.
"""

from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from typing import Optional, List
from app.models.schemas import (
    AnalyzeMessageRequest, AnalyzeTranscriptRequest,
    AnalysisResult, ScanRecord, ReportRequest, ReportResponse,
    DemoScenario, InputType
)
from app.ai.engine import analyze_communication
from app.services.scan_store import get_scan_store
from app.services.stt_service import get_stt_service
from app.services.demo_scenarios import get_demo_scenarios, get_demo_scenario_by_id

router = APIRouter()


# ── Analysis Endpoints ──

@router.post("/analyze/message", response_model=AnalysisResult, tags=["Analysis"],
             summary="Analyze a suspicious text message",
             description="Submit an SMS, WhatsApp message, or any text communication for AI-powered scam analysis.")
async def analyze_message(request: AnalyzeMessageRequest):
    """
    Core endpoint — analyzes text for scam indicators.
    Returns scam type, risk score, red flags, explanation, and safety recommendations.
    """
    result = await analyze_communication(request.message, request.input_type.value, language=request.language or "en")
    result.input_type = request.input_type
    
    # Save to scan history
    store = get_scan_store()
    await store.save_scan(result)
    
    return result


@router.post("/analyze/transcript", response_model=AnalysisResult, tags=["Analysis"],
             summary="Analyze a call transcript",
             description="Submit a call transcript (pasted or from STT) for scam analysis.")
async def analyze_transcript(request: AnalyzeTranscriptRequest):
    """Analyze a call transcript for scam indicators."""
    result = await analyze_communication(request.transcript, InputType.CALL_TRANSCRIPT.value, language=request.language or "en")
    result.input_type = InputType.CALL_TRANSCRIPT
    
    store = get_scan_store()
    await store.save_scan(result)
    
    return result


@router.post("/analyze/audio", response_model=dict, tags=["Analysis"],
             summary="Analyze uploaded audio",
             description="Upload an audio file for Speech-to-Text transcription followed by scam analysis. "
                         "If STT is in demo mode, returns a message to paste the transcript manually.")
async def analyze_audio(file: UploadFile = File(...)):
    """
    Audio analysis pipeline:
    1. Receive audio file
    2. Transcribe via STT service
    3. If demo mode, prompt for manual transcript
    4. If real STT, analyze the transcript
    """
    stt = get_stt_service()
    
    # Read audio data
    audio_data = await file.read()
    
    # Transcribe
    stt_result = await stt.transcribe(audio_data, file.filename or "audio")
    
    if stt_result.get("is_demo", True):
        return {
            "status": "demo_mode",
            "message": stt_result.get("message", "STT is in demo mode. Please paste the transcript manually."),
            "provider": "demo",
            "transcript": "",
            "analysis": None
        }
    
    # Analyze the transcript
    transcript = stt_result["transcript"]
    if transcript:
        result = await analyze_communication(transcript, InputType.CALL_TRANSCRIPT.value)
        result.input_type = InputType.AUDIO
        
        store = get_scan_store()
        await store.save_scan(result)
        
        return {
            "status": "success",
            "provider": stt_result["provider"],
            "transcript": transcript,
            "analysis": result.model_dump()
        }
    
    return {
        "status": "error",
        "message": "Could not transcribe audio. Please paste the transcript manually.",
        "provider": stt_result["provider"],
        "transcript": "",
        "analysis": None
    }


# ── Scan History ──

@router.get("/scans", response_model=List[ScanRecord], tags=["Scan History"],
            summary="List all scan records",
            description="Retrieve scan history sorted by most recent first.")
async def list_scans():
    """Get all scan records."""
    store = get_scan_store()
    return await store.get_all_scans()


@router.get("/scans/{scan_id}", response_model=AnalysisResult, tags=["Scan History"],
            summary="Get a specific scan result",
            description="Retrieve the full analysis result for a specific scan.")
async def get_scan(scan_id: str):
    """Get a specific scan by ID."""
    store = get_scan_store()
    result = await store.get_scan(scan_id)
    if not result:
        raise HTTPException(status_code=404, detail="Scan not found")
    return result


# ── Reports ──

@router.post("/reports", response_model=ReportResponse, tags=["Reports"],
             summary="Submit an incident report",
             description="Report a scam incident. For immediate help, contact the National Cyber Crime Helpline at 1930.")
async def submit_report(report: ReportRequest):
    """Submit an incident report for a detected scam."""
    store = get_scan_store()
    
    # Verify the scan exists
    scan = await store.get_scan(report.scan_id)
    if not scan:
        raise HTTPException(status_code=404, detail="Related scan not found")
    
    response = await store.save_report(report)
    return response


# ── Dashboard Stats ──

@router.get("/stats", response_model=dict, tags=["Dashboard"],
            summary="Get dashboard statistics",
            description="Get summary statistics for the dashboard.")
async def get_stats():
    """Get dashboard stats."""
    store = get_scan_store()
    return store.get_stats()


# ── Demo Scenarios ──

@router.get("/demo/scenarios", response_model=List[DemoScenario], tags=["Demo"],
            summary="List demo scenarios",
            description="Get all preset demo scenarios for demonstration during judging.")
async def list_demo_scenarios():
    """Get all available demo scenarios."""
    return get_demo_scenarios()


@router.post("/demo/run/{scenario_id}", response_model=AnalysisResult, tags=["Demo"],
             summary="Run a demo scenario",
             description="Execute a preset demo scenario and return the analysis result.")
async def run_demo_scenario(scenario_id: str):
    """Run a specific demo scenario through the analysis pipeline."""
    scenario = get_demo_scenario_by_id(scenario_id)
    if not scenario:
        raise HTTPException(status_code=404, detail="Demo scenario not found")
    
    result = await analyze_communication(scenario.input_text, scenario.input_type.value)
    result.input_type = scenario.input_type
    
    store = get_scan_store()
    await store.save_scan(result)
    
    return result
