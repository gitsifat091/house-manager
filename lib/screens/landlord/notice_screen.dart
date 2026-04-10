import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/notice_service.dart';
import '../../../models/notice_model.dart';
import '../shared/notification_screen.dart';

class NoticeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const NoticeScreen({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;
    final service = NoticeService();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => scaffoldKey?.currentState?.openDrawer(),
        ),
        title: const Text('নোটিশ বোর্ড'), centerTitle: true),
      body: StreamBuilder<List<NoticeModel>>(
        stream: service.getNotices(user.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notices = snap.data ?? [];
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
                  const SizedBox(height: 8),
                  const Text('নিচের বাটন দিয়ে নোটিশ দিন'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (ctx, i) => _NoticeCard(notice: notices[i], service: service),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddNoticeDialog(context, user.uid, service),
        icon: const Icon(Icons.add),
        label: const Text('নোটিশ দিন'),
      ),
    );
  }

  void _showAddNoticeDialog(
      BuildContext context, String landlordId, NoticeService service) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('নতুন নোটিশ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'শিরোনাম'),
                validator: (v) => v!.isEmpty ? 'শিরোনাম দিন' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: bodyCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'বিস্তারিত'),
                validator: (v) => v!.isEmpty ? 'বিস্তারিত লিখুন' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 50,
                child: FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    await service.addNotice(NoticeModel(
                      id: '',
                      landlordId: landlordId,
                      title: titleCtrl.text.trim(),
                      body: bodyCtrl.text.trim(),
                      createdAt: DateTime.now(),
                    ));
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('নোটিশ পাঠান'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final NoticeModel notice;
  final NoticeService service;
  const _NoticeCard({required this.notice, required this.service});

  @override
  Widget build(BuildContext context) {
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
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async => await service.deleteNotice(notice.id),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(notice.body, style: TextStyle(color: color.onSurface.withOpacity(0.7))),
            const SizedBox(height: 8),
            Text(
              '${notice.createdAt.day}/${notice.createdAt.month}/${notice.createdAt.year}',
              style: TextStyle(fontSize: 12, color: color.onSurface.withOpacity(0.4)),
            ),
          ],
        ),
      ),
    );
  }
}