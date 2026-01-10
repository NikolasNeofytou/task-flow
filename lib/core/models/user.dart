class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.avatar,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? avatar;
  final DateTime? createdAt;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'avatar': avatar,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      avatar: json['avatar'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
