import 'package:flutter/material.dart';
import '../../../../domain/models/analysis_report.dart';
import '../../../../domain/repositories/analysis_repository.dart';

class HistoryViewModel extends ChangeNotifier {
  final AnalysisRepository _analysisRepository;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<AnalysisReport> _reports = [];
  List<AnalysisReport> get reports => _reports;

  HistoryViewModel(this._analysisRepository);

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _reports = await _analysisRepository.getReportHistory();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
