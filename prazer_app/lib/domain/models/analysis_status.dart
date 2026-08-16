enum PipelineStage {
  idle,
  parsing,
  retrieval,
  vectorMath,
  llmSynthesis,
  completed,
  failed,
}

/// Domain status entity representing the live state of an analysis pipeline
class AnalysisStatus {
  final String documentId;
  final String status; // pending | processing | completed | failed
  final PipelineStage stage;
  final String? errorMessage;

  const AnalysisStatus({
    required this.documentId,
    required this.status,
    required this.stage,
    this.errorMessage,
  });

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isProcessing => status == 'processing' || status == 'pending';
}
