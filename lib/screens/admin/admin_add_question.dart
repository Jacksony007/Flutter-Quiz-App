import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/quiz.dart';
import '../../theme/colors/light_colors.dart';
import '../../widgets/back_button.dart';
import '../../widgets/my_text_field.dart';
import '../../widgets/top_container.dart';
import '/models/question.dart';
import '/services/firestore_service.dart';

class AdminAddQuestionScreen extends StatefulWidget {
  const AdminAddQuestionScreen({super.key});

  @override
  _AdminAddQuestionScreenState createState() => _AdminAddQuestionScreenState();
}

class _AdminAddQuestionScreenState extends State<AdminAddQuestionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _option1Controller = TextEditingController();
  final TextEditingController _option2Controller = TextEditingController();
  final TextEditingController _option3Controller = TextEditingController();
  final TextEditingController _option4Controller = TextEditingController();
  final TextEditingController _marksController = TextEditingController();
  int? _correctOptionIndex;
  final FirestoreService _firestoreService = FirestoreService();
  String? _selectedQuizId;

  _saveQuestion() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Question newQuestion = Question(
        quizId: _selectedQuizId!,
        questionText: _questionController.text.trim(),
        options: [
          _option1Controller.text.trim(),
          _option2Controller.text.trim(),
          _option3Controller.text.trim(),
          _option4Controller.text.trim(),
        ],
        correctOptionIndex: _correctOptionIndex!,
        marks: double.parse(_marksController.text.trim()),
      );

      await _firestoreService.addQuestion(newQuestion);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question added successfully')));

      _questionController.clear();
      _option1Controller.clear();
      _option2Controller.clear();
      _option3Controller.clear();
      _option4Controller.clear();
      _marksController.clear();
      _correctOptionIndex = null;
    }
  }

  //... Rest of your helper methods
  InputDecoration _inputDecoration(String labelText, {IconData? icon}) {
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: Colors.blueGrey) : null,
      labelText: labelText,
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color.fromRGBO(143, 148, 251, 1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(
        color: Colors.blueGrey,
      ),
    );
  }

  InputDecoration _dropdownDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      hintText: labelText,
      hintStyle: TextStyle(color: Colors.blueGrey.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color.fromRGBO(143, 148, 251, 1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(
        color: Colors.blueGrey,
      ),
    );
  }

  InputDecoration _dropdownDecorationQuiz(String labelText) {
    return InputDecoration(
      labelText: labelText,
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color.fromRGBO(143, 148, 251, 1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(
        color: Colors.blueGrey,
      ),
      hintStyle: const TextStyle(color: Colors.blueGrey),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    var downwardIcon = Icon(
      Icons.keyboard_arrow_down,
      color: Colors.black54,
    );

    return Scaffold(
        body: SafeArea(
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TopContainer(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
              width: width,
              child: Column(
                children: <Widget>[
                  MyBackButton(),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Add New Question',
                        style: TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  StreamBuilder<List<Quiz>>(
                    // This StreamBuilder fetches the list of quizzes for the dropdown
                    stream: _firestoreService.getAvailableQuizzes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        List<Quiz> quizzes = snapshot.data!;
                        return DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            dropdownColor: Colors.white.withOpacity(0.9),
                            value: _selectedQuizId,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedQuizId = newValue;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Please select a quiz' : null,
                            items: quizzes
                                .map<DropdownMenuItem<String>>((Quiz quiz) {
                              return DropdownMenuItem<String>(
                                value: quiz.id,
                                child: Text(quiz.title),
                              );
                            }).toList(),
                            decoration: _dropdownDecorationQuiz('Select Quiz'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                    MyTextField(
                      controller: _questionController,
                      label: 'Question',
                      icon: Icon(Icons.question_answer),
                      validator: (value) =>
                          value!.isEmpty ? 'Question cannot be empty' : null,
                    ),

                    MyTextField(
                      controller: _option1Controller,
                      label: 'Option 1',
                      icon: Icon(Icons.format_list_numbered),
                      validator: (value) =>
                          value!.isEmpty ? 'Option cannot be empty' : null,
                    ),
                    MyTextField(
                      controller: _option2Controller,
                      label: 'Option 2',
                      icon: Icon(Icons.format_list_numbered),
                      validator: (value) =>
                          value!.isEmpty ? 'Option cannot be empty' : null,
                    ),
                    MyTextField(
                      controller: _option3Controller,
                      label: 'Option 3',
                      icon: Icon(Icons.format_list_numbered),
                      validator: (value) =>
                          value!.isEmpty ? 'Option cannot be empty' : null,
                    ),
                    MyTextField(
                      controller: _option4Controller,
                      label: 'Option 4',
                      icon: Icon(Icons.format_list_numbered),
                      validator: (value) =>
                          value!.isEmpty ? 'Option cannot be empty' : null,
                    ),
                    MyTextField(
                      controller: _marksController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) =>
                          value!.isEmpty ? 'Marks cannot be empty' : null,
                      label: 'Marks',
                      icon: Icon(Icons.score),
                    ),

                    // Add similar fields for other options...

                    DropdownButtonFormField<int>(
                      value: _correctOptionIndex,
                      onChanged: (int? newValue) {
                        setState(() {
                          _correctOptionIndex = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Choose correct option' : null,
                      items:
                          [0, 1, 2, 3].map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('Option ${value + 1}',
                              style: const TextStyle(color: Colors.blueGrey)),
                        );
                      }).toList(),
                      decoration: _dropdownDecoration('Correct Option'),
                      dropdownColor: Colors.white.withOpacity(0.9),
                      itemHeight: 50,
                      isExpanded: true,
                    ),

                    ElevatedButton(
                      onPressed: _saveQuestion,
                      child: const Text(
                        'Save Question',
                        style: TextStyle(fontSize: 18),  // Increase the font size a bit
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),  // Adjust these values
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),  // Increased the border radius
                        ),
                        elevation: 5,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
