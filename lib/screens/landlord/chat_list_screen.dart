import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../../../services/chat_service.dart';
import '../../../services/tenant_service.dart';
import '../../../models/message_model.dart';
import '../../../models/tenant_model.dart';
import '../shared/chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;
    final chatService = ChatService();

    return Scaffold(
      appBar: AppBar(title: const Text('Messages'), centerTitle: true),
      body: StreamBuilder<List<ChatRoom>>(
        stream: chatService.getLandlordChats(user.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snap.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.chat_outlined, size: 44,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text('কোনো conversation নেই',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('ভাড়াটিয়ার সাথে chat শুরু করুন',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (ctx, i) {
              final chat = chats[i];
              final unread = 0; // landlord unread
              final color = Theme.of(context).colorScheme;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.primaryContainer,
                  child: Text(
                    chat.tenantName.isNotEmpty
                        ? chat.tenantName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: color.primary),
                  ),
                ),
                title: Text(chat.tenantName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('রুম ${chat.roomNumber}',
                        style: const TextStyle(fontSize: 11)),
                    if (chat.lastMessage != null)
                      Text(
                        chat.lastMessage!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13,
                            color: color.onSurface.withOpacity(0.6)),
                      ),
                  ],
                ),
                trailing: chat.lastMessageAt != null
                    ? Text(
                        _timeLabel(chat.lastMessageAt!),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      )
                    : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      chatRoomId: chat.id,
                      currentUserId: user.uid,
                      currentUserName: user.name,
                      otherUserName: chat.tenantName,
                      isLandlord: true,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewChatSheet(context, user),
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('নতুন chat'),
      ),
    );
  }

  String _timeLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'এখন';
    if (diff.inHours < 1) return '${diff.inMinutes}মি';
    if (diff.inDays < 1) return '${diff.inHours}ঘ';
    return '${dt.day}/${dt.month}';
  }

  void _showNewChatSheet(BuildContext context, dynamic user) async {
    final snap = await FirebaseFirestore.instance
        .collection('tenants')
        .where('landlordId', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true)
        .get();

    final tenants = snap.docs
        .map((d) => TenantModel.fromMap(d.data(), d.id))
        .toList();

    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text('কার সাথে chat করবেন?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...tenants.map((tenant) => ListTile(
              leading: CircleAvatar(
                child: Text(tenant.name[0].toUpperCase()),
              ),
              title: Text(tenant.name),
              subtitle: Text('রুম ${tenant.roomNumber}'),
              onTap: () async {
                Navigator.pop(context);
                final chatService = ChatService();
                final chatRoomId = await chatService.getOrCreateChatRoom(
                  landlordId: user.uid,
                  landlordName: user.name,
                  tenant: tenant,
                );
                if (context.mounted) {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      chatRoomId: chatRoomId,
                      currentUserId: user.uid,
                      currentUserName: user.name,
                      otherUserName: tenant.name,
                      isLandlord: true,
                    ),
                  ));
                }
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      );
    }
  }
}