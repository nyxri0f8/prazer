import logging
from typing import List, Dict, Any
import numpy as np

from services.parser import split_sentences
from services.embeddings import embed_sentences
from services.scoring import cosine_similarity_pct

logger = logging.getLogger(__name__)


def generate_sentence_heatmap(
    draft_text: str,
    top_candidates: List[Dict[str, Any]]
) -> List[Dict[str, Any]]:
    """
    Computes fine-grained sentence-level overlap between user's draft sentences and retrieved prior-art patents.
    Returns structured heatmap data for dual-pane visualization.
    """
    sentences = split_sentences(draft_text)
    if not sentences:
        sentences = [draft_text[:200]]

    sentence_vecs = embed_sentences(sentences)

    # Prepare candidate sentences
    candidate_sentence_pool = []
    for cand in top_candidates:
        cand_text = cand.get("abstract", cand.get("title", ""))
        cand_sentences = split_sentences(cand_text)
        if not cand_sentences:
            cand_sentences = [cand_text]
        for cs in cand_sentences:
            candidate_sentence_pool.append({
                "patent_id": cand.get("patent_id", "US-UNKNOWN"),
                "patent_title": cand.get("title", "Prior Art Patent"),
                "sentence_text": cs,
                "full_excerpt": cand_text[:400]
            })

    pool_texts = [item["sentence_text"] for item in candidate_sentence_pool]
    pool_vecs = embed_sentences(pool_texts) if pool_texts else []

    sentence_overlaps: List[Dict[str, Any]] = []

    for idx, (sentence, s_vec) in enumerate(zip(sentences, sentence_vecs)):
        best_overlap = 0.0
        best_match_patent = top_candidates[0].get("patent_id", "US-UNKNOWN") if top_candidates else "US-NONE"
        best_match_title = top_candidates[0].get("title", "Prior Art") if top_candidates else ""
        best_excerpt = top_candidates[0].get("abstract", "")[:300] if top_candidates else ""

        for pool_item, p_vec in zip(candidate_sentence_pool, pool_vecs):
            sim = cosine_similarity_pct(s_vec, p_vec)
            if sim > best_overlap:
                best_overlap = sim
                best_match_patent = pool_item["patent_id"]
                best_match_title = pool_item["patent_title"]
                best_excerpt = pool_item["sentence_text"]

        sentence_overlaps.append({
            "sentence_index": idx,
            "text": sentence,
            "overlap_pct": round(best_overlap, 1),
            "matched_patent_id": best_match_patent,
            "matched_patent_title": best_match_title,
            "matched_excerpt": best_excerpt
        })

    logger.info(f"Generated sentence heatmap for {len(sentence_overlaps)} sentences.")
    return sentence_overlaps
