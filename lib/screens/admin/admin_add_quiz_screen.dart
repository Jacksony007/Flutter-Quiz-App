import 'package:flutter/material.dart';
import '../../theme/colors/light_colors.dart';
import '../../widgets/back_button.dart';
import '../../widgets/my_text_field.dart';
import '../../widgets/top_container.dart';
import '/models/quiz.dart';
import '/services/firestore_service.dart';

class AdminAddQuizScreen extends StatefulWidget {
  const AdminAddQuizScreen({super.key});

  @override
  _AdminAddQuizScreenState createState() => _AdminAddQuizScreenState();
}

class _AdminAddQuizScreenState extends State<AdminAddQuizScreen> {
  final TextEditingController _titleController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _descriptionController = TextEditingController();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _scheduledDate;
  final List<String> _selectedQuestionIds = [];
  int? _duration;

  // List of categories
  final List<String> _categories = [
    "END SEMISTER EXAM",
    "MID SEM 1",
    "MID SEM 2",
    "TEST"
  ];

// List to keep track of selected categories
  List<String> _selectedCategories = [];

  String get _durationText {
    if (_startTime != null && _endTime != null) {
      int hours = _endTime!.hour - _startTime!.hour;
      int minutes = _endTime!.minute - _startTime!.minute;

      if (minutes < 0) {
        hours -= 1;
        minutes = 60 + minutes;
      }

      return '$hours hours and $minutes minutes';
    }
    return 'Duration will be shown here';
  }

  Future<void> _pickStartTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _startTime = pickedTime;
      });
    }
  }

  Future<void> _pickEndTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _endTime = pickedTime;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _scheduledDate = pickedDate;
      });
    }
  }

  _saveQuiz() async {
    if (_titleController.text.isNotEmpty &&
        _startTime != null &&
        _endTime != null &&
        _scheduledDate != null) {
      _duration = (_endTime!.hour - _startTime!.hour) * 60 +
          (_endTime!.minute - _startTime!.minute);

      DateTime startDateTime = DateTime(
        _scheduledDate!.year,
        _scheduledDate!.month,
        _scheduledDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      DateTime endDateTime = DateTime(
        _scheduledDate!.year,
        _scheduledDate!.month,
        _scheduledDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      Quiz newQuiz = Quiz(
        title: _titleController.text.trim(),
        questionIds: _selectedQuestionIds,
        startTime: startDateTime,
        endTime: endDateTime,
        duration: _duration!,
        description: _descriptionController.text.trim(),
        categories: _selectedCategories,
      );

      await _firestoreService.addQuiz(newQuiz);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz added successfully')));

      _titleController.clear();
      _selectedQuestionIds.clear();
      _startTime = null;
      _endTime = null;
      _scheduledDate = null;
    }
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
                        'Create new Quiz',
                        style: TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        MyTextField(
                          controller: _titleController,
                          label: 'Title',
                          icon: null,
                          onTap: null,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              child: MyTextField(
                                label: _scheduledDate == null
                                    ? 'Date'
                                    : '${_scheduledDate!.toLocal()}'
                                        .split(' ')[0],
                                icon: downwardIcon,
                                onTap: () => _selectDate(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: MyTextField(
                            label: _startTime == null
                                ? 'Start Time'
                                : '${_startTime!.hour}:${_startTime!.minute}',
                            icon: downwardIcon,
                            onTap: () => _pickStartTime(context),
                          ),
                        ),
                        SizedBox(width: 40),
                        Expanded(
                          child: MyTextField(
                            label: _endTime == null
                                ? 'End Time'
                                : '${_endTime!.hour}:${_endTime!.minute}',
                            icon: downwardIcon,
                            onTap: () => _pickEndTime(context),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(_durationText),
                    // ... [add other required fields or widgets here as per your design]
                    SizedBox(height: 10),
                    MyTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      minLines: 2,
                      maxLines: 2,
                    ),
                    SizedBox(height: 20),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 20),
                          Wrap(
                            // ... [Other properties of the Wrap widget]
                            spacing: 10.0,
                            children: _categories.map((category) {
                              bool isSelected =
                                  _selectedCategories.contains(category);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedCategories.remove(category);
                                    } else {
                                      _selectedCategories.clear();
                                      _selectedCategories.add(category);
                                    }
                                  });
                                },
                                child: Chip(
                                  label: Text(category),
                                  backgroundColor:
                                      isSelected ? LightColors.kRed : null,
                                  labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 80,
              width: width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: TextButton(
                      onPressed: _saveQuiz,
                      child: Text(
                        'Create Quiz',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18),
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(LightColors.kBlue),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
