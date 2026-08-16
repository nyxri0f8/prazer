import '../models/user_profile.dart';

abstract class AuthRepository {
  /// Signs in the user with Google OAuth via Supabase
  Future<UserProfile> signInWithGoogle();

  /// Retrieves the current active user session, if any
  Future<UserProfile?> getCurrentUser();

  /// Updates the user's profile metadata
  Future<UserProfile> updateProfile(UserProfile profile);

  /// Signs the user out
  Future<void> signOut();
}
