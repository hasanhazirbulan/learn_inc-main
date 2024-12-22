import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:learn_inc/providers/student_provider.dart';
import 'package:learn_inc/screens/flashy_screen.dart';
import 'package:learn_inc/screens/chat_screen.dart';
import 'package:learn_inc/screens/learn_screen.dart';
import 'package:learn_inc/screens/quiz_screen.dart';

import '../widgets/profile_modal.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  _StudentDashboardScreenState createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0; // Default index to show the MainPage
  AnimationController? _controller; // Nullable controller
  Animation<double>? _animation; // Nullable animation
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Initialize animation
    _animation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeInOut),
    );

    // Initialize the list of pages
    _pages = [
      MainPage(animation: _animation, isDayMode: true), // Main page with octopus
      FlashyScreen(isDayMode: true),
      ChatScreen(isDayMode: true),
      LearnScreen(isDayMode: true),
      QuizzesScreen(isDayMode: true),
    ];
  }

  @override
  void dispose() {
    _controller?.dispose(); // Dispose of the controller safely
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final isDayMode = studentProvider.isDayMode;

    return Scaffold(
      backgroundColor: isDayMode ? const Color(0xFFE0F7FA) : const Color(0xFF263238),
      body: _pages[_currentIndex], // Display the selected page

      // Curved Bottom Navigation Bar
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: isDayMode ? const Color(0xFFE0F7FA) : const Color(0xFF263238),
        color: isDayMode ? const Color(0xFF4DD0E1) : const Color(0xFF37474F),
        buttonBackgroundColor: isDayMode ? const Color(0xFF4DD0E1) : const Color(0xFF37474F),
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        index: _currentIndex,
        items: <Widget>[
          Icon(Icons.home, size: 30, color: isDayMode ? Colors.black : Colors.white),
          Icon(Icons.flash_on, size: 30, color: isDayMode ? Colors.black : Colors.white),
          Icon(Icons.chat, size: 30, color: isDayMode ? Colors.black : Colors.white),
          Icon(Icons.lightbulb, size: 30, color: isDayMode ? Colors.black : Colors.white),
          Icon(Icons.quiz, size: 30, color: isDayMode ? Colors.black : Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  final Animation<double>? animation;
  final bool isDayMode;

  const MainPage({Key? key, required this.animation, required this.isDayMode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Container(
          color: isDayMode ? const Color(0xFFE0F7FA) : const Color(0xFF263238),
        ),

        // Top Bar
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Shrimp and Heart Emojis with Counts
                Row(
                  children: [
                    Text(
                      "🍤 99",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDayMode ? Colors.black : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "❤️ 3",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDayMode ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),

                // Streak Count in the Center
                Text(
                  "🔥 5 Days Streak",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDayMode ? Colors.black : Colors.white,
                  ),
                ),

                // Profile Button
                IconButton(
                  icon: Icon(
                    Icons.person,
                    color: isDayMode ? Colors.black : Colors.white,
                  ),
                  onPressed: () {
                    // Open Profile Modal
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => ProfileModal(
                        fullName: "User Name", // Replace with real data
                        profileImage: 'assets/avatars/avatar1.png', // Replace with real data
                        isDayMode: isDayMode,
                        onNavigateToSettings: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                        role: 'Student',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Main Content with Octopus Animation
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Floating Octopus Animation
              if (animation != null)
                AnimatedBuilder(
                  animation: animation!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, animation!.value),
                      child: Image.asset(
                        'assets/octopus.png',
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),

              // Welcome Text
              Text(
                "Welcome to Learn Inc!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDayMode ? Colors.black : Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Learn, Chat, Quiz, and more!",
                style: TextStyle(
                  fontSize: 16,
                  color: isDayMode ? Colors.black54 : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
