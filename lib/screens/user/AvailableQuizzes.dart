import 'package:flutter/material.dart';
import 'package:quiz_app/screens/user/quiz_screen.dart';
import '../../models/quiz.dart';
import '../../services/firestore_service.dart';

class AvailableQuizzes extends StatelessWidget {
  final String userId;

  const AvailableQuizzes({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Available Quizzes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF536DFE),
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Quiz>>(
          stream: FirestoreService().getAvailableQuizzes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                  child: Text('Error fetching quizzes',
                      style: TextStyle(color: Colors.red)));
            } else {
              List<Quiz> quizzes = snapshot.data!;
              if (quizzes.isEmpty) {
                return const Center(
                    child: Text('No quizzes available',
                        style: TextStyle(color: Colors.grey)));
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: quizzes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];
                  final now = DateTime.now();

                  DateTime? endTime = quiz.endTime;
                  DateTime? startTime = quiz.startTime;

                  bool isLocked = (startTime == null || endTime == null) ||
                      now.isBefore(startTime) ||
                      now.isAfter(endTime);
                  bool hasAttempted = quiz.attempts?.contains(userId) ?? false;

                  return InkWell(
                    onTap: () {
                      // Check if the user has already attempted the quiz or if the quiz is locked
                      if (!hasAttempted && !isLocked) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => QuizScreen(quizId: quiz.id!),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            hasAttempted
                                ? 'You have already attempted this quiz.'
                                : 'This quiz is currently locked.',
                          ),
                        ));
                      }
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    quiz.title.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Icon(Icons.assignment, color: Colors.green),
                              ],
                            ),
                            Divider(color: Colors.grey[300], thickness: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Start: ${formatDate(startTime ?? DateTime.now())}",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Text(
                                  "End: ${formatDate(endTime ?? DateTime.now())}",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Duration: ${quiz.duration} minutes",
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              // This will ensure equal spacing between items
                              children: [
                                // Display Locked Status
                                Row(
                                  children: [
                                    Icon(Icons.lock,
                                        color: isLocked
                                            ? Colors.red
                                            : Colors.grey[400]),
                                    const SizedBox(width: 4),
                                    // Reduced width for tighter spacing
                                    Text(
                                      isLocked ? "Locked" : "Unlocked",
                                      style: TextStyle(
                                        color: isLocked
                                            ? Colors.red
                                            : Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),

                                // Display Attempted Status
                                Row(
                                  children: [
                                    Icon(
                                      hasAttempted
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: hasAttempted
                                          ? Colors.green
                                          : Colors.grey[400],
                                    ),
                                    const SizedBox(width: 4),
                                    // Reduced width for tighter spacing
                                    Text(
                                      hasAttempted
                                          ? "Attempted"
                                          : "Not Attempted",
                                      style: TextStyle(
                                        color: hasAttempted
                                            ? Colors.green
                                            : Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }

  String formatDate(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}";
  }
}
