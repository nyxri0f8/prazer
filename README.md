# PRAZER — Autonomous Patent Prior-Art & Novelty Engine

PRAZER is an end-to-end intelligent patent analytics, prior-art search, and novelty evaluation platform with **Indian Patent Office (IPO / InPASS)** #1 priority statutory legal screening, USPTO, EPO, and WIPO compliance.

---

## 🏛️ System Architecture

- **Neural Search Engine:** PyTorch transformer embeddings (`sentence-transformers/all-MiniLM-L6-v2`) on Hugging Face ZeroGPU.
- **Indian Patent Compliance:** Section 2(1)(j), Section 3(k) CRI clearance, and Rule 24C / Form 18A fast-track screening.
- **Vector Database:** 1024-dimensional PaECTER embeddings stored in Supabase Cloud `pgvector`.
- **LLM Reasoning:** Groq LLaMA 3.3 70B Versatile for automated claim formulation and legal briefing.
- **Client App:** Multi-page PDF dossier generator, live OCR parsing, and inline claim heatmap.
- **Android Mobile App:** Flutter cross-platform mobile client (`prazer_app/`).

---

## 📦 Automated Android APK Build

This repository includes a GitHub Actions workflow in [`.github/workflows/build-apk.yml`](.github/workflows/build-apk.yml) that automatically builds the Android `.apk` package in the cloud on every push.

---

## ⚖️ Legal Notice

PRAZER provides automated prior-art estimations and statistical novelty analysis. It does not constitute formal legal counsel.
