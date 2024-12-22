class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String password;
  final String profileImage;
  final int points;
  final int lives;
  final int streakDays;

  const UserModel({
    this.id,
    required this.email,
    required this.password,
    required this.fullName,
    required this.profileImage,
    this.points = 0,
    this.lives = 3,
    this.streakDays = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      "FullName": fullName,
      "Email": email,
      "Password": password,
      "ProfileImage": profileImage,
      "Points": points,
      "Lives": lives,
      "StreakDays": streakDays,
    };
  }

  static UserModel fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      email: json['Email'] ?? '', // Default empty if null
      password: json['Password'] ?? '', // Default empty
      fullName: json['FullName'] ?? 'Unknown', // Default 'Unknown'
      profileImage: json['ProfileImage'] ?? 'assets/avatars/default.png', // Default avatar
      points: json['Points'] ?? 0,
      lives: json['Lives'] ?? 3,
      streakDays: json['StreakDays'] ?? 0,
    );
  }



  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? password,
    String? profileImage,
    int? points,
    int? lives,
    int? streakDays,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
      points: points ?? this.points,
      lives: lives ?? this.lives,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}
