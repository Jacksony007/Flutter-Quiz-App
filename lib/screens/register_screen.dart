import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Animation/FadeAnimation.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthenticationService _authService = AuthenticationService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isAdmin = false;

  _registerWithEmail() async {
    // Add check to ensure password and confirm password match
    if (_passwordController.text != _confirmPasswordController.text) {
      // Handle error: passwords don't match
      return;
    }

    final user = await _authService.registerWithEmailAndPassword(
        _emailController.text, _passwordController.text);

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('user_roles')
          .doc(user.uid)
          .set({'role': _isAdmin ? 'admin' : 'user'});
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      // Handle registration error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 300,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/background.png'),
                        fit: BoxFit.fill)),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 30,
                      width: 80,
                      height: 200,
                      child: FadeAnimation(
                          delay: 1,
                          child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/light-1.png'))),
                          )),
                    ),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      child: FadeAnimation(
                          delay: 1.2,
                          child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/light-2.png'))),
                          )),
                    ),
                    Positioned(
                      right: 40,
                      top: 40,
                      width: 80,
                      height: 150,
                      child: FadeAnimation(
                          delay: 1.4,
                          child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/clock.png'))),
                          )),
                    ),

                    //... (This remains unchanged, it's the decoration of the screen)

                    Positioned(
                      child: FadeAnimation(
                          delay: 1.6,
                          child: Container(
                            margin: const EdgeInsets.only(top: 50),
                            child: const Center(
                              child: Text("Register",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold)),
                            ),
                          )),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    FadeAnimation(
                        delay: 1.8,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color.fromRGBO(143, 148, 251, .2),
                                    blurRadius: 20.0,
                                    offset: Offset(0, 10))
                              ]),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[100]!))),
                                child: TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Email",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[100]!))),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Password",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: _confirmPasswordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Confirm Password",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      title: Text(
                        "Register as Admin",
                        style: TextStyle(
                          color: Colors.blue[800],
                          // Using a darker shade of blue for text
                          fontSize: 16,
                          // A standard font size
                          fontWeight: FontWeight.bold, // Make text bold
                        ),
                      ),
                      subtitle: Text(
                        "Check this if you are an admin.",
                        style: TextStyle(
                          color: Colors.blue[
                              600], // A slightly lighter shade for the subtitle
                        ),
                      ),
                      value: _isAdmin,
                      activeColor: Colors.blue,
                      // Using a standard blue for the checkbox when active
                      checkColor: Colors.white,
                      // A white check for contrast
                      onChanged: (bool? value) {
                        setState(() {
                          _isAdmin = value!;
                        });
                      },
                      secondary: Icon(
                        Icons.admin_panel_settings,
                        color: Colors.blue[
                            800], // Using the same darker blue for the icon
                      ),
                      tileColor: Colors.blue[50],
                      // A very light blue for the background
                      dense:
                          true, // This reduces the height of the tile slightly for a compact look
                    ),
                    const SizedBox(height: 10),
                    FadeAnimation(
                        delay: 2.5,
                        child: GestureDetector(
                          onTap: _registerWithEmail,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(colors: [
                                  Color.fromRGBO(143, 148, 251, 1),
                                  Color.fromRGBO(143, 148, 251, .6),
                                ])),
                            child: const Center(
                              child: Text("Register",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        )),
                    const SizedBox(height: 20),
                    FadeAnimation(
                        delay: 3,
                        child: TextButton(
                          child: const Text("Already have an account? Login",
                              style: TextStyle(
                                  color: Color.fromRGBO(143, 148, 251, 1))),
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('/login');
                          },
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
