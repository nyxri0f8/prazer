/// Clean domain model for USPTO Form SB/08a (IDS) prior art citations
class IdsCitation {
  final int itemNumber;
  final String documentNumber;
  final String publicationDate;
  final String nameOfPatentee;
  final String relevantPassages;

  const IdsCitation({
    required this.itemNumber,
    required this.documentNumber,
    required this.publicationDate,
    required this.nameOfPatentee,
    required this.relevantPassages,
  });
}

/// Clean domain model for Portfolio White-Space Clustering Matrix point
class PortfolioPoint {
  final String id;
  final String name;
  final double similarity;
  final double novelty;
  final double patentPotential;
  final String clusterType; // 'Star' | 'Incremental' | 'Crowded' | 'White Space'

  const PortfolioPoint({
    required this.id,
    required this.name,
    required this.similarity,
    required this.novelty,
    required this.patentPotential,
    required this.clusterType,
  });
}
