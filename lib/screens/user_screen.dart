import 'package:flutter/material.dart';
import '../widgets/user/user_action_section.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),

          // 🔥 ONLY IMPORTED WIDGET USED HERE
          const UserActionSection(),
        ],
      ),
    );
  }
}
