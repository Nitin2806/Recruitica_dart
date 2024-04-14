import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late int _newPostID;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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

  Future<void> _getNextPostID() async {
    final DatabaseReference usersReference =
        FirebaseDatabase.instance.reference().child('posts');
    DataSnapshot snapshot;
    try {
      await usersReference
          .orderByChild('postID')
          .limitToLast(1)
          .once()
          .then((event) {
        snapshot = event.snapshot;
        if (snapshot.value != null) {
          Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

          if (data != null && data.isNotEmpty) {
            print("NEW Post ID: $data");

            int lastUserID = data.values.first['postID'];
            print("NEW Post ID: $lastUserID");
            _newPostID = lastUserID + 1;
          }
        } else {
          _newPostID = 1;
        }
      });
    } catch (error) {
      print('Error retrieving user data: $error');
    }
  }

  Future<void> _addPost() async {
    await _getNextPostID();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // print("User found : $user");
      String userUID = user.uid;
      String userID = "";

      DatabaseReference usersRef =
          FirebaseDatabase.instance.reference().child('users');

      DataSnapshot userSnapshot =
          (await usersRef.child(userUID).once()).snapshot;

      // print("Get snap : ${userSnapshot.runtimeType}");

      if (userSnapshot.value != null) {
        Map<dynamic, dynamic>? userData =
            userSnapshot.value as Map<dynamic, dynamic>?;

        if (userData != null && userData.containsKey('userID')) {
          dynamic userUserID = userData['userID'];
          // print("Printing user userid: $userUserID");
          userID = userUserID.toString();
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
        'postID': _newPostID,
        'userID': userID,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post added successfully!'),
          ),
        );
      }).catchError((error) {
        // print('Error adding post: $error');
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Create Post",
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Title',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write a description',
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide.none,
              ),
              filled: true,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(143, 148, 251, 1),
                  Color.fromRGBO(243, 148, 251, .6),
                ],
              ),
            ),
            child: ElevatedButton(
              onPressed: () => _addPost(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Center(
                child: Text(
                  "Add Post",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: CreatePost(),
  ));
}
