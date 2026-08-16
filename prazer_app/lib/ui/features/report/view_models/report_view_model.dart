import 'package:flutter/material.dart';
import '../../../../domain/models/analysis_report.dart';

class ReportViewModel extends ChangeNotifier {
  final AnalysisReport _report;
  final Set<String> _expandedPatentIds = {};

  ReportViewModel(this._report);

  AnalysisReport get report => _report;

  bool isExpanded(String patentId) => _expandedPatentIds.contains(patentId);

  void toggleExpand(String patentId) {
    if (_expandedPatentIds.contains(patentId)) {
      _expandedPatentIds.remove(patentId);
    } else {
      _expandedPatentIds.add(patentId);
    }
    notifyListeners();
  }
}
