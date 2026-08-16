/// User profile domain model for profile setup and settings screens
class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'Student' | 'Independent Inventor' | 'Founder' | 'Attorney' | 'Other'
  final String organization;
  final String primaryDomain;
  final bool isProfileComplete;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.role = 'Independent Inventor',
    this.organization = '',
    this.primaryDomain = '',
    this.isProfileComplete = false,
  });

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? organization,
    String? primaryDomain,
    bool? isProfileComplete,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      organization: organization ?? this.organization,
      primaryDomain: primaryDomain ?? this.primaryDomain,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  static const List<String> availableRoles = [
    'Student',
    'Independent Inventor',
    'Founder',
    'Attorney',
    'Other'
  ];
}
