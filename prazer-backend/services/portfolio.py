import logging
from typing import List, Dict, Any

logger = logging.getLogger(__name__)


def generate_portfolio_matrix(reports: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Computes a 2D Portfolio White-Space & Novelty Clustering Matrix across multiple invention disclosures.
    """
    matrix_points = []
    clusters = {
        "star_innovations": [],
        "incremental": [],
        "crowded_high_risk": [],
        "white_space_opportunities": []
    }

    for r in reports:
        doc_id = r.get("document_id", "DOC")
        name = r.get("file_name", "Draft")
        sim = float(r.get("similarity_score", 40.0))
        nov = float(r.get("novelty_score", 80.0))
        pot = float(r.get("patent_potential", 75.0))

        point = {
            "id": doc_id,
            "name": name,
            "x_similarity": sim,
            "y_novelty": nov,
            "patent_potential": pot,
            "confidence": r.get("confidence_rating", "High")
        }
        matrix_points.append(point)

        # Cluster categorization
        if nov >= 75.0 and sim < 45.0:
            clusters["star_innovations"].append(name)
        elif nov >= 60.0 and sim >= 45.0:
            clusters["incremental"].append(name)
        elif nov < 60.0 and sim >= 65.0:
            clusters["crowded_high_risk"].append(name)
        else:
            clusters["white_space_opportunities"].append(name)

    return {
        "matrix_points": matrix_points,
        "clusters": clusters,
        "total_disclosures": len(reports),
        "portfolio_health_score": round(
            sum(p["patent_potential"] for p in matrix_points) / max(1, len(matrix_points)), 1
        )
    }
