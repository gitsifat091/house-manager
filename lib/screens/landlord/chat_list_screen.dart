// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../services/auth_service.dart';
// import '../../../services/chat_service.dart';
// import '../../../services/tenant_service.dart';
// import '../../../models/message_model.dart';
// import '../../../models/tenant_model.dart';
// import '../shared/chat_screen.dart';

// class ChatListScreen extends StatelessWidget {
//   const ChatListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = context.read<AuthService>().currentUser!;
//     final chatService = ChatService();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Messages'), centerTitle: true),
//       body: StreamBuilder<List<ChatRoom>>(
//         stream: chatService.getLandlordChats(user.uid),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final chats = snap.data ?? [];

//           if (chats.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 90, height: 90,
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.primaryContainer,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.chat_outlined, size: 44,
//                         color: Theme.of(context).colorScheme.primary),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text('কোনো conversation নেই',
//                       style: TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   const Text('ভাড়াটিয়ার সাথে chat শুরু করুন',
//                       style: TextStyle(color: Colors.grey)),
//                 ],
//               ),
//             );
//           }

//           return ListView.builder(
//             itemCount: chats.length,
//             itemBuilder: (ctx, i) {
//               final chat = chats[i];
//               final unread = 0; // landlord unread
//               final color = Theme.of(context).colorScheme;

