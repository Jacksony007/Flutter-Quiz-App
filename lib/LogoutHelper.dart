import 'package:flutter/material.dart';
import 'package:quiz_app/services/auth_service.dart';

class LogoutHelper {
  final BuildContext context;

  LogoutHelper({required this.context});

  void logout() async {
    try {
      await AuthenticationService().signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to log out. Please try again.')));
    }
  }
}
