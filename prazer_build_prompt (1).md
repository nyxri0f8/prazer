# PRAZER — Build Instruction Prompt
### (Paste this whole document as the task prompt into Claude Code, Antigravity, or Codex)

---

## 0. How to use this document

This is a **phased build spec**, not a one-shot instruction. Give the agent **Phase 1 only** to start. Do not ask it to build Phase 2 or 3 until Phase 1 runs end-to-end and you've tested it. Each phase below is written so you can paste just that section as a follow-up prompt once the previous phase is working.

If you're using this with an agent that can run shell commands (Claude Code, Antigravity, Codex CLI), tell it explicitly: *"Set up the project structure and install dependencies as you go — don't just write code, get it running."*

---

## 1. Project Overview

**Name:** Prazer (a play on "Appraiser")
**What it is:** A 100% open-source, free, AI-assisted patent prior-art and novelty analysis tool. A user uploads a patent draft or invention disclosure (PDF/DOCX) and gets back a report showing how similar their idea is to existing patents, how much of their text overlaps with prior art, and a plain-English explanation of the findings.

**Core philosophy — non-negotiable:** *Math-first, AI-second.*
- All numerical scores (similarity, uniqueness, novelty, patent potential) are computed with deterministic math/algorithms — never estimated or guessed by an LLM.
- An LLM is used **only** to explain the math results in plain English — summarizing overlaps, writing the executive summary. It never invents a score.
- This is the product's core trust proposition — do not compromise it for convenience.

**Target users:** Students, independent inventors, and early-stage founders who can't afford commercial patent search tools (Clarivate, Questel, etc.) and want a quick novelty sanity-check before filing or before talking to a patent attorney.

**Important:** This tool gives an informational estimate, not legal advice. Every report must visibly state it is not a substitute for a registered patent attorney's opinion.

---

## 2. Design rules the agent must follow

1. **Do not self-host PQAI.** Use PQAI's free hosted API (`search.projectpq.ai` / their REST API). Self-hosting their search server means replicating an 11M-document Elasticsearch index — out of scope.
2. **Do not stand up a separate Qdrant instance for Phase 1.** Use `pgvector` inside Postgres (Supabase). Only introduce Qdrant later if vector volume genuinely outgrows Postgres.
3. **Do not implement the full Novelpy bibliometric pipeline in Phase 1.** Novelpy expects pre-built citation-network corpora; using it for a single live document is a research problem. Phase 1 uses a simple, explainable heuristic instead (see Phase 1 spec). Full Novelpy is a Phase 3 stretch goal.
4. **Supabase is fully hosted — you never deploy a database yourself.** Postgres, Auth, and Storage all live in Supabase's cloud. Your own backend code (FastAPI) is a separate thing you write and deploy, which *talks to* Supabase over its API/SDK. Don't conflate the two.
5. **Keep heavy ML inference off the same box as your FastAPI backend.** Embedding model, reranker, and Docling parsing should run as a separate service (see §9 Deployment).
6. **No placeholder/mock data** within whatever phase is currently being built — but it's fine (expected) for later-phase features to simply not exist yet. Don't fake Phase 2/3 features to look "done."
7. **Strict typing, real error handling**, clear separation of concerns (parser / retrieval / embedding / scoring / LLM-explainer / API / frontend as distinct modules).
8. **Every generated report includes a visible disclaimer**: *"This is an automated estimate, not legal advice. Consult a registered patent attorney before filing."*

---

## 3. Phase 1 — MVP Architecture

```
User uploads PDF/DOCX (Flutter app)
        │
        ▼
 [FastAPI backend] receives file → uploads to Supabase Storage → inserts row in Supabase Postgres
        │
        ▼
 [Docling] parse → clean sentence-level text
        │
        ▼
 [PQAI hosted API] → plain-English query → top prior-art candidates (patents + abstracts)
        │
        ▼
 [PaECTER] embed both the user's draft sentences AND the retrieved prior-art sentences
        │
        ▼
 [pgvector, inside the same Supabase Postgres] store + compare vectors
        │
        ▼
 [SciPy cosine similarity] → deterministic Similarity Score (0–100)
        │
        ▼
 [Groq LLM] → turn the math + top matches into a 3-sentence plain-English summary
        │
        ▼
 [FastAPI] writes report row to Supabase, returns JSON
        │
        ▼
 [Flutter app] → simple report screen: score gauge + summary + list of top matching patents
```

