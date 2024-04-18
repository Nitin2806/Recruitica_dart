import 'package:flutter/material.dart';
import '../models/user.dart';

class CandidateDetail extends StatelessWidget {
  final Candidate candidate;

  const CandidateDetail(
      {super.key,
      required this.candidate}); // Get the candidate information from candidate page

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      //Scrollview for handling the page
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Add all information in column
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              //Display image of the user
              child: CircleAvatar(
                backgroundImage: NetworkImage(candidate.imageUrl),
                radius: 100,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              candidate.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              candidate.bio,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            //Other information about the user
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            // Using a function to store information
            _buildDetailRow('Company', candidate.company),
            const SizedBox(height: 12),
            _buildDetailRow('Location', candidate.location),
            const SizedBox(height: 12),
            _buildDetailRow('Email', candidate.email),
            const SizedBox(height: 12),
            _buildDetailRow('Gender', candidate.gender),
          ],
        ),
      ),
    );
  }

//Get the data for label and value to display information's to decrease the code for same elemments
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
