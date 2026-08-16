/// Clean immutable domain model representing a matched prior-art patent
class PatentMatch {
  final String patentId;
  final String title;
  final double similarity;
  final String excerpt;
  final String publicationDate;
  final String patentOffice;
  final String? url;

  const PatentMatch({
    required this.patentId,
    required this.title,
    required this.similarity,
    required this.excerpt,
    required this.publicationDate,
    required this.patentOffice,
    this.url,
  });

  PatentMatch copyWith({
    String? patentId,
    String? title,
    double? similarity,
    String? excerpt,
    String? publicationDate,
    String? patentOffice,
    String? url,
  }) {
    return PatentMatch(
      patentId: patentId ?? this.patentId,
      title: title ?? this.title,
      similarity: similarity ?? this.similarity,
      excerpt: excerpt ?? this.excerpt,
      publicationDate: publicationDate ?? this.publicationDate,
      patentOffice: patentOffice ?? this.patentOffice,
      url: url ?? this.url,
    );
  }
}
