import 'patent_match.dart';
import 'sentence_overlap.dart';
import 'patent_potential_metrics.dart';

/// Clean domain model representing a completed Phase 3 prior-art analysis report
class AnalysisReport {
  final String documentId;
  final String fileName;
  final double similarityScore;
  final double uniquenessScore;
  final double noveltyScore;
  final double patentPotential;
  final String confidenceRating;
  final double technicalSpecificity;
  final double corpusDensity;
  final List<PatentMatch> topMatches;
  final List<SentenceOverlap> sentenceOverlaps;
  final String summaryText;
  final String disclaimer;
  final DateTime createdAt;

  const AnalysisReport({
    required this.documentId,
    required this.fileName,
    required this.similarityScore,
    this.uniquenessScore = 85.0,
    this.noveltyScore = 82.0,
    this.patentPotential = 78.5,
    this.confidenceRating = 'High',
    this.technicalSpecificity = 88.0,
    this.corpusDensity = 72.0,
    required this.topMatches,
    this.sentenceOverlaps = const [],
    required this.summaryText,
    required this.disclaimer,
    required this.createdAt,
  });

  bool get isHighOverlap => similarityScore >= 70.0;
  bool get isLowOverlap => similarityScore < 35.0;
  bool get isHighlyUnique => uniquenessScore >= 75.0;
  bool get isHighPatentPotential => patentPotential >= 75.0;

  PatentPotentialMetrics get metrics => PatentPotentialMetrics(
        patentPotential: patentPotential,
        noveltyScore: noveltyScore,
        uniquenessScore: uniquenessScore,
        similarityScore: similarityScore,
        technicalSpecificity: technicalSpecificity,
        corpusDensity: corpusDensity,
        confidenceRating: confidenceRating,
      );
}
