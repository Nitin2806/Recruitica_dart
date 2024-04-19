import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recruitica/screens/candidates.dart';
import 'package:recruitica/screens/create_post.dart';
import 'package:recruitica/screens/home.dart';
import 'package:recruitica/screens/job_listings.dart';
import 'package:recruitica/screens/login.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  _NavigationState createState() => _NavigationState(); //creating a state
}

class _NavigationState extends State<Navigation> {
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance; //Creating Firebase Instance
  Color blueApp = const Color(0xFF5D63D4); //Color for AppBar

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

//Function to check if user is authenticated and assigned the index
  void _checkAuth() {
    if (_auth.currentUser != null) {
      setState(() {
        _currentIndex = 0;
      });
    } else {
      setState(() {
        _currentIndex = 4;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recruitica',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: blueApp,
        actions: [
          //Icon Button for Log out based on the login status of the user
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          if (_auth.currentUser != null)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () {
                _logout();
              },
            ),
        ],
        //App bar Logo
        leading: Image.asset(
          'lib/images/logo.png',
          height: 40,
        ),
      ),
      body: _buildBody(),
      //Load the Icons if user is loggedin
      bottomNavigationBar: _auth.currentUser != null
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              unselectedItemColor: Colors.black,
              selectedItemColor: Colors.deepPurple,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Candidates',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: 'Create Post',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.work),
                  label: 'Job Listings',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_auth.currentUser != null) {
      // If user is not loggedin  return to login page
      return _screens[_currentIndex];
    } else {
      return const LoginPage();
    }
  }

  final List<Widget> _screens = [
    //List for widgets to be loaded based on navigation selected
    HomePage(title: "Home"),
    const CandidatePage(),
    const CreatePost(),
    const JobListings(),
  ];

  void _logout() async {
    //Function tologout
    await _auth.signOut();
    setState(() {});
  }
}
