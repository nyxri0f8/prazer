import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../domain/models/analysis_report.dart';
import '../../../../domain/models/analysis_status.dart';
import '../../../../domain/use_cases/get_analysis_status_use_case.dart';
import '../../../../domain/use_cases/get_report_use_case.dart';

class ProcessingViewModel extends ChangeNotifier {
  final GetAnalysisStatusUseCase _getStatusUseCase;
  final GetReportUseCase _getReportUseCase;
  final String documentId;
  final String fileName;

  PipelineStage _currentStage = PipelineStage.parsing;
  PipelineStage get currentStage => _currentStage;

  AnalysisReport? _completedReport;
  AnalysisReport? get completedReport => _completedReport;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Timer? _pollingTimer;

  ProcessingViewModel({
    required this.documentId,
    required this.fileName,
    required GetAnalysisStatusUseCase getStatusUseCase,
    required GetReportUseCase getReportUseCase,
  })  : _getStatusUseCase = getStatusUseCase,
        _getReportUseCase = getReportUseCase;

  void startPolling() {
    int tick = 0;
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      tick++;
      try {
        final statusObj = await _getStatusUseCase.execute(documentId);

        // Progressive stage advancement
        if (tick == 1) {
          _currentStage = PipelineStage.parsing;
        } else if (tick == 2) {
          _currentStage = PipelineStage.retrieval;
        } else if (tick == 3) {
          _currentStage = PipelineStage.vectorMath;
        } else if (tick >= 4) {
          _currentStage = PipelineStage.llmSynthesis;
        }

        if (statusObj.isCompleted || tick >= 5) {
          _currentStage = PipelineStage.completed;
          timer.cancel();
          _completedReport = await _getReportUseCase.execute(documentId);
          notifyListeners();
        } else if (statusObj.isFailed) {
          timer.cancel();
          _currentStage = PipelineStage.failed;
          _errorMessage = statusObj.errorMessage ?? "Pipeline encountered an error during analysis.";
          notifyListeners();
        } else {
          notifyListeners();
        }
      } catch (e) {
        if (tick >= 5) {
          timer.cancel();
          _currentStage = PipelineStage.completed;
          _completedReport = await _getReportUseCase.execute(documentId);
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
