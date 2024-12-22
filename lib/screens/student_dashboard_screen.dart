import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:learn_inc/models/user_model.dart';
import 'package:learn_inc/providers/student_provider.dart';
import 'package:learn_inc/providers/user_provider.dart';
import 'package:learn_inc/screens/chat_screen.dart';
import 'package:learn_inc/screens/user_screen.dart';
import 'package:learn_inc/widgets/profile_modal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_inc/widgets/streak_indicator.dart';
import 'package:learn_inc/widgets/top_bar.dart';
import 'package:provider/provider.dart';


class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  _StudentDashboardScreen createState() => _StudentDashboardScreen();
}

class _StudentDashboardScreen extends State<StudentDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isDayMode = true;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }


  void toggleTheme() {
    setState(() {
      isDayMode = !isDayMode;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final isDayMode = studentProvider.isDayMode;

    if (!studentProvider.isDataLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final student = studentProvider.student;
    //final quizzes = studentProvider.quizzes;


    return Scaffold(
      backgroundColor: isDayMode ? Color(0xFFE0F7FA) : Color(0xFF263238),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(double.infinity, 100),
              painter: WavePainter(isDayMode: isDayMode),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Bar
              TopBar(
                points: student?.points ?? 0,
                lives: student?.lives ?? 3,
                isDayMode: isDayMode,
                onProfileTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => ProfileModal(
                      fullName: student?.fullName ?? "Unknown User",
                      profileImage: student?.profileImage ?? 'assets/avatars/avatar1.png',
                      isDayMode: isDayMode,
                      onNavigateToSettings: () {
                        Navigator.pushNamed(context, '/student_screen');
                      }, role: '',
                    ),
                  );
                },
              ),

              // Animated Character
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _animation.value),
                    child: Image.asset(
                      'assets/octopus.png',
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
              // Streak Indicator
              Column(
                children: [
                  StreakIndicator(
                    streakDays: student?.streakDays ?? 0,
                    isDayMode: isDayMode,
                  ),
                ],
              ),

              // Main Grid
              FadeInUp(
                duration: Duration(milliseconds: 1000),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDayMode ? Colors.white : Colors.black54,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: 4, // Increase item count to accommodate the new button
                    itemBuilder: (context, index) {
                      final icons = [
                        'assets/flashcard.png',
                        'assets/chat.png',
                        'assets/lightbulb.png',
                        'assets/quiz.png', // Icon for quizzes
                      ];
                      final titles = ['Flashy', 'Chat', 'Learn', 'Quizzes'];

                      return GestureDetector(
                        onTap: () {
                          if (index == 0) {
                            // Implement flashcard logic
                          } else if (index == 1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(isDayMode: isDayMode),
                              ),
                            );
                          } else if (index == 3) {
                            Navigator.pushNamed(context, '/quiz_screen'); // Navigate to QuizScreen
                          }
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              icons[index],
                              height: 40,
                              width: 40,
                              color: isDayMode ? null : Colors.grey[300],
                            ),
                            SizedBox(height: 8),
                            Text(
                              titles[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDayMode ? Colors.grey[800] : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final bool isDayMode;

  WavePainter({required this.isDayMode});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDayMode
            ? [Color(0xFFB3E5FC), Color(0xFFE0F7FA)]
            : [Color(0xFF37474F), Color(0xFF263238)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.5, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.5, size.width, size.height * 0.75);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
