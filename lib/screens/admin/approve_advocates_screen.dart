import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class ApproveAdvocatesScreen extends StatefulWidget {
  const ApproveAdvocatesScreen({super.key});

  @override
  State<ApproveAdvocatesScreen> createState() => _ApproveAdvocatesScreenState();
}

class _ApproveAdvocatesScreenState extends State<ApproveAdvocatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> pendingAccounts = [];
  List<Map<String, dynamic>> pendingProfiles = [];
  List<Map<String, dynamic>> approved = [];
  List<Map<String, dynamic>> rejected = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final all = await AdminService.getAllAdvocates();
      setState(() {
        // Account not approved yet
        pendingAccounts = all.where((a) => a['status'] == 'pending').toList();
        // Account approved but profile pending review
        pendingProfiles = all
            .where(
              (a) =>
                  a['status'] == 'approved' && a['profile_status'] == 'pending',
            )
            .toList();
        // Fully approved (account + profile)
        approved = all
            .where(
              (a) =>
                  a['status'] == 'approved' &&
                  a['profile_status'] == 'approved',
            )
            .toList();
        // Rejected
        rejected = all
            .where(
              (a) =>
                  a['status'] == 'rejected' ||
                  a['profile_status'] == 'rejected',
            )
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _updateAccount(String userId, String status) async {
    try {
      await AdminService.updateAdvocateStatus(userId: userId, status: status);
      _showSnack("Account ${status}!", status == 'approved');
      _load();
    } catch (e) {
      _showSnack("Failed: $e", false);
    }
  }

  Future<void> _updateProfile(String userId, String profileStatus) async {
    try {
      await AdminService.approveProfile(
        userId: userId,
        profileStatus: profileStatus,
      );
      _showSnack(
        profileStatus == 'approved'
            ? "Profile approved! Now visible to users."
            : "Profile rejected.",
        profileStatus == 'approved',
      );
      _load();
    } catch (e) {
      _showSnack("Failed: $e", false);
    }
  }

  void _showSnack(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Advocate Approvals",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "${pendingAccounts.length} accounts · "
          "${pendingProfiles.length} profiles pending",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 16),

        TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          isScrollable: true,
          tabs: [
            Tab(text: "Accounts (${pendingAccounts.length})"),
            Tab(text: "Profiles (${pendingProfiles.length})"),
            Tab(text: "Approved (${approved.length})"),
            Tab(text: "Rejected (${rejected.length})"),
          ],
        ),

        const SizedBox(height: 12),

        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // TAB 1: Pending account approvals
                    _buildList(pendingAccounts, actionType: 'account'),
                    // TAB 2: Pending profile approvals
                    _buildList(pendingProfiles, actionType: 'profile'),
                    // TAB 3: Fully approved
                    _buildList(approved, actionType: 'none'),
                    // TAB 4: Rejected
                    _buildList(rejected, actionType: 'none'),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildList(
    List<Map<String, dynamic>> list, {
    required String actionType,
  }) {
    if (list.isEmpty) {
      return const Center(
        child: Text("Nothing here", style: TextStyle(color: Colors.grey)),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (ctx, i) => _card(list[i], actionType: actionType),
      ),
    );
  }

  Widget _card(Map<String, dynamic> a, {required String actionType}) {
    final accountStatus = a['status'] ?? 'pending';
    final profileStatus = a['profile_status'] ?? 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP ROW
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.green.withOpacity(0.1),
                  backgroundImage: a['photo_url'] != null
                      ? NetworkImage("http://10.0.2.2:5000${a['photo_url']}")
                      : null,
                  child: a['photo_url'] == null
                      ? const Icon(Icons.person, color: Colors.green)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a['name'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        a['email'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // STATUS BADGES
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _badge(
                      "Acct: $accountStatus",
                      accountStatus == 'approved'
                          ? Colors.green
                          : accountStatus == 'rejected'
                          ? Colors.red
                          : Colors.orange,
                    ),
                    const SizedBox(height: 4),
                    _badge(
                      "Profile: $profileStatus",
                      profileStatus == 'approved'
                          ? Colors.green
                          : profileStatus == 'rejected'
                          ? Colors.red
                          : Colors.orange,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // PROFILE DETAILS
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _detail(Icons.badge, "Bar #", a['bar_number']),
                _detail(Icons.phone, "Phone", a['phone']),
                _detail(Icons.location_on, "District", a['district']),
                _detail(Icons.gavel, "Court", a['court_name']),
                _detail(
                  Icons.work,
                  "Experience",
                  "${a['experience_years'] ?? '-'} yrs",
                ),
                _detail(
                  Icons.list,
                  "Practice",
                  a['practice_areas']?.toString(),
                ),
              ],
            ),

            if (a['bio'] != null && a['bio'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                a['bio'],
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],

            // ACTION BUTTONS
            if (actionType == 'account') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updateAccount(a['id'].toString(), 'approved'),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text("Approve Account"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _updateAccount(a['id'].toString(), 'rejected'),
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.red,
                      ),
                      label: const Text(
                        "Reject",
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // 🔥 PROFILE APPROVAL BUTTONS
            if (actionType == 'profile') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updateProfile(a['id'].toString(), 'approved'),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text("Publish Profile"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _updateProfile(a['id'].toString(), 'rejected'),
                      icon: const Icon(
                        Icons.visibility_off,
                        size: 18,
                        color: Colors.red,
                      ),
                      label: const Text(
                        "Reject Profile",
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );

  Widget _detail(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
