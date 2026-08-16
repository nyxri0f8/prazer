-- PRAZER: Supabase Postgres & pgvector Schema (Phase 1 MVP)

-- 1. Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- 2. Projects table
CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Documents table
CREATE TABLE IF NOT EXISTS documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  storage_path TEXT NOT NULL,
  file_name TEXT,
  file_size BIGINT,
  mime_type TEXT,
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending' | 'processing' | 'completed' | 'failed'
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Reports table
CREATE TABLE IF NOT EXISTS reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
  similarity_score NUMERIC NOT NULL,
  top_matches JSONB NOT NULL DEFAULT '[]'::jsonb, -- array of {patent_id, title, similarity, excerpt, publication_date, patent_office}
  summary_text TEXT NOT NULL,
  disclaimer TEXT NOT NULL DEFAULT 'This is an automated estimate, not legal advice. Consult a registered patent attorney before filing.',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. Document sentence vectors table (PaECTER 1024 dimensions)
CREATE TABLE IF NOT EXISTS document_vectors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
  sentence TEXT NOT NULL,
  sentence_index INT NOT NULL DEFAULT 0,
  embedding VECTOR(1024),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 6. Cosine similarity index on sentence embeddings
CREATE INDEX IF NOT EXISTS document_vectors_embedding_idx 
ON document_vectors USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- 7. User profiles table (synced with Supabase Auth)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  role TEXT, -- 'Student' | 'Independent Inventor' | 'Founder' | 'Attorney' | 'Other'
  organization TEXT,
  primary_domain TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
