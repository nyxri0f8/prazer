import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../domain/use_cases/submit_analysis_use_case.dart';

class AnalysisUploadViewModel extends ChangeNotifier {
  final SubmitAnalysisUseCase _submitAnalysisUseCase;

  PlatformFile? _selectedFile;
  PlatformFile? get selectedFile => _selectedFile;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AnalysisUploadViewModel(this._submitAnalysisUseCase);

  Future<void> pickFile() async {
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        _selectedFile = result.files.first;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Unable to select file. Please try again.";
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedFile = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<String?> submitForAnalysis() async {
    if (_selectedFile == null) {
      _errorMessage = "Please select a PDF or DOCX draft file to analyze.";
      notifyListeners();
      return null;
    }

    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final bytes = _selectedFile!.bytes ?? Uint8List(0);
      final docId = await _submitAnalysisUseCase.execute(
        fileBytes: bytes,
        fileName: _selectedFile!.name,
      );
      return docId;
    } catch (e) {
      _errorMessage = "Upload failed — check your connection and try again.";
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
