import 'package:flutter/material.dart';

class AddLawyerScreen extends StatelessWidget {
  const AddLawyerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Add Lawyer\nComing Soon 🚀",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
