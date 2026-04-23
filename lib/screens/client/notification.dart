import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];
  int unread = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final data = await NotificationService.getNotifications();
      setState(() {
        notifications = List<Map<String, dynamic>>.from(data['notifications']);
        unread = data['unread'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _markAllRead() async {
    await NotificationService.markRead();
    _load();
  }

  Future<void> _markOneRead(String id) async {
    await NotificationService.markRead(notificationId: id);
    _load();
  }

  Future<void> _deleteOne(String id) async {
    await NotificationService.deleteOne(id);
    _load();
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Clear All?"),
        content: const Text("This will delete all your notifications."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Clear", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await NotificationService.clearAll();
      _load();
    }
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'case_request':
        return Icons.gavel;
      case 'case_approved':
        return Icons.check_circle;
      case 'case_rejected':
        return Icons.cancel;
      case 'case_in_progress':
        return Icons.hourglass_top;
      case 'case_closed':
        return Icons.lock;
      case 'profile_approved':
        return Icons.verified;
      case 'profile_rejected':
        return Icons.report;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String? type) {
    if (type == null) return Colors.green;
    if (type.contains('rejected')) return Colors.red;
    if (type.contains('approved')) return Colors.green;
    if (type.contains('progress')) return Colors.orange;
    if (type.contains('closed')) return Colors.grey;
    if (type == 'case_request') return Colors.blue;
    return Colors.green;
  }

  String _timeAgo(String? timestamp) {
    if (timestamp == null) return '';
    final dt = DateTime.tryParse(timestamp);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
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
                    "Notifications",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (unread > 0)
                    Text(
                      "$unread unread",
                      style: const TextStyle(color: Colors.green, fontSize: 13),
                    ),
                ],
              ),
            ),
            if (unread > 0)
              TextButton.icon(
                onPressed: _markAllRead,
                icon: const Icon(Icons.done_all, size: 16, color: Colors.green),
                label: const Text(
                  "Mark all read",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            if (notifications.isNotEmpty)
              IconButton(
                onPressed: _clearAll,
                icon: const Icon(Icons.delete_sweep, color: Colors.red),
                tooltip: "Clear all",
              ),
          ],
        ),

        const SizedBox(height: 12),

        // LIST
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "No notifications yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (ctx, i) => _notifCard(notifications[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _notifCard(Map<String, dynamic> n) {
    final isRead = n['is_read'] == true;
    final type = n['type'] as String?;
    final color = _colorForType(type);
    final icon = _iconForType(type);

    return Dismissible(
      key: Key(n['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      onDismissed: (_) => _deleteOne(n['id'].toString()),
      child: GestureDetector(
        onTap: () => !isRead ? _markOneRead(n['id'].toString()) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isRead
                  ? Colors.grey.withOpacity(0.15)
                  : color.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ICON
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),

              // CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n['title'] ?? '',
                            style: TextStyle(
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n['body'] ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(n['created_at']?.toString()),
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
