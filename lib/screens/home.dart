import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recruitica/models/post.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final DatabaseReference postsReference =
      FirebaseDatabase.instance.reference().child('posts');
  final DatabaseReference connectionsReference =
      FirebaseDatabase.instance.reference().child('connections');

  HomePage({required this.title});

  final String title;

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
          // print("userID${uid}");

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
              // print("userID from home ${data}");
              final List<String> connectedUserIDs = [];

              if (data != null && data is List && data.length > 1) {
                for (var i = 1; i < data.length; i++) {
                  if (data[i] != null && data[i] is bool && data[i]) {
                    // print("userID from home ${i}");
                    connectedUserIDs.add(i.toString());
                  }
                }
              }

              return StreamBuilder(
                stream: postsReference.onValue,
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

                  final List<Post> posts = [];
                  final postData = snapshot.data!.snapshot.value;

                  if (postData != null && postData is List) {
                    for (var i = 1; i < postData.length; i++) {
                      final post = postData[i];
                      if (post != null && post is Map) {
                        final postUserID = post['userID'].toString();
                        if (connectedUserIDs.contains(postUserID)) {
                          posts.add(Post(
                            name: post['title'] ?? '',
                            imageUrl: post['imageURL'] ?? '',
                            description: post['description'] ?? '',
                          ));
                        }
                      }
                    }
                  }

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(posts[index].imageUrl),
                                ),
                                title: Text(posts[index].name),
                              ),
                              Image.network(
                                posts[index].imageUrl,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  posts[index].description,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              ButtonBar(
                                alignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.thumb_up),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.comment),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
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
