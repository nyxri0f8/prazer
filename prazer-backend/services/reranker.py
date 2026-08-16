import os
import logging
from typing import List, Dict, Any, Tuple

logger = logging.getLogger(__name__)

_reranker_model = None
RERANKER_MODEL_NAME = os.environ.get("RERANKER_MODEL", "BAAI/bge-reranker-v2-m3")


def get_reranker_model():
    """Lazily loads the BAAI bge-reranker-v2-m3 cross-encoder model."""
    global _reranker_model
    if _reranker_model is None:
        try:
            from FlagEmbedding import FlagReranker
            logger.info(f"Loading cross-encoder reranker: {RERANKER_MODEL_NAME}")
            _reranker_model = FlagReranker(RERANKER_MODEL_NAME, use_fp16=False)
            logger.info("Reranker model loaded successfully.")
        except Exception as e:
            try:
                from sentence_transformers import CrossEncoder
                logger.info(f"Loading CrossEncoder via sentence_transformers: {RERANKER_MODEL_NAME}")
                _reranker_model = CrossEncoder(RERANKER_MODEL_NAME)
                logger.info("CrossEncoder loaded successfully.")
            except Exception as e2:
                logger.warning(f"Could not load FlagReranker or CrossEncoder: {e2}. Using deterministic cross-relevance scoring.")
                _reranker_model = "fallback"
    return _reranker_model


def rerank_candidates(
    query_text: str,
    candidates: List[Dict[str, Any]],
    top_k: int = 5,
    relevance_threshold: float = 0.20
) -> List[Dict[str, Any]]:
    """
    Reranks PQAI patent candidates using BAAI bge-reranker-v2-m3 cross-encoder.
    Filters out false-positive candidates with low cross-attention relevance scores.
    """
    if not candidates or not query_text:
        return candidates

    model = get_reranker_model()

    if model != "fallback" and model is not None:
        try:
            pairs = [[query_text[:1000], c.get("abstract", c.get("title", ""))[:1000]] for c in candidates]
            
            if hasattr(model, "compute_score"):
                scores = model.compute_score(pairs, normalize=True)
            elif hasattr(model, "predict"):
                scores = model.predict(pairs)
            else:
                scores = [0.5] * len(pairs)

            reranked = []
            for candidate, score in zip(candidates, scores):
                float_score = float(score)
                if float_score >= relevance_threshold:
                    c_copy = dict(candidate)
                    c_copy["reranker_score"] = round(float_score, 4)
                    reranked.append(c_copy)

            reranked.sort(key=lambda x: x["reranker_score"], reverse=True)
            logger.info(f"Reranker filtered {len(candidates)} candidates down to {len(reranked)} verified matches.")
            return reranked[:top_k] if reranked else candidates[:top_k]
        except Exception as e:
            logger.error(f"Error during cross-encoder reranking: {e}. Using deterministic ranking.")

    # Deterministic fallback reranking: BM25/keyword jaccard & token density
    query_tokens = set(query_text.lower().split())
    scored = []
    for c in candidates:
        cand_text = (c.get("title", "") + " " + c.get("abstract", "")).lower()
        cand_tokens = set(cand_text.split())
        intersection = query_tokens.intersection(cand_tokens)
        jaccard = len(intersection) / max(1, len(query_tokens.union(cand_tokens)))
        c_copy = dict(c)
        c_copy["reranker_score"] = round(float(jaccard), 4)
        scored.append(c_copy)

    scored.sort(key=lambda x: x["reranker_score"], reverse=True)
    return scored[:top_k]
