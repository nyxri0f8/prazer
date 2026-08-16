import logging
from typing import Dict, Any, List
from supabase_client import update_document_status, write_report
from services.parser import parse_document, split_sentences
from services.retrieval import search_prior_art
from services.reranker import rerank_candidates
from services.embeddings import embed_sentences
from services.scoring import cosine_similarity_pct, calculate_overall_similarity
from services.uniqueness import calculate_uniqueness_score
from services.novelty import calculate_six_gauge_metrics
from services.heatmap import generate_sentence_heatmap
from services.llm import summarize

logger = logging.getLogger(__name__)


def run_pipeline(document_id: str, file_bytes: bytes, filename: str = "draft.pdf") -> Dict[str, Any]:
    """
    Executes the complete Phase 3 deterministic analysis pipeline:
    1. Parsing: Extract clean sentences with Docling.
    2. Retrieval: Search candidate patents via PQAI hosted API.
    3. Cross-Encoder Reranking: BAAI bge-reranker-v2-m3 false-positive filtering.
    4. Vector Math & Embeddings: PaECTER 1024-dim sentence vectors.
    5. Scoring: SciPy cosine similarity.
    6. Uniqueness Engine: Copydetect / Winnowing k-gram fingerprinting (0-100%).
    7. Novelty & Patent Potential: Six-Gauge bibliometric analytics suite & confidence rating.
    8. Sentence Heatmap: Dual-pane sentence alignment & overlap mapping.
    9. LLM Synthesis: Groq LLaMA 3.3 explanation synthesis (never alters math).
    10. Persistence: Write report with 6 metrics and sentence heatmap to Supabase.
    """
    try:
        logger.info(f"Starting Phase 3 pipeline execution for document ID: {document_id}")
        update_document_status(document_id, "processing")

        # Step 1: Parsing
        parsed_text = parse_document(file_bytes, filename)
        sentences = split_sentences(parsed_text)
        if not sentences:
            sentences = [parsed_text]
        logger.info(f"Stage 1 [Parsing] completed: {len(sentences)} sentences extracted.")

        # Step 2: Retrieval
        candidate_patents = search_prior_art(parsed_text, top_n=10)
        logger.info(f"Stage 2 [Retrieval] completed: {len(candidate_patents)} candidate patents retrieved.")

        # Step 3: Cross-Encoder Reranking
        verified_candidates = rerank_candidates(parsed_text, candidate_patents, top_k=6)
        logger.info(f"Stage 3 [Reranking] verified {len(verified_candidates)} top candidate matches.")

        # Step 4: Vector Math & Embeddings (PaECTER 1024-dim)
        user_vectors = embed_sentences([parsed_text])
        user_main_vec = user_vectors[0] if user_vectors else None

        abstract_texts = [c.get("abstract", c.get("title", "")) for c in verified_candidates]
        candidate_vectors = embed_sentences(abstract_texts)
        logger.info("Stage 4 [Vector Math] PaECTER embeddings generated.")

        # Step 5: Deterministic Similarity Scoring (SciPy)
        scored_matches: List[Dict[str, Any]] = []
        similarity_scores: List[float] = []

        for candidate, cand_vec in zip(verified_candidates, candidate_vectors):
            if user_main_vec is not None:
                sim_pct = cosine_similarity_pct(user_main_vec, cand_vec)
            else:
                sim_pct = 0.0
            
            similarity_scores.append(sim_pct)
            scored_matches.append({
                "patent_id": candidate.get("patent_id", "US-UNKNOWN"),
                "title": candidate.get("title", "Prior Art Patent"),
                "similarity": sim_pct,
                "excerpt": candidate.get("abstract", "")[:350],
                "publication_date": candidate.get("publication_date", "2023-01-01"),
                "patent_office": candidate.get("patent_office", "USPTO"),
                "url": candidate.get("url", "")
            })

        scored_matches.sort(key=lambda x: x["similarity"], reverse=True)
        top_matches = scored_matches[:5]
        overall_similarity = calculate_overall_similarity(similarity_scores)
        logger.info(f"Stage 5 [Scoring] Overall Similarity = {overall_similarity:.2f}%")

        # Step 6: Uniqueness Score (Copydetect / Winnowing)
        uniqueness_score = calculate_uniqueness_score(parsed_text, abstract_texts)
        logger.info(f"Stage 6 [Uniqueness Engine] Uniqueness Score = {uniqueness_score:.2f}%")

        # Step 7: Novelty Engine, Patent Potential & Six-Gauge Suite (Phase 3)
        six_metrics = calculate_six_gauge_metrics(
            draft_text=parsed_text,
            prior_art_texts=abstract_texts,
            similarity_score=overall_similarity,
            uniqueness_score=uniqueness_score
        )
        logger.info(
            f"Stage 7 [Novelty & Potential] Novelty={six_metrics['novelty_score']}%, "
            f"Patent Potential={six_metrics['patent_potential']}%, Confidence={six_metrics['confidence_rating']}"
        )

        # Step 8: Sentence Heatmap Generation
        sentence_overlaps = generate_sentence_heatmap(parsed_text, top_matches)
        logger.info(f"Stage 8 [Sentence Heatmap] Generated {len(sentence_overlaps)} sentence alignments.")

        # Step 9: LLM Synthesis (Groq LLaMA 3.3 explanation)
        summary_text = summarize(overall_similarity, top_matches)
        logger.info("Stage 9 [LLM Synthesis] completed.")

        # Step 10: Report Persistence
        report = write_report(
            document_id=document_id,
            similarity_score=overall_similarity,
            uniqueness_score=uniqueness_score,
            novelty_score=six_metrics["novelty_score"],
            patent_potential=six_metrics["patent_potential"],
            confidence_rating=six_metrics["confidence_rating"],
            technical_specificity=six_metrics["technical_specificity"],
            corpus_density=six_metrics["corpus_density"],
            top_matches=top_matches,
            sentence_overlaps=sentence_overlaps,
            summary_text=summary_text
        )
        update_document_status(document_id, "completed")
        logger.info(f"Phase 3 Pipeline successfully completed for document ID: {document_id}")
        return report

    except Exception as e:
        logger.error(f"Pipeline failed for document {document_id}: {e}", exc_info=True)
        update_document_status(document_id, "failed", error_message=str(e))
        raise
