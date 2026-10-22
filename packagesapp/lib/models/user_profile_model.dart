class UserProfileModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String theme;
  final String createdAt;

  const UserProfileModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.theme = 'system',
    required this.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['uid'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      theme: json['theme'] as String? ?? 'system',
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'theme': theme,
        'createdAt': createdAt,
      };

  UserProfileModel copyWith({
    String? displayName,
    String? photoUrl,
    String? theme,
  }) {
    return UserProfileModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      theme: theme ?? this.theme,
      createdAt: createdAt,
    );
  }
}
