import 'package:flutter/material.dart';
import '../../../../domain/repositories/auth_repository.dart';

class SplashViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  SplashViewModel(this._authRepository);

  Future<bool> checkAuthSession() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final user = await _authRepository.getCurrentUser();
    _isLoading = false;
    notifyListeners();
    return user != null;
  }
}
