import hashlib
import logging
from typing import List, Set, Tuple

logger = logging.getLogger(__name__)


def _tokenize(text: str) -> List[str]:
    """Cleans and normalizes text into lowercase alphanumeric tokens."""
    import re
    cleaned = re.sub(r'[^a-zA-Z0-9\s]', ' ', text.lower())
    return [t for t in cleaned.split() if len(t) > 1]


def _kgrams(tokens: List[str], k: int = 5) -> List[Tuple[str, ...]]:
    """Extracts contiguous k-grams of tokens."""
    if len(tokens) < k:
        return [tuple(tokens)] if tokens else []
    return [tuple(tokens[i:i + k]) for i in range(len(tokens) - k + 1)]


def _hash_kgram(kgram: Tuple[str, ...]) -> int:
    """Hashes a k-gram tuple into an integer fingerprint."""
    raw = " ".join(kgram).encode('utf-8')
    return int(hashlib.sha256(raw).hexdigest()[:16], 16)


def _winnow(hashes: List[int], window_size: int = 4) -> Set[int]:
    """
    Applies the Winnowing local minimum algorithm to select robust document fingerprints.
    Guarantees that at least one hash is chosen per sliding window.
    """
    if not hashes:
        return set()
    if len(hashes) <= window_size:
        return {min(hashes)}

    fingerprints: Set[int] = set()
    for i in range(len(hashes) - window_size + 1):
        window = hashes[i:i + window_size]
        min_val = min(window)
        fingerprints.add(min_val)
    return fingerprints


def calculate_uniqueness_score(
    draft_text: str,
    prior_art_texts: List[str],
    k: int = 5,
    window_size: int = 4
) -> float:
    """
    Computes a deterministic Uniqueness Score (0.0 to 100.0%) using Copydetect / Winnowing k-gram fingerprinting.
    Uniqueness = 100 - (overlapping_fingerprints / total_draft_fingerprints * 100).
    """
    draft_tokens = _tokenize(draft_text)
    if not draft_tokens:
        return 100.0

    draft_kgrams = _kgrams(draft_tokens, k=k)
    if not draft_kgrams:
        return 100.0

    draft_hashes = [_hash_kgram(kg) for kg in draft_kgrams]
    draft_fingerprints = _winnow(draft_hashes, window_size=window_size)

    if not draft_fingerprints:
        return 100.0

    # Collect fingerprints from all prior art candidates
    prior_art_fingerprints: Set[int] = set()
    for pa_text in prior_art_texts:
        pa_tokens = _tokenize(pa_text)
        pa_kgrams = _kgrams(pa_tokens, k=k)
        if pa_kgrams:
            pa_hashes = [_hash_kgram(kg) for kg in pa_kgrams]
            prior_art_fingerprints.update(_winnow(pa_hashes, window_size=window_size))

    # Calculate set intersection (exact overlapping text segments)
    overlapping_fingerprints = draft_fingerprints.intersection(prior_art_fingerprints)
    overlap_ratio = len(overlapping_fingerprints) / len(draft_fingerprints)
    
    # Uniqueness is the inverse of overlap
    uniqueness_pct = (1.0 - overlap_ratio) * 100.0
    return float(max(0.0, min(100.0, round(uniqueness_pct, 2))))
