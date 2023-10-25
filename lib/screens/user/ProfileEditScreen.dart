import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  _fetchProfileData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    _nameController.text = userData['displayName'] ?? '';
    _photoUrlController.text = userData['photoURL'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.blueGrey,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              NetworkImage(_photoUrlController.text),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.blueGrey),
                              onPressed: _updatePhoto,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Display Name",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _nameController,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a name' : null,
                    decoration: const InputDecoration(
                      hintText: "Enter your display name",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .update({
        'displayName': _nameController.text,
        'photoURL': _photoUrlController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated!")),
      );
    }
  }

  void _updatePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${currentUser?.uid}.jpg');
        await ref.putFile(imageFile);

        final url = await ref.getDownloadURL();
        _photoUrlController.text = url;

        setState(() {});
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload image.")),
        );
      }
    }
  }

}
