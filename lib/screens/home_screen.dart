import 'package:flutter/material.dart';
import '../widgets/navbar/top_navbar.dart';
import '../widgets/home/quick_actions.dart';
import '../widgets/home/legal_tips_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TopNavbar(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  QuickActions(), // 🔥 your 4 categories
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  LegalTipsSection(), // � legal tips
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