That's the entire Phase 1 scope. No reranker, no uniqueness score, no novelty score, no heatmap UI yet — those are Phase 2/3.

**Note there are two separate things called "backend" here — don't let the agent conflate them:**
- **Supabase** = your database, file storage, and user auth. Fully hosted by Supabase. You configure it, you don't deploy it.
- **FastAPI** = your own application code (the pipeline logic, the API routes). You write this and deploy it yourself (§9).

---

## 4. Tech stack — what each tool is, its license, and how to install/use it

### A. Backend framework — FastAPI
- **What:** Python async web framework for the REST API. This is *your* code — it orchestrates every other tool below.
- **License:** MIT.
- **Install:**
  ```bash
  pip install fastapi uvicorn python-multipart
  ```
- **Run locally:**
  ```bash
  uvicorn main:app --reload --port 8000
  ```

### B. Document parsing — Docling
- **What:** IBM's layout-aware document parser. Handles multi-column PDFs, tables, and figures without scrambling reading order.
- **License:** MIT.
- **Install:**
  ```bash
  pip install docling
  ```
- **Basic usage:**
  ```python
  from docling.document_converter import DocumentConverter

  converter = DocumentConverter()
  result = converter.convert("draft.pdf")
  text = result.document.export_to_markdown()  # clean, ordered text
  ```

### C. Prior-art retrieval — PQAI hosted API (not self-hosted)
- **What:** Free, open-source patent semantic search covering ~68 patent offices. MIT-licensed project; you use it as a hosted API, not a service you run.
- **Setup:** Sign up at `projectpq.ai` for an API key. Read the API guide at `github.com/pqaidevteam/pqai/blob/master/docs/README-API.md`.
- **Basic usage:**
  ```python
  import requests

  def search_prior_art(query_text: str, api_key: str):
      resp = requests.post(
          "https://api.projectpq.ai/search/102/",
          headers={"Authorization": f"Bearer {api_key}"},
          json={"q": query_text, "n": 10},
      )
      return resp.json()  # list of candidate patents with IDs, titles, abstracts
  ```
  *(Confirm exact endpoint paths against the current API guide — hosted APIs change versions over time.)*

### D. Patent-specific embeddings — PaECTER
- **What:** A BERT-for-Patents-based model fine-tuned on citation data specifically for patent similarity. Produces 1024-dimensional vectors. This is a meaningfully better choice than a generic sentence-transformer for this domain.
- **License:** Apache-2.0.
- **Model size:** ~1.4GB (safetensors) — budget RAM accordingly, don't load it on a memory-starved box.
- **Install:**
  ```bash
  pip install -U sentence-transformers
  ```
- **Usage:**
  ```python
  from sentence_transformers import SentenceTransformer

  model = SentenceTransformer("mpi-inno-comp/paecter")
  vectors = model.encode(["your patent sentence here"])  # -> 1024-dim vector
  ```

### E. Vector storage — pgvector (a Postgres extension INSIDE your Supabase project)
- **What:** A Postgres extension for storing and querying embedding vectors. Using this instead of a standalone Qdrant means one fewer service to run — it lives in the same Supabase Postgres database as everything else.
- **License:** PostgreSQL License (permissive).
- **Setup:** In your Supabase project's SQL editor, run:
  ```sql
  create extension if not exists vector;

  create table document_vectors (
    id uuid primary key default gen_random_uuid(),
    document_id uuid references documents(id),
    sentence text not null,
    embedding vector(1024),
    created_at timestamptz default now()
  );

  create index on document_vectors using ivfflat (embedding vector_cosine_ops);
  ```
- **Query example:**
  ```sql
  select sentence, 1 - (embedding <=> $1) as similarity
  from document_vectors
  order by embedding <=> $1
  limit 10;
  ```

