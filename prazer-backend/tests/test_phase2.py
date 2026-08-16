import pytest
from services.reranker import rerank_candidates
from services.uniqueness import calculate_uniqueness_score, _winnow, _kgrams, _tokenize
from services.heatmap import generate_sentence_heatmap
from pipeline import run_pipeline

def test_reranker_filtering():
    query = "A system for quantum magnetometer optical sensing with nitrogen-vacancy diamond centers."
    candidates = [
        {"patent_id": "US-01", "title": "Quantum Magnetometer", "abstract": "Optical sensing utilizing diamond centers."},
        {"patent_id": "US-02", "title": "Toaster oven timer", "abstract": "Mechanical heating element control unit."},
    ]
    reranked = rerank_candidates(query, candidates, top_k=2)
    assert len(reranked) > 0
    assert reranked[0]["patent_id"] == "US-01"


def test_uniqueness_winnowing_algorithm():
    draft = "A novel quantum sensor employing room temperature diamond nitrogen vacancy defects."
    prior_art_identical = ["A novel quantum sensor employing room temperature diamond nitrogen vacancy defects."]
    prior_art_distinct = ["Mechanical gears and sprockets for industrial automotive transmission."]

    sim_score = calculate_uniqueness_score(draft, prior_art_identical)
    distinct_score = calculate_uniqueness_score(draft, prior_art_distinct)

    assert sim_score < 50.0  # Low uniqueness for identical text
    assert distinct_score > 90.0  # High uniqueness for distinct text


def test_sentence_heatmap_generation():
    draft = "First claim describing laser excitation. Second claim regarding optical readout."
    candidates = [
        {
            "patent_id": "US-11482938-B2",
            "title": "Quantum Diamond Sensor",
            "abstract": "Methods for laser excitation and optical fluorescence readout."
        }
    ]
    overlaps = generate_sentence_heatmap(draft, candidates)
    assert len(overlaps) >= 2
    assert "overlap_pct" in overlaps[0]
    assert "matched_patent_id" in overlaps[0]
    assert "matched_excerpt" in overlaps[0]


def test_phase2_pipeline_execution():
    doc_id = "doc-phase2-test-01"
    content = b"%PDF-1.4 Quantum diamond sensor invention disclosure draft."
    report = run_pipeline(doc_id, content, "quantum_sensor.pdf")
    
    assert "similarity_score" in report
    assert "uniqueness_score" in report
    assert "sentence_overlaps" in report
    assert isinstance(report["sentence_overlaps"], list)
    assert report["uniqueness_score"] >= 0.0 and report["uniqueness_score"] <= 100.0
