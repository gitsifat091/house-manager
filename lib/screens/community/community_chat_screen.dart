// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../../models/community_message_model.dart';
//
// class CommunityChatScreen extends StatefulWidget {
//   final String propertyId;
//   final String propertyName;
//
//   const CommunityChatScreen({
//     Key? key,
//     required this.propertyId,
//     required this.propertyName,
//   }) : super(key: key);
//
//   @override
//   State<CommunityChatScreen> createState() => _CommunityChatScreenState();
// }
//
// class _CommunityChatScreenState extends State<CommunityChatScreen> {
//   final _controller = TextEditingController();
//   final _scrollController = ScrollController();
//   final _auth = FirebaseAuth.instance;
//   final _firestore = FirebaseFirestore.instance;
//   String _senderName = '';
//   String _senderRole = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserInfo();
//   }
//
//   Future<void> _loadUserInfo() async {
//     final uid = _auth.currentUser!.uid;
//     final doc = await _firestore.collection('users').doc(uid).get();
//     setState(() {
//       _senderName = doc['name'] ?? 'Unknown';
//       _senderRole = doc['role'] ?? 'tenant';
//     });
//   }
//
//   Future<void> _sendMessage() async {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;
//
//     final uid = _auth.currentUser!.uid;
//     final msg = CommunityMessage(
//       id: '',
//       senderId: uid,
//       senderName: _senderName,
//       senderRole: _senderRole,
//       message: text,
//       createdAt: DateTime.now(),
//     );
//
//     await _firestore
//         .collection('communityChats')
//         .doc(widget.propertyId)
//         .collection('messages')
//         .add(msg.toMap());
//
//     _controller.clear();
//     _scrollToBottom();
//   }
//
//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 300), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final uid = _auth.currentUser!.uid;
//
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Column(
//       //     crossAxisAlignment: CrossAxisAlignment.start,
//       //     children: [
//       //       Text(widget.propertyName,
//       //         style: const TextStyle(
//       //           fontSize: 18,           // size চাইলে adjust করো
//       //           fontWeight: FontWeight.bold,  // 👈 bold করার জন্য
//       //           color: Colors.white,    // 👈 এখানে color change করো
//       //         ),
//       //       ),
//       //       const Text('Community Chat',
//       //           style: TextStyle(fontSize: 12, color: Colors.white70)),
//       //     ],
//       //   ),
//       //   backgroundColor: Colors.blue,
//       // ),
//
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         elevation: 0,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               widget.propertyName,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 2),
//             const Text(
//               'Community Chat',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.white70,
//               ),
//             ),
//           ],
//         ),
//       ),
//
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection('communityChats')
//                   .doc(widget.propertyId)
//                   .collection('messages')
//                   .orderBy('createdAt', descending: false)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final msgs = snapshot.data!.docs
//                     .map((d) => CommunityMessage.fromMap(
//                         d.data() as Map<String, dynamic>, d.id))
//                     .toList();
//
//                 if (msgs.isEmpty) {
//                   return const Center(
//                     child: Text('কোনো message নেই। প্রথমে লিখুন! 💬'),
//                   );
//                 }
//
//                 return ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.all(12),
//                   itemCount: msgs.length,
//                   itemBuilder: (context, i) {
//                     final msg = msgs[i];
//                     final isMe = msg.senderId == uid;
//                     return _buildMessageBubble(msg, isMe);
//                   },
//                 );
//               },
//             ),
//           ),
//           _buildInputBar(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessageBubble(CommunityMessage msg, bool isMe) {
//     final isLandlord = msg.senderRole == 'landlord';
//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.72,
//         ),
//         decoration: BoxDecoration(
//           color: isMe
//               ? Colors.blue
//               : (isLandlord ? Colors.grey.shade100 : Colors.grey.shade200),
//           borderRadius: BorderRadius.only(
//             topLeft: const Radius.circular(16),
//             topRight: const Radius.circular(16),
//             bottomLeft: Radius.circular(isMe ? 16 : 0),
//             bottomRight: Radius.circular(isMe ? 0 : 16),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment:
//               isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//           children: [
//             if (!isMe)
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     msg.senderName,
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.bold,
//                       color: isLandlord ? Colors.black : Colors.grey.shade700,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   if (isLandlord)
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//                       decoration: BoxDecoration(
//                         color: Colors.grey,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: const Text('বাড়ীওয়ালা',
//                           style: TextStyle(fontSize: 9, color: Colors.white)),
//                     ),
//                 ],
//               ),
//             const SizedBox(height: 2),
//             Text(
//               msg.message,
//               style: TextStyle(
//                 color: isMe ? Colors.white : Colors.black87,
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               _formatTime(msg.createdAt),
//               style: TextStyle(
//                 fontSize: 10,
//                 color: isMe ? Colors.white60 : Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInputBar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 hintText: 'Message লিখুন...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(24),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey.shade100,
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               ),
//               onSubmitted: (_) => _sendMessage(),
//             ),
//           ),
//           const SizedBox(width: 8),
//           CircleAvatar(
//             backgroundColor: Colors.blue.shade700,
//             child: IconButton(
//               icon: const Icon(Icons.send, color: Colors.white, size: 18),
//               onPressed: _sendMessage,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatTime(DateTime dt) {
//     final h = dt.hour.toString().padLeft(2, '0');
//     final m = dt.minute.toString().padLeft(2, '0');
//     return '$h:$m';
//   }
// }




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/community_message_model.dart';

