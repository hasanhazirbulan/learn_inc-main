import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_inc/providers/teacher_provider.dart';

class TeacherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final teacherProvider = Provider.of<TeacherProvider>(context);
    final isDayMode = teacherProvider.isDayMode;

    if (!teacherProvider.isDataLoaded) {
      return Scaffold(
        backgroundColor: isDayMode ? Colors.white : Color(0xFF263238),
        appBar: AppBar(
          backgroundColor: isDayMode ? Color(0xFF4DD0E1) : Color(0xFF37474F),
          title: Text('Teacher Dashboard'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final teacher = teacherProvider.teacher;

    if (teacher == null) {
      return Scaffold(
        backgroundColor: isDayMode ? Colors.white : Color(0xFF263238),
        appBar: AppBar(
          backgroundColor: isDayMode ? Color(0xFF4DD0E1) : Color(0xFF37474F),
          title: Text('Teacher Dashboard'),
        ),
        body: Center(
          child: Text(
            'No teacher data available.',
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
          'Teacher Dashboard',
          style: TextStyle(
            color: isDayMode ? Colors.black87 : Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: teacher.profileImage.startsWith('http')
                  ? NetworkImage(teacher.profileImage)
                  : AssetImage(teacher.profileImage) as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              teacher.email,
              style: TextStyle(
                fontSize: 16,
                color: isDayMode ? Colors.black54 : Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Welcome, ${teacher.fullName}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDayMode ? Colors.black87 : Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/manage_classes');
              },
              icon: Icon(Icons.class_),
              label: Text("Manage Classes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDayMode ? Color(0xFF4DD0E1) : Colors.grey[700],
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/create_flashcards');
              },
              icon: Icon(Icons.note_add),
              label: Text("Create Flashcards"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDayMode ? Color(0xFF4DD0E1) : Colors.grey[700],
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
