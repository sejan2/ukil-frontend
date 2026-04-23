import 'package:flutter/material.dart';
import '../../widgets/forall/sidebar.dart';
import '../advocate/edit_profile.dart';
import '../advocate/manage_cases.dart'; // 🔥 NEW
import '../advocate/hearing_screen.dart';
import '../advocate/blog_screen.dart';
import '../advocate/notification.dart'; // 🔥 NEW

class AdvocatePanel extends StatefulWidget {
  const AdvocatePanel({super.key});

  @override
  State<AdvocatePanel> createState() => _AdvocatePanelState();
}

class _AdvocatePanelState extends State<AdvocatePanel> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return Scaffold(
      appBar: isMobile ? AppBar(title: const Text("Advocate Panel")) : null,
      drawer: isMobile
          ? Drawer(
              child: AdminSidebar(
                selectedIndex: selectedIndex,
                onItemSelected: (i) => setState(() => selectedIndex = i),
                onItemTapClose: () => Navigator.pop(context),
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            AdminSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: (i) => setState(() => selectedIndex = i),
            ),
          Expanded(
            child: Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.all(20),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return _dashboard();
      case 1:
        return const EditProfileScreen(); // Edit Profile
      case 2:
        return const ManageCasesScreen(); // 🔥 Manage Cases
      case 3:
        return const HearingScreen(); // Upcoming Hearing
      case 4:
        return const BlogScreen(); // Blog
      case 5:
        return const NotificationScreen(); // 🔥 Notifications
      default:
        return _dashboard();
    }
  }

  Widget _dashboard() => const Center(
    child: Text(
      "Advocate Dashboard Overview",
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
  );
}
