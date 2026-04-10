import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatelessWidget {
  final String userId;
  const NotificationScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('নোটিফিকেশন'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _markAllRead(userId),
            child: const Text('সব পড়া হয়েছে'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 80,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('কোনো নোটিফিকেশন নেই',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final isRead = data['isRead'] ?? false;
              final createdAt = DateTime.fromMillisecondsSinceEpoch(
                  data['createdAt'] ?? 0);
              final type = data['type'] ?? 'general';

              return Dismissible(
                key: Key(docs[i].id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                onDismissed: (_) {
                  FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(docs[i].id)
                      .delete();
                },
                child: InkWell(
                  onTap: () {
                    if (!isRead) {
                      FirebaseFirestore.instance
                          .collection('notifications')
                          .doc(docs[i].id)
                          .update({'isRead': true});
                    }
                  },
                  child: Container(
                    color: isRead
                        ? null
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.05),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _iconBg(type),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_icon(type),
                            color: _iconColor(type), size: 22),
                      ),
                      title: Text(data['title'] ?? '',
                          style: TextStyle(
                              fontWeight: isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['body'] ?? '',
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            _timeAgo(createdAt),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: !isRead
                          ? Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                      isThreeLine: true,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _icon(String type) {
    switch (type) {
      case 'payment': return Icons.payments_rounded;
      case 'payment_approved': return Icons.check_circle_rounded;
      case 'payment_rejected': return Icons.cancel_rounded;
      case 'notice': return Icons.campaign_rounded;
      case 'maintenance': return Icons.build_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'payment': return Colors.blue;
      case 'payment_approved': return Colors.green;
      case 'payment_rejected': return Colors.red;
      case 'notice': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Color _iconBg(String type) {
    switch (type) {
      case 'payment': return Colors.blue.shade50;
      case 'payment_approved': return Colors.green.shade50;
      case 'payment_rejected': return Colors.red.shade50;
      case 'notice': return Colors.orange.shade50;
      default: return Colors.grey.shade100;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'এইমাত্র';
    if (diff.inMinutes < 60) return '${diff.inMinutes} মিনিট আগে';
    if (diff.inHours < 24) return '${diff.inHours} ঘণ্টা আগে';
    return '${diff.inDays} দিন আগে';
  }

  Future<void> _markAllRead(String userId) async {
    final snap = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.update({'isRead': true});
    }
  }
}

class NotificationBell extends StatelessWidget {
  final String userId;
  const NotificationBell({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.data?.docs.length ?? 0;
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationScreen(userId: userId),
                ),
              ),
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                      minWidth: 16, minHeight: 16),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}