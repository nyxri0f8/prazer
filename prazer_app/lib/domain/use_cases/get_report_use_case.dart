import '../models/analysis_report.dart';
import '../repositories/analysis_repository.dart';

class GetReportUseCase {
  final AnalysisRepository _repository;

  GetReportUseCase(this._repository);

  Future<AnalysisReport> execute(String documentId) async {
    return await _repository.getAnalysisReport(documentId);
  }
}
