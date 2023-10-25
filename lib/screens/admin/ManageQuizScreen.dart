import 'package:flutter/material.dart';
import '../../theme/colors/light_colors.dart';
import '../../widgets/back_button.dart';
import '../../widgets/top_container.dart';
import '/models/quiz.dart';
import '/services/firestore_service.dart';

class ManageQuizScreen extends StatefulWidget {
  @override
  _ManageQuizScreenState createState() => _ManageQuizScreenState();
}

class _ManageQuizScreenState extends State<ManageQuizScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

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
                        'Manage Quizzes',
                        style: TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Quiz>>(
                stream: _firestoreService.getAvailableQuizzes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Quiz quiz = snapshot.data![index];
                        return Card(
                          elevation: 4.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quiz.title,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    color: LightColors.kBlue,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Start Time: ${quiz.startTime?.toLocal().toString() ?? 'Not specified'}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  'End Time: ${quiz.endTime?.toLocal().toString() ?? 'Not specified'}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  'Duration: ${quiz.duration?.toString() ?? 'Not specified'} minutes',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  'Total Score: ${quiz.totalScore?.toStringAsFixed(2) ?? 'Not specified'}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  'Category: ${quiz.categories?.toString() ?? 'Not specified'}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  'Description: ${quiz.description?.toString() ?? 'Not specified'}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit,
                                          color: LightColors.kBlue),
                                      onPressed: () {
                                        // Navigate to Edit Quiz page
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                      Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        bool confirmDelete = await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text("Delete Quiz"),
                                            content: Text(
                                                "Are you sure you want to delete this quiz?"),
                                            actions: [
                                              TextButton(
                                                child: Text("Cancel"),
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                              ),
                                              TextButton(
                                                child: Text("Delete",
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmDelete) {
                                          await _firestoreService
                                              .deleteQuiz(quiz.id!);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text('Quiz deleted')),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}