import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/prazer_colors.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../domain/models/analysis_report.dart';
import '../view_models/history_view_model.dart';
import '../../report/views/report_view.dart';

class HistoryView extends StatefulWidget {
  final VoidCallback? onStartNewAnalysis;

  const HistoryView({super.key, this.onStartNewAnalysis});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryViewModel>(context, listen: false).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HistoryViewModel>(context);

    return Scaffold(
      backgroundColor: PrazerColors.alabasterGrey,
      appBar: AppBar(
        backgroundColor: PrazerColors.alabasterGrey,
        elevation: 0,
        title: Text(
          'Analysis History',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: PrazerColors.onyx,
          ),
        ),
      ),
      body: SafeArea(
        child: viewModel.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: PrazerColors.coolHorizon),
              )
            : viewModel.reports.isEmpty
                ? _buildEmptyState(context)
                : _buildHistoryList(context, viewModel.reports),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: PrazerColors.borderSubtle),
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 48,
                color: PrazerColors.blueSlate,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No analyses yet',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: PrazerColors.onyx,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Run your first prior-art check to see it here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: PrazerColors.blueSlate,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: widget.onStartNewAnalysis,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Start New Analysis'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<AnalysisReport> reports) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: reports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, idx) {
        final report = reports[idx];
        final badgeColor = report.isHighOverlap
            ? PrazerColors.grapefruitPink
            : PrazerColors.coolHorizon;

        return BentoCard(
          padding: const EdgeInsets.all(18),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ReportView(report: report)),
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.insert_drive_file_outlined,
                  color: badgeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: PrazerColors.onyx,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${report.topMatches.length} prior-art matches found',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: PrazerColors.blueSlate,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  const SizedBox(height: 4),
                  Text(
                    '${report.createdAt.month}/${report.createdAt.day}/${report.createdAt.year}',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      color: PrazerColors.blueSlate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
