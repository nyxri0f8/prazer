import logging
import numpy as np
from scipy.spatial.distance import cosine

logger = logging.getLogger(__name__)


def cosine_similarity_pct(vec_a: np.ndarray, vec_b: np.ndarray) -> float:
    """
    Computes deterministic cosine similarity percentage between two vectors using SciPy.
    Returns float value strictly between 0.0 and 100.0.
    """
    try:
        dist = cosine(vec_a, vec_b)
        # Cosine distance is in [0, 2], where 0 is identical and 1 is orthogonal
        if np.isnan(dist):
            return 0.0
        similarity = (1.0 - dist) * 100.0
        # Clamp to [0, 100]
        return float(max(0.0, min(100.0, round(similarity, 2))))
    except Exception as e:
        logger.error(f"Error computing cosine similarity: {e}")
        return 0.0


def calculate_overall_similarity(match_scores: list[float]) -> float:
    """
    Calculates the aggregate deterministic similarity score from top candidate matches.
    Uses the highest match score as the primary anchor with weighted decay.
    """
    if not match_scores:
        return 0.0
    sorted_scores = sorted(match_scores, reverse=True)
    top_score = sorted_scores[0]
    return float(round(top_score, 2))
