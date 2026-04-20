import 'package:flutter/material.dart';

class LawyerListScreen extends StatelessWidget {
  const LawyerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Lawyer List\nComing Soon 🚀",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
