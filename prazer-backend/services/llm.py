import os
import logging
from typing import List, Dict, Any
import requests

logger = logging.getLogger(__name__)

GROQ_API_KEY = os.environ.get("GROQ_API_KEY", "")
GROQ_MODEL = os.environ.get("GROQ_MODEL", "llama-3.3-70b-versatile")
OLLAMA_HOST = os.environ.get("OLLAMA_HOST", "http://localhost:11434")
OLLAMA_MODEL = os.environ.get("OLLAMA_MODEL", "qwen2.5:3b")


def summarize(overall_similarity_pct: float, top_matches: List[Dict[str, Any]]) -> str:
    """
    Synthesizes a 2-3 sentence plain-English summary of the mathematical similarity findings.
    Enforces that LLM strictly explains the math and never invents or alters scores.
    Tries Groq hosted API first, then Ollama local fallback, then template fallback.
    """
    top_title = top_matches[0]["title"] if top_matches else "Indexed prior art"
    top_patent_id = top_matches[0].get("patent_id", "") if top_matches else ""
    num_matches = len(top_matches)

    system_prompt = (
        "You are the explanation engine for PRAZER, a patent prior-art analysis tool. "
        "Your task is to write a concise, objective 2-to-3 sentence plain-English summary of the mathematical findings. "
        "Rules: "
        "1. Strictly reference the exact similarity score provided; never invent, estimate, or modify numerical scores. "
        "2. Do not offer legal advice or claim patentability. "
        "3. Highlight the primary technical overlaps between the draft and the top matching prior-art patents."
    )

    user_prompt = (
        f"Similarity Score: {overall_similarity_pct:.1f}%.\n"
        f"Top matching patent: {top_patent_id} - \"{top_title}\".\n"
        f"Total candidate matches analyzed: {num_matches}.\n"
        "Write a clear, professional 2-3 sentence summary explaining these findings to the inventor."
    )

    # 1. Try Groq Hosted API
    if GROQ_API_KEY:
        try:
            from groq import Groq
            client = Groq(api_key=GROQ_API_KEY)
            chat_completion = client.chat.completions.create(
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                model=GROQ_MODEL,
                temperature=0.2,
                max_tokens=250
            )
            content = chat_completion.choices[0].message.content
            if content and len(content.strip()) > 0:
                logger.info("Successfully generated summary via Groq hosted API.")
                return content.strip()
        except Exception as e:
            logger.warning(f"Groq API call failed: {e}. Attempting Ollama local fallback.")

    # 2. Try Ollama Local Fallback
    try:
        ollama_url = f"{OLLAMA_HOST.rstrip('/')}/api/generate"
        resp = requests.post(
            ollama_url,
            json={
                "model": OLLAMA_MODEL,
                "prompt": f"{system_prompt}\n\n{user_prompt}",
                "stream": False
            },
            timeout=10
        )
        if resp.status_code == 200:
            ollama_resp = resp.json().get("response", "").strip()
            if ollama_resp:
                logger.info("Successfully generated summary via local Ollama.")
                return ollama_resp
    except Exception as e:
        logger.debug(f"Ollama local fallback unavailable: {e}")

    # 3. Deterministic template fallback
    if overall_similarity_pct < 35.0:
        return (
            f"The uploaded invention disclosure exhibits a low overall similarity score of {overall_similarity_pct:.1f}% "
            f"against indexed prior art, indicating strong structural distinction from existing disclosures. "
            f"The closest candidate identified is {top_patent_id} (\"{top_title}\"), though core inventive concepts appear differentiated."
        )
    elif overall_similarity_pct < 70.0:
        return (
            f"The analysis calculated a moderate similarity score of {overall_similarity_pct:.1f}% with prior-art publications. "
            f"Significant technical overlap was detected with {top_patent_id} (\"{top_title}\"), particularly in system architecture and functional claims. "
            f"We recommend reviewing the specific claim elements to emphasize unique technical contributions."
        )
    else:
        return (
            f"The document demonstrates a high similarity score of {overall_similarity_pct:.1f}% against published prior art. "
            f"Substantial conceptual and claim overlap was found with {top_patent_id} (\"{top_title}\"). "
            f"A detailed claim differentiation review with a registered patent attorney is strongly advised prior to filing."
        )
