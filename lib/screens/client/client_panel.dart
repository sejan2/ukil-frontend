import 'package:flutter/material.dart';
import '../../widgets/forall/sidebar.dart';
import '../client/case_request.dart'; // 🔥 REAL SCREEN
import '../client/notification.dart'; // 🔥 REAL SCREEN

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
        return const CaseRequestScreen(); // 🔥 My Cases
      case 2:
        return const NotificationScreen(); // 🔥 Notifications
      default:
        return _dashboard();
    }
  }

  Widget _dashboard() => const Center(
    child: Text(
      "Client Dashboard Overview",
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
  );
}
