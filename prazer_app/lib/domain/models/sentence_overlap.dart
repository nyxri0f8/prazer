/// Domain model for sentence-level overlap in the dual-pane heatmap
class SentenceOverlap {
  final int sentenceIndex;
  final String text;
  final double overlapPct;
  final String matchedPatentId;
  final String matchedPatentTitle;
  final String matchedExcerpt;

  const SentenceOverlap({
    required this.sentenceIndex,
    required this.text,
    required this.overlapPct,
    required this.matchedPatentId,
    required this.matchedPatentTitle,
    required this.matchedExcerpt,
  });

  bool get isHighOverlap => overlapPct >= 70.0;
  bool get isModerateOverlap => overlapPct >= 35.0 && overlapPct < 70.0;
  bool get isLowOverlap => overlapPct < 35.0;
}
