import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/models/quiz.dart';
import '../../services/auth_service.dart';
import 'ProfileSearchAndNotification.dart';
import 'AvailableQuizzes.dart';
import 'QuickActionButtons.dart';
import 'User_Stats_Widget.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  _UserDashboardScreenState createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  Future<List<Quiz>>? _quizzesFuture;
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final user = FirebaseAuth.instance.currentUser; // Get the current user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        elevation: 0,
        backgroundColor: Colors.deepPurple[400],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurple[400]!, Colors.blueAccent],
            ),
          ),
        ),
        actions: [  // <-- Add this section
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',  // Tooltip will show when the user long-presses the button
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            const ProfileSearchAndNotification(),

            // 1. Profile Summary
            UserStatsWidget(user: user),

            // 2. Quick Action Buttons
            const QuickActionButtons(),

            // 4. Available Quizzes
            AvailableQuizzes(userId: userId ?? ''), // Provide the `userId`
          ],
        ),
      ),

    );
  }

  void _logout() async {
    try {
      await AuthenticationService().signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (error) {
      // Optionally show an error message if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to log out. Please try again.')));
    }
  }

  // A helper function to create an action button
  Widget _actionButton(
      IconData icon, String label, Color color, Function onTap) {
    return Column(
      children: [
        InkWell(
          onTap: () => onTap(),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, size: 30, color: color),
          ),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}
