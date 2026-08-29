class AppUser {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.provider,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? provider;

  String get welcomeName {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final mail = email?.trim();
    if (mail != null && mail.isNotEmpty) return mail;
    return 'there';
  }
}

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.provider,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String name;
  final String email;
  final String provider;
  final String? photoUrl;
  final int? createdAt;
  final int? updatedAt;

  factory UserProfile.fromMap(Map<Object?, Object?> data) {
    return UserProfile(
      uid: data['uid'] as String? ?? '',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      provider: data['provider'] as String? ?? 'password',
      photoUrl: data['photoUrl'] as String?,
      createdAt: _asInt(data['createdAt']),
      updatedAt: _asInt(data['updatedAt']),
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }
}
