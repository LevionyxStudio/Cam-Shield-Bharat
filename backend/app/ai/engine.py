"""
FraudShield AI — AI Engine Orchestrator
Routes analysis requests to LLM or fallback classifier.
Implements the four-stage pipeline: DETECT → UNDERSTAND → CLASSIFY → PROTECT
"""

import logging
from app.models.schemas import AnalysisResult
from app.ai.llm_provider import get_llm_provider
from app.ai.fallback_classifier import analyze_with_fallback

logger = logging.getLogger("fraudshield.engine")


def detect_language(text: str) -> str:
    """
    Detect whether text is primarily Hindi, Punjabi, Hinglish, or English.
    Supports Devanagari script (Hindi), Gurmukhi script (Punjabi),
    Roman Punjabi phrases, and Hinglish.
    """
    if not text:
        return "en"
    
    # Count Gurmukhi and Devanagari characters
    # (Exclude danda \u0964 and double danda \u0965 from Hindi count as both scripts share it)
    gurmukhi_count = sum(1 for char in text if '\u0a00' <= char <= '\u0a7f')
    devanagari_count = sum(
        1 for char in text if ('\u0900' <= char <= '\u0963') or ('\u0966' <= char <= '\u097f')
    )
    
    if gurmukhi_count > devanagari_count and gurmukhi_count > 0:
        return "pa"
    if devanagari_count > 0:
        return "hi"
    
    import re
    text_lower = text.lower()
    
    # Roman Punjabi specific vocabulary
    punjabi_words = [
        "tussi", "saanu", "kiddan", "veere", "veerji", "chahida", "kar deo", 
        "ditta", "assi", "karde", "hoya", "daso", "sunao", "gall", "thoda"
    ]
    if any(re.search(r'\b' + re.escape(w) + r'\b', text_lower) for w in punjabi_words):
        return "pa"
    
    # Hinglish vocabulary
    hinglish_words = [
        "aapka", "karein", "bhejo", "turant", "khata", "band", "hoga", 
        "kripya", "jaldi", "dhanyawad", "apna", "paise", "karo", "nahi"
    ]
    matches = sum(1 for w in hinglish_words if re.search(r'\b' + re.escape(w) + r'\b', text_lower))
    if matches >= 2:
        return "hinglish"
    
    return "en"


async def analyze_communication(
    text: str, input_type: str = "text", language: str = "en"
) -> AnalysisResult:
    """
    Main analysis pipeline — the core of FraudShield AI / ScamShield Bharat.
    
    Pipeline stages:
    1. DETECT — Receive and normalize input, resolve language
    2. UNDERSTAND — Extract context, intent, and suspicious language  
    3. CLASSIFY — Identify scam type and calculate risk score (LLM or fallback)
    4. PROTECT — Generate warning, explanation, and safety guidance
    
    Routes to configured AI provider first (Ollama),
    falls back safely to rule-based engine if unavailable.
    """
    from app.models.schemas import Verdict

    # Stage 1: DETECT — Normalize input
    normalized_text = normalize_input(text)
    
    # Language resolution
    if not language or language == "auto":
        effective_language = detect_language(normalized_text)
    else:
        effective_language = language
    
    if not normalized_text or len(normalized_text.strip()) < 3:
        return AnalysisResult(
            scam_type="Legitimate",
            risk_score=0,
            risk_level="LOW",
            confidence=0.95,
            summary="Input too short for meaningful analysis.",
            explanation="The provided text is too short to analyze for scam patterns.",
            red_flags=[],
            recommended_actions=["Provide a longer message for better analysis."],
            detected_entities=[],
            score_breakdown=[],
            input_text=text,
            ai_provider="none",
            verdict=Verdict.LIKELY_LEGITIMATE.value,
            evidence=[],
            model_name="none",
            language=effective_language,
            fallback_used=True,
            fallback_reason="Input too short",
        )
    
    # Stages 2-4: UNDERSTAND → CLASSIFY → PROTECT
    llm = get_llm_provider()
    fallback_reason = None
    
    if llm.is_available():
        logger.info(f"Using LLM provider: {llm.provider}")
        try:
            result = await llm.analyze(normalized_text, input_type, language=effective_language)
            if result is not None:
                result.input_text = text  # Keep original text
                return result
            fallback_reason = getattr(llm, "last_error", None) or f"{llm.provider} returned empty response"
            logger.warning(f"LLM analysis returned None ({fallback_reason}), falling back to rule-based engine")
        except Exception as e:
            fallback_reason = f"{llm.provider} exception: {type(e).__name__} - {str(e)}"
            logger.warning(f"LLM analysis failed with error: {fallback_reason}, falling back to rule-based engine")
    else:
        if llm.provider != "fallback":
            fallback_reason = getattr(llm, "last_error", None) or f"Provider '{llm.provider}' is not available"
    
    # Fallback to rule-based classifier
    logger.info("Using fallback rule-based classifier")
    result = analyze_with_fallback(normalized_text, input_type, language=effective_language)
    result.input_text = text  # Keep original text
    result.fallback_used = True
    result.fallback_reason = fallback_reason
    return result


def normalize_input(text: str) -> str:
    """
    Normalize input text for consistent analysis.
    Preserves meaning while cleaning formatting.
    """
    if not text:
        return ""
    
    # Strip leading/trailing whitespace
    text = text.strip()
    
    # Normalize unicode quotes and dashes
    replacements = {
        '\u201c': '"', '\u201d': '"',  # Smart quotes
        '\u2018': "'", '\u2019': "'",
        '\u2013': '-', '\u2014': '-',  # Dashes
        '\u00a0': ' ',  # Non-breaking space
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    
    # Collapse multiple whitespace
    import re
    text = re.sub(r'\s+', ' ', text)
    
    return text
