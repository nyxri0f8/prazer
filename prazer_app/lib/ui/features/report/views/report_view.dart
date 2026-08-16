import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/prazer_colors.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../core/widgets/score_gauge.dart';
import '../../../../core/widgets/disclaimer_banner.dart';
import '../../../../domain/models/analysis_report.dart';
import '../../../../domain/models/patent_match.dart';
import '../view_models/report_view_model.dart';
import '../widgets/dual_pane_heatmap.dart';
import '../widgets/six_gauge_dashboard.dart';

class ReportView extends StatelessWidget {
  final AnalysisReport report;

  const ReportView({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportViewModel(report),
      child: const _ReportContent(),
    );
  }
}

class _ReportContent extends StatefulWidget {
  const _ReportContent();

  @override
  State<_ReportContent> createState() => _ReportContentState();
}

class _ReportContentState extends State<_ReportContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ReportViewModel>(context);
    final report = viewModel.report;

    return Scaffold(
      backgroundColor: PrazerColors.alabasterGrey,
      appBar: AppBar(
        backgroundColor: PrazerColors.alabasterGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: PrazerColors.onyx, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Analysis Report (Phase 3)',
          style: GoogleFonts.montserrat(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: PrazerColors.onyx,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: PrazerColors.coolHorizon,
          indicatorWeight: 3,
          labelColor: PrazerColors.onyx,
          unselectedLabelColor: PrazerColors.blueSlate,
          labelStyle: GoogleFonts.montserrat(fontSize: 11.5, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 11.5, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: '6-Gauge Suite'),
            Tab(text: 'Heatmap'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Executive Overview & Matches
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dual Score Gauges (Similarity + Patent Potential)
                        BentoCard(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  ScoreGauge(
                                    score: report.patentPotential,
                                    size: 140,
                                    label: 'Patent Potential',
                                  ),
                                  Container(height: 100, width: 1, color: PrazerColors.borderSubtle),
                                  ScoreGauge(
                                    score: report.similarityScore,
                                    size: 140,
                                    label: 'Similarity',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    report.fileName,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: PrazerColors.onyx,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: PrazerColors.coolHorizon.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${report.confidenceRating} Confidence',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: PrazerColors.coolHorizon,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Executive Summary
                        BentoCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome_rounded, color: PrazerColors.coolHorizon, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Executive Summary',
                                    style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: PrazerColors.onyx),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                report.summaryText,
                                style: GoogleFonts.montserrat(fontSize: 13, color: PrazerColors.onyx, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Top Matching Patents
                        Text(
                          'Top Matching Prior Art',
                          style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: PrazerColors.onyx),
                        ),
                        const SizedBox(height: 10),

                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: report.topMatches.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, idx) {
                            final match = report.topMatches[idx];
                            final isExpanded = viewModel.isExpanded(match.patentId);
                            return _buildPatentCard(context, viewModel, match, isExpanded);
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Tab 2: Six-Gauge Analytics Suite (Phase 3)
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: SixGaugeDashboardWidget(metrics: report.metrics),
                  ),

                  // Tab 3: Dual-Pane Sentence Heatmap
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: DualPaneHeatmapWidget(
                      sentenceOverlaps: report.sentenceOverlaps,
                    ),
                  ),
                ],
              ),
            ),

            // Persistent Legal Disclaimer Banner
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: DisclaimerBanner(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatentCard(
    BuildContext context,
    ReportViewModel viewModel,
    PatentMatch match,
    bool isExpanded,
  ) {
    final badgeColor = match.similarity >= 70.0
        ? PrazerColors.grapefruitPink
        : PrazerColors.coolHorizon;

    return BentoCard(
      padding: const EdgeInsets.all(16),
      onTap: () => viewModel.toggleExpand(match.patentId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: PrazerColors.alabasterGrey, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  match.patentOffice,
                  style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w700, color: PrazerColors.blueSlate),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                match.patentId,
                style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: PrazerColors.blueSlate),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: badgeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  '${match.similarity.toStringAsFixed(1)}% match',
                  style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            match.title,
            style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: PrazerColors.onyx),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('Published: ${match.publicationDate}', style: GoogleFonts.montserrat(fontSize: 11, color: PrazerColors.blueSlate)),
              const Spacer(),
              Icon(
                isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: PrazerColors.blueSlate,
                size: 20,
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            const Divider(color: PrazerColors.borderSubtle),
            const SizedBox(height: 6),
            Text('Abstract / Claim Excerpt:', style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: PrazerColors.onyx)),
            const SizedBox(height: 4),
            Text(match.excerpt, style: GoogleFonts.montserrat(fontSize: 12, color: PrazerColors.blueSlate, height: 1.4)),
          ],
        ],
      ),
    );
  }
}
