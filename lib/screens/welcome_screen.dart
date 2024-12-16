import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF80DEEA), Color(0xFF00796B)], // Day mode colors
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Main Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Welcome Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0), // Rounded corners
                    child: Image.asset(
                      'assets/welcome_image.png', // Replace with your image path
                      fit: BoxFit.cover,
                      height: 180, // Adjusted for minimalistic design
                    ),
                  ),
                  SizedBox(height: 20),
                  // Welcome Text
                  Text(
                    "Welcome to Learn.inc",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Subheading Text
                  Text(
                    "Learn faster and have fun while doing it!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 40),
                  // Sign Up Button
                  // Get Started Button
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, '/register'); // Navigate to the registration screen
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white.withOpacity(0.9), // Subtle background color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40), // Adjusted padding
    elevation: 5, // Optional: Add a shadow for better visuals
  ),
  child: Text(
    "Get Started",
    style: TextStyle(
      fontSize: 18, // Slightly larger font size
      color: Color(0xFF00796B), // Harmonized text color
      fontWeight: FontWeight.bold,
    ),
  ),
),

                  SizedBox(height: 16),
                  // Already have an account? Login
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login'); // Navigate to login screen
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
