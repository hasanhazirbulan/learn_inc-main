import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_inc/providers/student_provider.dart';

class StudentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final isDayMode = studentProvider.isDayMode;

    if (!studentProvider.isDataLoaded) {
      return Scaffold(
        backgroundColor: isDayMode ? Colors.white : Color(0xFF263238),
        appBar: AppBar(
          backgroundColor: isDayMode ? Color(0xFF4DD0E1) : Color(0xFF37474F),
          title: Text('Student Dashboard'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final student = studentProvider.student;

    if (student == null) {
      return Scaffold(
        backgroundColor: isDayMode ? Colors.white : Color(0xFF263238),
        appBar: AppBar(
          backgroundColor: isDayMode ? Color(0xFF4DD0E1) : Color(0xFF37474F),
          title: Text('Student Dashboard'),
        ),
        body: Center(
          child: Text(
            'No student data available.',
            style: TextStyle(
              color: isDayMode ? Colors.black : Colors.white,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDayMode ? Colors.white : Color(0xFF263238),
      appBar: AppBar(
        backgroundColor: isDayMode ? Color(0xFF4DD0E1) : Color(0xFF37474F),
        title: Text(
          'Student Dashboard',
          style: TextStyle(
            color: isDayMode ? Colors.black87 : Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0, bottom: 16.0), // Add top padding
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: student.profileImage.startsWith('http')
                    ? NetworkImage(student.profileImage)
                    : AssetImage(student.profileImage) as ImageProvider,
              ),
              const SizedBox(height: 20),
              Text(
                student.email,
                style: TextStyle(
                  fontSize: 16,
                  color: isDayMode ? Colors.black54 : Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome, ${student.fullName}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDayMode ? Colors.black87 : Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/view_teacher_quizzes');
                },
                icon: Icon(Icons.quiz),
                label: Text("View Quizzes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDayMode ? Color(0xFF4DD0E1) : Colors.grey[700],
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
