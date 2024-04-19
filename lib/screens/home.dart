import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recruitica/models/post.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
//Reference to firebase to fetch posts and connections collection
  final DatabaseReference postsReference =
      FirebaseDatabase.instance.ref('posts');
  final DatabaseReference connectionsReference =
      FirebaseDatabase.instance.ref('connections');

  HomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _auth.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            //If the fetching takes time load circular progress bar for loading
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
              //First get all the connections
              final List<String> connectedUserIDs = [];

              // print("USer data : $data");
              //Add all the connection userID to list of connecteduserID
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

                  //Get all the post based on the userID

                  if (postData != null && postData is List) {
                    for (var i = 1; i < postData.length; i++) {
                      final post = postData[i];
                      if (post != null && post is Map) {
                        final postUserID = post['userID'].toString();
                        //If post contain the userID of the connection collection then load the post
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

                  return posts.isEmpty
                      ? Center(
                          child: Text(
                            'No posts available.\nAdd new connections to see posts ',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      //builder to display all the item in list
                      : ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                elevation: 4,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
