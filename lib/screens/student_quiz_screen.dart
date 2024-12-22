import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quizzes'),
        backgroundColor: Color(0xff4DD0E1),
      ),
      body: ListView.builder(
        itemCount: 5, // Example count, replace with dynamic data
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Quiz ${index + 1}'),
            subtitle: Text('Description of Quiz ${index + 1}'),
            trailing: ElevatedButton(
              onPressed: () {
                // Navigate to Quiz Detail Screen
              },
              child: Text('Attempt'),
            ),
          );
        },
      ),
    );
  }
}
