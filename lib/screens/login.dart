import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recruitica/screens/navigation_bar.dart';
import 'package:recruitica/screens/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //Controller for Getting user entered data
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
//Creating Firebase Instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //String to store error message
  String _errorMessage = '';
  //Function to run when pressed login
  void _signInWithEmailAndPassword(BuildContext context) async {
    try {
      //trimming the email and password from controller
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
//If email or password is empty display error message
      if (email.isEmpty || password.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter email and password';
        });
        return;
      }
//User Firebase auth verify credentials
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
//If verified run the navigation  page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Navigation()),
      );
    } on FirebaseAuthException catch (e) {
      // print(e.code);
      //based on the error code show the errors
      if (e.code == 'invalid-credential') {
        setState(() {
          _errorMessage = 'Invalid Email or password';
        });
      } else {
        setState(() {
          _errorMessage = 'Error: ${e.message}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            //Used container for the overall screen to add a background image
            Container(
              height: 600,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                // Adding login header
                children: <Widget>[
                  Positioned(
                    child: Container(
                      margin: const EdgeInsets.only(top: 50),
                      child: const Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30.0, top: 0.0, right: 30.0, bottom: 30.0),
              child: Column(
                //adding fields boxes
                children: <Widget>[
                  Container(
                    // container for fields
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color.fromRGBO(143, 148, 251, 1),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(143, 148, 251, .2),
                          blurRadius: 20.0,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromRGBO(143, 148, 251, 1),
                              ),
                            ),
                          ),
                          //text fied for email
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Email",
                              hintStyle: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ),
                        Container(
                          //text field for password
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Password",
                              hintStyle: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    //styling container for button
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromRGBO(143, 148, 251, 1),
                          Color.fromRGBO(143, 148, 251, .6),
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () => _signInWithEmailAndPassword(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  //text for error message
                  if (_errorMessage.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  Row(
                    // adding signup option for user if account not created
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpPage()),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                              color: Color.fromRGBO(143, 148, 251, 1)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
