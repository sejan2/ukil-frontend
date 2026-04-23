import 'package:flutter/material.dart';
import '../../services/case_service.dart';

class ManageCasesScreen extends StatefulWidget {
  const ManageCasesScreen({super.key});

  @override
  State<ManageCasesScreen> createState() => _ManageCasesScreenState();
}

class _ManageCasesScreenState extends State<ManageCasesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> allCases = [];
  bool isLoading = true;

  final statuses = [
    'all',
    'pending',
    'approved',
    'in_progress',
    'closed',
    'rejected',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final cases = await CaseService.getAdvocateCases();
      setState(() {
        allCases = cases;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  List<Map<String, dynamic>> _filtered(String status) {
    if (status == 'all') return allCases;
    return allCases.where((c) => c['status'] == status).toList();
  }

  Future<void> _updateStatus(String caseId, String status) async {
    try {
      await CaseService.updateCaseStatus(caseId: caseId, status: status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Case marked as $status"),
          backgroundColor: Colors.green,
        ),
      );
      _load();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Manage Cases",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          "${allCases.length} total cases",
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
            Tab(text: "All (${allCases.length})"),
            Tab(text: "Pending (${_filtered('pending').length})"),
            Tab(text: "Active (${_filtered('in_progress').length})"),
            Tab(text: "Closed (${_filtered('closed').length})"),
            Tab(text: "Rejected (${_filtered('rejected').length})"),
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
                    _buildList(_filtered('all')),
                    _buildList(_filtered('pending')),
                    _buildList(_filtered('in_progress')),
                    _buildList(_filtered('closed')),
                    _buildList(_filtered('rejected')),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildList(List<Map<String, dynamic>> cases) {
    if (cases.isEmpty) {
      return const Center(
        child: Text("No cases here", style: TextStyle(color: Colors.grey)),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: cases.length,
        itemBuilder: (ctx, i) => _caseCard(cases[i]),
      ),
    );
  }

  Widget _caseCard(Map<String, dynamic> c) {
    final status = c['status'] ?? 'pending';
    final statusColor = _statusColor(status);

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
                Expanded(
                  child: Text(
                    c['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _statusBadge(status, statusColor),
              ],
            ),
            const SizedBox(height: 6),

            // USER
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  c['user_name'] ?? 'User',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // DESCRIPTION
            if (c['description'] != null &&
                c['description'].toString().isNotEmpty)
              Text(
                c['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ACTION BUTTONS — only for pending
            if (status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _updateStatus(c['id'].toString(), 'approved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Accept"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _updateStatus(c['id'].toString(), 'rejected'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Reject",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),

            // For approved → mark in progress or close
            if (status == 'approved')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _updateStatus(c['id'].toString(), 'in_progress'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Start Working"),
                    ),
                  ),
                ],
              ),

            // For in_progress → close
            if (status == 'in_progress')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _updateStatus(c['id'].toString(), 'closed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Close Case"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in_progress':
        return Colors.orange;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Widget _statusBadge(String status, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(
      status.replaceAll('_', ' ').toUpperCase(),
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );
}
