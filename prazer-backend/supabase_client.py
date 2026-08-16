import os
import logging
from typing import Optional, Dict, Any, List
from supabase import create_client, Client

logger = logging.getLogger(__name__)

SUPABASE_URL = os.environ.get("SUPABASE_URL", "https://quggxkvvfrunewpsijdn.supabase.co")
SUPABASE_KEY = (
    os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
    or os.environ.get("SUPABASE_ANON_KEY")
    or os.environ.get("SUPABASE_KEY", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF1Z2d4a3Z2ZnJ1bmV3cHNpamRuIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4Njg4MzY0NSwiZXhwIjoyMTAyNDU5NjQ1fQ.KojlP1ZNC1EuO4FfNGtW1nx3dSH4Kckcj5XnoJ2QTFo")
)

_client: Optional[Client] = None

# In-memory storage for mock/local development when Supabase credentials are not provided
_mock_documents: Dict[str, Dict[str, Any]] = {}
_mock_reports: Dict[str, Dict[str, Any]] = {}
_mock_storage: Dict[str, bytes] = {}


def get_supabase() -> Optional[Client]:
    """Initializes and returns the Supabase Client if credentials exist."""
    global _client
    if _client is None and SUPABASE_URL and SUPABASE_KEY:
        try:
            _client = create_client(SUPABASE_URL, SUPABASE_KEY)
            logger.info("Connected to Supabase client successfully.")
        except Exception as e:
            logger.warning(f"Failed to initialize Supabase client: {e}. Falling back to in-memory store.")
            _client = None
    return _client


def upload_draft(file_bytes: bytes, storage_path: str, bucket_name: str = "drafts") -> str:
    """Uploads draft file bytes to Supabase Storage or local in-memory fallback."""
    client = get_supabase()
    if client:
        try:
            client.storage.from_(bucket_name).upload(storage_path, file_bytes)
            logger.info(f"Uploaded file to Supabase storage bucket '{bucket_name}' at path '{storage_path}'")
            return storage_path
        except Exception as e:
            logger.error(f"Error uploading file to Supabase storage: {e}")
            raise
    else:
        logger.info(f"[In-Memory] Stored draft file '{storage_path}' ({len(file_bytes)} bytes)")
        _mock_storage[storage_path] = file_bytes
        return storage_path


def insert_document_row(document_id: str, storage_path: str, file_name: Optional[str] = None, file_size: Optional[int] = None) -> Dict[str, Any]:
    """Inserts a new document row with 'pending' status."""
    client = get_supabase()
    if client:
        try:
            res = client.table("documents").insert({
                "id": document_id,
                "storage_path": storage_path,
                "file_name": file_name,
                "file_size": file_size,
                "status": "pending"
            }).execute()
            return res.data[0] if res.data else {"id": document_id, "status": "pending"}
        except Exception as e:
            logger.error(f"Error inserting document row into Supabase: {e}")
            raise
    else:
        doc = {
            "id": document_id,
            "storage_path": storage_path,
            "file_name": file_name,
            "file_size": file_size,
            "status": "pending"
        }
        _mock_documents[document_id] = doc
        return doc


def update_document_status(document_id: str, status: str, error_message: Optional[str] = None) -> None:
    """Updates document processing status (pending | processing | completed | failed)."""
    client = get_supabase()
    if client:
        try:
            update_data: Dict[str, Any] = {"status": status}
            if error_message:
                update_data["error_message"] = error_message
            client.table("documents").update(update_data).eq("id", document_id).execute()
            logger.info(f"Updated document {document_id} status to '{status}'")
        except Exception as e:
            logger.error(f"Error updating document status: {e}")
    else:
        if document_id in _mock_documents:
            _mock_documents[document_id]["status"] = status
            if error_message:
                _mock_documents[document_id]["error_message"] = error_message
        logger.info(f"[In-Memory] Document {document_id} status updated to '{status}'")


def get_document(document_id: str) -> Optional[Dict[str, Any]]:
    """Retrieves document record by document ID."""
    client = get_supabase()
    if client:
        try:
            res = client.table("documents").select("*").eq("id", document_id).execute()
            return res.data[0] if res.data else None
        except Exception as e:
            logger.error(f"Error retrieving document from Supabase: {e}")
            return None
    else:
        return _mock_documents.get(document_id)


def write_report(
    document_id: str,
    similarity_score: float,
    top_matches: List[Dict[str, Any]],
    summary_text: str,
    uniqueness_score: float = 85.0,
    novelty_score: float = 82.0,
    patent_potential: float = 78.5,
    confidence_rating: str = "High",
    technical_specificity: float = 88.0,
    corpus_density: float = 72.0,
    sentence_overlaps: Optional[List[Dict[str, Any]]] = None,
    disclaimer: str = "This is an automated estimate, not legal advice. Consult a registered patent attorney before filing."
) -> Dict[str, Any]:
    """Writes the finalized deterministic report to the reports table."""
    client = get_supabase()
    report_data = {
        "document_id": document_id,
        "similarity_score": round(similarity_score, 2),
        "uniqueness_score": round(uniqueness_score, 2),
        "novelty_score": round(novelty_score, 2),
        "patent_potential": round(patent_potential, 2),
        "confidence_rating": confidence_rating,
        "technical_specificity": round(technical_specificity, 2),
        "corpus_density": round(corpus_density, 2),
        "top_matches": top_matches,
        "sentence_overlaps": sentence_overlaps or [],
        "summary_text": summary_text,
        "disclaimer": disclaimer
    }
    if client:
        try:
            res = client.table("reports").insert(report_data).execute()
            logger.info(f"Wrote report for document {document_id} to Supabase.")
            return res.data[0] if res.data else report_data
        except Exception as e:
            logger.error(f"Error writing report to Supabase: {e}")
            raise
    else:
        _mock_reports[document_id] = report_data
        logger.info(f"[In-Memory] Wrote report for document {document_id}: similarity={similarity_score}%, potential={patent_potential}%, confidence={confidence_rating}")
        return report_data


def get_report(document_id: str) -> Optional[Dict[str, Any]]:
    """Retrieves the report for a given document ID."""
    client = get_supabase()
    if client:
        try:
            res = client.table("reports").select("*").eq("document_id", document_id).execute()
            return res.data[0] if res.data else None
        except Exception as e:
            logger.error(f"Error getting report from Supabase: {e}")
            return None
    else:
        return _mock_reports.get(document_id)
