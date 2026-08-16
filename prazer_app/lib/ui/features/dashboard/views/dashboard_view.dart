import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/prazer_colors.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../domain/models/analysis_report.dart';
import '../view_models/dashboard_view_model.dart';
import '../../report/views/report_view.dart';

class DashboardView extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const DashboardView({super.key, this.onNavigateTab});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(context, listen: false).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);

    if (viewModel.isLoading) {
      return const Scaffold(
        backgroundColor: PrazerColors.alabasterGrey,
        body: Center(
          child: CircularProgressIndicator(color: PrazerColors.coolHorizon),
        ),
      );
    }

    return Scaffold(
      backgroundColor: PrazerColors.alabasterGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting header (NOT a card per §4.4)
              Text(
                viewModel.greeting,
                style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: PrazerColors.onyx,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Deterministic Patent Prior-Art & Novelty Overview',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: PrazerColors.blueSlate,
                ),
              ),
              const SizedBox(height: 24),

              // 1. High-Emphasis Card: New Analysis (2x2, Cool Horizon Fill)
              BentoCard(
                backgroundColor: PrazerColors.coolHorizon,
                padding: const EdgeInsets.all(24),
                borderRadius: 18,
                onTap: () => widget.onNavigateTab?.call(1),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_chart_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start New Analysis',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Upload invention draft (PDF/DOCX) for mathematical prior-art evaluation.',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. Stats & Trend Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Analyses (1x1, Papaya Whip tint)
                  Expanded(
                    flex: 1,
                    child: BentoCard(
                      backgroundColor: PrazerColors.papayaWhip,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${viewModel.totalAnalyses}',
                            style: GoogleFonts.montserrat(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: PrazerColors.onyx,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Analyses run',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: PrazerColors.onyx.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Top Prior-Art Sources (1x1, small bar chart)
                  Expanded(
                    flex: 1,
                    child: BentoCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Top Offices',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: PrazerColors.onyx,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 60,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 10,
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (val, _) {
                                        const labels = ['USPTO', 'EPO', 'WIPO'];
                                        if (val.toInt() >= 0 && val.toInt() < labels.length) {
                                          return Text(
                                            labels[val.toInt()],
                                            style: GoogleFonts.montserrat(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                              color: PrazerColors.blueSlate,
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                barGroups: [
                                  BarChartGroupData(x: 0, barRods: [
                                    BarChartRodData(toY: 7, color: PrazerColors.grapefruitPink, width: 14, borderRadius: BorderRadius.circular(4))
                                  ]),
                                  BarChartGroupData(x: 1, barRods: [
                                    BarChartRodData(toY: 4, color: PrazerColors.grapefruitPink, width: 14, borderRadius: BorderRadius.circular(4))
                                  ]),
                                  BarChartGroupData(x: 2, barRods: [
                                    BarChartRodData(toY: 5, color: PrazerColors.grapefruitPink, width: 14, borderRadius: BorderRadius.circular(4))
                                  ]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Similarity Trend (2x1, line chart)
              BentoCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Similarity Trend',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: PrazerColors.onyx,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: PrazerColors.coolHorizon.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Avg: 41.5%',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: PrazerColors.coolHorizon,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: PrazerColors.borderSubtle,
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: 6,
                          minY: 0,
                          maxY: 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 28),
                                FlSpot(1, 34),
                                FlSpot(2, 62),
                                FlSpot(3, 41),
                                FlSpot(4, 55),
                                FlSpot(5, 38),
                                FlSpot(6, 42),
                              ],
                              isCurved: true,
                              color: PrazerColors.coolHorizon,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: PrazerColors.coolHorizon.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 4. Recent Reports (2x1 compact list)
              BentoCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Reports',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: PrazerColors.onyx,
                          ),
                        ),
                        if (viewModel.recentReports.isNotEmpty)
                          GestureDetector(
                            onTap: () => widget.onNavigateTab?.call(2),
                            child: Text(
                              'View all',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: PrazerColors.coolHorizon,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (viewModel.recentReports.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.description_outlined,
                                size: 32,
                                color: PrazerColors.blueSlate,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No analyses yet',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: PrazerColors.onyx,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Run your first prior-art check to see it here.',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: PrazerColors.blueSlate,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: viewModel.recentReports.take(3).length,
                        separatorBuilder: (_, __) => const Divider(color: PrazerColors.borderSubtle),
                        itemBuilder: (ctx, idx) {
                          final report = viewModel.recentReports[idx];
                          return _buildReportItem(context, report);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, AnalysisReport report) {
    final badgeColor = report.isHighOverlap
        ? PrazerColors.grapefruitPink
        : PrazerColors.coolHorizon;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReportView(report: report)),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PrazerColors.onyx,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${report.topMatches.length} prior-art candidates matched',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: PrazerColors.blueSlate,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${report.similarityScore.toStringAsFixed(1)}%',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
