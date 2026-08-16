import pytest
from services.novelty import (
    calculate_novelty_score,
    calculate_patent_potential,
    determine_confidence_rating,
    calculate_six_gauge_metrics
)
from pipeline import run_pipeline

def test_patent_potential_formula_invariant():
    novelty = 85.0
    uniqueness = 90.0
    similarity = 30.0

    # (85.0 * 0.4) + (90.0 * 0.3) + (70.0 * 0.3) = 34.0 + 27.0 + 21.0 = 82.0
    expected = (novelty * 0.40) + (uniqueness * 0.30) + ((100.0 - similarity) * 0.30)
    calculated = calculate_patent_potential(novelty, uniqueness, similarity)
    
    assert calculated == 82.0
    assert abs(calculated - expected) < 1e-4


def test_confidence_rating_logic():
    assert determine_confidence_rating(candidate_count=6, text_length=1200) == "High"
    assert determine_confidence_rating(candidate_count=3, text_length=400) == "Medium"
    assert determine_confidence_rating(candidate_count=1, text_length=200) == "Low"


def test_six_gauge_metrics_structure():
    draft = "A high-precision optical magnetometry device utilizing nitrogen vacancy diamond centers and microwave frequency control."
    prior_art = [
        "Distributed neural architecture for automated semantic feature indexing.",
        "Laser excitation and photoluminescence detection in semiconductor devices."
    ]
    metrics = calculate_six_gauge_metrics(
        draft_text=draft,
        prior_art_texts=prior_art,
        similarity_score=35.0,
        uniqueness_score=85.0
    )

    assert "patent_potential" in metrics
    assert "novelty_score" in metrics
    assert "uniqueness_score" in metrics
    assert "similarity_score" in metrics
    assert "technical_specificity" in metrics
    assert "corpus_density" in metrics
    assert "confidence_rating" in metrics
    assert metrics["confidence_rating"] in ["High", "Medium", "Low"]


def test_phase3_full_pipeline_run():
    doc_id = "doc-phase3-full-run"
    content = b"%PDF-1.4 Diamond magnetometer patent disclosure draft."
    report = run_pipeline(doc_id, content, "diamond_sensor_claims.pdf")

    assert "patent_potential" in report
    assert "novelty_score" in report
    assert "confidence_rating" in report
    assert "technical_specificity" in report
    assert "corpus_density" in report
    assert report["patent_potential"] > 0
