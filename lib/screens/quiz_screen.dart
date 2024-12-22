import 'package:flutter/material.dart';

class QuizzesScreen extends StatelessWidget {
  final bool isDayMode;

  const QuizzesScreen({Key? key, required this.isDayMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Algoritmalar', 'icon': Icons.code, 'route': '/algorithm_quiz'},
      {'name': 'Veri Yapıları', 'icon': Icons.storage, 'route': '/data_structure_quiz'},
      {'name': 'Yazılım Dilleri', 'icon': Icons.computer, 'route': '/programming_language_quiz'},
    ];

    return Scaffold(
      backgroundColor: isDayMode ? Color(0xFFE0F7FA) : Color(0xFF263238),
      appBar: AppBar(
        backgroundColor: isDayMode ? Color(0xFF4DD0E1) : Color(0xFF37474F),
        title: Text("Quizzes"),
        iconTheme: IconThemeData(
          color: isDayMode ? Colors.black : Colors.white,
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            color: isDayMode ? Colors.white : Colors.grey[800],
            margin: EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                category['icon'] as IconData,
                color: isDayMode ? Colors.blue : Colors.teal,
              ),
              title: Text(
                category['name'] as String,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDayMode ? Colors.black : Colors.white,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: isDayMode ? Colors.blue : Colors.teal,
              ),
              onTap: () {
                Navigator.pushNamed(context, category['route'] as String);
              },
            ),
          );
        },
      ),
    );
  }
}