### F. Deterministic similarity scoring — SciPy
- **What:** Standard scientific Python library, used here purely for cosine distance math.
- **License:** BSD.
- **Install:**
  ```bash
  pip install scipy numpy
  ```
- **Usage:**
  ```python
  from scipy.spatial.distance import cosine

  similarity_pct = (1 - cosine(vec_a, vec_b)) * 100
  ```

### G. LLM explanation layer — Groq (primary)
- **What:** Fast hosted inference for open-weight models (Llama 3.3, Qwen). Free tier, no credit card.
- **License:** N/A (hosted API service, not open-source software — but the models it serves are open-weight).
- **Free tier limits to design around:** ~30 requests/min, ~6,000 tokens/min, ~1,000–14,400 requests/day depending on model. Do not assume production-scale throughput on the free tier.
- **Setup:** Create a key at `console.groq.com`.
  ```bash
  pip install groq
  ```
  ```python
  from groq import Groq

  client = Groq(api_key="YOUR_KEY")
  response = client.chat.completions.create(
      model="llama-3.3-70b-versatile",
      messages=[{
          "role": "system",
          "content": "You explain patent similarity scores in plain English. Never invent numbers — only reference the scores given to you."
      }, {
          "role": "user",
          "content": f"Similarity: {similarity_pct}%. Top matching patent: {top_match_title}. Write a 3-sentence summary."
      }],
  )
  ```

### H. LLM fallback — Ollama (local, offline)
- **What:** Runs a small open-weight model locally when Groq is unavailable or rate-limited.
- **License:** MIT.
- **Model choice:** Use a **3B-class model** (e.g. `qwen2.5:3b` or `phi4-mini`), not a 7–8B model — CPU-only inference on a small free-tier VM will be too slow at 7–8B.
- **Install:**
  ```bash
  curl -fsSL https://ollama.com/install.sh | sh
  ollama pull qwen2.5:3b
  ```
- **Usage:**
  ```python
  import requests

  def local_fallback(prompt: str):
      r = requests.post("http://localhost:11434/api/generate",
                         json={"model": "qwen2.5:3b", "prompt": prompt, "stream": False})
      return r.json()["response"]
  ```

### I. Backend ↔ Supabase — supabase-py
- **What:** Official Python client. This is how your FastAPI code talks to Supabase's Postgres, Storage, and Auth — you do not connect with raw SQL credentials for app logic, you use this client.
- **License:** MIT.
- **Install:**
  ```bash
  pip install supabase
  ```
- **Setup:** In your Supabase dashboard → Settings → API, copy your project URL and **service role key** (backend uses the service role key, never the public anon key — the service role key bypasses row-level security, which your trusted backend needs but your Flutter app never should).
  ```python
  from supabase import create_client, Client
  import os

  supabase: Client = create_client(
      os.environ["SUPABASE_URL"],
      os.environ["SUPABASE_SERVICE_ROLE_KEY"],
  )
  ```

### J. Frontend — Flutter
- **What:** Cross-platform UI (web/Android/desktop) from one codebase.
- **License:** BSD.
- **Install:** Follow `flutter.dev` install instructions for your OS, then:
  ```bash
  flutter create prazer_app
  cd prazer_app
  flutter pub add flutter_riverpod fl_chart dio file_picker
  ```
- **State management:** Riverpod. **Charts/gauges:** `fl_chart`. **File upload:** `file_picker` + `dio` for the HTTP call to your FastAPI backend. The Flutter app talks to *your FastAPI backend only* — it never calls Supabase directly for this MVP, so there's no anon key or RLS policy work needed on the client side yet.

---

## 5. Backend service architecture (this is the part that was missing)

### Project structure
```
prazer-backend/
├── main.py                 # FastAPI app + routes + CORS setup
├── supabase_client.py       # Supabase client init + storage/db helper functions
├── pipeline.py              # orchestrates the full Phase 1 pipeline, called as a background task
├── services/
│   ├── parser.py            # Docling wrapper
│   ├── retrieval.py         # PQAI API calls
│   ├── embeddings.py        # PaECTER wrapper
│   ├── scoring.py           # SciPy cosine similarity
│   └── llm.py               # Groq call + Ollama fallback logic
├── requirements.txt
├── Dockerfile
├── docker-compose.yml        # just your API + local Ollama — Postgres is remote (Supabase), nothing to run for it
└── .env
```

