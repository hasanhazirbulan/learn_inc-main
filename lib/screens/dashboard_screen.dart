import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:learn_inc/services/auth_service.dart'; // AuthService için import
import 'package:learn_inc/screens/login_screen.dart'; // Login ekranı için import
import 'package:learn_inc/file_upload_helper.dart'; // Dosya işlemleri için yardımcı sınıf
import 'package:learn_inc/screens/chat_screen.dart'; // ChatScreen ekranı için import

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int points = 0;
  int lives = 3;
  int streakDays = 5;
  bool isDayMode = true; // Gündüz/Gece modu

  final AuthService _authService = AuthService(); // Firebase logout işlemleri

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

  void toggleTheme() {
    setState(() {
      isDayMode = !isDayMode;
    });
  }

  Future<void> logout() async {
    await _authService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDayMode ? Color(0xFFE0F7FA) : Color(0xFF263238),
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: isDayMode ? Colors.blueAccent : Colors.black54,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Üst Bar Dalga Tasarımı
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
              // Üst Bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.yellow),
                              SizedBox(width: 4),
                              Text('$points',
                                  style: TextStyle(
                                      color: isDayMode
                                          ? Colors.black87
                                          : Colors.white)),
                            ],
                          ),
                          SizedBox(width: 16),
                          Row(
                            children: [
                              Icon(Icons.favorite, color: Colors.red),
                              SizedBox(width: 4),
                              Text('$lives',
                                  style: TextStyle(
                                      color: isDayMode
                                          ? Colors.black87
                                          : Colors.white)),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          isDayMode ? Icons.wb_sunny : Icons.nights_stay,
                          color: isDayMode ? Colors.orange : Colors.white,
                        ),
                        onPressed: toggleTheme,
                      ),
                    ],
                  ),
                ),
              ),
              // Animasyonlu Karakter
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
              // Streak Göstergesi
              Column(
                children: [
                  Image.asset(
                    'assets/streak_icon.png',
                    height: 50,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$streakDays Days Streak',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDayMode
                          ? Colors.grey[700]
                          : Colors.grey[300],
                    ),
                  ),
                ],
              ),
              // Grid Options
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
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final titles = ['Load a File', 'Chat', 'Learn'];
                      final icons = [
                        Icons.upload_file,
                        Icons.chat,
                        Icons.lightbulb
                      ];
                      return GestureDetector(
                        onTap: () {
                          if (index == 0) {
                            FileUploadHelper.showFilePicker(context);
                          } else if (index == 1) {
                            // Chat butonuna tıklayınca ChatScreen'e yönlendir
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatScreen()),
                            );
                          }
                        },
                        child: Column(
                          children: [
                            Icon(
                              icons[index],
                              size: 40,
                              color: isDayMode
                                  ? Color(0xff4DD0E1)
                                  : Colors.grey[300],
                            ),
                            SizedBox(height: 8),
                            Text(
                              titles[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDayMode
                                    ? Colors.grey[800]
                                    : Colors.grey[400],
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
    Paint paint = Paint()
      ..color = isDayMode ? Color(0xFFB3E5FC) : Color(0xFF263238)
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.5,
        size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.5, size.width,
        size.height * 0.75);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
