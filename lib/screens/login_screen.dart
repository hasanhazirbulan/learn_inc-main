import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  late bool _isDayMode; // Determines whether it's day or night mode

  @override
  void initState() {
    super.initState();
    _updateThemeBasedOnTime(); // Set theme based on the current time
  }

  void _updateThemeBasedOnTime() {
    final hour = DateTime.now().hour;
    // Day mode for 6 AM - 6 PM, Night mode otherwise
    _isDayMode = hour >= 6 && hour < 18;
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Perform login logic here (e.g., Firebase Authentication)
      Navigator.pushReplacementNamed(context, '/dashboard'); // Navigate to Dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isDayMode
                    ? [Color(0xFF80DEEA), Color(0xFF00796B)] // Day mode colors
                    : [Color(0xFF37474F), Color(0xFF263238)], // Night mode colors
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Waves Decoration
          Positioned.fill(
            child: CustomPaint(
              painter: WavePainter(isDayMode: _isDayMode),
            ),
          ),
          // Main Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Custom Mascot Image for Day/Night
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDayMode = !_isDayMode; // Toggle theme
                        });
                      },
                      child: Image.asset(
                        _isDayMode
                            ? 'assets/morning_mascot.png' // Morning mascot
                            : 'assets/night_mascot.png', // Night mascot
                        height: 80,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Welcome Text
                    Text(
                      _isDayMode ? "Good Morning" : "Good Evening",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Email Input
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.email, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    // Password Input
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 24),
                    // Login Button
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isDayMode ? Colors.teal.shade700 : Colors.grey.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                    SizedBox(height: 16),
                    // Sign Up Link
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class WavePainter extends CustomPainter {
  final bool isDayMode;

  WavePainter({required this.isDayMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDayMode
          ? Colors.white.withOpacity(0.2) // Light waves for day mode
          : Colors.black.withOpacity(0.3); // Darker waves for night mode
    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.7,
        size.width * 0.5,
        size.height * 0.8,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.9,
        size.width,
        size.height * 0.8,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
