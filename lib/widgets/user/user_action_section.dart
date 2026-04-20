import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';

class UserActionSection extends StatelessWidget {
  const UserActionSection({super.key});

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  void navigateByRole(BuildContext context, String? role) {
    if (role == "admin") {
      Navigator.pushNamed(context, AppRoutes.admin);
    } else if (role == "user") {
      Navigator.pushNamed(context, AppRoutes.client);
    } else if (role == "advocate") {
      Navigator.pushNamed(context, AppRoutes.advocate);
    } else {
      Navigator.pushNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// 🔥 LOGIN
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.login);
            },
            child: const Text("Login"),
          ),

          const SizedBox(width: 10),

          /// 🔥 MY ACCOUNT (ROLE BASED)
          OutlinedButton(
            onPressed: () async {
              final role = await getRole();
              navigateByRole(context, role);
            },
            child: const Text("My Account"),
          ),
        ],
      ),
    );
  }
}
