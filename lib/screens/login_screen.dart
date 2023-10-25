import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Animation/FadeAnimation.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthenticationService _authService = AuthenticationService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  _loginWithEmail() async {
    final user = await _authService.signInWithEmailAndPassword(
        _emailController.text, _passwordController.text);

    if (user == null) {
      // Handle login error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Incorrect email or password. Please try again.')),
      );
      return;
    }

    DocumentSnapshot roleDoc = await FirebaseFirestore.instance
        .collection('user_roles')
        .doc(user.uid)
        .get();

    if (!roleDoc.exists) {
      // Handle error: user's role is not set
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User role not set.')),
      );
      return;
    }

    String role = roleDoc['role'];
    if (role == 'admin') {
      Navigator.of(context).pushReplacementNamed('/AdminDashboardScreen');
    } else {
      Navigator.of(context).pushReplacementNamed('/UserDashboardScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              FadeAnimation(
                delay: 1,
                child: Container(
                  height: 300,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/background.png'),
                          fit: BoxFit.fill)),
                  child: Stack(
                    children: <Widget>[
                      FadeAnimation(
                        delay: 1.2,
                        child: Positioned(
                          left: 30,
                          width: 80,
                          height: 200,
                          child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/light-1.png'))),
                          ),
                        ),
                      ),
                      FadeAnimation(
                        delay: 1.4,
                        child: Positioned(
                          left: 140,
                          width: 80,
                          height: 150,
                          child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/light-2.png'))),
                          ),
                        ),
                      ),
                      FadeAnimation(
                        delay: 1.6,
                        child: Positioned(
                          right: 40,
                          top: 40,
                          width: 80,
                          height: 150,
                          child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/clock.png'))),
                          ),
                        ),
                      ),
                      FadeAnimation(
                        delay: 1.8,
                        child: Positioned(
                          child: Container(
                            margin: const EdgeInsets.only(top: 50),
                            child: const Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    FadeAnimation(
                      delay: 2,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(143, 148, 251, .2),
                              blurRadius: 20.0,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[100]!)),
                              ),
                              child: TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Email or Phone number",
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Password",
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    FadeAnimation(
                      delay: 2.5,
                      child: GestureDetector(
                        onTap: _loginWithEmail,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromRGBO(143, 148, 251, 1),
                                Color.fromRGBO(143, 148, 251, .6),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    FadeAnimation(
                      delay: 3,
                      child: TextButton(
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                              color: Color.fromRGBO(143, 148, 251, 1)),
                        ),
                        onPressed: () async {
                          if (_emailController.text.isNotEmpty) {
                            await _authService
                                .resetPassword(_emailController.text);
                            // Inform user that reset email has been sent
                          } else {
                            // Inform user to enter their email first
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    // You can adjust this value for your design needs.
                    FadeAnimation(
                      delay: 3.2,
                      child: TextButton(
                        child: const Text(
                          "Don't have an account? Register",
                          style: TextStyle(
                              color: Color.fromRGBO(143, 148, 251, 1)),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed('/register');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
