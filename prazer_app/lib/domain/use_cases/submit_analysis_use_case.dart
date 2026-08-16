import '../repositories/analysis_repository.dart';

class SubmitAnalysisUseCase {
  final AnalysisRepository _repository;

  SubmitAnalysisUseCase(this._repository);

  Future<String> execute({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    if (fileBytes.isEmpty) {
      throw ArgumentError("Cannot analyze an empty file.");
    }
    return await _repository.submitAnalysis(
      fileBytes: fileBytes,
      fileName: fileName,
    );
  }
}
