import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/api_models.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
                headers: {
                  'Accept': 'application/json',
                },
              ),
            );

  /// Submits draft file bytes to POST /api/v1/analyze
  Future<AnalyzeResponseDto> submitAnalysis({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        ApiConstants.analyzeEndpoint,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        return AnalyzeResponseDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to submit document. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Polls status via GET /api/v1/status/{document_id}
  Future<StatusResponseDto> getStatus(String documentId) async {
    try {
      final response = await _dio.get('${ApiConstants.statusEndpoint}/$documentId');
      if (response.statusCode == 200) {
        return StatusResponseDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Status check failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves report via GET /api/v1/report/{document_id}
  Future<ReportResponseDto> getReport(String documentId) async {
    try {
      final response = await _dio.get('${ApiConstants.reportEndpoint}/$documentId');
      if (response.statusCode == 200) {
        return ReportResponseDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to retrieve report: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
