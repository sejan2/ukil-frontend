import 'dart:convert';
import 'package:http/http.dart' as http;

class PublicService {
  static const String baseUrl = "http://10.0.2.2:5000/api/advocates";

  // GET /api/users?area=&practice=&name=&page=&limit=
  static Future<Map<String, dynamic>> browseAdvocates({
    String? area, // location/district/division filter
    String? practice, // practice area filter (exact, lowercased)
    String? name, // name search
    int page = 1,
    int limit = 12,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (area != null && area.isNotEmpty) params['area'] = area;
    if (practice != null && practice.isNotEmpty)
      params['practice'] = practice.toLowerCase();
    if (name != null && name.isNotEmpty) params['name'] = name;

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    final res = await http.get(uri);
    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return {
        'advocates': List<Map<String, dynamic>>.from(data['advocates']),
        'total': data['total'] as int,
        'page': data['page'] as int,
      };
    }
    throw Exception(data['message'] ?? "Failed to load advocates");
  }

  // GET /api/users/:id
  static Future<Map<String, dynamic>> getAdvocateById(String id) async {
    final res = await http.get(Uri.parse("$baseUrl/$id"));
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data['advocate'];
    throw Exception(data['message'] ?? "Advocate not found");
  }
}
