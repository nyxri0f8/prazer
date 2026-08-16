import '../models/analysis_status.dart';
import '../repositories/analysis_repository.dart';

class GetAnalysisStatusUseCase {
  final AnalysisRepository _repository;

  GetAnalysisStatusUseCase(this._repository);

  Future<AnalysisStatus> execute(String documentId) async {
    return await _repository.getAnalysisStatus(documentId);
  }
}
