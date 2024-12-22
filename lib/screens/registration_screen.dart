import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = "default"; // Default role for users
  bool _isLoading = false;
  bool _isDayMode = true; // Default mode

  Future<void> _register() async {
    if (_selectedRole == "default") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a role.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Kullanıcıyı Firebase Authentication'a ekle
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Doğru koleksiyonu belirle
      String collection = 'Users'; // Varsayılan koleksiyon
      if (_selectedRole == 'Teacher') {
        collection = 'Teachers';
      } else if (_selectedRole == 'Student') {
        collection = 'Students';
      }

      // Seçilen koleksiyona kullanıcı verisini ekle
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(userCredential.user?.uid)
          .set({
        'FullName': _nameController.text.trim(),
        'Email': _emailController.text.trim(),
        'Role': _selectedRole == 'None' ? 'User' : _selectedRole,
        'LastLogin': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Successful!")),
      );

      // Rol seçimine göre yönlendirme
      if (_selectedRole == 'Teacher') {
        Navigator.pushReplacementNamed(context, '/teacher_dashboard_screen');
      } else if (_selectedRole == 'Student') {
        Navigator.pushReplacementNamed(context, '/student_dashboard_screen');
      } else {
        Navigator.pushReplacementNamed(context, '/dashboard_screen');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
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
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB2DFDB), Color(0xFF00796B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Wave effect
          Positioned.fill(
            child: CustomPaint(
              painter: WavePainter(),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Register",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Full Name",
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 16),
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
                    SizedBox(height: 16),
                    Column(
                      children: [
                        Text(
                          "Are you one of these?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            //fontWeight: FontWeight.bold,
                            color: _isDayMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() => _selectedRole = 'Teacher');
                              },
                              icon: Icon(Icons.school, size: 18), // Küçültülmüş ikon
                              label: Text(
                                "Teacher",
                                style: TextStyle(fontSize: 14), // Daha küçük metin boyutu
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedRole == 'Teacher'
                                    ? Colors.teal.shade700 // Highlighted color
                                    : (_isDayMode ? Colors.teal : Colors.grey[700]),
                                foregroundColor: _selectedRole == 'Teacher'
                                    ? Colors.white // Highlighted text color
                                    : Colors.black87,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Daha küçük padding
                                elevation: _selectedRole == 'Teacher' ? 6 : 2, // Elevation effect
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20), // Daha küçük border radius
                                ),
                              ),
                            ),
                            SizedBox(width: 12), // Daha dar aralık
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() => _selectedRole = 'Student');
                              },
                              icon: Icon(Icons.person, size: 18), // Küçültülmüş ikon
                              label: Text(
                                "Student",
                                style: TextStyle(fontSize: 14), // Daha küçük metin boyutu
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedRole == 'Student'
                                    ? Colors.teal.shade700 // Highlighted color
                                    : (_isDayMode ? Colors.teal : Colors.grey[600]),
                                foregroundColor: _selectedRole == 'Student'
                                    ? Colors.white // Highlighted text color
                                    : Colors.black87,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Daha küçük padding
                                elevation: _selectedRole == 'Student' ? 6 : 2, // Elevation effect
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20), // Daha küçük border radius
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12), // Daha geniş aralık
// None of These Option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() => _selectedRole = 'None');
                              },
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedRole == 'None'
                                        ? Colors.teal.shade700
                                        : (_isDayMode ? Colors.white : Colors.black87),
                                    width: 2,
                                  ),
                                  color: _selectedRole == 'None' ? Colors.teal.shade700 : Colors.transparent,
                                ),
                              ),
                            ),
                            SizedBox(width: 8), // Yuvarlak kutucuk ile metin arası boşluk
                            Text(
                              "None of these",
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedRole == 'None'
                                    ? Colors.teal.shade700
                                    : (_isDayMode ? Colors.white : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Register",
                        style:
                        TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        "Already have an account? Login",
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.2);
    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.7, size.width * 0.5, size.height * 0.8)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.9, size.width, size.height * 0.8)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
