// import 'package:flutter/material.dart';
// import '../../models/message_model.dart';
// import '../../services/chat_service.dart';
//
// class ChatScreen extends StatefulWidget {
//   final String chatRoomId;
//   final String currentUserId;
//   final String currentUserName;
//   final String otherUserName;
//   final bool isLandlord;
//
//   const ChatScreen({
//     super.key,
//     required this.chatRoomId,
//     required this.currentUserId,
//     required this.currentUserName,
//     required this.otherUserName,
//     required this.isLandlord,
//   });
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final _msgCtrl = TextEditingController();
//   final _scrollCtrl = ScrollController();
//   final _service = ChatService();
//
//   @override
//   void initState() {
//     super.initState();
//     _service.markRead(widget.chatRoomId, widget.isLandlord);
//   }
//
//   @override
//   void dispose() {
//     _msgCtrl.dispose();
//     _scrollCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _send() async {
//     final text = _msgCtrl.text.trim();
//     if (text.isEmpty) return;
//     _msgCtrl.clear();
//
//     await _service.sendMessage(
//       chatRoomId: widget.chatRoomId,
//       senderId: widget.currentUserId,
//       senderName: widget.currentUserName,
//       text: text,
//       isLandlord: widget.isLandlord,
//     );
//
//     // Scroll to bottom
//     await Future.delayed(const Duration(milliseconds: 100));
//     if (_scrollCtrl.hasClients) {
//       _scrollCtrl.animateTo(
//         _scrollCtrl.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//
//     return Scaffold(
//       appBar: AppBar(
//         titleSpacing: 0,
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 18,
//               backgroundColor: color.primaryContainer,
//               child: Text(
//                 widget.otherUserName.isNotEmpty
//                     ? widget.otherUserName[0].toUpperCase()
//                     : '?',
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: color.primary,
//                     fontSize: 14),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(widget.otherUserName,
//                     style: const TextStyle(
//                         fontSize: 15, fontWeight: FontWeight.bold)),
//                 Text(
//                   widget.isLandlord ? 'ভাড়াটিয়া' : 'বাড়ীওয়ালা',
//                   style: TextStyle(
//                       fontSize: 11,
//                       color: color.onSurface.withOpacity(0.6)),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           // Messages
//           Expanded(
//             child: StreamBuilder<List<MessageModel>>(
//               stream: _service.getMessages(widget.chatRoomId),
//               builder: (context, snap) {
//                 if (snap.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 final messages = snap.data ?? [];
//
//                 if (messages.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.chat_bubble_outline_rounded,
//                             size: 64,
//                             color: color.primary.withOpacity(0.3)),
//                         const SizedBox(height: 12),
//                         const Text('কথোপকথন শুরু করুন',
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 4),
//                         Text('${widget.otherUserName} কে message পাঠান',
//                             style: TextStyle(
//                                 color: color.onSurface.withOpacity(0.5))),
//                       ],
//                     ),
//                   );
//                 }
//
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   if (_scrollCtrl.hasClients) {
//                     _scrollCtrl.jumpTo(
//                         _scrollCtrl.position.maxScrollExtent);
//                   }
//                 });
//
//                 return ListView.builder(
//                   controller: _scrollCtrl,
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16, vertical: 12),
//                   itemCount: messages.length,
//                   itemBuilder: (ctx, i) {
//                     final msg = messages[i];
//                     final isMe = msg.senderId == widget.currentUserId;
//
//                     // Date separator
//                     bool showDate = false;
//                     if (i == 0) {
//                       showDate = true;
//                     } else {
//                       final prev = messages[i - 1];
//                       if (msg.createdAt.day != prev.createdAt.day) {
//                         showDate = true;
//                       }
//                     }
//
//                     return Column(
//                       children: [
//                         if (showDate)
//                           _DateSeparator(date: msg.createdAt),
//                         _MessageBubble(
//                             message: msg, isMe: isMe),
//                       ],
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//
//           // Input bar
//           Container(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: color.surface,
//               border: Border(
//                   top: BorderSide(color: color.outlineVariant)),
//             ),
//             child: SafeArea(
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: color.surfaceVariant,
//                         borderRadius: BorderRadius.circular(24),
//                       ),
//                       child: TextField(
//                         controller: _msgCtrl,
//                         maxLines: 4,
//                         minLines: 1,
//                         decoration: const InputDecoration(
//                           hintText: 'Message লিখুন...',
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 10),
//                         ),
//                         onSubmitted: (_) => _send(),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   // Send button
//                   Material(
//                     color: color.primary,
//                     borderRadius: BorderRadius.circular(24),
//                     child: InkWell(
//                       onTap: _send,
//                       borderRadius: BorderRadius.circular(24),
//                       child: const Padding(
//                         padding: EdgeInsets.all(12),
//                         child: Icon(Icons.send_rounded,
//                             color: Colors.white, size: 22),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _MessageBubble extends StatelessWidget {
//   final MessageModel message;
//   final bool isMe;
//   const _MessageBubble({required this.message, required this.isMe});
//
//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     final time =
//         '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}';
//
//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 6),
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.75,
//         ),
//         decoration: BoxDecoration(
//           color: isMe ? color.primary : color.surfaceVariant,
//           borderRadius: BorderRadius.only(
//             topLeft: const Radius.circular(18),
//             topRight: const Radius.circular(18),
//             bottomLeft: Radius.circular(isMe ? 18 : 4),
//             bottomRight: Radius.circular(isMe ? 4 : 18),
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(
//             horizontal: 14, vertical: 10),
//         child: Column(
//           crossAxisAlignment: isMe
//               ? CrossAxisAlignment.end
//               : CrossAxisAlignment.start,
//           children: [
//             Text(
//               message.text,
//               style: TextStyle(
//                 color: isMe ? Colors.white : color.onSurface,
//                 fontSize: 15,
//                 height: 1.4,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               time,
//               style: TextStyle(
//                 fontSize: 11,
//                 color: isMe
//                     ? Colors.white70
//                     : color.onSurface.withOpacity(0.5),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _DateSeparator extends StatelessWidget {
//   final DateTime date;
//   const _DateSeparator({required this.date});
//
//   String _label() {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final msgDay = DateTime(date.year, date.month, date.day);
//     final diff = today.difference(msgDay).inDays;
//     if (diff == 0) return 'আজ';
//     if (diff == 1) return 'গতকাল';
//     return '${date.day}/${date.month}/${date.year}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.symmetric(
//               horizontal: 12, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(_label(),
//               style: const TextStyle(
//                   fontSize: 12, color: Colors.grey)),
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import '../../models/message_model.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String currentUserId;
  final String currentUserName;
  final String otherUserName;
  final bool isLandlord;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.currentUserId,
    required this.currentUserName,
    required this.otherUserName,
    required this.isLandlord,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _service = ChatService();

  @override
  void initState() {
    super.initState();
    _service.markRead(widget.chatRoomId, widget.isLandlord);
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();

    await _service.sendMessage(
      chatRoomId: widget.chatRoomId,
      senderId: widget.currentUserId,
      senderName: widget.currentUserName,
      text: text,
      isLandlord: widget.isLandlord,
    );

    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B141A)
          : const Color(0xFFEBEBE1),
      appBar: AppBar(
        backgroundColor: color.primary,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: Colors.white24,
              child: Text(
                widget.otherUserName.isNotEmpty
                    ? widget.otherUserName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  widget.isLandlord ? 'ভাড়াটিয়া' : 'বাড়ীওয়ালা',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _service.getMessages(widget.chatRoomId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snap.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: color.primaryContainer.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.chat_bubble_outline_rounded,
                              size: 48, color: color.primary),
                        ),
                        const SizedBox(height: 16),
                        const Text('কথোপকথন শুরু করুন',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.otherUserName} কে message পাঠান',
                          style: TextStyle(
                              color: color.onSurface.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollCtrl.hasClients) {
                    _scrollCtrl.jumpTo(
                        _scrollCtrl.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = messages[i];
                    final isMe = msg.senderId == widget.currentUserId;

                    bool showDate = i == 0 ||
                        messages[i - 1].createdAt.day != msg.createdAt.day;

                    return Column(
                      children: [
                        if (showDate)
                          _DateSeparator(date: msg.createdAt),
                        _MessageBubble(message: msg, isMe: isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _InputBar(controller: _msgCtrl, onSend: _send),
        ],
      ),
    );
  }
}

// ── Message Bubble ─────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const sentBubble = Color(0xFF005C4B);
    final receivedBubble = isDark ? const Color(0xFF1F2C34) : Colors.white;
    final receivedText = isDark ? Colors.white : Colors.black87;

    final time =
        '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? sentBubble : receivedBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : receivedText,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: isMe
                    ? Colors.white60
                    : (isDark ? Colors.white38 : Colors.black38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Date Separator ─────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(msgDay).inDays;
    if (diff == 0) return 'আজ';
    if (diff == 1) return 'গতকাল';
    const months = [
      '', 'জানু', 'ফেব্রু', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টে', 'অক্টো', 'নভে', 'ডিসে'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1F2C34)
                : Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06), blurRadius: 4)
            ],
          ),
          child: Text(
            _label(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Input Bar ──────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barBg = isDark ? const Color(0xFF1F2C34) : Colors.white;
    final fieldBg =
    isDark ? const Color(0xFF2A3942) : const Color(0xFFF0F2F5);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: barBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Message লিখুন...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFF005C4B),
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: onSend,
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}