### Supabase Storage — where uploaded files actually live
Create a bucket called `drafts` in the Supabase dashboard (Storage tab) before you start. Files never touch your FastAPI server's disk long-term — they're streamed to Supabase Storage.

```python
# supabase_client.py
from supabase import create_client, Client
import os

supabase: Client = create_client(
    os.environ["SUPABASE_URL"],
    os.environ["SUPABASE_SERVICE_ROLE_KEY"],
)

def upload_draft(file_bytes: bytes, storage_path: str) -> str:
    supabase.storage.from_("drafts").upload(storage_path, file_bytes)
    return storage_path

def insert_document_row(document_id: str, storage_path: str):
    supabase.table("documents").insert({
        "id": document_id,
        "storage_path": storage_path,
        "status": "pending",
    }).execute()

def update_document_status(document_id: str, status: str):
    supabase.table("documents").update({"status": status}).eq("id", document_id).execute()

def write_report(document_id: str, similarity_score: float, top_matches: list, summary_text: str):
    supabase.table("reports").insert({
        "document_id": document_id,
        "similarity_score": similarity_score,
        "top_matches": top_matches,
        "summary_text": summary_text,
    }).execute()
```

### The /analyze endpoint — background processing without a separate job queue
For Phase 1, FastAPI's built-in `BackgroundTasks` is enough — you don't need Celery/Redis yet. Upgrade to a real task queue only if you outgrow this (multiple concurrent users, need retries).

```python
# main.py
from fastapi import FastAPI, UploadFile, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
import uuid

from supabase_client import upload_draft, insert_document_row, update_document_status
from pipeline import run_pipeline

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten to your Flutter app's actual origin before shipping
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/api/v1/analyze")
async def analyze(file: UploadFile, background_tasks: BackgroundTasks):
    document_id = str(uuid.uuid4())
    contents = await file.read()
    storage_path = f"{document_id}_{file.filename}"

    upload_draft(contents, storage_path)
    insert_document_row(document_id, storage_path)

    background_tasks.add_task(run_pipeline, document_id, contents)
    return {"document_id": document_id}
```

```python
# pipeline.py — the actual Phase 1 pipeline, run in the background
from supabase_client import update_document_status, write_report
from services.parser import parse_document
from services.retrieval import search_prior_art
from services.embeddings import embed_sentences
from services.scoring import cosine_similarity_pct
from services.llm import summarize

def run_pipeline(document_id: str, file_bytes: bytes):
    try:
        update_document_status(document_id, "processing")

        text = parse_document(file_bytes)
        candidates = search_prior_art(text)
        user_vec = embed_sentences([text])[0]
        candidate_vecs = embed_sentences([c["abstract"] for c in candidates])

        scored = [
            {**c, "similarity": cosine_similarity_pct(user_vec, v)}
            for c, v in zip(candidates, candidate_vecs)
        ]
        scored.sort(key=lambda x: x["similarity"], reverse=True)
        top_matches = scored[:5]
        overall_score = top_matches[0]["similarity"] if top_matches else 0

        summary = summarize(overall_score, top_matches)
        write_report(document_id, overall_score, top_matches, summary)
        update_document_status(document_id, "completed")
    except Exception as e:
        update_document_status(document_id, "failed")
        raise
```

### Dockerfile (for your FastAPI backend — this is what actually gets deployed)
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### docker-compose.yml (local dev — no Postgres container, Supabase is remote)
```yaml
services:
  api:
    build: .
    ports:
      - "8000:8000"
    env_file: .env
    depends_on:
      - ollama

  ollama:
    image: ollama/ollama
    volumes:
      - ollama_data:/root/.ollama
    ports:
      - "11434:11434"

volumes:
  ollama_data:
```

---

## 6. Phase 1 database schema (run in the Supabase SQL editor, not locally)

