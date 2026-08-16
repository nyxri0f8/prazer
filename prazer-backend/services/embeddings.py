import os
import logging
from typing import List
import numpy as np

logger = logging.getLogger(__name__)

_model = None
MODEL_NAME = os.environ.get("EMBEDDINGS_MODEL", "mpi-inno-comp/paecter")


def get_embedding_model():
    """Lazily loads the sentence-transformers model."""
    global _model
    if _model is None:
        try:
            from sentence_transformers import SentenceTransformer
            logger.info(f"Loading embedding model: {MODEL_NAME}")
            _model = SentenceTransformer(MODEL_NAME)
            logger.info("Embedding model loaded successfully.")
        except Exception as e:
            logger.warning(f"Could not load SentenceTransformer '{MODEL_NAME}': {e}. Using deterministic feature encoder fallback.")
            _model = "fallback"
    return _model


def embed_sentences(sentences: List[str], dimension: int = 1024) -> List[np.ndarray]:
    """
    Generates 1024-dimensional normalized vector embeddings for a list of sentences.
    Uses PaECTER when available, with a deterministic TF-IDF/hashing fallback for tests.
    """
    if not sentences:
        return []

    model = get_embedding_model()
    if model != "fallback" and model is not None:
        try:
            embeddings = model.encode(sentences, convert_to_numpy=True, normalize_embeddings=True)
            return [np.array(e, dtype=np.float32) for e in embeddings]
        except Exception as e:
            logger.error(f"Error encoding sentences with PaECTER: {e}. Falling back to deterministic encoder.")

    # Deterministic fallback embedding generation (1024-dimensional normalized vector)
    vectors: List[np.ndarray] = []
    for s in sentences:
        import hashlib
        vec = np.zeros(dimension, dtype=np.float32)
        words = s.lower().split()
        for i, word in enumerate(words):
            h = int(hashlib.md5(word.encode('utf-8')).hexdigest(), 16)
            idx = h % dimension
            sign = 1.0 if ((h >> 8) & 1) else -1.0
            vec[idx] += sign * (1.0 + (i % 3) * 0.1)
        norm = np.linalg.norm(vec)
        if norm > 0:
            vec /= norm
        else:
            vec[0] = 1.0
        vectors.append(vec)
    return vectors
