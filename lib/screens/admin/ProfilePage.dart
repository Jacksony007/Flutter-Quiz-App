import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../theme/colors/light_colors.dart';
import '../../widgets/back_button.dart';
import '../../widgets/my_text_field.dart';
import '../../widgets/top_container.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  User? currentUser;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    _nameController.text = currentUser?.displayName ?? 'Admin';
    _emailController.text = currentUser?.email ?? 'Email not available';
    _phoneController.text = currentUser?.phoneNumber ?? 'PhoneNumber not set';
  }

  _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Call the function to save the user's info
        _saveProfileData();
      }
    });
  }

  _saveProfileData() async {
    String newDisplayName = _nameController.text;
    String newEmail = _emailController.text;
    String newPhoneNumber = _phoneController.text;

    await FirestoreService().updateUserInfo(
        currentUser!.uid, newDisplayName, newEmail, newPhoneNumber
    );

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User information updated'))
    );
  }


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
                  CircleAvatar(
                    radius: 60.0,
                    backgroundImage:
                        AssetImage('assets/images/default_avatar.png'),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    _nameController.text,
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                  Text(
                    _emailController.text,
                    style: TextStyle(
                      color: Colors.blueGrey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  MyTextField(
                    controller: _nameController,
                    label: 'Name',
                    icon: Icon(Icons.person),
                    enabled: _isEditing,
                  ),
                  SizedBox(height: 20.0),
                  MyTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icon(Icons.email),
                    enabled: _isEditing,
                  ),
                  SizedBox(height: 20.0),
                  MyTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icon(Icons.phone_iphone),
                    enabled: _isEditing,
                  ),
                  SizedBox(height: 20.0),
                  _styledButton(
                      _isEditing ? 'Save' : 'Edit Profile',
                      LightColors.kBlue,
                      _isEditing ? Icons.save : Icons.edit,
                      _toggleEditMode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _styledButton(
      String title, Color color, IconData iconData, Function onPressed) {
    return ElevatedButton.icon(
      icon: Icon(iconData, color: Colors.white),
      label: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color),
        padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      onPressed: () => _toggleEditMode(),
    );
  }
}
