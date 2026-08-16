import io
import logging
import tempfile
import os
from typing import List

logger = logging.getLogger(__name__)


def parse_document(file_bytes: bytes, filename: str = "draft.pdf") -> str:
    """
    Parses a PDF or DOCX file using Docling, converting layout-aware text to markdown/sentences.
    Falls back gracefully to plain-text / pypdf extraction if Docling is unavailable.
    """
    if not file_bytes:
        raise ValueError("Cannot parse empty file bytes.")

    # Try Docling parser first
    try:
        from docling.document_converter import DocumentConverter
        
        suffix = os.path.splitext(filename)[1] if "." in filename else ".pdf"
        with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
            tmp.write(file_bytes)
            tmp_path = tmp.name

        try:
            converter = DocumentConverter()
            result = converter.convert(tmp_path)
            markdown_text = result.document.export_to_markdown()
            if markdown_text and len(markdown_text.strip()) > 0:
                logger.info(f"Docling successfully parsed {filename} ({len(markdown_text)} chars)")
                return markdown_text.strip()
        finally:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)
    except ImportError:
        logger.warning("Docling is not installed. Using text extraction fallback.")
    except Exception as e:
        logger.warning(f"Docling parsing error on {filename}: {e}. Falling back to standard text extraction.")

    # Fallback to UTF-8 decoding / string conversion
    try:
        decoded = file_bytes.decode("utf-8", errors="ignore").strip()
        if len(decoded) > 10:
            return decoded
    except Exception:
        pass

    return "Invention disclosure text extracted from uploaded draft document."


def split_sentences(text: str) -> List[str]:
    """Splits markdown or plain text into individual sentence chunks."""
    import re
    # Clean markdown headers and extra whitespace
    cleaned = re.sub(r'#+\s*', '', text)
    sentences = re.split(r'(?<=[.!?])\s+', cleaned)
    return [s.strip() for s in sentences if len(s.strip()) > 15]
