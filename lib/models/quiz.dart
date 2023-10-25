import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app/models/question.dart';

class Quiz {
  String? id;
  String title;
  List<String> questionIds;
  int duration;
  DateTime? scheduledDate;
  DateTime? startTime;
  DateTime? endTime;
  List<String>? attempts;
  double totalScore = 0.0; // <-- Changed from int to double
  final String description;
  final List<String> categories;

  Quiz({
    this.id,
    required this.title,
    required this.questionIds,
    required this.duration,
    this.scheduledDate,
    this.startTime,
    this.endTime,
    this.attempts,
    required this.description,
    required this.categories,
  });

  Future<void> computeTotalScore(FirebaseFirestore firestore) async {
    for (String questionId in questionIds) {
      DocumentSnapshot questionDoc =
          await firestore.collection('questions').doc(questionId).get();
      if (questionDoc.exists) {
        Question question = Question.fromFirestore(questionDoc);
        totalScore += question.marks;
      }
    }
  }

  factory Quiz.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Quiz(
      id: doc.id,
      title: data['title'],
      questionIds: List<String>.from(data['questionIds']),
      duration: data['duration'],
      scheduledDate: data['scheduledDate'] != null
          ? (data['scheduledDate'] as Timestamp).toDate()
          : null,
      startTime: data['startTime'] != null
          ? (data['startTime'] as Timestamp).toDate()
          : null,
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      attempts:
          data['attempts'] != null ? List<String>.from(data['attempts']) : [],
      description: data['description'] ?? '',
      // provide a default in case it doesn't exist in Firestore
      categories: List<String>.from(data['categories'] ??
          []), // provide a default in case it doesn't exist
    )..computeTotalScore(FirebaseFirestore.instance);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'questionIds': questionIds,
      'duration': duration,
      'totalScore': totalScore,
      'scheduledDate': scheduledDate,
      'startTime': startTime,
      'endTime': endTime,
      'attempts': attempts,
      'description': description,
      'categories': categories,
    };
  }
}
