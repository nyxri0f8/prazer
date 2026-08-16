import pytest
from services.optimizer import generate_claim_optimizations
from services.jurisdiction import evaluate_jurisdiction_compliance
from services.delta import calculate_version_delta

def test_claim_optimizer_generates_options():
    claim = "A green excitation laser beam configured to illuminate the defect centers."
    opts = generate_claim_optimizations(
        original_claim_text=claim,
        matched_patent_id="US-11482938-B2",
        overlap_pct=76.4,
        prior_art_excerpt="532nm laser source illuminating diamond substrates."
    )
    assert len(opts) == 3
    assert opts[0]["strategy"] == "Narrowing Limitation"
    assert opts[0]["estimated_overlap"] < 76.4


def test_jurisdiction_statutory_evaluation():
    res = evaluate_jurisdiction_compliance(
        similarity_score=38.4,
        uniqueness_score=84.5,
        novelty_score=88.2,
        top_matches=[{"similarity": 38.4}]
    )
    assert "uspto" in res
    assert "epo" in res
    assert "wipo" in res
    assert res["uspto"]["statute_102"] == "Low Risk"
    assert "article_54_novelty" in res["epo"]


def test_version_delta_calculation():
    v1 = {"similarity_score": 52.0, "novelty_score": 70.0, "uniqueness_score": 75.0, "patent_potential": 65.0}
    v2 = {"similarity_score": 38.0, "novelty_score": 88.0, "uniqueness_score": 85.0, "patent_potential": 79.0}

    delta = calculate_version_delta(v1, v2)
    assert delta["delta_similarity"] == -14.0
    assert delta["delta_novelty"] == 18.0
    assert delta["delta_patent_potential"] == 14.0
    assert delta["is_improvement"] is True
