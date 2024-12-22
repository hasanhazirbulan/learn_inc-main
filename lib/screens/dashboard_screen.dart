import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:learn_inc/providers/user_provider.dart';
import 'package:learn_inc/screens/chat_screen.dart';
import 'package:learn_inc/screens/user_screen.dart';
import 'package:learn_inc/widgets/profile_modal.dart';
import 'package:learn_inc/widgets/streak_indicator.dart';
import 'package:learn_inc/widgets/top_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<Widget> _pages;

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

    _pages = [
      MainPage(animation: _animation),
      ChatScreen(isDayMode: true),
      UserScreen(),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDayMode = userProvider.isDayMode;

    return Scaffold(
      backgroundColor: isDayMode ? const Color(0xFFE0F7FA) : const Color(0xFF263238),
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
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
          Icon(Icons.chat, size: 30, color: isDayMode ? Colors.black : Colors.white),
          Icon(Icons.person, size: 30, color: isDayMode ? Colors.black : Colors.white),
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

  const MainPage({Key? key, required this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDayMode = userProvider.isDayMode;

    return Stack(
      children: [
        Container(
          color: isDayMode ? const Color(0xFFE0F7FA) : const Color(0xFF263238),
        ),

        // Added Padding to move TopBar down
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: TopBar(
            points: userProvider.user?.points ?? 0,
            lives: userProvider.user?.lives ?? 3,
            isDayMode: isDayMode,
            onProfileTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => ProfileModal(
                  fullName: userProvider.user?.fullName ?? "Unknown User",
                  profileImage:
                  userProvider.user?.profileImage ?? 'assets/avatars/avatar1.png',
                  isDayMode: isDayMode,
                  onNavigateToSettings: () {
                    Navigator.pushNamed(context, '/user_screen');
                  },
                  role: 'Student',
                ),
              );
            },
          ),
        ),

        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

              StreakIndicator(
                streakDays: userProvider.user?.streakDays ?? 0,
                isDayMode: isDayMode,
              ),

              const SizedBox(height: 10),

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