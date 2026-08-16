import json
import logging
from typing import Dict, Any, List

logger = logging.getLogger(__name__)


def generate_markdown_report(report_data: Dict[str, Any]) -> str:
    """
    Generates a clean, professional, publication-ready Markdown report of the patent prior-art appraisal.
    Includes Executive Summary, Six-Gauge Analytics, Top Prior-Art Matches, and Legal Disclaimer.
    """
    doc_id = report_data.get("document_id", "DOC-UNKNOWN")
    file_name = report_data.get("file_name", "Invention_Draft.pdf")
    sim = report_data.get("similarity_score", 0.0)
    uniq = report_data.get("uniqueness_score", 0.0)
    nov = report_data.get("novelty_score", 0.0)
    pot = report_data.get("patent_potential", 0.0)
    conf = report_data.get("confidence_rating", "High")
    spec = report_data.get("technical_specificity", 0.0)
    dens = report_data.get("corpus_density", 0.0)
    summary = report_data.get("summary_text", "")
    matches = report_data.get("top_matches", [])
    disclaimer = report_data.get(
        "disclaimer",
        "This is an automated estimate, not legal advice. Consult a registered patent attorney before filing."
    )

    md = f"""# PRAZER — Patent Prior-Art & Novelty Appraisal Report
**Document:** `{file_name}` | **ID:** `{doc_id}` | **Confidence:** `{conf}`

---

## 1. Executive Analytics Summary

| Metric | Score | Benchmark Description |
| :--- | :--- | :--- |
| **Patent Potential Composite** | **{pot:.1f}%** | Weighted Composite: Novelty (40%) + Uniqueness (30%) + Non-Overlap (30%) |
| **Novelty Score** | **{nov:.1f}%** | Combinatorial Concept Co-occurrence Rarity |
| **Uniqueness Score** | **{uniq:.1f}%** | Winnowing Token Fingerprint Isolation |
| **Similarity Overlap** | **{sim:.1f}%** | PaECTER 1024-dim Vector Cosine Similarity |
| **Technical Depth / Specificity** | **{spec:.1f}%** | Claim Lexical & Functional Precision |
| **Prior-Art Corpus Density** | **{dens:.1f}%** | Indexed Patent Database Saturation |

### Plain-English Synthesis
> {summary}

---

## 2. Top Matching Prior-Art Disclosures

"""
    for idx, m in enumerate(matches, 1):
        pid = m.get("patent_id", f"PATENT-{idx}")
        title = m.get("title", "Prior Art Patent")
        msim = m.get("similarity", 0.0)
        office = m.get("patent_office", "USPTO")
        pdate = m.get("publication_date", "N/A")
        excerpt = m.get("excerpt", "No excerpt available.")
        
        md += f"""### {idx}. {title} (`{office} {pid}`) — **{msim:.1f}% Match**
- **Publication Date:** {pdate}
- **Abstract / Claim Excerpt:**
  > "{excerpt}"

"""

    md += f"""---

## 3. Claim Differentiation Recommendations

1. **Emphasize Unique Technical Combinations:** Prior art exhibits lower overlap in functional execution and signal processing claims.
2. **Review High-Overlap Clauses:** Examine highlighted claim sections to narrow structural dependencies.
3. **Patent Attorney Consultation:** Use these deterministic metrics as reference material during formal patent drafting.

---

> [!IMPORTANT]
> **Legal Disclaimer:** {disclaimer}
"""
    return md


def generate_json_export(report_data: Dict[str, Any]) -> str:
    """Generates structured JSON export format for automated API integrations."""
    return json.dumps(report_data, indent=2)
