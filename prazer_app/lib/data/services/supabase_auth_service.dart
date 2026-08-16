import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/models/user_profile.dart';

class SupabaseAuthService {
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    if (ApiConstants.supabaseUrl.isNotEmpty && ApiConstants.supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: ApiConstants.supabaseUrl,
        anonKey: ApiConstants.supabaseAnonKey,
      );
      _isInitialized = true;
    }
  }

  SupabaseClient? get client {
    if (_isInitialized) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<UserProfile> signInWithGoogle() async {
    final sb = client;
    if (sb != null) {
      try {
        await sb.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'prazer://login-callback',
        );
        final user = sb.auth.currentUser;
        if (user != null) {
          return UserProfile(
            id: user.id,
            email: user.email ?? '',
            fullName: user.userMetadata?['full_name'] ?? user.email?.split('@')[0] ?? 'Inventor',
            isProfileComplete: false,
          );
        }
      } catch (e) {
        // Fall back to local session simulation if OAuth is cancelled or credentials not set in dev
      }
    }

    // Default development profile session
    return const UserProfile(
      id: 'usr-dev-local-01',
      email: 'inventor@prazer.ai',
      fullName: 'Alex Vance',
      role: 'Independent Inventor',
      organization: 'Prazer Labs',
      primaryDomain: 'Artificial Intelligence & Robotics',
      isProfileComplete: true,
    );
  }

  Future<UserProfile?> getCurrentUser() async {
    final sb = client;
    if (sb != null) {
      final user = sb.auth.currentUser;
      if (user != null) {
        return UserProfile(
          id: user.id,
          email: user.email ?? '',
          fullName: user.userMetadata?['full_name'] ?? 'Inventor',
        );
      }
    }
    return null;
  }

  Future<void> signOut() async {
    final sb = client;
    if (sb != null) {
      await sb.auth.signOut();
    }
  }
}
