import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class JobListings extends StatefulWidget {
  const JobListings({super.key});

  @override
  _JobListingsState createState() => _JobListingsState();
}

class _JobListingsState extends State<JobListings>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final databaseReference = FirebaseDatabase.instance.reference();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Set<String> _appliedJobIds = {};

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

    _fetchAppliedJobs();
  }

  void _fetchAppliedJobs() async {
    final user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      final dataSnapshot = await databaseReference
          .child('appliedjobs')
          .orderByChild('uid')
          .equalTo(uid)
          .once();
      // print("Applied job ${dataSnapshot.snapshot.value}");
      if (dataSnapshot.snapshot.value != null) {
        final data = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
        final List<int> jobIds = [];
        data.forEach((key, value) {
          if (value['jobDetails']['id'] is int) {
            jobIds.add(value['jobDetails']['id']);
          }
        });

        _appliedJobIds = jobIds.map((id) => id.toString()).toSet();

        // print(_appliedJobIds);
      }

      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    return StreamBuilder(
      stream: databaseReference.child('joblistings').onValue,
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
        final List<Widget> jobTiles = [];
        final dynamic data = snapshot.data!.snapshot.value;

        if (data != null && data is List) {
          for (var i = 1; i < data.length; i++) {
            final jobData = data[i];
            if (jobData is Map<dynamic, dynamic>) {
              jobTiles.add(_buildJobTile(jobData));
            }
          }
        }
        return ListView(
          children: jobTiles,
        );
      },
    );
  }

  Widget _buildJobTile(Map<dynamic, dynamic> jobData) {
    final jobId = jobData['id'].toString();
    // print(jobId);
    final isApplied = _appliedJobIds.contains(jobId);
    // print(isApplied);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        child: ListTile(
          title: Text(
            jobData['title'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('Company Name: ${jobData['companyName']}'),
              const SizedBox(height: 4),
              Text('Location: ${jobData['location']}'),
              const SizedBox(height: 4),
              Text('Salary: ${jobData['salary']}'),
            ],
          ),
          trailing: isApplied
              ? ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Applied',
                      style: TextStyle(color: Colors.white)),
                )
              : ElevatedButton(
                  onPressed: () => _applyForJob(jobData),
                  child: const Text('Apply'),
                ),
        ),
      ),
    );
  }

  void _applyForJob(Map<dynamic, dynamic> jobData) async {
    final user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      final jobApplicationKey =
          databaseReference.child('appliedjobs').push().key;
      final jobApplicationData = {
        'uid': uid,
        'jobDetails': jobData,
      };

      await databaseReference
          .child('appliedjobs')
          .child(jobApplicationKey!)
          .set(jobApplicationData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Applied for ${jobData['title']}'),
        ),
      );

      _fetchAppliedJobs();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated.'),
        ),
      );
    }
  }
}
