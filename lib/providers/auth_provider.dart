import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  UserModel? user;

  Future<bool> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role, // 🔥 ADD THIS
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      user = await AuthService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role, // 🔥 PASS ROLE
      );

      final prefs = await SharedPreferences.getInstance();
      if (user?.token != null) {
        await prefs.setString("token", user!.token!);
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Register error: $e");

      user = null;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 🔵 LOGIN
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      user = await AuthService.login(email: email, password: password);

      if (user?.token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", user!.token!);
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Login error: $e");

      user = null;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    notifyListeners();
  }
}
