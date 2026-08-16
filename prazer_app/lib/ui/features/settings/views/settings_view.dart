import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/prazer_colors.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../domain/models/user_profile.dart';
import '../view_models/settings_view_model.dart';
import '../../auth/views/login_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SettingsViewModel>(context, listen: false).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SettingsViewModel>(context);

    if (viewModel.isLoading || viewModel.profile == null) {
      return const Scaffold(
        backgroundColor: PrazerColors.alabasterGrey,
        body: Center(
          child: CircularProgressIndicator(color: PrazerColors.coolHorizon),
        ),
      );
    }

    final profile = viewModel.profile!;

    return Scaffold(
      backgroundColor: PrazerColors.alabasterGrey,
      appBar: AppBar(
        backgroundColor: PrazerColors.alabasterGrey,
        elevation: 0,
        title: Text(
          'Settings & Profile',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: PrazerColors.onyx,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Edit Card
              BentoCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Details',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: PrazerColors.onyx,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email (Read only)
                    Text(
                      'Email Address',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: PrazerColors.blueSlate,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: PrazerColors.onyx,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: PrazerColors.borderSubtle),
                    const SizedBox(height: 16),

                    // Name
                    _buildLabel('Full Name'),
                    TextFormField(
                      initialValue: profile.fullName,
                      onChanged: viewModel.updateName,
                    ),
                    const SizedBox(height: 16),

                    // Role
                    _buildLabel('Role'),
                    DropdownButtonFormField<String>(
                      value: profile.role,
                      items: UserProfile.availableRoles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role, style: GoogleFonts.montserrat(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) viewModel.updateRole(val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Organization
                    _buildLabel('Institution / Organization'),
                    TextFormField(
                      initialValue: profile.organization,
                      onChanged: viewModel.updateOrganization,
                    ),
                    const SizedBox(height: 16),

                    // Primary Domain
                    _buildLabel('Primary Domain of Work'),
                    TextFormField(
                      initialValue: profile.primaryDomain,
                      onChanged: viewModel.updatePrimaryDomain,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: viewModel.isSaving ? null : viewModel.saveProfile,
                        child: viewModel.isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Save Changes'),
                      ),
                    ),

                    if (viewModel.saveMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Center(
                          child: Text(
                            viewModel.saveMessage!,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: PrazerColors.coolHorizon,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sign Out Button (Grapefruit Pink text, no fill per §4.9)
              BentoCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                onTap: () async {
                  await viewModel.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginView()),
                      (route) => false,
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: PrazerColors.grapefruitPink,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sign Out',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: PrazerColors.grapefruitPink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // App Version Footer per §4.9
              Center(
                child: Column(
                  children: [
                    Text(
                      'PRAZER v1.0.0 (Phase 1 MVP)',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PrazerColors.blueSlate.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Open-Source Deterministic Prior-Art & Novelty Engine',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: PrazerColors.blueSlate.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: PrazerColors.onyx,
        ),
      ),
    );
  }
}
