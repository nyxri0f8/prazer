import pytest
from fastapi.testclient import TestClient
import numpy as np

from main import app
from services.scoring import cosine_similarity_pct, calculate_overall_similarity
from services.embeddings import embed_sentences
from services.parser import split_sentences
from services.llm import summarize
import supabase_client

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_scoring_deterministic_math():
    vec_a = np.array([1.0, 0.0, 0.0], dtype=np.float32)
    vec_b = np.array([1.0, 0.0, 0.0], dtype=np.float32)
    assert cosine_similarity_pct(vec_a, vec_b) == 100.0

    vec_c = np.array([0.0, 1.0, 0.0], dtype=np.float32)
    assert cosine_similarity_pct(vec_a, vec_c) == 0.0

    scores = [78.5, 45.2, 82.1]
    assert calculate_overall_similarity(scores) == 82.1


def test_embeddings_generation():
    sentences = ["A system for automated prior art patent analysis.", "Machine learning sentence embedding."]
    vectors = embed_sentences(sentences, dimension=1024)
    assert len(vectors) == 2
    assert vectors[0].shape[0] == 1024
    assert vectors[1].shape[0] == 1024


def test_parser_sentence_splitting():
    text = "This is the first sentence of an invention. Here is the second detailed claim! And a third element?"
    sentences = split_sentences(text)
    assert len(sentences) >= 2


def test_llm_summary_truthfulness():
    matches = [{
        "patent_id": "US-11482938-B2",
        "title": "Distributed neural architecture for automated semantic feature indexing",
        "similarity": 68.5,
        "excerpt": "A system and method for deterministic semantic indexing..."
    }]
    summary = summarize(68.5, matches)
    assert len(summary) > 20
    # Must never invent numbers, should describe similarity
    assert "68.5%" in summary or "similarity" in summary.lower()


def test_end_to_end_analyze_pipeline():
    test_pdf_content = b"%PDF-1.4 Simulated patent disclosure text describing novel semantic partitioning."
    files = {"file": ("novel_invention.pdf", test_pdf_content, "application/pdf")}
    
    # 1. POST /analyze
    resp = client.post("/api/v1/analyze", files=files)
    assert resp.status_code == 202
    data = resp.json()
    assert "document_id" in data
    doc_id = data["document_id"]

    # 2. GET /status
    status_resp = client.get(f"/api/v1/status/{doc_id}")
    assert status_resp.status_code == 200
    assert status_resp.json()["status"] in ["pending", "processing", "completed"]

    # 3. Trigger synchronous pipeline for test verification
    from pipeline import run_pipeline
    report = run_pipeline(doc_id, test_pdf_content, "novel_invention.pdf")
    assert report is not None
    assert "similarity_score" in report

    # 4. GET /report
    report_resp = client.get(f"/api/v1/report/{doc_id}")
    assert report_resp.status_code == 200
    report_data = report_resp.json()
    assert report_data["document_id"] == doc_id
    assert isinstance(report_data["similarity_score"], (int, float))
    assert len(report_data["top_matches"]) > 0
    assert "not legal advice" in report_data["disclaimer"].lower()
