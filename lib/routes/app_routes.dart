import 'package:flutter/material.dart';

// Screens
import '../screens/auth/login.dart';
import '../screens/auth/registration.dart';
import '../screens/home_screen.dart';
import '../screens/homeBottom/advocates.dart';
import '../screens/admin/admin_panel.dart';
import '../screens/advocate/advocate_panel.dart';
import '../screens/client/client_panel.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String advocates = '/advocates';
  static const String admin = '/admin';
  static const String advocate = '/advocate';
  static const String client = '/client';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case advocates:
        return MaterialPageRoute(builder: (_) => const AdvocatesScreen());

      case admin:
        return MaterialPageRoute(builder: (_) => const AdminPanel());

      case advocate:
        return MaterialPageRoute(builder: (_) => const AdvocatePanel());

      case client:
        return MaterialPageRoute(builder: (_) => const ClientPanel());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }

  // 🔥 SAFE ROLE ROUTING (NEW)
  static String getRouteByRole(String? role) {
    switch (role) {
      case "admin":
        return admin;
      case "advocate":
        return advocate;
      case "user":
      default:
        return client;
    }
  }
}
