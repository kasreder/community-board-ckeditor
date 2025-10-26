class UserSummary {
  const UserSummary({
    required this.id,
    required this.nickname,
    required this.score,
    this.email,
    this.avatarUrl,
  });

  final int id;
  final String nickname;
  final int score;
  final String? email;
  final String? avatarUrl;

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] as int,
      nickname: json['nickname'] as String? ?? json['name'] as String? ?? '사용자',
      score: json['score'] is int
          ? json['score'] as int
          : int.tryParse('${json['score']}') ?? 0,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'score': score,
      'email': email,
      'avatar_url': avatarUrl,
    };
  }

  UserSummary copyWith({
    String? nickname,
    int? score,
    String? email,
    String? avatarUrl,
  }) {
    return UserSummary(
      id: id,
      nickname: nickname ?? this.nickname,
      score: score ?? this.score,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class CurrentUser extends UserSummary {
  const CurrentUser({
    required super.id,
    required super.nickname,
    required super.score,
    super.email,
    super.avatarUrl,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: json['id'] as int,
      nickname: json['nickname'] as String? ?? json['name'] as String? ?? '사용자',
      score: json['score'] is int
          ? json['score'] as int
          : int.tryParse('${json['score']}') ?? 0,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
