import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/prazer_colors.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../domain/models/sentence_overlap.dart';

/// Interactive dual-pane sentence heatmap viewer adhering to Phase 2 spec
class DualPaneHeatmapWidget extends StatefulWidget {
  final List<SentenceOverlap> sentenceOverlaps;

  const DualPaneHeatmapWidget({super.key, required this.sentenceOverlaps});

  @override
  State<DualPaneHeatmapWidget> createState() => _DualPaneHeatmapWidgetState();
}

class _DualPaneHeatmapWidgetState extends State<DualPaneHeatmapWidget> {
  int _selectedSentenceIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.sentenceOverlaps.isEmpty) {
      return const BentoCard(
        child: Center(
          child: Text('No sentence overlap data available for this document.'),
        ),
      );
    }

    final selectedOverlap = widget.sentenceOverlaps.firstWhere(
      (s) => s.sentenceIndex == _selectedSentenceIndex,
      orElse: () => widget.sentenceOverlaps.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heatmap Legend
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: PrazerColors.borderSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem(PrazerColors.grapefruitPink, 'High Overlap (≥70%)'),
              _buildLegendItem(PrazerColors.coolHorizon, 'Moderate Overlap (35–69%)'),
              _buildLegendItem(PrazerColors.alabasterGrey, 'Novel / Unique (<35%)'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Dual Pane Layout (Responsive Split View)
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 650;

            final leftPane = BentoCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description_outlined, size: 16, color: PrazerColors.blueSlate),
                      const SizedBox(width: 6),
                      Text(
                        'User Draft Claims (Tap sentence to inspect)',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: PrazerColors.onyx,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 4,
                    runSpacing: 8,
                    children: widget.sentenceOverlaps.map((overlap) {
                      final isSelected = overlap.sentenceIndex == _selectedSentenceIndex;
                      final highlightColor = _getHighlightColor(overlap.overlapPct);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSentenceIndex = overlap.sentenceIndex;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: highlightColor.withOpacity(isSelected ? 0.35 : 0.18),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? PrazerColors.onyx : highlightColor,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            overlap.text,
                            style: GoogleFonts.montserrat(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: PrazerColors.onyx,
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );

            final rightPane = BentoCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.link_rounded, size: 16, color: PrazerColors.coolHorizon),
                          const SizedBox(width: 6),
                          Text(
                            'Matched Prior-Art Excerpt',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: PrazerColors.onyx,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getHighlightColor(selectedOverlap.overlapPct).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${selectedOverlap.overlapPct.toStringAsFixed(1)}% overlap',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _getHighlightColor(selectedOverlap.overlapPct),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: PrazerColors.alabasterGrey,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      selectedOverlap.matchedPatentId,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: PrazerColors.blueSlate,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedOverlap.matchedPatentTitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: PrazerColors.onyx,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: PrazerColors.borderSubtle),
                  const SizedBox(height: 6),
                  Text(
                    'Prior-Art Excerpt:',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: PrazerColors.blueSlate,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PrazerColors.alabasterGrey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: PrazerColors.borderSubtle),
                    ),
                    child: Text(
                      selectedOverlap.matchedExcerpt,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: PrazerColors.onyx,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: leftPane),
                  const SizedBox(width: 14),
                  Expanded(flex: 2, child: rightPane),
                ],
              );
            } else {
              return Column(
                children: [
                  leftPane,
                  const SizedBox(height: 14),
                  rightPane,
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Color _getHighlightColor(double overlap) {
    if (overlap >= 70.0) {
      return PrazerColors.grapefruitPink;
    } else if (overlap >= 35.0) {
      return PrazerColors.coolHorizon;
    } else {
      return PrazerColors.blueSlate.withOpacity(0.5);
    }
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: PrazerColors.blueSlate,
          ),
        ),
      ],
    );
  }
}
