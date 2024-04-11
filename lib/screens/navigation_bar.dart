import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recruitica/screens/candidates.dart';
import 'package:recruitica/screens/create_post.dart';
import 'package:recruitica/screens/home.dart';
import 'package:recruitica/screens/job_listings.dart';
import 'package:recruitica/screens/login.dart';

class Navigationmenu extends StatefulWidget {
  const Navigationmenu({Key? key}) : super(key: key);

  @override
  _NavigationmenuState createState() => _NavigationmenuState();
}

class _NavigationmenuState extends State<Navigationmenu> {
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

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
        backgroundColor: Colors.deepPurple,
        actions: [
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
        leading: Image.asset(
          'lib/images/logo.png',
          height: 40,
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.deepPurple,
        items: _buildBottomNavBarItems(),
      ),
    );
  }

  Widget _buildBody() {
    if (_auth.currentUser != null) {
      return _screens[_currentIndex];
    } else {
      return LoginPage();
    }
  }

  List<BottomNavigationBarItem> _buildBottomNavBarItems() {
    if (_auth.currentUser != null) {
      return const [
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
      ];
    } else {
      return const [
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
        BottomNavigationBarItem(
          icon: Icon(Icons.login),
          label: 'Login',
        ),
      ];
    }
  }

  final List<Widget> _screens = [
    HomePage(title: "Home"),
    CandidatePage(),
    const CreatePost(),
    const JobListings(),
  ];

  void _logout() async {
    await _auth.signOut();
    setState(() {});
  }
}
