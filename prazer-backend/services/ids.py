import logging
from typing import Dict, Any, List

logger = logging.getLogger(__name__)


def generate_form_sb08a_citations(report_data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Formats retrieved prior art into a USPTO Form SB/08a (Information Disclosure Statement) compliant table.
    """
    matches = report_data.get("top_matches", [])
    us_patents = []
    foreign_patents = []

    for idx, m in enumerate(matches, 1):
        office = m.get("patent_office", "USPTO")
        patent_id = m.get("patent_id", f"US-{idx}")
        title = m.get("title", "Prior Art Patent")
        pub_date = m.get("publication_date", "2024-01-01")

        entry = {
            "item_number": idx,
            "document_number": patent_id,
            "publication_date": pub_date,
            "name_of_patentee": title[:40],
            "pages_or_relevant_passages": m.get("excerpt", "")[:120]
        }

        if office == "USPTO" or patent_id.startswith("US"):
            us_patents.append(entry)
        else:
            foreign_patents.append(entry)

    return {
        "form": "PTO/SB/08a",
        "title": "Information Disclosure Statement (IDS)",
        "us_patents": us_patents,
        "foreign_patents": foreign_patents,
        "total_citations": len(matches)
    }
