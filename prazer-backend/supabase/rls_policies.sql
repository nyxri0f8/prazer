-- PRAZER: Row Level Security (RLS) Policies (Phase 2)

-- 1. Enable RLS on all tables
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_vectors ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 2. Projects RLS Policies
CREATE POLICY "Users can select own projects"
ON projects FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own projects"
ON projects FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own projects"
ON projects FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own projects"
ON projects FOR DELETE
USING (auth.uid() = user_id);

-- 3. Documents RLS Policies
CREATE POLICY "Users can access documents belonging to their projects"
ON documents FOR ALL
USING (
  project_id IN (
    SELECT id FROM projects WHERE user_id = auth.uid()
  ) OR auth.jwt() ->> 'role' = 'service_role'
);

-- 4. Reports RLS Policies
CREATE POLICY "Users can access reports for their documents"
ON reports FOR ALL
USING (
  document_id IN (
    SELECT d.id FROM documents d
    JOIN projects p ON d.project_id = p.id
    WHERE p.user_id = auth.uid()
  ) OR auth.jwt() ->> 'role' = 'service_role'
);

-- 5. Document Vectors RLS Policies
CREATE POLICY "Vectors accessible only by owner or trusted backend service role"
ON document_vectors FOR ALL
USING (
  document_id IN (
    SELECT d.id FROM documents d
    JOIN projects p ON d.project_id = p.id
    WHERE p.user_id = auth.uid()
  ) OR auth.jwt() ->> 'role' = 'service_role'
);

-- 6. User Profiles RLS Policies
CREATE POLICY "Users can view and update own profile"
ON profiles FOR ALL
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);
