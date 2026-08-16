import logging
from typing import Dict, Any, List

logger = logging.getLogger(__name__)


def evaluate_jurisdiction_compliance(
    similarity_score: float,
    uniqueness_score: float,
    novelty_score: float,
    top_matches: List[Dict[str, Any]]
) -> Dict[str, Any]:
    """
    Evaluates patentability against statutory standards across Indian Patent Office (IPO), USPTO, EPO, and WIPO.
    """
    max_single_overlap = max((m.get("similarity", 0.0) for m in top_matches), default=similarity_score)

    # 1. Indian Patent Act 1970 (Section 2(1)(j), 3(k), 3(d)) — #1 Priority Jurisdiction
    ipo_novelty_status = "Pass (Section 2(1)(j) Novelty Met)" if max_single_overlap < 65.0 else "Section 2(1)(j) Prior-Art Scrutiny Advised"
    ipo_section_3k_status = "Bypassed: Tangible Hardware & Sensor Integration (CRI Compliant)" if uniqueness_score >= 50.0 else "Risk of Sec 3(k) Software Algorithm Rejection"
    ipo_inventive_step = "Section 2(1)(ja) Inventive Step Favorable" if novelty_score >= 60.0 else "Moderate Obviousness Risk"
    ipo_expedited = "Rule 24C / Form 18A Expedited Examination Eligible"

    # 2. USPTO 35 U.S.C. §102 & §103
    uspto_102_risk = "Low Risk" if max_single_overlap < 50.0 else ("Moderate Risk" if max_single_overlap < 75.0 else "High Anticipation Risk")
    uspto_103_obviousness = float(min(95.0, max(10.0, round((similarity_score * 0.6) + ((100.0 - novelty_score) * 0.4), 1))))

    # 3. EPO EPC Articles 54 & 56
    epo_novelty_status = "Likely Novel (Pass)" if max_single_overlap < 65.0 else "Detailed Review Advised"
    epo_inventive_step = "High Inventive Step" if novelty_score >= 80.0 else ("Moderate Inventive Step" if novelty_score >= 55.0 else "Low Inventive Step")

    # 4. WIPO / PCT Preliminary Outlook
    wipo_pct_rating = "Favorable Written Opinion Likely" if (novelty_score >= 75.0 and similarity_score < 45.0) else "Amendments Recommended Prior to National Phase"

    return {
        "ipo_india": {
            "section_2_1_j_novelty": ipo_novelty_status,
            "section_3_k_cri_compliance": ipo_section_3k_status,
            "section_2_1_ja_inventive_step": ipo_inventive_step,
            "filing_track": ipo_expedited,
            "recommendation": "File complete specification under Form 2 with IPO Chennai/Delhi/Mumbai/Kolkata. Emphasize tangible technical effect to bypass Section 3(k)."
        },
        "uspto": {
            "statute_102": uspto_102_risk,
            "statute_103_obviousness_score": uspto_103_obviousness,
            "recommendation": "File provisional application focusing on non-obvious combinatorial couplings."
        },
        "epo": {
            "article_54_novelty": epo_novelty_status,
            "article_56_inventive_step": epo_inventive_step,
            "recommendation": "Adopt Problem-Solution Approach highlighting unexpected technical effects."
        },
        "wipo": {
            "pct_outlook": wipo_pct_rating,
            "international_search_risk": "Low" if similarity_score < 40.0 else "Moderate"
        }
    }
