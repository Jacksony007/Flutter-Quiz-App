import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/firestore_service.dart'; // Ensure this path is correct.

class UserStatsWidget extends StatefulWidget {
  final User? user;

  const UserStatsWidget({super.key, this.user});

  @override
  _UserStatsWidgetState createState() => _UserStatsWidgetState();
}

class _UserStatsWidgetState extends State<UserStatsWidget> {
  final FirestoreService _firestoreService = FirestoreService();

  int? totalQuizzes;
  double? averageScore;
  double? highestScore;
  double? lowestScore;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  _loadUserStats() async {
    totalQuizzes = await _firestoreService.getTotalQuizzes(widget.user!.uid);
    averageScore = await _firestoreService.getAverageScore(widget.user!.uid);
    highestScore = await _firestoreService.getHighestScore(widget.user!.uid);
    lowestScore = await _firestoreService.getLowestScore(widget.user!.uid);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Activity Highlights",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statCard(Icons.checklist, 'Total Quizzes',
                      totalQuizzes?.toString() ?? "Loading..."),
                  _statCard(Icons.star, 'Average Score',
                      '${averageScore?.toStringAsFixed(2) ?? "Loading..."}%'),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statCard(Icons.trending_up, 'Highest Score',
                      '${highestScore?.toString() ?? "Loading..."}%'),
                  _statCard(Icons.trending_down, 'Lowest Score',
                      '${lowestScore?.toString() ?? "Loading..."}%'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, size: 40, color: const Color(0xFF536DFE)),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: Colors.blue[800],
          ),
        ),
      ],
    );
  }
}
