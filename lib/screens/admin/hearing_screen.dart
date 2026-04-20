import 'package:flutter/material.dart';

class HearingScreen extends StatelessWidget {
  const HearingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Upcoming Hearing\nComing Soon 🚀",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
