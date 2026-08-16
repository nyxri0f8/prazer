import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/prazer_colors.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../core/widgets/score_gauge.dart';
import '../../../../domain/models/patent_potential_metrics.dart';

/// Phase 3 Six-Gauge Analytics Suite Widget
class SixGaugeDashboardWidget extends StatelessWidget {
  final PatentPotentialMetrics metrics;

  const SixGaugeDashboardWidget({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Card: Patent Potential & Confidence Rating
        BentoCard(
          backgroundColor: PrazerColors.coolHorizon,
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PATENT POTENTIAL INDEX',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${metrics.confidenceRating} Confidence',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    '${metrics.patentPotential.toStringAsFixed(1)}%',
                    style: GoogleFonts.montserrat(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      'Weighted Composite: Novelty (40%) + Uniqueness (30%) + Non-Overlap (30%)',
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.92),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Section Title
        Text(
          'Six-Dimension Analytical Breakdown',
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: PrazerColors.onyx,
          ),
        ),
        const SizedBox(height: 10),

        // 6-Gauge Bento Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
          children: [
            // Gauge 1: Novelty Score
            _buildGaugeCard(
              title: 'Novelty Score',
              score: metrics.noveltyScore,
              subtitle: 'Concept Combinatorial Rarity',
              color: PrazerColors.coolHorizon,
            ),

            // Gauge 2: Uniqueness Score
            _buildGaugeCard(
              title: 'Uniqueness',
              score: metrics.uniquenessScore,
              subtitle: 'Winnowing Claim Footprint',
              color: PrazerColors.coolHorizon,
            ),

            // Gauge 3: Similarity Overlap
            _buildGaugeCard(
              title: 'Similarity Overlap',
              score: metrics.similarityScore,
              subtitle: 'Cosine Distance vs Prior Art',
              color: metrics.similarityScore >= 70 ? PrazerColors.grapefruitPink : PrazerColors.coolHorizon,
            ),

            // Gauge 4: Technical Specificity
            _buildGaugeCard(
              title: 'Technical Depth',
              score: metrics.technicalSpecificity,
              subtitle: 'Claim Lexical Density Index',
              color: PrazerColors.coolHorizon,
            ),

            // Gauge 5: Corpus Density
            _buildGaugeCard(
              title: 'Corpus Density',
              score: metrics.corpusDensity,
              subtitle: 'Global Index Saturation',
              color: PrazerColors.blueSlate,
            ),

            // Gauge 6: Inverted Overlap (Clean Space)
            _buildGaugeCard(
              title: 'Differentiated Space',
              score: 100.0 - metrics.similarityScore,
              subtitle: 'Novel Unclaimed White Space',
              color: PrazerColors.coolHorizon,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGaugeCard({
    required String title,
    required double score,
    required String subtitle,
    required Color color,
  }) {
    return BentoCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScoreGauge(
            score: score,
            size: 95,
            label: '',
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: PrazerColors.onyx,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 9.5,
              color: PrazerColors.blueSlate,
            ),
          ),
        ],
      ),
    );
  }
}
