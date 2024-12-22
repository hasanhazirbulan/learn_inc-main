import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:learn_inc/screens/chat_screen.dart';
import 'package:learn_inc/widgets/profile_modal.dart';
import 'package:learn_inc/providers/teacher_provider.dart';
import 'package:provider/provider.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({Key? key}) : super(key: key);

  @override
  _TeacherDashboardScreenState createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
    final teacherProvider = Provider.of<TeacherProvider>(context);
    final isDayMode = teacherProvider.isDayMode;
    final teacher = teacherProvider.teacher;

    if (!teacherProvider.isDataLoaded || teacher == null) {
      return Scaffold(
        backgroundColor: isDayMode ? Colors.white : const Color(0xFF263238),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDayMode ? const Color(0xFFE0F7FA) : const Color(0xFF263238),
      body: SafeArea(
        child: Stack(
          children: [
            // Wave Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: const Size(double.infinity, 100),
                painter: WavePainter(isDayMode: isDayMode),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Teacher Dashboard",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDayMode ? Colors.black87 : Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.person,
                          color: isDayMode ? Colors.black87 : Colors.white,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => ProfileModal(
                              fullName: teacher.fullName,
                              profileImage: teacher.profileImage,
                              isDayMode: isDayMode,
                              onNavigateToSettings: () {
                                Navigator.pushNamed(context, '/teacher_settings');
                              },
                              role: 'Teacher',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Animated Mascot
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

                // Main Dashboard Grid
                Expanded(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        color: isDayMode ? Colors.white : Colors.black54,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60),
                        ),
                      ),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildDashboardButton(
                            context,
                            "View Class",
                            Icons.class_,
                                () => Navigator.pushNamed(context, '/class_list'),
                          ),
                          _buildDashboardButton(
                            context,
                            "Send Flashcards",
                            Icons.flash_on,
                                () => Navigator.pushNamed(context, '/send_flashcards'),
                          ),
                          _buildDashboardButton(
                            context,
                            "Send Quiz",
                            Icons.quiz,
                                () => Navigator.pushNamed(context, '/send_quiz'),
                          ),
                          _buildDashboardButton(
                            context,
                            "Chat",
                            Icons.chat,
                                () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(isDayMode: isDayMode),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
      BuildContext context,
      String label,
      IconData icon,
      VoidCallback onTap,
      ) {
    final isDayMode = Provider.of<TeacherProvider>(context).isDayMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDayMode ? const Color(0xff4DD0E1) : const Color(0xFF37474F),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDayMode ? Colors.grey.withOpacity(0.3) : Colors.black54,
              blurRadius: 6.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isDayMode ? Colors.white : Colors.tealAccent,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isDayMode ? Colors.white : Colors.tealAccent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
            ? [const Color(0xFFB3E5FC), const Color(0xFFE0F7FA)]
            : [const Color(0xFF37474F), const Color(0xFF263238)],
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
