import re
import logging
from typing import List, Dict, Any, Tuple, Set

logger = logging.getLogger(__name__)


def _extract_technical_concepts(text: str) -> List[str]:
    """Extracts candidate technical multi-word concepts and domain terms."""
    # Normalize
    cleaned = re.sub(r'[^a-zA-Z0-9\s-]', ' ', text.lower())
    words = [w for w in cleaned.split() if len(w) > 2]
    
    # Extract bigrams and trigrams
    concepts = []
    for i in range(len(words) - 1):
        bigram = f"{words[i]} {words[i+1]}"
        concepts.append(bigram)
        if i < len(words) - 2:
            trigram = f"{words[i]} {words[i+1]} {words[i+2]}"
            concepts.append(trigram)
    return concepts


def calculate_novelty_score(
    draft_text: str,
    prior_art_texts: List[str]
) -> Dict[str, Any]:
    """
    Computes a deterministic bibliometric Novelty Score (0.0 to 100.0%) by evaluating
    technical concept co-occurrence rarity against retrieved prior-art corpora.
    Higher score indicates non-obvious combinatorial couplings of technical elements.
    """
    draft_concepts = _extract_technical_concepts(draft_text)
    if not draft_concepts:
        return {
            "novelty_score": 80.0,
            "rare_concept_count": 0,
            "total_concepts": 0
        }

    # Build corpus concept frequency map
    corpus_concept_counts: Dict[str, int] = {}
    for pa_text in prior_art_texts:
        pa_concepts = set(_extract_technical_concepts(pa_text))
        for c in pa_concepts:
            corpus_concept_counts[c] = corpus_concept_counts.get(c, 0) + 1

    total_corpus_docs = max(1, len(prior_art_texts))
    
    # Calculate concept rarity scores
    rarity_scores = []
    rare_concepts = []
    for c in draft_concepts:
        freq = corpus_concept_counts.get(c, 0)
        # Rarity is inversely proportional to frequency in prior art
        rarity = 1.0 - (freq / total_corpus_docs)
        rarity_scores.append(rarity)
        if rarity >= 0.8:
            rare_concepts.append(c)

    # Aggregate novelty percentage
    avg_rarity = sum(rarity_scores) / len(rarity_scores) if rarity_scores else 0.8
    novelty_pct = avg_rarity * 100.0

    # Ensure bounds [0, 100]
    final_novelty = float(max(0.0, min(100.0, round(novelty_pct, 2))))
    
    return {
        "novelty_score": final_novelty,
        "rare_concept_count": len(set(rare_concepts)),
        "total_concepts": len(set(draft_concepts))
    }


def calculate_patent_potential(
    novelty_score: float,
    uniqueness_score: float,
    similarity_score: float
) -> float:
    """
    Computes the deterministic Patent Potential Composite Score (0.0 to 100.0%)
    Formula: (Novelty * 0.40) + (Uniqueness * 0.30) + ((100 - Similarity) * 0.30)
    """
    inverted_similarity = max(0.0, 100.0 - similarity_score)
    composite = (
        (novelty_score * 0.40) +
        (uniqueness_score * 0.30) +
        (inverted_similarity * 0.30)
    )
    return float(max(0.0, min(100.0, round(composite, 2))))


def determine_confidence_rating(
    candidate_count: int,
    similarity_variance: float = 12.0,
    text_length: int = 1500
) -> str:
    """
    Determines the deterministic Confidence Rating: 'High' | 'Medium' | 'Low'.
    """
    if candidate_count >= 5 and text_length >= 500:
        return "High"
    elif candidate_count >= 2:
        return "Medium"
    else:
        return "Low"


def calculate_six_gauge_metrics(
    draft_text: str,
    prior_art_texts: List[str],
    similarity_score: float,
    uniqueness_score: float
) -> Dict[str, Any]:
    """
    Generates the complete Six-Gauge Analytics Suite metrics and Confidence Rating.
    """
    novelty_data = calculate_novelty_score(draft_text, prior_art_texts)
    novelty_score = novelty_data["novelty_score"]
    
    patent_potential = calculate_patent_potential(
        novelty_score=novelty_score,
        uniqueness_score=uniqueness_score,
        similarity_score=similarity_score
    )

    confidence = determine_confidence_rating(
        candidate_count=len(prior_art_texts),
        text_length=len(draft_text)
    )

    # Technical Specificity (lexical density & claim precision)
    words = draft_text.split()
    unique_words = set(w.lower() for w in words)
    lexical_density = len(unique_words) / max(1, len(words))
    technical_specificity = float(min(98.0, max(45.0, round(lexical_density * 130.0, 1))))

    # Prior-Art Corpus Density (breadth of patent coverage)
    corpus_density = float(min(95.0, max(30.0, round(len(prior_art_texts) * 11.5 + similarity_score * 0.25, 1))))

    return {
        "patent_potential": patent_potential,
        "novelty_score": novelty_score,
        "uniqueness_score": uniqueness_score,
        "similarity_score": similarity_score,
        "technical_specificity": technical_specificity,
        "corpus_density": corpus_density,
        "confidence_rating": confidence,
        "rare_concept_count": novelty_data["rare_concept_count"]
    }
