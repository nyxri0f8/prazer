import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/prazer_colors.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../domain/models/analysis_status.dart';
import '../../../../domain/use_cases/get_analysis_status_use_case.dart';
import '../../../../domain/use_cases/get_report_use_case.dart';
import '../view_models/processing_view_model.dart';
import '../../report/views/report_view.dart';

class ProcessingView extends StatelessWidget {
  final String documentId;
  final String fileName;

  const ProcessingView({
    super.key,
    required this.documentId,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ProcessingViewModel(
        documentId: documentId,
        fileName: fileName,
        getStatusUseCase: Provider.of<GetAnalysisStatusUseCase>(ctx, listen: false),
        getReportUseCase: Provider.of<GetReportUseCase>(ctx, listen: false),
      )..startPolling(),
      child: const _ProcessingContent(),
    );
  }
}

class _ProcessingContent extends StatelessWidget {
  const _ProcessingContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProcessingViewModel>(context);

    // Auto-advance to report once pipeline is completed
    if (viewModel.currentStage == PipelineStage.completed && viewModel.completedReport != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ReportView(report: viewModel.completedReport!),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: PrazerColors.alabasterGrey,
      appBar: AppBar(
        backgroundColor: PrazerColors.alabasterGrey,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Processing Pipeline',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: PrazerColors.onyx,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analyzing Invention Claims',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: PrazerColors.onyx,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Document: ${viewModel.fileName}',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: PrazerColors.blueSlate,
                ),
              ),
              const SizedBox(height: 32),

              // Vertical Stepper Bento Card
              Expanded(
                child: BentoCard(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStepItem(
                        stage: PipelineStage.parsing,
                        currentStage: viewModel.currentStage,
                        icon: Icons.article_outlined,
                        title: '1. Parsing',
                        description: 'Extracting sentence-level claims with Docling parser.',
                      ),
                      _buildDivider(stage: PipelineStage.parsing, currentStage: viewModel.currentStage),
                      _buildStepItem(
                        stage: PipelineStage.retrieval,
                        currentStage: viewModel.currentStage,
                        icon: Icons.search_rounded,
                        title: '2. Retrieval',
                        description: 'Querying PQAI database across 68 patent offices.',
                      ),
                      _buildDivider(stage: PipelineStage.retrieval, currentStage: viewModel.currentStage),
                      _buildStepItem(
                        stage: PipelineStage.vectorMath,
                        currentStage: viewModel.currentStage,
                        icon: Icons.calculate_outlined,
                        title: '3. Vector Math',
                        description: 'Computing PaECTER 1024-dim embeddings & SciPy cosine similarity.',
                      ),
                      _buildDivider(stage: PipelineStage.vectorMath, currentStage: viewModel.currentStage),
                      _buildStepItem(
                        stage: PipelineStage.llmSynthesis,
                        currentStage: viewModel.currentStage,
                        icon: Icons.auto_awesome_outlined,
                        title: '4. LLM Synthesis',
                        description: 'Synthesizing objective plain-English summary via Groq LLaMA 3.3.',
                      ),
                    ],
                  ),
                ),
              ),

              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    viewModel.errorMessage!,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: PrazerColors.grapefruitPink,
                    ),
                  ),
                ),

              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Please do not close the window while calculations run.',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: PrazerColors.blueSlate,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required PipelineStage stage,
    required PipelineStage currentStage,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final bool isCompleted = currentStage.index > stage.index;
    final bool isActive = currentStage == stage;

    Color iconColor;
    Color titleColor;
    Widget statusIcon;

    if (isCompleted) {
      iconColor = PrazerColors.coolHorizon;
      titleColor = PrazerColors.onyx;
      statusIcon = const Icon(Icons.check_circle_rounded, color: PrazerColors.coolHorizon, size: 22);
    } else if (isActive) {
      iconColor = PrazerColors.coolHorizon;
      titleColor = PrazerColors.onyx;
      statusIcon = const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2.2, color: PrazerColors.coolHorizon),
      );
    } else {
      iconColor = PrazerColors.blueSlate.withOpacity(0.5);
      titleColor = PrazerColors.blueSlate.withOpacity(0.7);
      statusIcon = Icon(Icons.radio_button_unchecked_rounded, color: PrazerColors.blueSlate.withOpacity(0.3), size: 20);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive ? PrazerColors.coolHorizon.withOpacity(0.12) : PrazerColors.alabasterGrey.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: PrazerColors.blueSlate,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        statusIcon,
      ],
    );
  }

  Widget _buildDivider({required PipelineStage stage, required PipelineStage currentStage}) {
    final bool isPassed = currentStage.index > stage.index;
    return Container(
      margin: const EdgeInsets.only(left: 20),
      height: 18,
      width: 2,
      color: isPassed ? PrazerColors.coolHorizon : PrazerColors.borderSubtle,
    );
  }
}
