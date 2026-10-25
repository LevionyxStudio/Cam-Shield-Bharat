"""
FraudShield AI — Scan Storage Service
In-memory storage with optional Firebase Firestore persistence.
"""

import os
import logging
from typing import List, Optional, Dict
from datetime import datetime
from app.models.schemas import AnalysisResult, ScanRecord, ReportRequest, ReportResponse, RiskLevel

logger = logging.getLogger("fraudshield.store")


class ScanStore:
    """
    Manages scan history and reports.
    Uses in-memory storage; optionally persists to Firebase Firestore.
    """
    
    def __init__(self):
        self._scans: Dict[str, AnalysisResult] = {}
        self._reports: Dict[str, dict] = {}
        self._firebase_enabled = os.getenv("FIREBASE_ENABLED", "false").lower() == "true"
        self._db = None
        
        if self._firebase_enabled:
            self._init_firebase()
    
    def _init_firebase(self):
        """Initialize Firebase Firestore connection."""
        try:
            import firebase_admin
            from firebase_admin import credentials, firestore
            
            cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH", "")
            project_id = os.getenv("FIREBASE_PROJECT_ID", "")
            
            if cred_path and os.path.exists(cred_path):
                cred = credentials.Certificate(cred_path)
                firebase_admin.initialize_app(cred, {"projectId": project_id})
            elif project_id:
                firebase_admin.initialize_app(options={"projectId": project_id})
            else:
                logger.warning("Firebase credentials not found. Using in-memory storage only.")
                self._firebase_enabled = False
                return
            
            self._db = firestore.client()
            logger.info("Firebase Firestore connected successfully.")
        except Exception as e:
            logger.error(f"Firebase initialization failed: {e}. Using in-memory storage.")
            self._firebase_enabled = False
    
    async def save_scan(self, result: AnalysisResult) -> str:
        """Save a scan result. Returns the scan ID."""
        self._scans[result.id] = result
        
        if self._firebase_enabled and self._db:
            try:
                self._db.collection("scans").document(result.id).set(
                    result.model_dump(),
                    merge=True
                )
            except Exception as e:
                logger.error(f"Firebase save failed: {e}")
        
        return result.id
    
    async def get_scan(self, scan_id: str) -> Optional[AnalysisResult]:
        """Retrieve a scan by ID."""
        if scan_id in self._scans:
            return self._scans[scan_id]
        
        if self._firebase_enabled and self._db:
            try:
                doc = self._db.collection("scans").document(scan_id).get()
                if doc.exists:
                    return AnalysisResult(**doc.to_dict())
            except Exception as e:
                logger.error(f"Firebase get failed: {e}")
        
        return None
    
    async def get_all_scans(self) -> List[ScanRecord]:
        """Get all scan records (summary view)."""
        records = []
        for scan in sorted(self._scans.values(), key=lambda s: s.created_at, reverse=True):
            records.append(ScanRecord(
                id=scan.id,
                scam_type=scan.scam_type,
                risk_score=scan.risk_score,
                risk_level=scan.risk_level,
                input_type=scan.input_type,
                summary=scan.summary,
                created_at=scan.created_at,
            ))
        return records
    
    async def save_report(self, report: ReportRequest) -> ReportResponse:
        """Save an incident report."""
        response = ReportResponse(scan_id=report.scan_id)
        self._reports[response.id] = {
            "id": response.id,
            "scan_id": report.scan_id,
            "scam_type": report.scam_type,
            "risk_score": report.risk_score,
            "description": report.description,
            "communication_source": report.communication_source,
            "status": "submitted",
            "created_at": response.created_at,
        }
        
        if self._firebase_enabled and self._db:
            try:
                self._db.collection("reports").document(response.id).set(
                    self._reports[response.id]
                )
            except Exception as e:
                logger.error(f"Firebase report save failed: {e}")
        
        return response
    
    def get_stats(self) -> dict:
        """Get dashboard statistics from scan history."""
        total = len(self._scans)
        threats = sum(1 for s in self._scans.values() if s.risk_score >= 30)
        high_risk = sum(1 for s in self._scans.values() if s.risk_score >= 60)
        critical = sum(1 for s in self._scans.values() if s.risk_score >= 80)
        
        return {
            "total_scans": total,
            "threats_detected": threats,
            "high_risk_alerts": high_risk,
            "critical_alerts": critical,
            "protection_status": "active",
        }


# Singleton
_store: Optional[ScanStore] = None

def get_scan_store() -> ScanStore:
    """Get or create the scan store singleton."""
    global _store
    if _store is None:
        _store = ScanStore()
    return _store
