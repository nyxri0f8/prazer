import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/prazer_colors.dart';
import '../../../../core/theme/prazer_theme.dart';
import '../view_models/splash_view_model.dart';
import '../../auth/views/login_view.dart';
import '../../../core/main_layout_view.dart';

class SplashView extends StatefulWidget {
  final SplashViewModel viewModel;

  const SplashView({super.key, required this.viewModel});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _handleRouting();
  }

  Future<void> _handleRouting() async {
    final hasSession = await widget.viewModel.checkAuthSession();
    if (!mounted) return;

    if (hasSession) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainLayoutView()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: PrazerTheme.heroGradient,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PRAZER',
                style: GoogleFonts.montserrat(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: PrazerColors.alabasterGrey,
                  letterSpacing: 4.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'PATENT PRIOR-ART & NOVELTY APPRAISAL',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: PrazerColors.alabasterGrey.withOpacity(0.8),
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
