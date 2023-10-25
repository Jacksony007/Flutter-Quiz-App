import 'package:flutter/material.dart';
import '/models/question.dart';
import '/models/quiz.dart';
import '/services/firestore_service.dart';
import 'dart:async';

class UserQuizScreen extends StatefulWidget {
  final String quizId;

  const UserQuizScreen({super.key, required this.quizId});

  @override
  _UserQuizScreenState createState() => _UserQuizScreenState();
}

class _UserQuizScreenState extends State<UserQuizScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Question>? _questions;
  Quiz? _quiz;
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  int _correctAnswers = 0;
  int? _secondsLeft;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadQuizAndQuestions();
  }

  _loadQuizAndQuestions() async {
    _quiz = await _firestoreService.getQuiz(widget.quizId).first;
    _questions = await _firestoreService.getQuestionsByIds(_quiz!.questionIds);
    _secondsLeft = _quiz!.duration;
    _startTimer();
  }


  _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft! > 0) {
        setState(() {
          _secondsLeft = _secondsLeft! - 1;
        });
      } else {
        _endQuiz();
      }
    });
  }

  _nextQuestion() {
    if (_selectedOptionIndex == _questions![_currentQuestionIndex].correctOptionIndex) {
      _correctAnswers++;
    }

    if (_currentQuestionIndex < _questions!.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
      });
    } else {
      _endQuiz();
    }
  }

  _endQuiz() {
    _timer.cancel();
    // Navigate to results screen or show a dialog
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
        title: Text('Quiz: ${_quiz?.title ?? 'Loading...'}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text("$_secondsLeft s"),
              avatar: const Icon(Icons.timer),
            ),
          )
        ],
      ),
      body: (_questions == null)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text("Question ${_currentQuestionIndex + 1} of ${_questions!.length}"),
              const SizedBox(height: 20),
              Text(_questions![_currentQuestionIndex].questionText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ...List.generate(
                _questions![_currentQuestionIndex].options.length,
                    (index) => ListTile(
                  tileColor: _selectedOptionIndex == index ? Colors.blue[100] : null,
                  title: Text(_questions![_currentQuestionIndex].options[index]),
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
              ElevatedButton(onPressed: _nextQuestion, child: const Text('Next')),
            ],
          ),
        ),
      ),
    );
  }
}
