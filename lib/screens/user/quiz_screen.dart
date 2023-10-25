import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/models/question.dart';
import '/services/firestore_service.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Question>? _questions;
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  double _correctAnswers = 0.0;

  late Timer _timer;
  int? _duration;
  int? _secondsLeft;
  bool? _hasAttempted;
  int? _previousScore;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchPreviousScore();
    _checkQuizAttempt();
    _loadQuizAndQuestions(widget.quizId);
  }

  _fetchPreviousScore() {
    _firestoreService
        .getUserQuizResult(
      quizId: widget.quizId,
      userId: FirebaseAuth.instance.currentUser!.uid,
    )
        .listen((resultData) {
      if (resultData != null && resultData.containsKey('score')) {
        setState(() {
          _previousScore = resultData['score'];
        });
      }
    });
  }

  _checkQuizAttempt() async {
    final quiz = await _firestoreService.getQuiz(widget.quizId).first;
    bool hasAttemptedBefore =
        quiz.attempts?.contains(FirebaseAuth.instance.currentUser?.uid) ??
            false;

    setState(() {
      _hasAttempted = hasAttemptedBefore;
    });

    if (!_hasAttempted!) {
      await _firestoreService.addAttempt(
          widget.quizId, FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        _hasAttempted = true;
      });
    }
  }

  _loadQuizAndQuestions(String quizId) async {
    final quiz = await _firestoreService.getQuiz(quizId).first;
    _duration = quiz.duration;
    _secondsLeft = _duration! * 60;
    _firestoreService.getQuestions(quizId).listen((questionData) {
      setState(() {
        _questions = questionData;
      });
    });
    _startTimer();
  }

  _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft! > 0) {
        setState(() {
          _secondsLeft = _secondsLeft! - 1;
        });
      } else {
        _timer.cancel();
        _showResults();
      }
    });
  }

  _showResults() async {
    // Saving quiz results
    await _firestoreService.saveQuizResult(
      quizId: widget.quizId,
      userId: FirebaseAuth.instance.currentUser!.uid,
      score: _correctAnswers,
    );

    // Storing the score in the quizzes' sub-collection 'scores'
    await _firestore
        .collection('quizzes')
        .doc(widget.quizId)
        .collection('scores')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'score': _correctAnswers,
      'timestamp': DateTime.now(),
      // This allows you to see when the score was recorded
    });

    // The dialog now shows marks instead of correct question count.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Finished!"),
        content: Text(
            "You scored ${_correctAnswers.toStringAsFixed(2)} out of ${_getTotalQuizMarks().toStringAsFixed(2)} marks."),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text(
                "${(_secondsLeft ?? 0) ~/ 60}m ${(_secondsLeft ?? 0) % 60}s",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.redAccent,
            ),
          ),
          if (_questions != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: Text(
                  "Total Marks: ${_getTotalQuizMarks().toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
            ),
        ],
      ),
      body: (_questions == null)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      "Question ${_currentQuestionIndex + 1} of ${_questions!.length}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Marks for this question: ${_questions![_currentQuestionIndex].marks.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _questions![_currentQuestionIndex].questionText,
                        key: ValueKey<int>(_currentQuestionIndex),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(
                      _questions![_currentQuestionIndex].options.length,
                      (index) => ListTile(
                        tileColor: _selectedOptionIndex == index
                            ? Colors.blue[100]
                            : null,
                        title: Text(
                            _questions![_currentQuestionIndex].options[index]),
                        leading: Radio(
                          activeColor: Colors.blue,
                          value: index,
                          groupValue: _selectedOptionIndex,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedOptionIndex = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed:
                              _currentQuestionIndex > 0 ? _prevQuestion : null,
                          child: const Text('Previous'),
                        ),
                        ElevatedButton(
                          onPressed: _nextQuestion,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  _nextQuestion() {
    if (_questions != null &&
        _selectedOptionIndex ==
            _questions?[_currentQuestionIndex].correctOptionIndex) {
      _correctAnswers += _questions![_currentQuestionIndex].marks;
    }

    if (_currentQuestionIndex < _questions!.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
      });
    } else {
      _timer.cancel();
      _showResults();
    }
  }

  _prevQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedOptionIndex = null;
      });
    }
  }

  double _getTotalQuizMarks() {
    if (_questions != null) {
      return _questions!.map((q) => q.marks).reduce((a, b) => a + b);
    }
    return 0.0;
  }
}
