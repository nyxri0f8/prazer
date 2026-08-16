import '../models/analysis_report.dart';
import '../models/analysis_status.dart';

abstract class AnalysisRepository {
  /// Uploads a document draft file and kicks off the background analysis
  Future<String> submitAnalysis({
    required List<int> fileBytes,
    required String fileName,
  });

  /// Polls the processing status of a submitted document
  Future<AnalysisStatus> getAnalysisStatus(String documentId);

  /// Retrieves the finalized report for a document
  Future<AnalysisReport> getAnalysisReport(String documentId);

  /// Retrieves all cached or persisted user analysis reports
  Future<List<AnalysisReport>> getReportHistory();
}
