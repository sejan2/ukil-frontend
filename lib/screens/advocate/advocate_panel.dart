import 'package:flutter/material.dart';
import '../../widgets/forall/sidebar.dart';

import '../advocate/blog_screen.dart';
import '../advocate/edit_profile.dart';
import '../advocate/hearing_screen.dart';
import '../advocate/notification.dart';

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

      /// 📱 MOBILE DRAWER
      drawer: isMobile
          ? Drawer(
              child: AdminSidebar(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                onItemTapClose: () {
                  Navigator.pop(context);
                },
              ),
            )
          : null,

      body: Row(
        children: [
          /// 💻 WEB SIDEBAR
          if (!isMobile)
            AdminSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),

          /// RIGHT CONTENT
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

  /// 🔥 ADVOCATE ROUTING
  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return _dashboardUI();

      case 1:
        return const EditProfileScreen(); // Edit My Profile

      case 2:
        return const BlogScreen(); // Manage Cases / Upcoming content

      case 3:
        return const HearingScreen(); // Upcoming Hearing

      case 4:
        return const NotificationScreen(); // Notifications

      default:
        return const Center(child: Text("Advocate Dashboard"));
    }
  }

  /// 🟢 DASHBOARD UI
  Widget _dashboardUI() {
    return const Center(
      child: Text(
        "Advocate Dashboard Overview",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
