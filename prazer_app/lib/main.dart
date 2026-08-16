import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/prazer_theme.dart';
import 'data/services/api_service.dart';
import 'data/services/supabase_auth_service.dart';
import 'data/repositories/analysis_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/analysis_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/use_cases/submit_analysis_use_case.dart';
import 'domain/use_cases/get_report_use_case.dart';
import 'domain/use_cases/get_analysis_status_use_case.dart';
import 'ui/features/splash/view_models/splash_view_model.dart';
import 'ui/features/splash/views/splash_view.dart';
import 'ui/features/auth/view_models/auth_view_model.dart';
import 'ui/features/dashboard/view_models/dashboard_view_model.dart';
import 'ui/features/history/view_models/history_view_model.dart';
import 'ui/features/settings/view_models/settings_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Services
  final apiService = ApiService();
  final authService = SupabaseAuthService();
  await authService.initialize();

  // 2. Initialize Repositories
  final analysisRepository = AnalysisRepositoryImpl(apiService: apiService);
  final authRepository = AuthRepositoryImpl(authService: authService);

  // 3. Initialize Use Cases
  final submitAnalysisUseCase = SubmitAnalysisUseCase(analysisRepository);
  final getReportUseCase = GetReportUseCase(analysisRepository);
  final getAnalysisStatusUseCase = GetAnalysisStatusUseCase(analysisRepository);

  runApp(
    MultiProvider(
      providers: [
        // Repositories
        Provider<AnalysisRepository>.value(value: analysisRepository),
        Provider<AuthRepository>.value(value: authRepository),

        // Use Cases
        Provider<SubmitAnalysisUseCase>.value(value: submitAnalysisUseCase),
        Provider<GetReportUseCase>.value(value: getReportUseCase),
        Provider<GetAnalysisStatusUseCase>.value(value: getAnalysisStatusUseCase),

        // ViewModels
        ChangeNotifierProvider(create: (_) => SplashViewModel(authRepository)),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepository)),
        ChangeNotifierProvider(create: (_) => DashboardViewModel(analysisRepository, authRepository)),
        ChangeNotifierProvider(create: (_) => HistoryViewModel(analysisRepository)),
        ChangeNotifierProvider(create: (_) => SettingsViewModel(authRepository)),
      ],
      child: const PrazerApp(),
    ),
  );
}

class PrazerApp extends StatelessWidget {
  const PrazerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PRAZER — Patent Appraisal & Prior-Art Engine',
      debugShowCheckedModeBanner: false,
      theme: PrazerTheme.themeData,
      home: Consumer<SplashViewModel>(
        builder: (ctx, vm, _) => SplashView(viewModel: vm),
      ),
    );
  }
}
