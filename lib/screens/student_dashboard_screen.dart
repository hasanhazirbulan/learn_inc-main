import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:learn_inc/models/user_model.dart';
import 'package:learn_inc/providers/student_provider.dart';
import 'package:learn_inc/screens/chat_screen.dart';
import 'package:learn_inc/screens/learn_screen.dart';
import 'package:learn_inc/screens/quiz_screen.dart';
import 'package:learn_inc/widgets/profile_modal.dart';
import 'package:learn_inc/widgets/streak_indicator.dart';
import 'package:learn_inc/widgets/top_bar.dart';
import 'package:provider/provider.dart';

import 'flashy_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  _StudentDashboardScreen createState() => _StudentDashboardScreen();
}

class _StudentDashboardScreen extends State<StudentDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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

    return Scaffold(
      backgroundColor: isDayMode ? Color(0xFFE0F7FA) : Color(0xFF263238),
      body: Stack(
        children: [
          // Custom Wave Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(double.infinity, 100),
              painter: WavePainter(isDayMode: isDayMode),
            ),
          ),

          // Main Content
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.only(top: 40.0), // Ensure proper spacing
                child: TopBar(
                  points: student?.points ?? 0,
                  lives: student?.lives ?? 3,
                  isDayMode: isDayMode,
                  onProfileTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => ProfileModal(
                        fullName: student?.fullName ?? "Unknown User",
                        profileImage: student?.profileImage ??
                            'assets/avatars/avatar1.png',
                        isDayMode: isDayMode,
                        onNavigateToSettings: () {
                          Navigator.pushNamed(context, '/student_screen');
                        },
                        role: '',
                      ),
                    );
                  },
                ),
              ),

              // Animated Octopus
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
              StreakIndicator(
                streakDays: student?.streakDays ?? 0,
                isDayMode: isDayMode,
              ),

              // Main Grid with Menu Options
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
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final icons = [
                        'assets/flashcard.png',
                        'assets/chat.png',
                        'assets/lightbulb.png',
                        'assets/quiz.png',
                      ];
                      final titles = ['Flashy', 'Chat', 'Learn', 'Quiz'];

                      return GestureDetector(
                        onTap: () {
                          if (index == 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FlashyScreen(isDayMode: isDayMode),
                              ),
                            );
                          } else if (index == 1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(isDayMode: isDayMode),
                              ),
                            );
                          } else if (index == 2) {
                            // Learn logic - LearnScreen'e yönlendirme
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LearnScreen(isDayMode: isDayMode),
                              ),
                            );
                          } else if (index == 3) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizzesScreen(isDayMode: isDayMode),
                              ),
                            );
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
