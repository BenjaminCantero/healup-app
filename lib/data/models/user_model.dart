class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final UserProfileModel? profile;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['fullName'] as String,
        role: json['role'] as String,
        isActive: json['isActive'] as bool? ?? true,
        profile: json['profile'] != null
            ? UserProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
            : null,
      );
}

class UserProfileModel {
  final String? avatarUrl;
  final String? dateOfBirth;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? medicalNotes;

  const UserProfileModel({
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.medicalNotes,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        avatarUrl: json['avatarUrl'] as String?,
        dateOfBirth: json['dateOfBirth'] as String?,
        gender: json['gender'] as String?,
        heightCm: (json['heightCm'] as num?)?.toDouble(),
        weightKg: (json['weightKg'] as num?)?.toDouble(),
        medicalNotes: json['medicalNotes'] as String?,
      );
}

class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final tokens = data['tokens'] as Map<String, dynamic>?;
    return AuthResponse(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      accessToken: tokens?['accessToken'] as String? ?? data['accessToken'] as String,
      refreshToken: tokens?['refreshToken'] as String? ?? data['refreshToken'] as String,
    );
  }
}
