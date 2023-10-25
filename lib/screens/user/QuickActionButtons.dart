import 'package:flutter/material.dart';
import 'HistoryPage.dart';
import 'SettingsPage.dart';

class QuickActionButtons extends StatelessWidget {
  const QuickActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _actionButton(Icons.history, "History", Colors.orange, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const HistoryPage())); // Adjust as necessary
          }),
          _actionButton(Icons.settings, "Settings", Colors.blue, () {
            // Navigate to Settings Page
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const SettingsPage())); // Adjust as necessary
          }),
          _actionButton(Icons.leaderboard, "Rankings", Colors.green, () {
            // Navigate to Rankings Page
          }),
        ],
      ),
    );
  }

  Widget _actionButton(
      IconData icon, String label, Color color, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.7),
                  color,
                ],
              ),
            ),
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
