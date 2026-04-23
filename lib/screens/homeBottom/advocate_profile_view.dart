import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/public_service.dart';
import '../cases/case_request_screen.dart'; // 🔥 NEW

class AdvocateProfileView extends StatefulWidget {
  final String advocateId;
  const AdvocateProfileView({required this.advocateId, super.key});

  @override
  State<AdvocateProfileView> createState() => _AdvocateProfileViewState();
}

class _AdvocateProfileViewState extends State<AdvocateProfileView> {
  Map<String, dynamic>? advocate;
  bool isLoading = true;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = await PublicService.getAdvocateById(widget.advocateId);
    setState(() {
      advocate = data;
      userRole = prefs.getString("role");
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : advocate == null
          ? const Center(child: Text("Advocate not found"))
          : CustomScrollView(
              slivers: [
                // ── GREEN HEADER ────────────────────────────
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: const Color(0xFF138424),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0B3D2E), Color(0xFF138424)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: advocate!['photo_url'] != null
                                ? NetworkImage(
                                    "http://10.0.2.2:5000${advocate!['photo_url']}",
                                  )
                                : null,
                            child: advocate!['photo_url'] == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.green,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            advocate!['name'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            advocate!['court_name'] ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── BODY ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // STATS
                        Row(
                          children: [
                            _stat(
                              Icons.work,
                              "${advocate!['experience_years'] ?? 0}",
                              "Years Exp.",
                            ),
                            _stat(
                              Icons.location_on,
                              advocate!['district'] ?? '-',
                              "District",
                            ),
                            _stat(
                              Icons.badge,
                              advocate!['bar_number'] ?? '-',
                              "Bar No.",
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // BIO
                        if (advocate!['bio'] != null &&
                            advocate!['bio'].toString().isNotEmpty) ...[
                          _sectionTitle("About"),
                          Text(
                            advocate!['bio'],
                            style: const TextStyle(
                              color: Colors.black87,
                              height: 1.6,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // PRACTICE AREAS
                        _sectionTitle("Practice Areas"),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _areaList(advocate!['practice_areas'])
                              .map(
                                (a) => Chip(
                                  label: Text(
                                    a,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: Colors.green.withOpacity(
                                    0.1,
                                  ),
                                  side: BorderSide(
                                    color: Colors.green.withOpacity(0.3),
                                  ),
                                ),
                              )
                              .toList(),
                        ),

                        const SizedBox(height: 20),

                        // LOCATION
                        _sectionTitle("Location"),
                        _infoRow(
                          Icons.location_on,
                          "Area",
                          advocate!['location'],
                        ),
                        _infoRow(Icons.map, "Division", advocate!['division']),
                        _infoRow(Icons.gavel, "Court", advocate!['court_name']),

                        const SizedBox(height: 28),

                        // 🔥 BUTTONS ROW
                        Row(
                          children: [
                            // CONTACT BUTTON
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // TODO: chat
                                },
                                icon: const Icon(
                                  Icons.chat_bubble_outline,
                                  color: Color(0xFF138424),
                                ),
                                label: const Text(
                                  "Contact",
                                  style: TextStyle(color: Color(0xFF138424)),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF138424),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // 🔥 CASE REQUEST BUTTON (only for users)
                            if (userRole == 'user' || userRole == null)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Check logged in
                                    if (userRole == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please login to send a case request",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CaseRequestScreen(
                                          advocateId: widget.advocateId,
                                          advocateName: advocate!['name'] ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.gavel, size: 18),
                                  label: const Text("Case Request"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF138424),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  List<String> _areaList(dynamic areas) {
    if (areas == null) return [];
    if (areas is List) return areas.map((e) => e.toString()).toList();
    return areas.toString().split(',').map((e) => e.trim()).toList();
  }

  Widget _stat(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.green, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF138424),
      ),
    ),
  );

  Widget _infoRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
