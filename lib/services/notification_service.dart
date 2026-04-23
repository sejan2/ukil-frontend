import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String baseUrl = "http://10.0.2.2:5000/api/notifications";

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // GET /api/notifications
  static Future<Map<String, dynamic>> getNotifications() async {
    final res = await http.get(Uri.parse(baseUrl), headers: await _headers());
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data;
    throw Exception(data['message'] ?? "Failed to load notifications");
  }

  // GET /api/notifications/unread-count
  static Future<int> getUnreadCount() async {
    final res = await http.get(
      Uri.parse("$baseUrl/unread-count"),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data['unread'] as int;
    return 0;
  }

  // POST /api/notifications/read  (mark one or all)
  static Future<void> markRead({String? notificationId}) async {
    final body = notificationId != null
        ? jsonEncode({"notification_id": notificationId})
        : jsonEncode({});
    await http.post(
      Uri.parse("$baseUrl/read"),
      headers: await _headers(),
      body: body,
    );
  }

  // DELETE /api/notifications/:id
  static Future<void> deleteOne(String id) async {
    await http.delete(Uri.parse("$baseUrl/$id"), headers: await _headers());
  }

  // DELETE /api/notifications/clear
  static Future<void> clearAll() async {
    await http.delete(Uri.parse("$baseUrl/clear"), headers: await _headers());
  }
}
