import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isPending = false; // 🔥 NEW — true when advocate not approved
  String pendingMessage = '';
  UserModel? user;

  Future<bool> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      user = await AuthService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      final prefs = await SharedPreferences.getInstance();
      if (user?.token != null) await prefs.setString("token", user!.token!);
      await prefs.setString("role", user!.role);
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

  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    isPending = false;
    notifyListeners();

    try {
      user = await AuthService.login(email: email, password: password);
      final prefs = await SharedPreferences.getInstance();
      if (user?.token != null) await prefs.setString("token", user!.token!);
      await prefs.setString("role", user!.role);
      isLoading = false;
      notifyListeners();
      return true;
    } on AdvocatePendingException catch (e) {
      // 🔥 Advocate not approved — set flag, don't treat as error
      isPending = true;
      pendingMessage = e.message;
      user = null;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint("Login error: $e");
      isPending = false;
      user = null;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    user = null;
    isPending = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
