import 'package:flutter/material.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // space for 70 logo
      // 🔥 ONLY bottom shadow
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 5), // 👇 shadow only bottom
          ),
        ],
      ),

      child: Center(
        child: Image.asset(
          "assets/logo/ukillogo.png",
          height: 80,
          width: 80,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
