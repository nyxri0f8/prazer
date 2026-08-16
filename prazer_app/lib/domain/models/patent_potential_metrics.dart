/// Domain entity representing the Six-Gauge Analytics Suite and Confidence Rating
class PatentPotentialMetrics {
  final double patentPotential; // Composite (Novelty 40% + Uniqueness 30% + Inverted Similarity 30%)
  final double noveltyScore;
  final double uniquenessScore;
  final double similarityScore;
  final double technicalSpecificity;
  final double corpusDensity;
  final String confidenceRating; // 'High' | 'Medium' | 'Low'

  const PatentPotentialMetrics({
    required this.patentPotential,
    required this.noveltyScore,
    required this.uniquenessScore,
    required this.similarityScore,
    required this.technicalSpecificity,
    required this.corpusDensity,
    required this.confidenceRating,
  });

  bool get isHighPotential => patentPotential >= 75.0;
  bool get isHighConfidence => confidenceRating == 'High';
}
