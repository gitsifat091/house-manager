import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/notice_model.dart';
import '../../../models/user_model.dart';
import '../../../services/notice_service.dart';

class TenantNoticeScreen extends StatelessWidget {
  final UserModel user;
  // const TenantNoticeScreen({super.key, required this.user});
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const TenantNoticeScreen({super.key, required this.user, this.scaffoldKey});

  Future<String?> _getLandlordId(String email) async {
    final snap = await FirebaseFirestore.instance
        .collection('tenants')
        .where('email', isEqualTo: email)
        .where('isActive', isEqualTo: true)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data()['landlordId'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => scaffoldKey?.currentState?.openDrawer(),
        ),
        title: const Text('নোটিশ বোর্ড'), centerTitle: true),
      body: FutureBuilder<String?>(
        future: _getLandlordId(user.email),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final landlordId = snap.data;
          if (landlordId == null) {
            return const Center(child: Text('তথ্য পাওয়া যায়নি'));
          }
          return StreamBuilder<List<NoticeModel>>(
            stream: NoticeService().getNotices(landlordId),
            builder: (context, snap2) {
              if (snap2.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final notices = snap2.data ?? [];
              if (notices.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.campaign_outlined, size: 80,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      const Text('কোনো নোটিশ নেই',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notices.length,
                itemBuilder: (ctx, i) {
                  final notice = notices[i];
                  final color = Theme.of(context).colorScheme;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.campaign_rounded, color: color.primary, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(notice.title,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(notice.body,
                              style: TextStyle(color: color.onSurface.withOpacity(0.7))),
                          const SizedBox(height: 8),
                          Text(
                            '${notice.createdAt.day}/${notice.createdAt.month}/${notice.createdAt.year}',
                            style: TextStyle(fontSize: 12, color: color.onSurface.withOpacity(0.4)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}