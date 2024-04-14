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

                  // print("USer data : $data");

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
                                      ElevatedButton(
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
