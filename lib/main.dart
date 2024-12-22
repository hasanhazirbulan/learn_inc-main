import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:learn_inc/screens/user_screen.dart';
import 'package:learn_inc/screens/welcome_screen.dart';
import 'package:learn_inc/screens/login_screen.dart';
import 'package:learn_inc/screens/registration_screen.dart';
import 'package:learn_inc/screens/dashboard_screen.dart';
import 'package:learn_inc/screens/student_dashboard_screen.dart';
import 'package:learn_inc/screens/student_screen.dart';
import 'package:learn_inc/screens/teacher_dashboard_screen.dart';
import 'package:learn_inc/screens/teacher_screen.dart';

import 'package:learn_inc/providers/user_provider.dart';
import 'package:learn_inc/providers/teacher_provider.dart';
import 'package:learn_inc/providers/student_provider.dart';

import 'firebase_options.dart'; // Import Firebase configuration file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // Giriş yapmış kullanıcı

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider()..loadUserData(),
        ),
        if (user != null)
          ChangeNotifierProvider(
            create: (context) => TeacherProvider()..loadTeacherData(user.uid),
          ),
        if (user != null)
          ChangeNotifierProvider(
            create: (context) => StudentProvider()..loadStudentData(user.uid),
          ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => WelcomeScreen(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegistrationScreen(),
          '/dashboard_screen': (context) => DashboardScreen(),
          '/student_dashboard_screen': (context) => StudentDashboardScreen(),
          '/teacher_dashboard_screen': (context) => TeacherDashboardScreen(),
          '/user_screen': (context) => UserScreen(),
          '/teacher_screen': (context) => TeacherScreen(),
          '/student_screen': (context) => StudentScreen(),
        },
      ),
    );
  }
}
