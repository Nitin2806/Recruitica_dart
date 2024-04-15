import 'package:flutter/material.dart';

class JobDetail extends StatelessWidget {
  const JobDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Detail'),
      ),
      body: const Center(
        child: Text('Job Detail Screen'),
      ),
    );
  }
}
