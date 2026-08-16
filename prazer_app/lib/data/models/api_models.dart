/// Data Transfer Objects for Phase 3 API Serialization/Deserialization

class AnalyzeResponseDto {
  final String documentId;
  final String fileName;
  final String status;

  AnalyzeResponseDto({
    required this.documentId,
    required this.fileName,
    required this.status,
  });

  factory AnalyzeResponseDto.fromJson(Map<String, dynamic> json) {
    return AnalyzeResponseDto(
      documentId: json['document_id'] as String,
      fileName: json['file_name'] as String? ?? 'uploaded_draft.pdf',
      status: json['status'] as String? ?? 'pending',
    );
  }
}

class StatusResponseDto {
  final String documentId;
  final String status;
  final String? errorMessage;

  StatusResponseDto({
    required this.documentId,
    required this.status,
    this.errorMessage,
  });

  factory StatusResponseDto.fromJson(Map<String, dynamic> json) {
    return StatusResponseDto(
      documentId: json['document_id'] as String,
      status: json['status'] as String,
      errorMessage: json['error_message'] as String?,
    );
  }
}

class PatentMatchDto {
  final String patentId;
  final String title;
  final double similarity;
  final String excerpt;
  final String publicationDate;
  final String patentOffice;
  final String? url;
  final double? rerankerScore;

  PatentMatchDto({
    required this.patentId,
    required this.title,
    required this.similarity,
    required this.excerpt,
    required this.publicationDate,
    required this.patentOffice,
    this.url,
    this.rerankerScore,
  });

  factory PatentMatchDto.fromJson(Map<String, dynamic> json) {
    return PatentMatchDto(
      patentId: json['patent_id'] as String? ?? 'US-UNKNOWN',
      title: json['title'] as String? ?? 'Prior Art Patent',
      similarity: (json['similarity'] as num?)?.toDouble() ?? 0.0,
      excerpt: json['excerpt'] as String? ?? '',
      publicationDate: json['publication_date'] as String? ?? '2023-01-01',
      patentOffice: json['patent_office'] as String? ?? 'USPTO',
      url: json['url'] as String?,
      rerankerScore: (json['reranker_score'] as num?)?.toDouble(),
    );
  }
}

class SentenceOverlapDto {
  final int sentenceIndex;
  final String text;
  final double overlapPct;
  final String matchedPatentId;
  final String matchedPatentTitle;
  final String matchedExcerpt;

  SentenceOverlapDto({
    required this.sentenceIndex,
    required this.text,
    required this.overlapPct,
    required this.matchedPatentId,
    required this.matchedPatentTitle,
    required this.matchedExcerpt,
  });

  factory SentenceOverlapDto.fromJson(Map<String, dynamic> json) {
    return SentenceOverlapDto(
      sentenceIndex: json['sentence_index'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      overlapPct: (json['overlap_pct'] as num?)?.toDouble() ?? 0.0,
      matchedPatentId: json['matched_patent_id'] as String? ?? '',
      matchedPatentTitle: json['matched_patent_title'] as String? ?? '',
      matchedExcerpt: json['matched_excerpt'] as String? ?? '',
    );
  }
}

class ReportResponseDto {
  final String documentId;
  final double similarityScore;
  final double uniquenessScore;
  final double noveltyScore;
  final double patentPotential;
  final String confidenceRating;
  final double technicalSpecificity;
  final double corpusDensity;
  final List<PatentMatchDto> topMatches;
  final List<SentenceOverlapDto> sentenceOverlaps;
  final String summaryText;
  final String disclaimer;

  ReportResponseDto({
    required this.documentId,
    required this.similarityScore,
    required this.uniquenessScore,
    required this.noveltyScore,
    required this.patentPotential,
    required this.confidenceRating,
    required this.technicalSpecificity,
    required this.corpusDensity,
    required this.topMatches,
    required this.sentenceOverlaps,
    required this.summaryText,
    required this.disclaimer,
  });

  factory ReportResponseDto.fromJson(Map<String, dynamic> json) {
    final matchesList = json['top_matches'] as List<dynamic>? ?? [];
    final overlapsList = json['sentence_overlaps'] as List<dynamic>? ?? [];

    return ReportResponseDto(
      documentId: json['document_id'] as String,
      similarityScore: (json['similarity_score'] as num?)?.toDouble() ?? 0.0,
      uniquenessScore: (json['uniqueness_score'] as num?)?.toDouble() ?? 85.0,
      noveltyScore: (json['novelty_score'] as num?)?.toDouble() ?? 82.0,
      patentPotential: (json['patent_potential'] as num?)?.toDouble() ?? 78.5,
      confidenceRating: json['confidence_rating'] as String? ?? 'High',
      technicalSpecificity: (json['technical_specificity'] as num?)?.toDouble() ?? 88.0,
      corpusDensity: (json['corpus_density'] as num?)?.toDouble() ?? 72.0,
      topMatches: matchesList
          .map((m) => PatentMatchDto.fromJson(m as Map<String, dynamic>))
          .toList(),
      sentenceOverlaps: overlapsList
          .map((s) => SentenceOverlapDto.fromJson(s as Map<String, dynamic>))
          .toList(),
      summaryText: json['summary_text'] as String? ?? '',
      disclaimer: json['disclaimer'] as String? ??
          'This is an automated estimate, not legal advice. Consult a registered patent attorney before filing.',
    );
  }
}
