import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdvocateService {
  static const String baseUrl = "http://10.0.2.2:5000/api/advocates/me";

  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ✅ GET MY PROFILE
  // GET /api/advocate/profile
  static Future<Map<String, dynamic>> getMyProfile() async {
    final token = await _token();
    final res = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data['profile'];
    throw Exception(data['message'] ?? "Failed to load profile");
  }

  // ✅ UPDATE PROFILE (with optional photo)
  // PUT /api/advocate/profile  multipart/form-data
  static Future<bool> updateProfile({
    required Map<String, String> fields, // text fields
    File? photo, // optional image
  }) async {
    final token = await _token();
    final req = http.MultipartRequest('PUT', Uri.parse("$baseUrl/profile"));
    req.headers['Authorization'] = "Bearer $token";

    // Add text fields
    req.fields.addAll(fields);

    // Add photo if selected
    if (photo != null) {
      req.files.add(await http.MultipartFile.fromPath('photo', photo.path));
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    final data = jsonDecode(res.body);

    if (res.statusCode == 200) return true;
    throw Exception(data['message'] ?? "Failed to update profile");
  }
}
