import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Constants
  static const String FIELD_NOTIFICATIONS = 'notifications';
  static const String FIELD_DARKMODE = 'darkMode';

  bool _notifications = true;
  bool _darkMode = false;
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('settings')
        .doc(userId)
        .get();
    if (doc.exists) {
      final settings = UserSettings.fromMap(doc.data() as Map<String, dynamic>);
      setState(() {
        _notifications = settings.notifications;
        _darkMode = settings.darkMode;
      });
    }
  }

  // Function to update user settings in Firestore
  _updateSetting(String field, bool value) async {
    FirebaseFirestore.instance.collection('settings').doc(userId).update({
      field: value,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0,
        title: const Text("Settings"),
        backgroundColor: Colors.deepPurple[400],
      ),
      body: ListView(
        children: <Widget>[
          _buildSettingsCategory("General"),
          _buildSettingTile(
              "Notifications", _notifications, FIELD_NOTIFICATIONS),
          _buildSettingTile("Dark Mode", _darkMode, FIELD_DARKMODE),
          const SizedBox(height: 20),
          _buildSettingsCategory("Account"),
          ListTile(
            title: const Text("Change Email"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              // Code to change email
            },
          ),
          ListTile(
            title: const Text("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              // Code to change password
            },
          ),
          ListTile(
            title: const Text("Delete Account"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              // Code to delete account
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCategory(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Colors.white,
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, bool value, String field) {
    return Container(
      color: Colors.white,
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: (bool newValue) {
          setState(() {
            if (field == FIELD_NOTIFICATIONS) {
              _notifications = newValue;
            } else if (field == FIELD_DARKMODE) {
              _darkMode = newValue;
            }
          });
          _updateSetting(field, newValue);
        },
        activeColor: Colors.deepPurple[400],
      ),
    );
  }
}
