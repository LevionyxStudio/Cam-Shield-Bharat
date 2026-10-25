"""
ScamShield Bharat — AI Provider Manager
Supports Ollama as the primary AI provider with fallback rule-based classification.
Google Gemini and OpenAI are strictly prohibited per hackathon rules and have been removed.
"""

import os
import logging
from typing import Optional
from app.models.schemas import AnalysisResult
from app.ai.ollama_provider import OllamaProvider

logger = logging.getLogger("scamshield.provider")

SUPPORTED_PROVIDERS = {"ollama", "fallback"}


class LLMProvider:
    """Configurable AI provider manager for ScamShield Bharat."""
    
    def __init__(self):
        raw_provider = os.getenv("AI_PROVIDER", "ollama")
        self.provider = raw_provider.lower().strip() if raw_provider else "ollama"
        
        if self.provider not in SUPPORTED_PROVIDERS:
            raise ValueError(
                f"Unsupported AI_PROVIDER '{self.provider}'. Only 'ollama' and 'fallback' are supported. "
                "Google Gemini and OpenAI are strictly prohibited per competition rules and have been removed."
            )
        
        self.model = os.getenv("OLLAMA_MODEL") or os.getenv("AI_MODEL", "")
        self._ollama: Optional[OllamaProvider] = None
        self.last_error: Optional[str] = None
        
        if self.provider == "ollama":
            self._ollama = OllamaProvider()
            self.model = self._ollama.model
        
        logger.info(f"AI Provider initialized: {self.provider} (model: {self.model or 'N/A'})")
    
    def is_available(self) -> bool:
        """Check if an external AI provider (Ollama) is configured."""
        if self.provider == "ollama":
            return bool(self._ollama and self._ollama.is_available())
        return False
    
    async def analyze(
        self, text: str, input_type: str = "text", language: str = "en"
    ) -> Optional[AnalysisResult]:
        """
        Analyze text using Ollama.
        Returns AnalysisResult on success, or None on failure (recording self.last_error).
        """
        self.last_error = None
        if not self.is_available():
            self.last_error = f"AI provider '{self.provider}' is not available."
            return None
        
        try:
            if self.provider == "ollama" and self._ollama:
                result = await self._ollama.analyze(text, input_type, language)
                self.last_error = self._ollama.last_error
                return result
            return None
        except Exception as e:
            self.last_error = f"Ollama provider error: {type(e).__name__} - {str(e)}"
            logger.error(self.last_error)
            return None


# Singleton instance
_llm_provider: Optional[LLMProvider] = None

def get_llm_provider() -> LLMProvider:
    """Get or create the AI provider singleton."""
    global _llm_provider
    if _llm_provider is None:
        _llm_provider = LLMProvider()
    return _llm_provider

def reset_llm_provider() -> None:
    """Reset the AI provider singleton (useful for testing configuration changes)."""
    global _llm_provider
    _llm_provider = None
