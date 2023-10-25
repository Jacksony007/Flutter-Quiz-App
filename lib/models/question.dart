import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  String? id;
  String quizId;
  String questionText;
  List<String> options;
  int correctOptionIndex;
  double marks; // <-- Added marks as a double for decimal values

  Question({
    this.id,
    required this.quizId,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.marks,  // <-- Make sure to require marks when creating a Question
  });

  // Convert Firestore document to Question
  factory Question.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Question(
      id: doc.id,
      quizId: data['quizId'],
      questionText: data['questionText'],
      options: List<String>.from(data['options']),
      correctOptionIndex: data['correctOptionIndex'],
      marks: (data['marks'] ?? 0.0).toDouble(),  // <-- Parse marks and provide a default value
    );
  }

  // Convert Question to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'marks': marks,  // <-- Store the marks in Firestore
    };
  }
}