```sql
create table projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  title text not null,
  created_at timestamptz default now()
);

create table documents (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id),
  storage_path text not null,
  status text default 'pending', -- pending | processing | completed | failed
  created_at timestamptz default now()
);

create table reports (
  id uuid primary key default gen_random_uuid(),
  document_id uuid references documents(id),
  similarity_score numeric,
  top_matches jsonb,        -- array of {patent_id, title, similarity, excerpt}
  summary_text text,
  created_at timestamptz default now()
);

create extension if not exists vector;

create table document_vectors (
  id uuid primary key default gen_random_uuid(),
  document_id uuid references documents(id),
  sentence text not null,
  embedding vector(1024),
  created_at timestamptz default now()
);
create index on document_vectors using ivfflat (embedding vector_cosine_ops);
```

For Phase 1, `project_id` on `documents` can be nullable and auth can be skipped entirely — add real Supabase Auth (email/password or magic link) once the pipeline itself works, not before.

---

## 7. Phase 1 REST API spec (served by your FastAPI backend)

```
POST /api/v1/analyze
  body: multipart file upload (PDF/DOCX)
  → uploads to Supabase Storage, creates a document row, kicks off background processing, returns {document_id}

GET /api/v1/status/{document_id}
  → returns {status: "pending"|"processing"|"completed"|"failed"}

GET /api/v1/report/{document_id}
  → returns {similarity_score, top_matches[], summary_text}
```

---

## 8. Environment variables (.env template)

```
SUPABASE_URL=
SUPABASE_SERVICE_ROLE_KEY=
PQAI_API_KEY=
GROQ_API_KEY=
OLLAMA_HOST=http://localhost:11434
```

---

## 9. Deployment plan

- **Supabase (Postgres + pgvector + Storage + Auth):** fully hosted on Supabase's own free tier. Nothing to deploy, nothing to run yourself — just configure it via their dashboard/SQL editor.
- **FastAPI backend (your code):** deploy the Docker image from §5 to an Oracle Cloud Always Free ARM instance (currently 2 OCPU / 12GB — note this was cut down from 4 OCPU/24GB in mid-2026, so don't assume it stays fixed long-term).
- **ML inference (Docling parsing, PaECTER embedding):** keep this OFF the same box as the FastAPI backend — run it as a separate service (e.g. a Hugging Face Space on the free CPU tier, or a small dedicated worker) so it doesn't compete with your API for RAM.
- **LLM:** Groq hosted (primary) + local Ollama on the same Oracle box as FastAPI (fallback only, small 3B model — see §4H).

---

## 10. Phase 2 (build only after Phase 1 works end-to-end)

- Add BAAI `bge-reranker-v2-m3` (`pip install FlagEmbedding`) to filter false-positive prior-art matches before scoring.
- Add Copydetect (`pip install copydetect`) for a k-gram/Winnowing-based Uniqueness Score.
- Add the dual-pane sentence-level heatmap UI (left: user's draft with highlighted overlaps; right: matching prior-art excerpt on tap).
- Add real Supabase Auth (email/password or magic link) and lock down Row Level Security policies so users only see their own projects/reports.

## 11. Phase 3 (stretch — treat as R&D, not a guaranteed feature)

- Investigate whether Novelpy's bibliometric co-occurrence methods can be adapted for single-document novelty scoring, or design a custom lighter-weight novelty heuristic (e.g. rarity-weighted concept overlap against the retrieved corpus). Prototype this separately before wiring it into the main pipeline.
- Add the six-gauge dashboard, Patent Potential composite score (weighted Novelty 40% / Uniqueness 30% / inverted Similarity 30%), and full confidence rating (High/Medium/Low).

---

## 12. Instruction to the coding agent

Build **only Phase 1** first, in this order: (1) Supabase schema from §6, (2) FastAPI backend from §5 with the pipeline stubbed to real calls per §4, (3) minimal Flutter upload+report screen. When done: run it end-to-end on one sample PDF, show me the report output, and stop. Do not proceed to Phase 2 until I confirm Phase 1 works.
