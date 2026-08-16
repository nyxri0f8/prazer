import '../models/analysis_report.dart';

/// Clean use case for exporting an Analysis Report to Markdown or formatted text
class ExportReportUseCase {
  String exportMarkdown(AnalysisReport report) {
    final buffer = StringBuffer();
    buffer.writeln('# PRAZER — Patent Prior-Art & Novelty Appraisal Report');
    buffer.writeln('**Document:** `${report.fileName}` | **Confidence:** `${report.confidenceRating}`\n');
    buffer.writeln('---');
    buffer.writeln('## 1. Executive Analytics Summary\n');
    buffer.writeln('| Metric | Score | Description |');
    buffer.writeln('| :--- | :--- | :--- |');
    buffer.writeln('| **Patent Potential Composite** | **${report.patentPotential.toStringAsFixed(1)}%** | Weighted: Novelty (40%) + Uniqueness (30%) + Non-Overlap (30%) |');
    buffer.writeln('| **Novelty Score** | **${report.noveltyScore.toStringAsFixed(1)}%** | Concept Co-occurrence Rarity |');
    buffer.writeln('| **Uniqueness Score** | **${report.uniquenessScore.toStringAsFixed(1)}%** | Winnowing Token Fingerprint Isolation |');
    buffer.writeln('| **Similarity Overlap** | **${report.similarityScore.toStringAsFixed(1)}%** | PaECTER Vector Cosine Distance |');
    buffer.writeln('| **Technical Depth** | **${report.technicalSpecificity.toStringAsFixed(1)}%** | Claim Lexical & Functional Depth |');
    buffer.writeln('| **Corpus Density** | **${report.corpusDensity.toStringAsFixed(1)}%** | Prior-Art Saturation Index |\n');

    buffer.writeln('### Plain-English Synthesis');
    buffer.writeln('> ${report.summaryText}\n');
    buffer.writeln('---');
    buffer.writeln('## 2. Top Matching Prior Art\n');

    for (var i = 0; i < report.topMatches.length; i++) {
      final m = report.topMatches[i];
      buffer.writeln('### ${i + 1}. ${m.title} (`${m.patentOffice} ${m.patentId}`) — **${m.similarity.toStringAsFixed(1)}% Match**');
      buffer.writeln('- **Published:** ${m.publicationDate}');
      buffer.writeln('- **Excerpt:** "${m.excerpt}"\n');
    }

    buffer.writeln('---');
    buffer.writeln('> [!IMPORTANT]');
    buffer.writeln('> **Disclaimer:** ${report.disclaimer}');

    return buffer.toString();
  }
}
