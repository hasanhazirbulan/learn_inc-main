class Teacher {
  final String id;
  final String fullName;
  final String email;
  final String subject;
  final String profileImage;
  final String assignedClass;

  Teacher({
    required this.id,
    required this.fullName,
    required this.email,
    required this.subject,
    required this.profileImage,
    this.assignedClass = '',
  });

  Map<String, dynamic> toJson() {
    return {
      "FullName": fullName,
      "Email": email,
      "Subject": subject,
      "ProfileImage": profileImage,
      "AssignedClass": assignedClass,
    };
  }

  static Teacher fromJson(Map<String, dynamic> json, String id) {
    return Teacher(
      id: id,
      fullName: json['FullName'] ?? '',
      email: json['Email'] ?? '',
      subject: json['Subject'] ?? '',
      profileImage: json['ProfileImage'] ?? 'assets/avatars/default.png',
      assignedClass: json['AssignedClass'] ?? '',
    );
  }
}