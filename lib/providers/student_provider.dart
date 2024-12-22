import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/student_model.dart';


class StudentProvider with ChangeNotifier {
  Student? _student;
  bool _isDayMode = true; // Default to day mode
  bool _isDataLoaded = false;

  // Getter for day mode
  bool get isDayMode => _isDayMode;

  // Getter for data loaded status
  bool get isDataLoaded => _isDataLoaded;

  // Getter for student
  Student? get student => _student;

  // Toggle day mode and notify listeners
  void toggleDayMode() {
    _isDayMode = !_isDayMode;
    notifyListeners();
  }

  Future<void> loadStudentData(String studentId) async {
    try {
      print("Fetching student data for ID: $studentId");

      // Set data loaded flag to false while fetching
      _isDataLoaded = false;
      notifyListeners();

      final studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(studentId)
          .get();

      if (studentDoc.exists) {
        final data = studentDoc.data();
        print("Student document found: $data");

        if (data == null) {
          print("Student document is null. This shouldn't happen.");
        } else {
          print("Validating fields in student document...");
          print("FullName: ${data['FullName']}");
          print("Email: ${data['Email']}");
          print("Grade: ${data['Grade']}");
          print("ProfileImage: ${data['ProfileImage']}");
          print("Points: ${data['Points']}");
          print("Lives: ${data['Lives']}");
          print("StreakDays: ${data['StreakDays']}");
          print("EnrolledCourses: ${data['EnrolledCourses']}");
        }

        // Parse the data into the Student model
        _student = Student.fromJson(data!, studentId);
        print("Student data successfully loaded.");
      } else {
        print("No student document found for ID: $studentId");
      }
    } catch (e) {
      print("Error loading student data: $e");
    } finally {
      _isDataLoaded = true; // Mark data as loaded
      notifyListeners();
    }
  }
}
