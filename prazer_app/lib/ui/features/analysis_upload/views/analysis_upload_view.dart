import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/prazer_colors.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../domain/use_cases/submit_analysis_use_case.dart';
import '../view_models/analysis_upload_view_model.dart';
import '../../processing/views/processing_view.dart';

class AnalysisUploadView extends StatelessWidget {
  const AnalysisUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => AnalysisUploadViewModel(
        Provider.of<SubmitAnalysisUseCase>(ctx, listen: false),
      ),
      child: const _AnalysisUploadContent(),
    );
  }
}

class _AnalysisUploadContent extends StatelessWidget {
  const _AnalysisUploadContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AnalysisUploadViewModel>(context);

    return Scaffold(
      backgroundColor: PrazerColors.alabasterGrey,
      appBar: AppBar(
        backgroundColor: PrazerColors.alabasterGrey,
        elevation: 0,
        title: Text(
          'New Prior-Art Analysis',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: PrazerColors.onyx,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Invention Disclosure',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: PrazerColors.onyx,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Supported formats: PDF, DOCX (up to 25MB). The document is parsed with layout-aware Docling extraction.',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: PrazerColors.blueSlate,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Drag and drop zone with dashed Blue Slate border
              Expanded(
                child: BentoCard(
                  padding: const EdgeInsets.all(32),
                  onTap: viewModel.isUploading ? null : viewModel.pickFile,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: PrazerColors.coolHorizon.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_upload_outlined,
                            size: 48,
                            color: PrazerColors.coolHorizon,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Drag and drop patent draft here',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: PrazerColors.onyx,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'or tap to browse files on your device',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: PrazerColors.blueSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Selected file chip
              if (viewModel.selectedFile != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PrazerColors.coolHorizon),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: PrazerColors.coolHorizon,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.selectedFile!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: PrazerColors.onyx,
                              ),
                            ),
                            Text(
                              '${(viewModel.selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: PrazerColors.blueSlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20, color: PrazerColors.blueSlate),
                        onPressed: viewModel.clearSelection,
                      ),
                    ],
                  ),
                ),

              // Error display
              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
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

              // "Analyze" full-width button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (viewModel.selectedFile != null && !viewModel.isUploading)
                      ? () async {
                          final docId = await viewModel.submitForAnalysis();
                          if (docId != null && context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProcessingView(
                                  documentId: docId,
                                  fileName: viewModel.selectedFile!.name,
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PrazerColors.coolHorizon,
                    disabledBackgroundColor: PrazerColors.coolHorizon.withOpacity(0.4),
                  ),
                  child: viewModel.isUploading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'Analyzing…',
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Analyze',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
