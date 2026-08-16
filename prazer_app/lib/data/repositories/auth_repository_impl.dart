import '../../domain/models/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/supabase_auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthService _authService;
  UserProfile? _currentUser;

  AuthRepositoryImpl({SupabaseAuthService? authService})
      : _authService = authService ?? SupabaseAuthService();

  @override
  Future<UserProfile> signInWithGoogle() async {
    final profile = await _authService.signInWithGoogle();
    _currentUser = profile;
    return profile;
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    _currentUser = await _authService.getCurrentUser();
    return _currentUser;
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    _currentUser = profile.copyWith(isProfileComplete: true);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
  }
}
