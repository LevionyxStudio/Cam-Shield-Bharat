"""
FraudShield AI — Speech-to-Text Service Abstraction
Extensible STT with demo fallback mode.
"""

import os
import logging
from typing import Optional

logger = logging.getLogger("fraudshield.stt")


class SpeechToTextService:
    """
    Abstract Speech-to-Text service.
    Supports: google, demo (fallback).
    """
    
    def __init__(self):
        self.provider = os.getenv("STT_PROVIDER", "demo")
        logger.info(f"STT Provider initialized: {self.provider}")
    
    def is_available(self) -> bool:
        """Check if a real STT provider is configured."""
        return self.provider == "google"
    
    async def transcribe(self, audio_data: bytes, filename: str = "") -> dict:
        """
        Transcribe audio to text.
        
        Returns:
            dict with keys: transcript, provider, is_demo
        """
        if self.provider == "google":
            return await self._transcribe_google(audio_data, filename)
        else:
            return self._demo_response()
    
    async def _transcribe_google(self, audio_data: bytes, filename: str) -> dict:
        """Transcribe using Google Cloud Speech-to-Text."""
        try:
            # Google Cloud STT integration point
            # Requires GOOGLE_APPLICATION_CREDENTIALS environment variable
            from google.cloud import speech
            
            client = speech.SpeechClient()
            audio = speech.RecognitionAudio(content=audio_data)
            config = speech.RecognitionConfig(
                encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
                language_code="en-IN",
                alternative_language_codes=["hi-IN"],
                enable_automatic_punctuation=True,
            )
            
            response = client.recognize(config=config, audio=audio)
            transcript = " ".join(
                result.alternatives[0].transcript 
                for result in response.results
            )
            
            return {
                "transcript": transcript,
                "provider": "google",
                "is_demo": False
            }
        except Exception as e:
            logger.error(f"Google STT failed: {e}")
            return self._demo_response()
    
    def _demo_response(self) -> dict:
        """Demo fallback — clearly indicates demo mode."""
        return {
            "transcript": "",
            "provider": "demo",
            "is_demo": True,
            "message": "Speech-to-Text is in demo mode. Please paste the call transcript manually or configure an STT provider."
        }


# Singleton
_stt_service: Optional[SpeechToTextService] = None

def get_stt_service() -> SpeechToTextService:
    """Get or create the STT service singleton."""
    global _stt_service
    if _stt_service is None:
        _stt_service = SpeechToTextService()
    return _stt_service
