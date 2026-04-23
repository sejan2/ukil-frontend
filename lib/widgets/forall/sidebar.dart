import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuItem {
  final String title;
  final IconData icon;
  MenuItem(this.title, this.icon);
}

class AdminSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback? onItemTapClose;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onItemTapClose,
  });

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  String role = "user";

  @override
  void initState() {
    super.initState();
    loadRole();
  }

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => role = prefs.getString("role") ?? "user");
  }

  List<MenuItem> getMenuItems() {
    if (role == "admin") {
      return [
        MenuItem("Dashboard", Icons.dashboard),
        MenuItem("Approve Advocates", Icons.approval), // 🔥 index 1
        MenuItem("Upload Lawyers", Icons.upload_file), // index 2
        MenuItem("Manage Lawyers", Icons.people), // index 3
        MenuItem("Upcoming Hearing", Icons.event), // index 4
        MenuItem("Blog Upload", Icons.article), // index 5
      ];
    }
    if (role == "advocate") {
      return [
        MenuItem("Dashboard", Icons.dashboard),
        MenuItem("Edit My Profile", Icons.person),
        MenuItem("Manage Cases", Icons.gavel),
        MenuItem("Upcoming Hearing", Icons.event),
        MenuItem("Blog Upload", Icons.article),
        MenuItem("Notifications", Icons.notifications),
      ];
    }
    return [
      MenuItem("Dashboard", Icons.dashboard),
      MenuItem("Case Requests", Icons.folder_shared),
      MenuItem("Notifications", Icons.notifications),
    ];
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = getMenuItems();

    return Container(
      width: 235,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B3D2E), Color(0xFF198754)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF198754)),
            ),
            const SizedBox(height: 10),
            Text(
              role.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Text(
              "Panel",
              style: TextStyle(
                color: Color(0xFFA7F3D0),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15),
            const Divider(color: Colors.white24),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (context, index) {
                  final isSelected = widget.selectedIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(color: Colors.white30)
                          : null,
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        items[index].icon,
                        size: 20,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFB7E4C7),
                      ),
                      title: Text(
                        items[index].title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFD1FAE5),
                        ),
                      ),
                      onTap: () {
                        widget.onItemSelected(index);
                        widget.onItemTapClose?.call();
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(color: Colors.white24),
            const ListTile(
              leading: Icon(Icons.settings, color: Color(0xFFD1FAE5)),
              title: Text(
                "Settings",
                style: TextStyle(
                  color: Color(0xFFD1FAE5),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFFCA5A5)),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Color(0xFFFCA5A5),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              onTap: _logout,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
