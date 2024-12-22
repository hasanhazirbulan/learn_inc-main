class Student {
  final String id;
  final String fullName;
  final String email;
  final int grade;
  final String profileImage;
  final int points;
  final int lives;
  final int streakDays;
  final String enrolledCourses;

  Student({
    required this.id,
    required this.fullName,
    required this.email,
    required this.grade,
    required this.profileImage,
    this.points = 0,
    this.lives = 3,
    this.streakDays = 0,
    this.enrolledCourses= '',
  });

  Map<String, dynamic> toJson() {
    return {
      "FullName": fullName,
      "Email": email,
      "Grade": grade,
      "ProfileImage": profileImage,
      "Points": points,
      "Lives": lives,
      "StreakDays": streakDays,
      "EnrolledCourses": enrolledCourses,
    };
  }

  static Student fromJson(Map<String, dynamic> json, String id) {
    return Student(
      id: id,
      fullName: json['FullName'] ?? '',
      email: json['Email'] ?? '',
      grade: json['Grade'] ?? 0,
      profileImage: json['ProfileImage'] ?? 'assets/avatars/default.png',
      points: json['Points'] ?? 0,
      lives: json['Lives'] ?? 3,
      streakDays: json['StreakDays'] ?? 0,
      enrolledCourses: json['EnrolledCourses'] ?? '',
    );
  }
}
