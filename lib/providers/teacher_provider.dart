import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher_model.dart';

class TeacherProvider with ChangeNotifier {
  Teacher? _teacher;
  bool _isDayMode = true; // Default to day mode
  bool _isDataLoaded = false;

  // Getter for day mode
  bool get isDayMode => _isDayMode;

  // Getter for data loaded status
  bool get isDataLoaded => _isDataLoaded;

  // Getter for teacher
  Teacher? get teacher => _teacher;

  // Toggle day mode and notify listeners
  void toggleDayMode() {
    _isDayMode = !_isDayMode;
    notifyListeners();
  }

  // Load teacher data from Firestore
  Future<void> loadTeacherData(String teacherId) async {
    try {
      _isDataLoaded = false;
      notifyListeners();

      final teacherDoc = await FirebaseFirestore.instance
          .collection('Teachers')
          .doc(teacherId)
          .get();

      if (teacherDoc.exists) {
        print("Teacher document found: ${teacherDoc.data()}");
        _teacher = Teacher.fromJson(teacherDoc.data()!, teacherId);
      } else {
        print("No teacher document found for ID: $teacherId");
        _teacher = null; // Belge yoksa null olarak ayarlayın
      }
    } catch (e) {
      print("Error loading teacher data: $e");
      _teacher = null; // Hata durumunda null olarak ayarlayın
    } finally {
      _isDataLoaded = true; // Veri yüklendi olarak işaretle
      notifyListeners();
    }
  }



}
