import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_settings.dart';
import '/models/question.dart';
import '/models/quiz.dart';

class FirestoreService {
  final CollectionReference _questionsCollection =
      FirebaseFirestore.instance.collection('questions');
  final CollectionReference _quizzesCollection =
      FirebaseFirestore.instance.collection('quizzes');

  // Methods related to Questions

  Future<void> addQuestion(Question question) async {
    // Add the question to Firestore
    await _questionsCollection.add(question.toMap());

    // Fetch the associated quiz
    DocumentSnapshot quizSnapshot =
        await _quizzesCollection.doc(question.quizId).get();
    if (!quizSnapshot.exists) return; // If the quiz doesn't exist, exit

    Map<String, dynamic> quizData = quizSnapshot.data() as Map<String, dynamic>;
    double currentTotalScore = quizData['totalScore'] ?? 0.0;

    // Update the totalScore for the quiz
    currentTotalScore += question.marks;

    // Save the updated totalScore back to Firestore
    await _quizzesCollection
        .doc(question.quizId)
        .update({'totalScore': currentTotalScore});
  }

  Future<void> updateQuestion(
      Question oldQuestion, Question newQuestion) async {
    // Logic to handle how the totalScore should be updated if a question's marks are changed
    DocumentSnapshot quizSnapshot =
        await _quizzesCollection.doc(oldQuestion.quizId).get();
    if (!quizSnapshot.exists) return;

    Map<String, dynamic> quizData = quizSnapshot.data() as Map<String, dynamic>;
    double currentTotalScore = quizData['totalScore'] ?? 0.0;

    currentTotalScore =
        currentTotalScore - oldQuestion.marks + newQuestion.marks;

    // Update the quiz's totalScore
    await _quizzesCollection
        .doc(oldQuestion.quizId)
        .update({'totalScore': currentTotalScore});

    // Update the question itself
    await _questionsCollection.doc(oldQuestion.id).update(newQuestion.toMap());
  }

  Future<void> deleteQuestion(Question question) async {
    // Deduct the question's marks from the quiz's total score
    DocumentSnapshot quizSnapshot =
        await _quizzesCollection.doc(question.quizId).get();
    if (!quizSnapshot.exists) return;

    Map<String, dynamic> quizData = quizSnapshot.data() as Map<String, dynamic>;
    double currentTotalScore = quizData['totalScore'] ?? 0.0;

    currentTotalScore -= question.marks; // Deduct the marks

    // Update the quiz's totalScore
    await _quizzesCollection
        .doc(question.quizId)
        .update({'totalScore': currentTotalScore});

    // Delete the question
    await _questionsCollection.doc(question.id).delete();
  }

