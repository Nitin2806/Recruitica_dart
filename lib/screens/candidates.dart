import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recruitica/models/user.dart';
import 'package:recruitica/screens/candidate_detail.dart';

class CandidatePage extends StatefulWidget {
  const CandidatePage({super.key});

  @override
  _CandidatePageState createState() => _CandidatePageState();
}

class _CandidatePageState extends State<CandidatePage> {
  //Create instance for firebase users and their connections
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final DatabaseReference _usersReference =
      FirebaseDatabase.instance.ref('users');
  final DatabaseReference _connectionsReference =
      FirebaseDatabase.instance.ref('connections');
  final DatabaseReference connectionsReference =
      FirebaseDatabase.instance.ref('connections');

// lines to declare variables to hold references to changes in auth
// The question mark checks for null
  StreamSubscription? _userSubscription;
  StreamSubscription? _connectionsSubscription;

// This runs when the app launches
  @override
  void initState() {
    super.initState(); // Call the superclass' version of this method first
    _resetStreamSubscriptions(); // This method sets up listeners
  }

// This method runs when the app is closed
  @override
  void dispose() {
    _userSubscription?.cancel(); // Stop listening for user changes
    _connectionsSubscription?.cancel(); // Stop listening for connection changes
    super.dispose(); // Call the superclass' version of this method
  }

// This method resets the listeners
  void _resetStreamSubscriptions() {
    // Stop any existing listeners
    _userSubscription?.cancel();
    _connectionsSubscription?.cancel();

    // User Auth Changes
    _userSubscription = _auth.authStateChanges().listen((authUser) {});

    // Connection Changes
    _connectionsSubscription = connectionsReference
        .child(_auth.currentUser?.uid ?? '')
        .onValue
        .listen((connectionsSnapshot) {});
  }

  //Function to connect user and add the data to collection of connections if user is added as connection
  Future<void> _connectUser(int userId) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String currentUserUid = user.uid;
        // print("Current userID: ${currentUserUid} ${userId}");
        await _connectionsReference
            .child(currentUserUid)
            .child(userId.toString())
            .set(true);
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error connecting user: $error");
      }
    }
  }
  //Function to disconnect user and remove the data of connections if user is removed as connection

  Future<void> _disconnectUser(int userId) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String currentUserUid = user.uid;
        await _connectionsReference
            .child(currentUserUid)
            .child(userId.toString())
            .remove();
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error disconnecting user: $error");
      }
    }
  }

  //UI for screen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _auth.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
// Stroing user snapshot
          User? user = authSnapshot.data;
          String? uid = user?.uid;

          return StreamBuilder(
            stream: _usersReference.onValue,
            builder: (context, userSnapshot) {
              // print("user : ${userSnapshot}");

              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (userSnapshot.hasError) {
                return Center(
                  child: Text('Error: ${userSnapshot.error}'),
                );
              }
              //list to store all candidates
              final List<Candidate> candidates = [];
// adding snapshot value to userData variable
              final userData = userSnapshot.data!.snapshot.value;

              if (userData != null && userData is Map) {
                //from userData list getting all the data sepeately and using the Candidate model to input data getter and setter
                userData.forEach((key, value) {
                  if (key != uid) {
                    int candidateUserId = value['userID'];

                    candidates.add(Candidate(
                      name: value['name'],
                      imageUrl: value['photo'],
                      bio: value['bio'],
                      company: value['company'],
                      email: value['email'],
                      location: value['location'],
                      gender: value['gender'],
                      userID: candidateUserId,
                    ));
                  }
                });
              }
              return StreamBuilder(
                // If it takes time do loading
                stream: connectionsReference.child(uid ?? '').onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  final data = snapshot.data!.snapshot.value;
                  // Now, check for connection to assign button condtions to connect
                  final List<String> connectedUserIDs = [];

                  // print("USer data : $data");
// Data for recieved in mutliple form therefore verifying data to be a map ro list and adding it to connectedUserIds list
                  if (data != null) {
                    if (data is Map) {
                      data.forEach((key, value) {
                        if (value is bool && value) {
                          // print("USer ID : $key");
                          connectedUserIDs.add(key.toString());
                        }
                      });
                    } else if (data is List) {
                      for (var i = 1; i < data.length; i++) {
                        if (data[i] != null && data[i] is bool && data[i]) {
                          // print("USer ID : $i");
                          connectedUserIDs.add(i.toString());
                        }
                      }
                    }
                  }

                  // print("Connected UserID array: $connectedUserIDs");
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      // Creating grid view
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 5.0,
                        mainAxisSpacing: 5.0,
                        childAspectRatio: 1,
                      ),
                      itemCount: candidates.length,
                      itemBuilder: (context, index) {
                        Candidate candidate = candidates[index];

                        bool isConnected = connectedUserIDs
                            .contains(candidate.userID.toString());
// creating card for each user
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CandidateDetail(candidate: candidate),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    //Container to display all deta in column
                                    height: 250,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(candidate.imageUrl),
                                        fit: BoxFit.contain,
                                      ),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        candidate.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        candidate.position,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      // Display button based on the condition if user is connected or not
                                      ElevatedButton(
                                        //is pressed on connected then disconnect to then recoonect
                                        onPressed: isConnected
                                            ? () {
                                                _disconnectUser(int.parse(
                                                    candidate.userID
                                                        .toString()));
                                              }
                                            : () {
                                                _connectUser(int.parse(candidate
                                                    .userID
                                                    .toString()));
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isConnected
                                              ? Colors.red
                                              : Colors.blue,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        //Change the text based on user connection status
                                        child: Text(
                                          isConnected ? 'Remove' : 'Connect',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
