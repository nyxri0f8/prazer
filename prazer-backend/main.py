import logging
import uuid
import os
from typing import List, Dict, Any, Optional
from fastapi import FastAPI, UploadFile, File, BackgroundTasks, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from supabase_client import (
    upload_draft,
    insert_document_row,
    get_document,
    get_report
)
from pipeline import run_pipeline

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("prazer-backend")

app = FastAPI(
    title="PRAZER Backend API (Phase 3 Full Analytics)",
    description="Deterministic Patent Prior-Art, Novelty, Patent Potential, and Six-Gauge Analysis API",
    version="3.0.0"
)

# CORS Configuration
ALLOWED_ORIGINS = os.environ.get("ALLOWED_ORIGINS", "*").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS if "*" not in ALLOWED_ORIGINS else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# --- DTO Models ---
class AnalyzeResponse(BaseModel):
    document_id: str
    file_name: str
    status: str
    message: str = "File received and Phase 3 full analytics processing initiated in background."


class StatusResponse(BaseModel):
    document_id: str
    status: str = Field(..., description="pending | processing | completed | failed")
    error_message: Optional[str] = None


class PatentMatch(BaseModel):
    patent_id: str
    title: str
    similarity: float
    excerpt: str
    publication_date: str
    patent_office: str
    url: Optional[str] = None
    reranker_score: Optional[float] = None


class SentenceOverlap(BaseModel):
    sentence_index: int
    text: str
    overlap_pct: float
    matched_patent_id: str
    matched_patent_title: str
    matched_excerpt: str


class ReportResponse(BaseModel):
    document_id: str
    similarity_score: float
    uniqueness_score: float = 85.0
    novelty_score: float = 82.0
    patent_potential: float = 78.5
    confidence_rating: str = "High"
    technical_specificity: float = 88.0
    corpus_density: float = 72.0
    top_matches: List[PatentMatch]
    sentence_overlaps: List[SentenceOverlap] = []
    summary_text: str
    disclaimer: str


# --- Endpoints ---

@app.get("/health", tags=["Health"])
async def health_check():
    """Health verification endpoint."""
    return {"status": "ok", "service": "prazer-backend", "version": "3.0.0", "phase": "3"}


@app.post("/api/v1/analyze", response_model=AnalyzeResponse, status_code=status.HTTP_202_ACCEPTED, tags=["Analysis"])
async def analyze_document(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...)
):
    """
    Accepts a patent draft (PDF/DOCX), uploads to storage, and initiates the full Phase 3 background pipeline.
    """
    if not file.filename:
        raise HTTPException(status_code=400, detail="Filename is required.")

    valid_extensions = (".pdf", ".docx", ".txt")
    if not any(file.filename.lower().endswith(ext) for ext in valid_extensions):
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported file format. Please upload PDF or DOCX format."
        )

    try:
        contents = await file.read()
        if len(contents) == 0:
            raise HTTPException(status_code=400, detail="Uploaded file is empty.")

        document_id = str(uuid.uuid4())
        safe_filename = file.filename.replace(" ", "_")
        storage_path = f"{document_id}_{safe_filename}"

        # 1. Upload to Supabase Storage
        upload_draft(contents, storage_path)

        # 2. Insert tracking row in Postgres
        insert_document_row(
            document_id=document_id,
            storage_path=storage_path,
            file_name=file.filename,
            file_size=len(contents)
        )

        # 3. Trigger asynchronous background pipeline
        background_tasks.add_task(run_pipeline, document_id, contents, file.filename)

        logger.info(f"Queued Phase 3 analysis for document {document_id} ({file.filename})")
        return AnalyzeResponse(
            document_id=document_id,
            file_name=file.filename,
            status="pending"
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error initiating analysis: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Failed to process document: {str(e)}")


@app.get("/api/v1/status/{document_id}", response_model=StatusResponse, tags=["Analysis"])
async def get_analysis_status(document_id: str):
    """
    Polls the current processing status of a document.
    """
    doc = get_document(document_id)
    if not doc:
        raise HTTPException(status_code=404, detail=f"Document ID '{document_id}' not found.")

    return StatusResponse(
        document_id=document_id,
        status=doc.get("status", "pending"),
        error_message=doc.get("error_message")
    )


@app.get("/api/v1/report/{document_id}", response_model=ReportResponse, tags=["Analysis"])
async def get_analysis_report(document_id: str):
    """
    Retrieves the complete Phase 3 report with six-gauge analytics and confidence rating.
    """
    report = get_report(document_id)
    if not report:
        doc = get_document(document_id)
        if doc and doc.get("status") in ["pending", "processing"]:
            raise HTTPException(
                status_code=202,
                detail=f"Report is still processing for document '{document_id}'."
            )
        raise HTTPException(status_code=404, detail=f"Report not found for document ID '{document_id}'.")

@app.get("/api/v1/report/{document_id}/export", tags=["Analysis"])
async def export_analysis_report(document_id: str, format: str = "markdown"):
    """
    Exports the analysis report in Markdown (.md) or JSON format.
    """
    from services.export import generate_markdown_report, generate_json_export
    from fastapi.responses import Response

    report = get_report(document_id)
    if not report:
        raise HTTPException(status_code=404, detail=f"Report not found for document ID '{document_id}'.")

    if format.lower() == "json":
        json_content = generate_json_export(report)
        return Response(content=json_content, media_type="application/json")
    else:
        md_content = generate_markdown_report(report)
        return Response(content=md_content, media_type="text/markdown")


# --- Phase 4 Endpoints ---

class OptimizeClaimRequest(BaseModel):
    claim_text: str
    matched_patent_id: str
    overlap_pct: float
    prior_art_excerpt: str = ""


class CompareVersionsRequest(BaseModel):
    document_id_v1: str
    document_id_v2: str


@app.post("/api/v1/optimize/claim", tags=["Phase 4 Drafting Assistant"])
async def optimize_claim(req: OptimizeClaimRequest):
    """Generates 3 non-infringing claim formulations to bypass prior-art overlaps."""
    from services.optimizer import generate_claim_optimizations
    opts = generate_claim_optimizations(
        original_claim_text=req.claim_text,
        matched_patent_id=req.matched_patent_id,
        overlap_pct=req.overlap_pct,
        prior_art_excerpt=req.prior_art_excerpt
    )
    return {"optimizations": opts}


@app.get("/api/v1/report/{document_id}/jurisdiction", tags=["Phase 4 Jurisdiction Screening"])
async def get_jurisdiction_screening(document_id: str):
    """Evaluates patentability against USPTO §102/103, EPO Art 54/56, and WIPO PCT."""
    from services.jurisdiction import evaluate_jurisdiction_compliance
    report = get_report(document_id)
    if not report:
        raise HTTPException(status_code=404, detail=f"Report '{document_id}' not found.")
    
    compliance = evaluate_jurisdiction_compliance(
        similarity_score=report.get("similarity_score", 40.0),
        uniqueness_score=report.get("uniqueness_score", 85.0),
        novelty_score=report.get("novelty_score", 82.0),
        top_matches=report.get("top_matches", [])
    )
    return compliance


@app.post("/api/v1/compare/versions", tags=["Phase 4 Version Delta"])
async def compare_document_versions(req: CompareVersionsRequest):
    """Compares two draft versions and returns the delta novelty and potential gains."""
    from services.delta import calculate_version_delta
    rep1 = get_report(req.document_id_v1)
    rep2 = get_report(req.document_id_v2)
    if not rep1 or not rep2:
        raise HTTPException(status_code=404, detail="One or both document reports not found.")
    
    delta = calculate_version_delta(rep1, rep2)
    return delta

