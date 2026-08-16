import 'package:flutter/material.dart';
import '../../../../domain/models/analysis_report.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../../domain/repositories/analysis_repository.dart';
import '../../../../domain/repositories/auth_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final AnalysisRepository _analysisRepository;
  final AuthRepository _authRepository;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  UserProfile? _user;
  UserProfile? get user => _user;

  List<AnalysisReport> _recentReports = [];
  List<AnalysisReport> get recentReports => _recentReports;

  DashboardViewModel(this._analysisRepository, this._authRepository);

  String get greeting {
    final hour = DateTime.now().hour;
    final name = _user?.fullName.split(' ').first ?? 'Inventor';
    if (hour < 12) {
      return 'Good morning, $name';
    } else if (hour < 17) {
      return 'Good afternoon, $name';
    } else {
      return 'Good evening, $name';
    }
  }

  int get totalAnalyses => _recentReports.length;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authRepository.getCurrentUser();
      _recentReports = await _analysisRepository.getReportHistory();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