//               return ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: color.primaryContainer,
//                   child: Text(
//                     chat.tenantName.isNotEmpty
//                         ? chat.tenantName[0].toUpperCase()
//                         : '?',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold, color: color.primary),
//                   ),
//                 ),
//                 title: Text(chat.tenantName,
//                     style: const TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('রুম ${chat.roomNumber}',
//                         style: const TextStyle(fontSize: 11)),
//                     if (chat.lastMessage != null)
//                       Text(
//                         chat.lastMessage!,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                             fontSize: 13,
//                             color: color.onSurface.withOpacity(0.6)),
//                       ),
//                   ],
//                 ),
//                 trailing: chat.lastMessageAt != null
//                     ? Text(
//                         _timeLabel(chat.lastMessageAt!),
//                         style: const TextStyle(
//                             fontSize: 11, color: Colors.grey),
//                       )
//                     : null,
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => ChatScreen(
//                       chatRoomId: chat.id,
//                       currentUserId: user.uid,
//                       currentUserName: user.name,
//                       otherUserName: chat.tenantName,
//                       isLandlord: true,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _showNewChatSheet(context, user),
//         icon: const Icon(Icons.add_comment_rounded),
//         label: const Text('নতুন chat'),
//       ),
//     );
//   }

//   String _timeLabel(DateTime dt) {
//     final now = DateTime.now();
//     final diff = now.difference(dt);
//     if (diff.inMinutes < 1) return 'এখন';
//     if (diff.inHours < 1) return '${diff.inMinutes}মি';
//     if (diff.inDays < 1) return '${diff.inHours}ঘ';
//     return '${dt.day}/${dt.month}';
//   }

//   void _showNewChatSheet(BuildContext context, dynamic user) async {
//     final snap = await FirebaseFirestore.instance
//         .collection('tenants')
//         .where('landlordId', isEqualTo: user.uid)
//         .where('isActive', isEqualTo: true)
//         .get();

//     final tenants = snap.docs
//         .map((d) => TenantModel.fromMap(d.data(), d.id))
//         .toList();

//     if (context.mounted) {
//       showModalBottomSheet(
//         context: context,
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//         builder: (_) => Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const SizedBox(height: 16),
//             const Text('কার সাথে chat করবেন?',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             ...tenants.map((tenant) => ListTile(
//               leading: CircleAvatar(
//                 child: Text(tenant.name[0].toUpperCase()),
//               ),
//               title: Text(tenant.name),
//               subtitle: Text('রুম ${tenant.roomNumber}'),
//               onTap: () async {
//                 Navigator.pop(context);
//                 final chatService = ChatService();
//                 final chatRoomId = await chatService.getOrCreateChatRoom(
//                   landlordId: user.uid,
//                   landlordName: user.name,
//                   tenant: tenant,
//                 );
//                 if (context.mounted) {
//                   Navigator.push(context, MaterialPageRoute(
//                     builder: (_) => ChatScreen(
//                       chatRoomId: chatRoomId,
//                       currentUserId: user.uid,
//                       currentUserName: user.name,
//                       otherUserName: tenant.name,
//                       isLandlord: true,
//                     ),
//                   ));
//                 }
//               },
//             )),
//             const SizedBox(height: 16),
//           ],
//         ),
//       );
//     }
//   }
// }






import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../../../services/chat_service.dart';
import '../../../models/message_model.dart';
import '../../../models/tenant_model.dart';
import '../shared/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;
    final chatService = ChatService();
    final color = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7),
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7),
        elevation: 0,
        title: const Text('Messages',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: color.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.add_comment_rounded,
                  color: color.primary, size: 22),
              tooltip: 'নতুন chat',
              onPressed: () => _showNewChatSheet(context, user),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'নাম বা রুম খুঁজুন...',
                hintStyle: TextStyle(
                    color: isDark ? Colors.white30 : Colors.grey.shade400,
                    fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                    size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: isDark ? Colors.white10 : Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: isDark ? Colors.white10 : Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: color.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // ── Chat List ─────────────────────────────────
          Expanded(
            child: StreamBuilder<List<ChatRoom>>(
              stream: chatService.getLandlordChats(user.uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final all = snap.data ?? [];
                final chats = _query.isEmpty
                    ? all
                    : all
                        .where((c) =>
                            c.tenantName
                                .toLowerCase()
                                .contains(_query) ||
                            c.roomNumber.toLowerCase().contains(_query))
                        .toList();

                if (all.isEmpty) {
                  return _EmptyState(color: color);
                }

                if (chats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 56,
                            color: color.onSurface.withOpacity(0.2)),
                        const SizedBox(height: 12),
                        Text('"$_query" পাওয়া যায়নি',
                            style: TextStyle(
                                color: color.onSurface.withOpacity(0.5))),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: chats.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) =>
                      _ChatTile(
                        chat: chats[i],
                        user: user,
                        color: color,
                        isDark: isDark,
                      ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNewChatSheet(BuildContext context, dynamic user) async {
    final snap = await FirebaseFirestore.instance
        .collection('tenants')
        .where('landlordId', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true)
        .get();

    final tenants =
        snap.docs.map((d) => TenantModel.fromMap(d.data(), d.id)).toList();

    if (!context.mounted) return;

    if (tenants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('কোনো active ভাড়াটিয়া নেই'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final color = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('কার সাথে chat করবেন?',
                  style:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 8),
          ...tenants.map((tenant) => ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 4),
                leading: _AvatarWidget(
                    name: tenant.name, color: color, radius: 22),
                title: Text(tenant.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('রুম ${tenant.roomNumber}',
                    style: const TextStyle(fontSize: 12)),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: color.primary),
                onTap: () async {
                  Navigator.pop(context);
                  final chatService = ChatService();
                  final chatRoomId =
                      await chatService.getOrCreateChatRoom(
                    landlordId: user.uid,
                    landlordName: user.name,
                    tenant: tenant,
                  );
                  if (context.mounted) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Chat Tile ─────────────────────────────────────────────────────────────────

class _ChatTile extends StatelessWidget {
  final ChatRoom chat;
  final dynamic user;
  final ColorScheme color;
  final bool isDark;

  const _ChatTile({
    required this.chat,
    required this.user,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final hasMessage = chat.lastMessage != null && chat.lastMessage!.isNotEmpty;

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey.shade100),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // ── Avatar ──
              _AvatarWidget(name: chat.tenantName, color: color, radius: 26),
              const SizedBox(width: 14),

              // ── Info ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.tenantName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (chat.lastMessageAt != null)
                          Text(
                            _timeLabel(chat.lastMessageAt!),
                            style: TextStyle(
                                fontSize: 11,
                                color:
                                    color.onSurface.withOpacity(0.4)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'রুম ${chat.roomNumber}',
                            style: TextStyle(
                                fontSize: 10,
                                color: color.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (hasMessage)
                          Expanded(
                            child: Text(
                              chat.lastMessage!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: color.onSurface
                                      .withOpacity(0.5)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Arrow ──
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded,
                  color: color.onSurface.withOpacity(0.2), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _timeLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'এখন';
    if (diff.inHours < 1) return '${diff.inMinutes}মি';
    if (diff.inDays < 1) return '${diff.inHours}ঘ';
    if (diff.inDays < 7) return '${dt.day}/${dt.month}';
    return '${dt.day}/${dt.month}/${dt.year.toString().substring(2)}';
  }
}

// ── Avatar Widget ─────────────────────────────────────────────────────────────

class _AvatarWidget extends StatelessWidget {
  final String name;
  final ColorScheme color;
  final double radius;

  const _AvatarWidget({
    required this.name,
    required this.color,
    required this.radius,
  });

  // name → consistent color
  Color _avatarColor() {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFF0891B2),
      const Color(0xFF059669),
      const Color(0xFFD97706),
      const Color(0xFFDC2626),
      const Color(0xFF7C3AED),
    ];
    int hash = 0;
    for (final c in name.runes) {
      hash = (hash * 31 + c) & 0xFFFFFFFF;
    }
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bg = _avatarColor();
    final initial =
        name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bg, bg.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: bg.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.75,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final ColorScheme color;
  const _EmptyState({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: color.primaryContainer.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded,
                size: 48, color: color.primary.withOpacity(0.6)),
          ),
          const SizedBox(height: 20),
          const Text('কোনো conversation নেই',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'উপরের + বাটনে চাপ দিয়ে\nভাড়াটিয়ার সাথে chat শুরু করুন',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey.shade500, height: 1.6),
          ),
        ],
      ),
    );
  }
}