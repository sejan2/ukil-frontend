import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  static const String baseUrl = "http://10.0.2.2:5000/api/admin";

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // GET /api/admin/advocates?status=approved&profile_status=pending
  static Future<List<Map<String, dynamic>>> getAllAdvocates({
    String? status,
    String? profileStatus,
  }) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (profileStatus != null) params['profile_status'] = profileStatus;

    final uri = Uri.parse(
      "$baseUrl/advocates",
    ).replace(queryParameters: params);
    final res = await http.get(uri, headers: await _headers());
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['advocates']);
    }
    throw Exception(data['message'] ?? "Failed to load advocates");
  }

  // PATCH /api/admin/advocates/:id  body: { status }
  static Future<bool> updateAdvocateStatus({
    required String userId,
    required String status,
  }) async {
    final res = await http.patch(
      Uri.parse("$baseUrl/advocates/$userId"),
      headers: await _headers(),
      body: jsonEncode({"status": status}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return true;
    throw Exception(data['message'] ?? "Failed to update status");
  }

  // 🔥 NEW: PATCH /api/admin/advocates/:id  body: { profile_status }
  static Future<bool> approveProfile({
    required String userId,
    required String profileStatus, // 'approved' or 'rejected'
  }) async {
    final res = await http.patch(
      Uri.parse("$baseUrl/advocates/$userId"),
      headers: await _headers(),
      body: jsonEncode({"profile_status": profileStatus}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return true;
    throw Exception(data['message'] ?? "Failed to update profile status");
  }

  static Future<bool> editAdvocateProfile({
    required String userId,
    required Map<String, dynamic> fields,
  }) async {
    final res = await http.put(
      Uri.parse("$baseUrl/advocates/$userId"),
      headers: await _headers(),
      body: jsonEncode(fields),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return true;
    throw Exception(data['message'] ?? "Failed to update profile");
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final res = await http.get(
      Uri.parse("$baseUrl/users"),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['users']);
    }
    throw Exception(data['message'] ?? "Failed to load users");
  }

  static Future<bool> deactivateUser(String userId) async {
    final res = await http.patch(
      Uri.parse("$baseUrl/users/$userId/deactivate"),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return true;
    throw Exception(data['message'] ?? "Failed to deactivate user");
  }
}
