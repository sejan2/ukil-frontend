import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CaseService {
  static const String baseUrl = "http://10.0.2.2:5000/api/cases";

  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<Map<String, String>> _headers() async => {
    "Content-Type": "application/json",
    "Authorization": "Bearer ${await _token()}",
  };

  // POST /api/cases  (user creates case)
  static Future<bool> createCase({
    required String advocateId,
    required String title,
    required String description,
    List<File> files = const [],
  }) async {
    final token = await _token();
    final req = http.MultipartRequest('POST', Uri.parse(baseUrl));
    req.headers['Authorization'] = "Bearer $token";
    req.fields['advocate_id'] = advocateId;
    req.fields['title'] = title;
    req.fields['description'] = description;
    for (final f in files) {
      req.files.add(await http.MultipartFile.fromPath('files', f.path));
    }
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    final data = jsonDecode(res.body);
    if (res.statusCode == 201) return true;
    throw Exception(data['message'] ?? "Failed to submit case");
  }

  // GET /api/cases/my  (user sees their cases)
  static Future<List<Map<String, dynamic>>> getMyCases() async {
    final res = await http.get(
      Uri.parse("$baseUrl/my"),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200)
      return List<Map<String, dynamic>>.from(data['cases']);
    throw Exception(data['message'] ?? "Failed to load cases");
  }

  // GET /api/cases/my  (advocate also uses same endpoint)
  static Future<List<Map<String, dynamic>>> getAdvocateCases() async {
    final res = await http.get(
      Uri.parse("$baseUrl/my"),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200)
      return List<Map<String, dynamic>>.from(data['cases']);
    throw Exception(data['message'] ?? "Failed to load cases");
  }

  // PATCH /api/cases/:id/status  (advocate updates status)
  static Future<bool> updateCaseStatus({
    required String caseId,
    required String status,
    String? message,
  }) async {
    final res = await http.patch(
      Uri.parse("$baseUrl/$caseId/status"),
      headers: await _headers(),
      body: jsonEncode({
        "status": status,
        if (message != null) "message": message,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return true;
    throw Exception(data['message'] ?? "Failed to update status");
  }
}
