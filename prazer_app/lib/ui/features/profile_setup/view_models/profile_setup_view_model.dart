import 'package:flutter/material.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../../domain/repositories/auth_repository.dart';

class ProfileSetupViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  UserProfile _profile;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  ProfileSetupViewModel(this._authRepository, this._profile);

  UserProfile get profile => _profile;

  void updateName(String name) {
    _profile = _profile.copyWith(fullName: name);
    notifyListeners();
  }

  void updateRole(String role) {
    _profile = _profile.copyWith(role: role);
    notifyListeners();
  }

  void updateOrganization(String organization) {
    _profile = _profile.copyWith(organization: organization);
    notifyListeners();
  }

  void updatePrimaryDomain(String domain) {
    _profile = _profile.copyWith(primaryDomain: domain);
    notifyListeners();
  }

  bool get isValid => _profile.fullName.trim().isNotEmpty && _profile.primaryDomain.trim().isNotEmpty;

  Future<void> saveProfile() async {
    if (!isValid) return;
    _isSubmitting = true;
    notifyListeners();
    try {
      await _authRepository.updateProfile(_profile);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
