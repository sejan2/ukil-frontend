import 'package:flutter/material.dart';
import '../../services/case_service.dart';

class CaseRequestScreen extends StatefulWidget {
  const CaseRequestScreen({super.key});

  @override
  State<CaseRequestScreen> createState() => _CaseRequestScreenState();
}

class _CaseRequestScreenState extends State<CaseRequestScreen> {
  List<Map<String, dynamic>> cases = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final data = await CaseService.getMyCases();
      setState(() {
        cases = data;
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

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'in_progress':
        return Icons.hourglass_top;
      case 'closed':
        return Icons.lock;
      default:
        return Icons.schedule;
    }
  }

  String _timeAgo(String? timestamp) {
    if (timestamp == null) return '';
    final dt = DateTime.tryParse(timestamp);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "My Cases",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${cases.length} case requests",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh, color: Colors.green),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : cases.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 64,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "No cases submitted yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: cases.length,
                    itemBuilder: (ctx, i) => _caseCard(cases[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _caseCard(Map<String, dynamic> c) {
    final status = c['status'] ?? 'pending';
    final statusColor = _statusColor(status);
    final statusIcon = _statusIcon(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE + STATUS
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ADVOCATE
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.green.withOpacity(0.1),
                  backgroundImage: c['advocate_photo'] != null
                      ? NetworkImage(
                          "http://10.0.2.2:5000${c['advocate_photo']}",
                        )
                      : null,
                  child: c['advocate_photo'] == null
                      ? const Icon(Icons.person, size: 14, color: Colors.green)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  c['advocate_name'] ?? 'Advocate',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  _timeAgo(c['created_at']?.toString()),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),

            if (c['description'] != null &&
                c['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                c['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],

            // PROGRESS STEPPER
            const SizedBox(height: 14),
            _progressStepper(status),
          ],
        ),
      ),
    );
  }

  Widget _progressStepper(String status) {
    final steps = ['pending', 'approved', 'in_progress', 'closed'];
    final idx = steps.indexOf(status);

    return Row(
      children: steps.asMap().entries.map((e) {
        final stepIdx = e.key;
        final isDone = idx >= stepIdx && status != 'rejected';
        final isActive = idx == stepIdx;

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? Colors.green : Colors.grey.shade300,
                      border: isActive
                          ? Border.all(color: Colors.green, width: 2)
                          : null,
                    ),
                    child: isDone
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    e.value.replaceAll('_', '\n'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDone ? Colors.green : Colors.grey,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              if (stepIdx < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: idx > stepIdx ? Colors.green : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
