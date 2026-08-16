import logging
from typing import Dict, Any

logger = logging.getLogger(__name__)


def calculate_version_delta(
    report_v1: Dict[str, Any],
    report_v2: Dict[str, Any]
) -> Dict[str, Any]:
    """
    Computes exact mathematical delta improvements between two successive draft revisions.
    """
    sim_v1 = float(report_v1.get("similarity_score", 50.0))
    sim_v2 = float(report_v2.get("similarity_score", 50.0))
    
    nov_v1 = float(report_v1.get("novelty_score", 70.0))
    nov_v2 = float(report_v2.get("novelty_score", 70.0))
    
    uniq_v1 = float(report_v1.get("uniqueness_score", 75.0))
    uniq_v2 = float(report_v2.get("uniqueness_score", 75.0))

    pot_v1 = float(report_v1.get("patent_potential", 65.0))
    pot_v2 = float(report_v2.get("patent_potential", 65.0))

    delta_sim = round(sim_v2 - sim_v1, 2)
    delta_nov = round(nov_v2 - nov_v1, 2)
    delta_uniq = round(uniq_v2 - uniq_v1, 2)
    delta_pot = round(pot_v2 - pot_v1, 2)

    return {
        "delta_similarity": delta_sim,
        "delta_novelty": delta_nov,
        "delta_uniqueness": delta_uniq,
        "delta_patent_potential": delta_pot,
        "is_improvement": delta_pot > 0 or delta_sim < 0,
        "summary": (
            f"Draft revision demonstrated a +{delta_pot:.1f}% increase in Patent Potential and "
            f"reduced prior-art overlap by {abs(delta_sim):.1f}%."
            if delta_sim < 0 else
            f"Draft revision resulted in a {delta_pot:+.1f}% change in Patent Potential."
        )
    }
