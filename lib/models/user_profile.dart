class UserProfile {
  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final String themePreference;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    required this.themePreference,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      themePreference: json['theme_preference'] as String? ?? 'system',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'theme_preference': themePreference,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? themePreference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      themePreference: themePreference ?? this.themePreference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, fullName: $fullName, '
        'avatarUrl: $avatarUrl, themePreference: $themePreference, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.avatarUrl == avatarUrl &&
        other.themePreference == themePreference &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        fullName.hashCode ^
        avatarUrl.hashCode ^
        themePreference.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
