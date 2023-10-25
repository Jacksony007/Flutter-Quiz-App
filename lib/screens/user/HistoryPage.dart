import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/firestore_service.dart';

class QuizHistory {
  final String name;
  final double score;
  final double total; // <-- Add this
  final DateTime date;

  QuizHistory(
      {required this.name,
      required this.score,
      required this.total,
      required this.date});
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Quiz History'),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Colors.blue[400]!,
                Colors.blue[700]!,
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<QuizHistory>>(
        stream: _getQuizHistories(),
        builder:
            (BuildContext context, AsyncSnapshot<List<QuizHistory>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('StreamBuilder Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found!'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              QuizHistory quizHistory = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.quiz, color: Colors.white),
                    ),
                    title: Text("Quiz Name: ${quizHistory.name}"),
                    subtitle: Text(
                        "Score: ${quizHistory.score} out of ${quizHistory.total}\nDate: ${quizHistory.date.toLocal()}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Stream<List<QuizHistory>> _getQuizHistories() async* {
    List<QuizHistory> histories = [];

    final quizSnapshots = await _firestore.collection('quizzes').get();
    for (var quizDoc in quizSnapshots.docs) {
      final quizId = quizDoc.id;
      final quizName = quizDoc.data()['title'] ?? 'Unknown';

      final double total = (quizDoc.data()['totalScore'] ?? 0).toDouble();

      double score = (await FirestoreService()
          .getUserScores(_auth.currentUser!.uid, quizId)
          .first).toDouble();

      histories.add(QuizHistory(
          name: quizName, score: score, total: total, date: DateTime.now()));
    }

    yield histories;
  }

}
