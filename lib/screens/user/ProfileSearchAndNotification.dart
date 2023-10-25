import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/screens/user/ProfileEditScreen.dart';

import '../../models/quiz.dart';
import '../../services/firestore_service.dart';

class ProfileSearchAndNotification extends StatefulWidget {
  final User? user;

  const ProfileSearchAndNotification({Key? key, this.user}) : super(key: key);

  @override
  _ProfileSearchAndNotificationState createState() =>
      _ProfileSearchAndNotificationState();
}

class _ProfileSearchAndNotificationState
    extends State<ProfileSearchAndNotification> {
  final TextEditingController _searchController = TextEditingController();
  int notificationCount = 0;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Quiz>>(
        stream: _firestoreService.getQuizzesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Filter out quizzes that this user has already attempted
            List<Quiz> unattemptedQuizzes = snapshot.data!.where((quiz) {
              return quiz.attempts == null ||
                  (quiz.attempts != null &&
                      !quiz.attempts!.contains(widget.user?.uid));
            }).toList();

            notificationCount = unattemptedQuizzes.length;
          }
          return Container(
            margin: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => const ProfileEditScreen()));
                              },
                              child: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(widget.user?.photoURL ?? ''),
                                radius: 30.0,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.user?.displayName ?? 'User',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: _editProfile,
                                      color: Colors.blue[800],
                                    ),
                                  ],
                                ),
                                Text(
                                  widget.user?.email ?? '',
                                  style: TextStyle(
                                    color: Colors.blueGrey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Stack(
                          children: <Widget>[
                            Icon(
                              Icons.notifications,
                              size: 30.0,
                              // Set the color based on the notification count
                              color: notificationCount > 0
                                  ? Colors.blueGrey
                                  : Colors.grey[400],
                            ),
                            if (notificationCount > 0)
                              Positioned(
                                right: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 12,
                                    minHeight: 12,
                                  ),
                                  child: Text(
                                    '$notificationCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 0),
                            blurRadius: 5.0,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search profiles...",
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                          border: InputBorder.none,
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.blueGrey),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _editProfile() {
    // Navigate to the profile editing screen
  }
}
