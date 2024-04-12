import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../main.dart';
import 'home.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String? _selectedGender;
  late int _newUserID;

  Future<void> _getNextUserID() async {
    final DatabaseReference usersReference =
        FirebaseDatabase.instance.reference().child('users');
    DataSnapshot snapshot;
    try {
      await usersReference
          .orderByChild('userID')
          .limitToLast(1)
          .once()
          .then((event) {
        snapshot = event.snapshot;
        if (snapshot.value != null) {
          Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          if (data != null && data.isNotEmpty) {
            int lastUserID = data.values.first['userID'];
            _newUserID = lastUserID + 1;
          }
        } else {
          _newUserID = 1;
        }
      });
    } catch (error) {
      print('Error retrieving user data: $error');
    }
  }

  void _registerWithEmailAndPassword(BuildContext context) async {
    try {
      await _getNextUserID();

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final DatabaseReference usersReference =
          FirebaseDatabase.instance.reference().child('users');
      await usersReference.child(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'gender': _selectedGender,
        'location': _locationController.text.trim(),
        'company': _companyController.text.trim(),
        'bio': _bioController.text.trim(),
        'photo':
            "https://firebasestorage.googleapis.com/v0/b/recruitica-8c2be.appspot.com/o/logo.png?alt=media&token=9ec2840c-c6d7-4ac0-a75a-c2dbce9f3715",
        'userID': _newUserID,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } catch (e) {
      print("Error registering user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12.0),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: ['Male', 'Female', 'Other']
                  .map((gender) => DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12.0),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Company',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _registerWithEmailAndPassword(context),
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
