import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartassistant/home.dart';
import 'package:smartassistant/register.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      print('User logged in: ${userCredential.user?.email}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Error during login: $e');
      setState(() {
        _errorMessage = 'Login failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.1),

                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset('assets/logopg.png',
                          height: screenHeight * 0.05),
                      Image.asset('assets/logogd.png',
                          height: screenHeight * 0.05),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  // Title
                  Text(
                    'SMART ASSISTANT GUDANG & PENGANTONGAN AREA III',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  // Background Image
                  Image.asset(
                    'assets/bgdb.jpeg',
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.25,
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Form
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  SizedBox(
                    width: screenWidth * 0.8,
                    child: TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: UnderlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Error message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),

                  // Login Button
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.07,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(239, 175, 12, 100),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.2,
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text('Don\'t have an account? Register here'),
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  // Footer
                  Text(
                    '@2024. Gudang & Pengantongan III. Petrokimia Gresik',
                    style: TextStyle(
                      fontSize: screenWidth * 0.025,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  // Spacer to push content up from bottom
                  SizedBox(height: screenHeight * 0.1),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
