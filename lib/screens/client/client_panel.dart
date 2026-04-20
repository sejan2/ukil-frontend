import 'package:flutter/material.dart';
import '../../widgets/forall/sidebar.dart';

import '../client/case_request.dart';
import '../client/notification.dart';

class ClientPanel extends StatefulWidget {
  const ClientPanel({super.key});

  @override
  State<ClientPanel> createState() => _ClientPanelState();
}

class _ClientPanelState extends State<ClientPanel> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return Scaffold(
      appBar: isMobile ? AppBar(title: const Text("Client Panel")) : null,

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

  /// 🔥 CLIENT ROUTING
  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return _dashboardUI();

      case 1:
        return const CaseRequestScreen(); // Case Requests

      case 2:
        return const NotificationScreen(); // Notifications

      default:
        return const Center(child: Text("Client Dashboard"));
    }
  }

  /// 🟢 DASHBOARD UI
  Widget _dashboardUI() {
    return const Center(
      child: Text(
        "Client Dashboard Overview",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
