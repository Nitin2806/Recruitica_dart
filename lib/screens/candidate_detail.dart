import 'package:flutter/material.dart';

import '../models/user.dart';

class CandidateDetail extends StatelessWidget {
  final Candidate candidate;

  const CandidateDetail({super.key, required this.candidate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidate Detail'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(candidate.imageUrl),
              radius: 50,
            ),
            const SizedBox(height: 20),
            Text(
              candidate.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              candidate.position,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
