class ApiConstants {
  // Backend base URL (default local development host)
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  // Endpoints
  static const String analyzeEndpoint = '/api/v1/analyze';
  static const String statusEndpoint = '/api/v1/status';
  static const String reportEndpoint = '/api/v1/report';

  // Supabase Config (Live Cloud Instance)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://quggxkvvfrunewpsijdn.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF1Z2d4a3Z2ZnJ1bmV3cHNpamRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY4ODM2NDUsImV4cCI6MjEwMjQ1OTY0NX0.1FN5Un4jq4HddrrNkNXEcQ0gyRyjgdi3m8jB122kaAM',
  );

  // PQAI Neural Search Engine (Hugging Face ZeroGPU Cloud)
  static const String pqaiCloudUrl = String.fromEnvironment(
    'PQAI_API_URL',
    defaultValue: 'https://nyxvarun-prazer-pqai.hf.space',
  );

  // Legal Disclaimer
  static const String legalDisclaimer =
      'This is an automated estimate, not legal advice. Consult a registered patent attorney before filing.';
}