  Stream<List<Question>> getQuestions(String quizId) {
    return _questionsCollection
        .where('quizId', isEqualTo: quizId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();
    });
  }

  Stream<Question> getQuestion(String questionId) {
    return _questionsCollection
        .doc(questionId)
        .snapshots()
        .map((doc) => Question.fromFirestore(doc));
  }

  Future<List<Question>> getQuestionsByIds(List<String> ids) async {
    List<Question> questions = [];

    for (String id in ids) {
      final doc = await _questionsCollection.doc(id).get();
      questions.add(Question.fromFirestore(doc));
    }

    return questions;
  }

  // Methods related to Quizzes

  Future<void> addQuiz(Quiz quiz) async {
    await _quizzesCollection.add(quiz.toMap());
  }

  Future<void> updateQuiz(Quiz quiz) async {
    await _quizzesCollection.doc(quiz.id).update(quiz.toMap());
  }

  Future<void> deleteQuiz(String quizId) async {
    await _quizzesCollection.doc(quizId).delete();
  }

  Stream<List<Quiz>> getAvailableQuizzes() {
    return _quizzesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Quiz.fromFirestore(doc)).toList();
    });
  }

  Stream<Quiz> getQuiz(String quizId) {
    return _quizzesCollection
        .doc(quizId)
        .snapshots()
        .map((doc) => Quiz.fromFirestore(doc));
  }

  Future<void> saveScore({
    required String quizId,
    required String userId,
    required int score,
  }) async {
    await _quizzesCollection.doc(quizId).collection('scores').doc(userId).set({
      'score': score,
      'date': Timestamp.now(),
    });
  }

  Stream<double> getUserScores(String userId, String quizId) {
    return _quizzesCollection
        .doc(quizId)
        .collection('scores')
        .doc(userId)
        .snapshots()
        .map((doc) => (doc.data()?['score'] as num? ?? 0)
            .toDouble()); // adjusted to handle potential type mismatch
  }

  Future<void> addAttempt(String quizId, String userId) async {
    await _quizzesCollection.doc(quizId).update({
      'attempts': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> saveQuizResult({
    required String quizId,
    required String userId,
    required double score, // <-- Change int to double here
  }) async {
    await _quizzesCollection
        .doc(quizId)
        .collection('attempts')
        .doc(userId)
        .set({
      'score': score,
      'date': Timestamp.now(), // Store date as Timestamp
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> getUserQuizResult({
    required String quizId,
    required String userId,
  }) {
    return _quizzesCollection
        .doc(quizId)
        .collection('attempts')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data());
  }

  Future<void> updateTotalScoreOfQuiz(String quizId) async {
    Quiz quiz = await getQuiz(quizId).first; // Fetch the quiz by its ID
    await quiz.computeTotalScore(
        FirebaseFirestore.instance); // Compute the new total score
    await _quizzesCollection.doc(quizId).update({
      'totalScore': quiz.totalScore,
    }); // Update the totalScore in Firestore
  }

  Future<int> getTotalQuizzes(String userId) async {
    QuerySnapshot quizSnapshots =
        await _quizzesCollection.where('attempts', arrayContains: userId).get();
    return quizSnapshots.docs.length;
  }

  Future<double> getAverageScore(String userId) async {
    // First, get all the quizzes the user has taken.
    QuerySnapshot quizSnapshots =
        await _quizzesCollection.where('attempts', arrayContains: userId).get();

    if (quizSnapshots.docs.isEmpty) return 0.0;

    double totalScore = 0.0;
    for (DocumentSnapshot quizDoc in quizSnapshots.docs) {
      String quizId = quizDoc.id;

      // For each quiz, get the user's score.
      DocumentSnapshot scoreDoc = await _quizzesCollection
          .doc(quizId)
          .collection('scores')
          .doc(userId)
          .get();
      Map<String, dynamic>? data = scoreDoc.data() as Map<String, dynamic>?;
      double score = (data?['score'] as num? ?? 0.0).toDouble();
      totalScore += score;
    }

    return totalScore / quizSnapshots.docs.length;
  }

  Future<double> getHighestScore(String userId) async {
    // First, get all the quizzes the user has taken.
    QuerySnapshot quizSnapshots =
        await _quizzesCollection.where('attempts', arrayContains: userId).get();

    if (quizSnapshots.docs.isEmpty) return 0.0;

    List<double> allScores = [];
    for (DocumentSnapshot quizDoc in quizSnapshots.docs) {
      String quizId = quizDoc.id;

      // For each quiz, get the user's score.
      DocumentSnapshot scoreDoc = await _quizzesCollection
          .doc(quizId)
          .collection('scores')
          .doc(userId)
          .get();
      Map<String, dynamic>? data = scoreDoc.data() as Map<String, dynamic>?;
      double score = (data?['score'] as num? ?? 0.0).toDouble();
      allScores.add(score);
    }

    // Determine the highest score from all the quizzes the user has taken.
    return allScores.reduce((curr, next) => curr > next ? curr : next);
  }

  Future<double> getLowestScore(String userId) async {
    // Step 1: First, get all the quizzes the user has taken.
    QuerySnapshot quizSnapshots =
        await _quizzesCollection.where('attempts', arrayContains: userId).get();

    if (quizSnapshots.docs.isEmpty) return 0.0;

    List<double> allScores = [];
    for (DocumentSnapshot quizDoc in quizSnapshots.docs) {
      String quizId = quizDoc.id;

      // Step 2: For each quiz, get the user's score.
      DocumentSnapshot scoreDoc = await _quizzesCollection
          .doc(quizId)
          .collection('scores')
          .doc(userId)
          .get();
      Map<String, dynamic>? data = scoreDoc.data() as Map<String, dynamic>?;
      double score = (data?['score'] as num? ?? 0.0).toDouble();
      allScores.add(score);
    }

    // Step 3: Determine the lowest score from all the quizzes the user has taken.
    return allScores.reduce((curr, next) => curr < next ? curr : next);
  }

  //Notification Alert
  Stream<List<Quiz>> getQuizzesStream() {
    return _quizzesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Quiz.fromFirestore(doc)).toList();
    });
  }

// User Settings
  final CollectionReference _settingsCollection =
      FirebaseFirestore.instance.collection('userSettings');

  Future<UserSettings> getSettings(String userId) async {
    DocumentSnapshot doc = await _settingsCollection.doc(userId).get();

    if (!doc.exists) {
      return UserSettings(
          notifications: true,
          darkMode: false); // Return default settings if document doesn't exist
    }
    return UserSettings.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<void> saveSettings(String userId, UserSettings settings) async {
    DocumentSnapshot doc = await _settingsCollection.doc(userId).get();

    if (doc.exists) {
      print("Updating settings for userId: $userId");
      await _settingsCollection.doc(userId).update(settings.toMap());
    } else {
      print("Creating settings for userId: $userId");
      await _settingsCollection.doc(userId).set(settings.toMap());
    }
  }

//Updating User Profile
  Future<void> updateUserInfo(String userId, String displayName, String email,
      String phoneNumber) async {
    // Update the user's display name and email in Firebase Authentication
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updateProfile(displayName: displayName);
      await user.updateEmail(email);
    }

    // Update the user's information in Firestore
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
    });
  }
}
