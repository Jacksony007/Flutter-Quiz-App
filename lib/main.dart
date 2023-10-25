import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/screens/admin/AdminDashboardScreen.dart';
import 'package:quiz_app/screens/admin/ManageQuizScreen.dart';
import 'package:quiz_app/screens/admin/ProfilePage.dart';
import 'package:quiz_app/screens/admin/admin_add_question.dart';
import 'package:quiz_app/screens/admin/admin_add_quiz_screen.dart';
import 'package:quiz_app/screens/user/UserDashboardScreen.dart';

import '/screens/register_screen.dart';
import '/screens/login_screen.dart';
import 'firebase_options.dart';

// Add other screen imports here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:  LandingPage(),
      routes: {
        // Authentication routes
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),

        // Admin routes
        '/AdminDashboardScreen': (context) => AdminDashboardScreen(),
        '/Admin_add_question': (context) => const AdminAddQuestionScreen(),
        '/Admin_add_quiz_screen': (context) => const AdminAddQuizScreen(),
         '/adminManageQuizzes': (context) =>  ManageQuizScreen(),
        '/AdminProfile': (context) =>  ProfilePage(),

        // User routes
        '/UserDashboardScreen': (context) => const UserDashboardScreen(),
        //'/quiz_screen': (context) => QuizScreen(),
      },
    );
  }
}

class LandingPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LandingPage({Key? key}) : super(key: key);

  Future<String?> _getUserRole(User user) async {
    DocumentSnapshot roleDoc = await FirebaseFirestore.instance
        .collection('user_roles')
        .doc(user.uid)
        .get();
    if (roleDoc.exists) {
      return roleDoc['role'] as String?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          } else {
            return FutureBuilder<String?>(
              future: _getUserRole(user),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.done) {
                  final role = roleSnapshot.data;
                  if (role == 'admin') {
                    return  AdminDashboardScreen();
                  } else {
                    return const UserDashboardScreen();
                  }
                }
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            );
          }
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
