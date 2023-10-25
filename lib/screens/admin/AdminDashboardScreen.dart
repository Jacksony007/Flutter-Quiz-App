import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:percent_indicator/percent_indicator.dart';

import '../../theme/colors/light_colors.dart';
import '../../widgets/active_project_card.dart';
import '../../widgets/task_column.dart';
import '../../widgets/top_container.dart';
import 'SearchBarWidget.dart';
import 'StylishDrawer.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth
      .instance; // Add this line to access the current user details.

  Text subheading(String title) {
    return Text(
      title,
      style: TextStyle(
          color: LightColors.kDarkBlue,
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2),
    );
  }

  static CircleAvatar calendarIcon() {
    return CircleAvatar(
      radius: 25.0,
      backgroundColor: LightColors.kGreen,
      child: Icon(
        Icons.calendar_today,
        size: 20.0,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // Access the current logged-in user.
    final User? currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      // Drawer for menu items
      drawer: StylishDrawer(),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TopContainer(
              height: 200,
              width: width,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SearchBarWidget(
                    onSearch: (searchTerm) {
                      // Handle the search logic here, if necessary
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 0.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        CircularPercentIndicator(
                          radius: 50.0,
                          lineWidth: 5.0,
                          animation: true,
                          percent: 0.75,
                          // Modify as needed.
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: LightColors.kRed,
                          backgroundColor: LightColors.kDarkYellow,
                          center: CircleAvatar(
                            backgroundColor: LightColors.kBlue,
                            radius: 35.0,
                            backgroundImage: NetworkImage(
                                "assets/images/default_avatar.png"), // Default image when user's photoURL is null.
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Text(
                                currentUser?.displayName ?? 'Quiz App Admin',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 22.0,
                                  color: LightColors.kDarkBlue,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                currentUser?.email ?? 'Email not available',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black45,
                                  fontWeight: FontWeight.w400,
                                ),
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
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              subheading('My Tasks'),
                              GestureDetector(
                                onTap: () {},
                                child: calendarIcon(),
                              ),
                            ],
                          ),
                          SizedBox(height: 15.0),
                          TaskColumn(
                            icon: Icons.question_answer,
                            iconBackgroundColor: LightColors.kRed,
                            title: 'Add Question',
                            subtitle: 'Tap to add questions.',
                            onTap: () => Navigator.of(context)
                                .pushNamed('/Admin_add_question'),
                          ),
                          SizedBox(height: 15.0),
                          TaskColumn(
                            icon: Icons.list,
                            iconBackgroundColor: LightColors.kDarkYellow,
                            title: 'Manage Questions',
                            subtitle: 'Tap to manage questions.',
                            onTap: () => Navigator.of(context)
                                .pushNamed('/adminManageQuestions'),
                          ),
                          SizedBox(height: 15.0),
                          TaskColumn(
                            icon: Icons.add_box,
                            iconBackgroundColor: LightColors.kBlue,
                            title: 'Add Quiz',
                            subtitle: 'Tap to add a quiz.',
                            onTap: () => Navigator.of(context)
                                .pushNamed('/Admin_add_quiz_screen'),
                          ),
                          SizedBox(height: 15.0),
                          TaskColumn(
                            icon: Icons.edit,
                            iconBackgroundColor: LightColors.kGreen,
                            title: 'Manage Quizzes',
                            subtitle: 'Tap to manage quizzes.',
                            onTap: () => Navigator.of(context)
                                .pushNamed('/adminManageQuizzes'),
                          ),
                          // ... Keep the rest of the widgets if any
                        ],
                      ),
                    ),
                    // ... Keep the rest of your ActiveProjects and other parts unchanged
                    Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          subheading('Active Projects'),
                          SizedBox(height: 5.0),
                          Row(
                            children: <Widget>[
                              ActiveProjectsCard(
                                cardColor: LightColors.kGreen,
                                loadingPercent: 0.25,
                                title: 'Medical App',
                                subtitle: '9 hours progress',
                              ),
                              SizedBox(width: 20.0),
                              ActiveProjectsCard(
                                cardColor: LightColors.kRed,
                                loadingPercent: 0.6,
                                title: 'Making History Notes',
                                subtitle: '20 hours progress',
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              ActiveProjectsCard(
                                cardColor: LightColors.kDarkYellow,
                                loadingPercent: 0.45,
                                title: 'Sports App',
                                subtitle: '5 hours progress',
                              ),
                              SizedBox(width: 20.0),
                              ActiveProjectsCard(
                                cardColor: LightColors.kBlue,
                                loadingPercent: 0.9,
                                title: 'Online Flutter Course',
                                subtitle: '23 hours progress',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
