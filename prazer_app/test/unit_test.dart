import 'package:flutter_test/flutter_test.dart';
import 'package:prazer_app/domain/models/patent_match.dart';
import 'package:prazer_app/domain/models/analysis_report.dart';
import 'package:prazer_app/domain/models/user_profile.dart';
import 'package:prazer_app/data/repositories/analysis_repository_impl.dart';
import 'package:prazer_app/data/repositories/auth_repository_impl.dart';
import 'package:prazer_app/domain/use_cases/submit_analysis_use_case.dart';
import 'package:prazer_app/domain/use_cases/get_report_use_case.dart';

void main() {
  group('PRAZER Domain & Layered Architecture Tests', () {
    test('Domain Models instantiate and calculate overlap flags correctly', () {
      final match = PatentMatch(
        patentId: 'US-11482938-B2',
        title: 'Distributed Neural Indexing',
        similarity: 82.5,
        excerpt: 'Claims regarding vector cosine space...',
        publicationDate: '2024-03-12',
        patentOffice: 'USPTO',
      );

      final report = AnalysisReport(
        documentId: 'doc-123',
        fileName: 'Draft_Patent.pdf',
        similarityScore: 82.5,
        topMatches: [match],
        summaryText: 'Significant technical overlap detected.',
        disclaimer: 'This is an automated estimate, not legal advice.',
        createdAt: DateTime.now(),
      );

      expect(report.isHighOverlap, isTrue);
      expect(report.isLowOverlap, isFalse);
      expect(report.topMatches.length, 1);
      expect(report.topMatches.first.patentOffice, 'USPTO');
    });

    test('UserProfile role selection and copyWith work as expected', () {
      const user = UserProfile(
        id: 'usr-1',
        email: 'founder@domain.com',
        fullName: 'Jordan Lee',
        role: 'Founder',
      );

      final updated = user.copyWith(
        organization: 'Acro Robotics',
        primaryDomain: 'Autonomous Drones',
        isProfileComplete: true,
      );

      expect(updated.organization, 'Acro Robotics');
      expect(updated.primaryDomain, 'Autonomous Drones');
      expect(updated.isProfileComplete, isTrue);
    });

    test('SubmitAnalysisUseCase and AnalysisRepository handle submission and caching', () async {
      final repo = AnalysisRepositoryImpl();
      final submitUseCase = SubmitAnalysisUseCase(repo);
      final getReportUseCase = GetReportUseCase(repo);

      final fileBytes = [1, 2, 3, 4, 5];
      final docId = await submitUseCase.execute(
        fileBytes: fileBytes,
        fileName: 'novel_quantum_sensor.pdf',
      );

      expect(docId, isNotEmpty);

      final status = await repo.getAnalysisStatus(docId);
      expect(status.documentId, docId);

      final report = await getReportUseCase.execute(docId);
      expect(report.documentId, docId);
      expect(report.similarityScore, greaterThanOrEqualTo(0.0));

      final history = await repo.getReportHistory();
      expect(history.length, greaterThanOrEqualTo(1));
      expect(history.first.documentId, docId);
    });

    test('AuthRepositoryImpl handles session sign-in and profile updates', () async {
      final authRepo = AuthRepositoryImpl();
      final user = await authRepo.signInWithGoogle();

      expect(user.id, isNotEmpty);
      expect(user.email, isNotEmpty);

      final currentUser = await authRepo.getCurrentUser();
      expect(currentUser, isNotNull);
      expect(currentUser!.id, user.id);
    });
  });
}
