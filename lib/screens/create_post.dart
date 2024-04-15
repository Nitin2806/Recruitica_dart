import 'package:flutter/foundation.dart';
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
  late int _newJobListingID;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  String _selectedType = 'Post'; // Default value

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

  Future<void> _getNextJobListingID() async {
    final DatabaseReference jobListingsReference =
        FirebaseDatabase.instance.ref('joblistings');
    DataSnapshot snapshot;
    try {
      await jobListingsReference.once().then((event) {
        snapshot = event.snapshot;
        if (snapshot.value != null) {
          List<dynamic> data = snapshot.value as List<dynamic>;
          // print("Printing Data for job listings : ${data}");
          if (data.isNotEmpty) {
            int lastJobListingID = 0;
            for (var item in data) {
              if (item != null && item['id'] != null) {
                // print("Printing Data for job listings : ${item}");
                int jobListingID = item['id'];
                if (jobListingID > lastJobListingID) {
                  lastJobListingID = jobListingID;
                }
              }
            }

            _newJobListingID = lastJobListingID + 1;
            // print("Printing Job lisiting new one : ${_newJobListingID}");
          }
        } else {
          _newJobListingID = 1;
        }
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error retrieving job listings data: $error');
      }
    }
  }

  Future<void> _addJobListing() async {
    await _getNextJobListingID();

    DatabaseReference jobListingsRef =
        FirebaseDatabase.instance.ref('joblistings');

    try {
      await jobListingsRef.child(_newJobListingID.toString()).set({
        'companyName': _companyNameController.text,
        'location': _locationController.text,
        'salary': _salaryController.text,
        'title': _titleController.text,
        'id': _newJobListingID,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job listing added successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add job listing: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getNextPostID() async {
    final DatabaseReference usersReference =
        FirebaseDatabase.instance.ref('posts');
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

          if (data.isNotEmpty) {
            // print("NEW Post ID: $data");

            int lastUserID = data.values.first['postID'];
            // print("NEW Post ID: $lastUserID");
            _newPostID = lastUserID + 1;
          }
        } else {
          _newPostID = 1;
        }
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error retrieving user data: $error');
      }
    }
  }

  Future<void> _addPost() async {
    await _getNextPostID();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // print("User found : $user");
      String userUID = user.uid;
      String userID = "";

      DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');

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
      DatabaseReference postsRef = FirebaseDatabase.instance.ref('posts');

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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Stack(
            children: [
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
          const Text(
            "Create Post",
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            items: ['Post', 'Job Listing']
                .map<DropdownMenuItem<String>>(
                  (value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                          color: Colors.black), // Adjust text color if needed
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
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
          if (_selectedType == 'Job Listing') ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyNameController,
              decoration: const InputDecoration(
                hintText: 'Company Name',
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
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'Location',
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
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Salary',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
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
              onPressed: () => {
                if (_selectedType == 'Job Listing')
                  {_addJobListing()}
                else
                  {_addPost()}
              },
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
