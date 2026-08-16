import 'package:flutter/material.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../../domain/repositories/auth_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _saveMessage;
  String? get saveMessage => _saveMessage;

  SettingsViewModel(this._authRepository);

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _authRepository.getCurrentUser() ??
          const UserProfile(
            id: 'usr-local',
            email: 'inventor@prazer.ai',
            fullName: 'Alex Vance',
            role: 'Independent Inventor',
            organization: 'Prazer Labs',
            primaryDomain: 'Artificial Intelligence',
          );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateName(String name) {
    if (_profile != null) {
      _profile = _profile!.copyWith(fullName: name);
      notifyListeners();
    }
  }

  void updateRole(String role) {
    if (_profile != null) {
      _profile = _profile!.copyWith(role: role);
      notifyListeners();
    }
  }

  void updateOrganization(String organization) {
    if (_profile != null) {
      _profile = _profile!.copyWith(organization: organization);
      notifyListeners();
    }
  }

  void updatePrimaryDomain(String domain) {
    if (_profile != null) {
      _profile = _profile!.copyWith(primaryDomain: domain);
      notifyListeners();
    }
  }

  Future<void> saveProfile() async {
    if (_profile == null) return;
    _isSaving = true;
    _saveMessage = null;
    notifyListeners();

    try {
      _profile = await _authRepository.updateProfile(_profile!);
      _saveMessage = "Profile updated successfully.";
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
