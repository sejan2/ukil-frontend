import 'package:flutter/material.dart';
import '../../widgets/forall/sidebar.dart';

import '../admin/add_lawyer_screen.dart';

import '../admin/blog_screen.dart';
import '../admin/hearing_screen.dart';
import '../admin/lawyer_list_screen.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return Scaffold(
      appBar: isMobile ? AppBar(title: const Text("Admin Panel")) : null,

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

                /// 🔥 CLOSE DRAWER AFTER CLICK
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

  /// 🔥 NAVIGATION FIXED (NO MISMATCH)
  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return _dashboardUI();

      case 1:
        return const AddLawyerScreen(); // Upload Lawyers

      case 2:
        return const LawyerListScreen(); // Manage Lawyers

      case 3:
        return const HearingScreen(); // Upcoming Hearing

      case 4:
        return const BlogScreen(); // Blog Upload

      default:
        return const Center(child: Text("Dashboard"));
    }
  }

  /// 🟢 DASHBOARD UI
  Widget _dashboardUI() {
    return const Center(
      child: Text(
        "Dashboard Overview",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
