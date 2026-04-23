import 'package:flutter/material.dart';
import '../../widgets/forall/sidebar.dart';
import '../admin/approve_advocates_screen.dart';
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
      drawer: isMobile
          ? Drawer(
              child: AdminSidebar(
                selectedIndex: selectedIndex,
                onItemSelected: (index) =>
                    setState(() => selectedIndex = index),
                onItemTapClose: () => Navigator.pop(context),
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            AdminSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: (index) => setState(() => selectedIndex = index),
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
        return _dashboardUI();
      case 1:
        return const ApproveAdvocatesScreen(); // 🔥 APPROVE ADVOCATES
      case 2:
        return const AddLawyerScreen();
      case 3:
        return const LawyerListScreen();
      case 4:
        return const HearingScreen();
      case 5:
        return const BlogScreen();
      default:
        return const Center(child: Text("Dashboard"));
    }
  }

  Widget _dashboardUI() {
    return const Center(
      child: Text(
        "Dashboard Overview",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
