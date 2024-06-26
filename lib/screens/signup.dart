import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../main.dart';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  //Controller for getting field data
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordVerifyController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String? _selectedGender;
  late int _newUserID;
  String _errorMessage = '';
// Getting the last user ID
  Future<void> _getNextUserID() async {
    //get firebase instance for users collection
    final DatabaseReference usersReference =
        FirebaseDatabase.instance.ref('users');
    //Based on the snapshot received find the userID from the object
    DataSnapshot snapshot;
    try {
      // get the users from snapchat and order by ID and then fetch last user
      await usersReference
          .orderByChild('userID')
          .limitToLast(1)
          .once()
          .then((event) {
        snapshot = event.snapshot;
        if (snapshot.value != null) {
          Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          if (data.isNotEmpty) {
            int lastUserID = data.values.first['userID'];
            // increase the value for userID with 1 to assign for new user
            _newUserID = lastUserID + 1;
          }
        } else {
          // if no user then assign it as user 1
          _newUserID = 1;
        }
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error retrieving user data: $error');
      }
    }
  }

// Function to register user
  void _registerWithEmailAndPassword(BuildContext context) async {
    try {
      //Validate user email and password and display error accordingly
      if (_emailController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty) {
        setState(() {
          _errorMessage = 'Please enter email and password';
        });
        return;
      }

      if (_passwordController.text.trim() !=
          _passwordVerifyController.text.trim()) {
        setState(() {
          _errorMessage = 'Password does not match!';
        });
        return;
      }

      await _getNextUserID(); // Wait to fetch next user id

      // After everything goes fine and user ID is recieved create the user in the firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // instance for the users collections
      final DatabaseReference usersReference =
          FirebaseDatabase.instance.ref('users');
// add the data of user to firebase users collection when new user is created
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

      //once everything is fine push it to the main app which will load navigation

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error registering user: $e");
      }
      setState(() {
        _errorMessage = 'Error registering user. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //Add background image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, top: 40.0, right: 16.0, bottom: 16.0),
          child: Center(
            //Add scrollview to the page for multiple content
            child: SingleChildScrollView(
              child: Column(
                // Container for heading
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create new account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32.0),
                  //Textfields for signup page
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: "Name",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordVerifyController,
                    decoration: const InputDecoration(
                      hintText: "Re-enter Password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Gender",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((gender) => DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: "Location",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _companyController,
                    decoration: const InputDecoration(
                      hintText: "Company",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      hintText: "Bio",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32.0),
                  // Style container for signup
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromRGBO(143, 148, 251, 0.9),
                          Color.fromRGBO(143, 110, 251, 0.9),
                        ],
                      ),
                    ),
                    //button for signup
                    child: ElevatedButton(
                      onPressed: () {
                        _registerWithEmailAndPassword(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Create account',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  //Display error message text
                  if (_errorMessage.isNotEmpty) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 8.0,
                        ),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  Row(
                    // Row for login option to display two text
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                              color: Color.fromRGBO(143, 148, 251, 1)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
