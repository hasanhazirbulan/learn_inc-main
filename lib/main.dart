import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:learn_inc/screens/welcome_screen.dart';
import 'package:learn_inc/screens/login_screen.dart';
import 'package:learn_inc/screens/registration_screen.dart';
import 'package:learn_inc/screens/dashboard_screen.dart';
import 'firebase_options.dart'; // Import Firebase configuration file
import 'package:learn_inc/screens/flashcard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase initialization
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/flashcard': (context) => FlashcardScreen()
      },
    );
  }
}
