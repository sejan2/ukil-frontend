import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:5000/api/auth";

  static Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
        "role": role,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserModel.fromJson({...data['user'], "token": data['token']});
    }
    throw Exception(data['message'] ?? "Registration failed");
  }

  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    final data = jsonDecode(response.body);

    // ✅ 200 — login success
    if (response.statusCode == 200) {
      if (data['user'] == null || data['token'] == null) {
        throw Exception("Invalid response from server");
      }
      return UserModel.fromJson({...data['user'], "token": data['token']});
    }

    // 🔥 403 — advocate not approved yet (or deactivated)
    // Throw with the exact backend message so UI can catch it
    if (response.statusCode == 403) {
      throw AdvocatePendingException(
        data['message'] ?? "Account pending approval",
      );
    }

    throw Exception(data['message'] ?? "Login failed");
  }
}

// 🔥 Custom exception so we can identify pending advocates
class AdvocatePendingException implements Exception {
  final String message;
  AdvocatePendingException(this.message);
}
