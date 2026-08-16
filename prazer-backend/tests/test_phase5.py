import pytest
from services.brief import generate_certified_opinion_brief
from services.ids import generate_form_sb08a_citations
from services.portfolio import generate_portfolio_matrix

def test_certified_opinion_brief_generator():
    report = {
        "document_id": "doc-01",
        "file_name": "Quantum_Sensor.pdf",
        "patent_potential": 79.1,
        "novelty_score": 88.2,
        "similarity_score": 38.4,
        "confidence_rating": "High",
        "top_matches": [{"title": "Optical Sensor", "patent_id": "US-11482938-B2", "patent_office": "USPTO"}]
    }
    brief = generate_certified_opinion_brief(report)
    assert "CERTIFIED PATENTABILITY OPINION BRIEF" in brief
    assert "G01R 33/032" in brief
    assert "US-11482938-B2" in brief


def test_form_sb08a_generation():
    report = {
        "top_matches": [
            {"patent_id": "US-11482938-B2", "title": "Neural Indexing", "patent_office": "USPTO", "publication_date": "2024-03-12", "excerpt": "Excerpt A"},
            {"patent_id": "EP-3928174-A1", "title": "Scoring Method", "patent_office": "EPO", "publication_date": "2023-11-28", "excerpt": "Excerpt B"}
        ]
    }
    ids = generate_form_sb08a_citations(report)
    assert ids["form"] == "PTO/SB/08a"
    assert len(ids["us_patents"]) == 1
    assert len(ids["foreign_patents"]) == 1


def test_portfolio_matrix_clustering():
    reports = [
        {"document_id": "1", "file_name": "Star.pdf", "similarity_score": 25.0, "novelty_score": 90.0, "patent_potential": 85.0},
        {"document_id": "2", "file_name": "Crowded.docx", "similarity_score": 75.0, "novelty_score": 40.0, "patent_potential": 40.0}
    ]
    matrix = generate_portfolio_matrix(reports)
    assert matrix["total_disclosures"] == 2
    assert "Star.pdf" in matrix["clusters"]["star_innovations"]
    assert "Crowded.docx" in matrix["clusters"]["crowded_high_risk"]
