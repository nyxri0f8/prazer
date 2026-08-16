import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/prazer_colors.dart';
import '../../../../core/theme/prazer_theme.dart';
import '../view_models/auth_view_model.dart';
import '../../profile_setup/views/profile_setup_view.dart';
import '../../../core/main_layout_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: PrazerTheme.heroGradient,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
        child: Column(
          children: [
            const Spacer(flex: 3),
            // Centered Branding
            Text(
              'PRAZER',
              style: GoogleFonts.montserrat(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                color: PrazerColors.alabasterGrey,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Autonomous Patent Prior-Art & Novelty Engine',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: PrazerColors.alabasterGrey.withOpacity(0.85),
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(flex: 3),

            // Error display if any
            if (viewModel.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: PrazerColors.grapefruitPink.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: PrazerColors.grapefruitPink.withOpacity(0.3)),
                ),
                child: Text(
                  viewModel.errorMessage!,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: PrazerColors.alabasterGrey,
                  ),
                ),
              ),

            // Google OAuth White Pill Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final user = await viewModel.signInWithGoogle();
                        if (user != null && context.mounted) {
                          if (!user.isProfileComplete) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => ProfileSetupView(user: user)),
                            );
                          } else {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const MainLayoutView()),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: PrazerColors.onyx,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: viewModel.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: PrazerColors.onyx,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF2F2F2),
                            ),
                            child: const Text(
                              'G',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4285F4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Continue with Google',
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: PrazerColors.onyx,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 18),

            // Mandatory disclaimer subtitle per §4.2
            Text(
              'By continuing you agree this tool provides estimates, not legal advice.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: PrazerColors.alabasterGrey.withOpacity(0.7),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
