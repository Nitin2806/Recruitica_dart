import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recruitica/models/user.dart';
import 'package:recruitica/screens/candidate_detail.dart';

class CandidatePage extends StatefulWidget {
  @override
  _CandidatePageState createState() => _CandidatePageState();
}

class _CandidatePageState extends State<CandidatePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _usersReference =
      FirebaseDatabase.instance.reference().child('users');
  final DatabaseReference _connectionsReference =
      FirebaseDatabase.instance.reference().child('connections');
  final DatabaseReference connectionsReference =
      FirebaseDatabase.instance.reference().child('connections');

  StreamSubscription? _userSubscription;
  StreamSubscription? _connectionsSubscription;

  @override
  void initState() {
    super.initState();
    _resetStreamSubscriptions();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _connectionsSubscription?.cancel();
    super.dispose();
  }

  void _resetStreamSubscriptions() {
    _userSubscription?.cancel();
    _connectionsSubscription?.cancel();

    _userSubscription = _auth.authStateChanges().listen((authUser) {});

    _connectionsSubscription = connectionsReference
        .child(_auth.currentUser?.uid ?? '')
        .onValue
        .listen((connectionsSnapshot) {});
  }

  Future<void> _connectUser(int userId) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String currentUserUid = user.uid;
        print("Current userID: ${currentUserUid} ${userId}");
        await _connectionsReference
            .child(currentUserUid)
            .child(userId.toString())
            .set(true);
      }
    } catch (error) {
      print("Error connecting user: $error");
    }
  }

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
      print("Error disconnecting user: $error");
    }
  }

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

              final List<Candidate> candidates = [];
              final userData = userSnapshot.data!.snapshot.value;

              if (userData != null && userData is Map) {
                userData.forEach((key, value) {
                  if (key != uid) {
                    int candidateUserId = value['userID'];

                    candidates.add(Candidate(
                      name: value['name'],
                      imageUrl: value['photo'],
                      position: value['bio'],
                      userID: candidateUserId,
                    ));
                  }
                });
              }
              return StreamBuilder(
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
                  final List<String> connectedUserIDs = [];
                  print("USer data : ${data}");

                  if (data != null && data is List && data.length > 1) {
                    for (var i = 1; i < data.length; i++) {
                      if (data[i] != null && data[i] is bool && data[i]) {
                        print("USer ID : ${i}");
                        connectedUserIDs.add(i.toString());
                      }
                    }
                  }
                  print(connectedUserIDs);
                  return ListView.builder(
                    itemCount: candidates.length,
                    itemBuilder: (context, index) {
                      Candidate candidate = candidates[index];

                      bool isConnected = connectedUserIDs
                          .contains(candidate.userID.toString());

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 4,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(candidate.imageUrl),
                            ),
                            title: Text(candidate.name),
                            subtitle: Text(candidate.position),
                            onTap: () {
                              // Navigate to candidate detail screen
                            },
                            trailing: isConnected
                                ? ElevatedButton(
                                    onPressed: () {
                                      _disconnectUser(int.parse(
                                          candidate.userID.toString()));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .red, // Set the background color to red
                                    ),
                                    child: const Text('Remove',
                                        style: TextStyle(color: Colors.white)),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      _connectUser(int.parse(
                                          candidate.userID.toString()));
                                    },
                                    child: const Text('Connect'),
                                  ),
                          ),
                        ),
                      );
                    },
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
