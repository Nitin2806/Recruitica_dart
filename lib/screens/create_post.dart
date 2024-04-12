import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({Key? key}) : super(key: key);

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _addPost() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print(user);
      String userUID = user.uid;
      String userID = "";

      DatabaseReference usersRef =
          FirebaseDatabase.instance.reference().child('users');

      DataSnapshot userSnapshot =
          (await usersRef.child(userUID).once()).snapshot;

      print("Get snapp : ${userSnapshot.runtimeType}");

      if (userSnapshot.value != null) {
        Map<dynamic, dynamic>? userData =
            userSnapshot.value as Map<dynamic, dynamic>?;

        if (userData != null && userData.containsKey('userID')) {
          dynamic userUserID = userData['userID'];
          userID = userUserID.toString();

          print('UserID from users collection: $userUserID');
        }
      }

      DatabaseReference postsRef =
          FirebaseDatabase.instance.reference().child('posts');

      DataSnapshot snapshot = (await postsRef.once()).snapshot;

      int newPostKey = 1;
      if (snapshot.value != null) {
        if (snapshot.value is Map) {
          newPostKey = (snapshot.value as Map).length;
        } else if (snapshot.value is List) {
          newPostKey = (snapshot.value as List).length;
        }
      }

      postsRef.child(newPostKey.toString()).set({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'imageURL': 'https://fakeimg.pl/400x200',
        'likes': 0,
        'userID': userID,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post added successfully!'),
          ),
        );
      }).catchError((error) {
        print('Error adding post: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add post: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write a description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addPost,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Post',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CreatePost(),
  ));
}
