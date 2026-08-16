import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/prazer_colors.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../view_models/profile_setup_view_model.dart';
import '../../../core/main_layout_view.dart';

class ProfileSetupView extends StatelessWidget {
  final UserProfile user;

  const ProfileSetupView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ProfileSetupViewModel(
        Provider.of<AuthRepository>(ctx, listen: false),
        user,
      ),
      child: const _ProfileSetupContent(),
    );
  }
}

class _ProfileSetupContent extends StatefulWidget {
  const _ProfileSetupContent();

  @override
  State<_ProfileSetupContent> createState() => _ProfileSetupContentState();
}

class _ProfileSetupContentState extends State<_ProfileSetupContent> {
  late TextEditingController _nameController;
  late TextEditingController _orgController;
  late TextEditingController _domainController;

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<ProfileSetupViewModel>(context, listen: false);
    _nameController = TextEditingController(text: vm.profile.fullName);
    _orgController = TextEditingController(text: vm.profile.organization);
    _domainController = TextEditingController(text: vm.profile.primaryDomain);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orgController.dispose();
    _domainController.dispose();
    super.dispose();
  }

  void _proceedToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainLayoutView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfileSetupViewModel>(context);

    return Scaffold(
      backgroundColor: PrazerColors.alabasterGrey,
      appBar: AppBar(
        backgroundColor: PrazerColors.alabasterGrey,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _proceedToDashboard,
            child: Text(
              'Skip for now',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: PrazerColors.blueSlate,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complete Your Profile',
                style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: PrazerColors.onyx,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Configure your research domain to tailor prior-art analytics.',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: PrazerColors.blueSlate,
                ),
              ),
              const SizedBox(height: 32),

              // Full Name
              _buildFieldLabel('Full Name'),
              TextField(
                controller: _nameController,
                onChanged: viewModel.updateName,
                decoration: const InputDecoration(
                  hintText: 'e.g. Alex Vance',
                ),
              ),
              const SizedBox(height: 20),

              // Role Dropdown
              _buildFieldLabel('Role / Affiliation'),
              DropdownButtonFormField<String>(
                value: viewModel.profile.role,
                items: UserProfile.availableRoles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(
                      role,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: PrazerColors.onyx,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) viewModel.updateRole(val);
                },
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 20),

              // Organization
              _buildFieldLabel('Institution / Organization (Optional)'),
              TextField(
                controller: _orgController,
                onChanged: viewModel.updateOrganization,
                decoration: const InputDecoration(
                  hintText: 'e.g. Stanford University or Stealth Startup',
                ),
              ),
              const SizedBox(height: 20),

              // Primary Domain of Work
              _buildFieldLabel('Primary Domain of Work'),
              TextField(
                controller: _domainController,
                onChanged: viewModel.updatePrimaryDomain,
                decoration: const InputDecoration(
                  hintText: 'e.g. Electronics, Biotech, Machine Learning',
                ),
              ),
              const SizedBox(height: 36),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: viewModel.isValid && !viewModel.isSubmitting
                      ? () async {
                          await viewModel.saveProfile();
                          if (context.mounted) _proceedToDashboard();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PrazerColors.coolHorizon,
                    disabledBackgroundColor: PrazerColors.coolHorizon.withOpacity(0.4),
                  ),
                  child: viewModel.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Continue',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: PrazerColors.onyx,
        ),
      ),
    );
  }
}