class CommunityChatScreen extends StatefulWidget {
  final String propertyId;
  final String propertyName;

  const CommunityChatScreen({
    Key? key,
    required this.propertyId,
    required this.propertyName,
  }) : super(key: key);

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String _senderName = '';
  String _senderRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();
    setState(() {
      _senderName = doc['name'] ?? 'Unknown';
      _senderRole = doc['role'] ?? 'tenant';
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final uid = _auth.currentUser!.uid;
    final msg = CommunityMessage(
      id: '',
      senderId: uid,
      senderName: _senderName,
      senderRole: _senderRole,
      message: text,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('communityChats')
        .doc(widget.propertyId)
        .collection('messages')
        .add(msg.toMap());

    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser!.uid;
    final color = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor: color.surfaceVariant.withOpacity(0.2),
      backgroundColor: isDark
          ? const Color(0xFF0B141A)   // WhatsApp dark bg
          : const Color(0xFFEBEBE1), // WhatsApp light bg (হালকা ক্রিম)
      appBar: AppBar(
        elevation: 0,
        backgroundColor: color.primary,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            // Community icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.groups_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.propertyName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Community Chat',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('communityChats')
                  .doc(widget.propertyId)
                  .collection('messages')
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final msgs = snapshot.data!.docs
                    .map((d) => CommunityMessage.fromMap(
                    d.data() as Map<String, dynamic>, d.id))
                    .toList();

                if (msgs.isEmpty) {
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
                          child: Icon(Icons.forum_outlined,
                              size: 48, color: color.primary),
                        ),
                        const SizedBox(height: 16),
                        Text('এখনো কোনো message নেই',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: color.onSurface)),
                        const SizedBox(height: 6),
                        Text('প্রথমে কথা শুরু করুন! 👋',
                            style: TextStyle(
                                fontSize: 13,
                                color: color.onSurface.withOpacity(0.5))),
                      ],
                    ),
                  );
                }

                // Group messages by date
                return ListView.builder(
                  controller: _scrollController,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final msg = msgs[i];
                    final isMe = msg.senderId == uid;

                    // Date separator
                    final showDate = i == 0 ||
                        !_isSameDay(msgs[i - 1].createdAt, msg.createdAt);

                    return Column(
                      children: [
                        if (showDate) _DateChip(date: msg.createdAt),
                        _MessageBubble(msg: msg, isMe: isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _InputBar(
            controller: _controller,
            onSend: _sendMessage,
            color: color,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Date Chip ──────────────────────────────────────────────────────────────

class _DateChip extends StatelessWidget {
  final DateTime date;
  const _DateChip({required this.date});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'আজ';
    if (d == today.subtract(const Duration(days: 1))) return 'গতকাল';
    const months = [
      '', 'জানু', 'ফেব্রু', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টে', 'অক্টো', 'নভে', 'ডিসে'
    ];
    return '${date.day} ${months[date.month]}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _label(),
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Message Bubble ─────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final CommunityMessage msg;
  final bool isMe;
  const _MessageBubble({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLandlord = msg.senderRole == 'landlord';

    // Fixed colors — dark/light উভয়তেই ভালো দেখায়
    const sentBubble = Color(0xFF005C4B);
    final receivedBubble =
    isDark ? const Color(0xFF1F2C34) : Colors.white;
    final receivedText =
    isDark ? Colors.white : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              _Avatar(
                  name: msg.senderName,
                  isLandlord: isLandlord,
                  color: color),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 13, vertical: 9),
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
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg.senderName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isLandlord
                                    ? Colors.deepOrange
                                    : color.primary,
                              ),
                            ),
                            if (isLandlord) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('বাড়ীওয়ালা',
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.white)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    Text(
                      msg.message,
                      style: TextStyle(
                        color: isMe ? Colors.white : receivedText,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatTime(msg.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe
                            ? Colors.white60
                            : (isDark
                            ? Colors.white38
                            : Colors.black38),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Mini Avatar ────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final bool isLandlord;
  final ColorScheme color;
  const _Avatar(
      {required this.name, required this.isLandlord, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor:
      isLandlord ? Colors.deepOrange.withOpacity(0.15) : color.primaryContainer,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isLandlord ? Colors.deepOrange : color.primary,
        ),
      ),
    );
  }
}

// ── Input Bar ──────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final ColorScheme color;
  const _InputBar(
      {required this.controller,
        required this.onSend,
        required this.color});

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
                      color: isDark
                          ? Colors.white38
                          : Colors.black38,
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