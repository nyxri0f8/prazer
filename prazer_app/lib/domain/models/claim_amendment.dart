/// Clean domain model for AI-generated Claim Optimization options
class ClaimOptimization {
  final String strategy; // 'Narrowing Limitation' | 'Functional Protocol' | 'Combinatorial Coupling'
  final String suggestedText;
  final double estimatedOverlap;
  final String noveltyBoost;

  const ClaimOptimization({
    required this.strategy,
    required this.suggestedText,
    required this.estimatedOverlap,
    required this.noveltyBoost,
  });
}

/// Clean domain model for statutory compliance across USPTO, EPO, and WIPO
class JurisdictionScreening {
  final String usptoStatute102;
  final double usptoStatute103Obviousness;
  final String epoArticle54Novelty;
  final String epoArticle56InventiveStep;
  final String wipoPctOutlook;

  const JurisdictionScreening({
    required this.usptoStatute102,
    required this.usptoStatute103Obviousness,
    required this.epoArticle54Novelty,
    required this.epoArticle56InventiveStep,
    required this.wipoPctOutlook,
  });
}
