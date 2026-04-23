// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../services/auth_service.dart';
// import '../../../services/notice_service.dart';
// import '../../../models/notice_model.dart';
// import '../shared/notification_screen.dart';

// class NoticeScreen extends StatelessWidget {
//   final GlobalKey<ScaffoldState>? scaffoldKey;
//   const NoticeScreen({super.key, this.scaffoldKey});

//   @override
//   Widget build(BuildContext context) {
//     final user = context.read<AuthService>().currentUser!;
//     final service = NoticeService();

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.menu_rounded),
//           onPressed: () => scaffoldKey?.currentState?.openDrawer(),
//         ),
//         title: const Text('নোটিশ বোর্ড'), centerTitle: true),
//       body: StreamBuilder<List<NoticeModel>>(
//         stream: service.getNotices(user.uid),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final notices = snap.data ?? [];
//           if (notices.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.campaign_outlined, size: 80,
//                       color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
//                   const SizedBox(height: 16),
//                   const Text('কোনো নোটিশ নেই',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   const Text('নিচের বাটন দিয়ে নোটিশ দিন'),
//                 ],
//               ),
//             );
//           }
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: notices.length,
//             itemBuilder: (ctx, i) => _NoticeCard(notice: notices[i], service: service),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _showAddNoticeDialog(context, user.uid, service),
//         icon: const Icon(Icons.add),
//         label: const Text('নোটিশ দিন'),
//       ),
//     );
//   }

//   void _showAddNoticeDialog(
//       BuildContext context, String landlordId, NoticeService service) {
//     final titleCtrl = TextEditingController();
//     final bodyCtrl = TextEditingController();
//     final formKey = GlobalKey<FormState>();

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (_) => Padding(
//         padding: EdgeInsets.only(
//           left: 20, right: 20, top: 20,
//           bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//         ),
//         child: Form(
//           key: formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('নতুন নোটিশ',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: titleCtrl,
//                 decoration: const InputDecoration(labelText: 'শিরোনাম'),
//                 validator: (v) => v!.isEmpty ? 'শিরোনাম দিন' : null,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: bodyCtrl,
//                 maxLines: 4,
//                 decoration: const InputDecoration(labelText: 'বিস্তারিত'),
//                 validator: (v) => v!.isEmpty ? 'বিস্তারিত লিখুন' : null,
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity, height: 50,
//                 child: FilledButton(
//                   onPressed: () async {
//                     if (!formKey.currentState!.validate()) return;
//                     await service.addNotice(NoticeModel(
//                       id: '',
//                       landlordId: landlordId,
//                       title: titleCtrl.text.trim(),
//                       body: bodyCtrl.text.trim(),
//                       createdAt: DateTime.now(),
//                     ));
//                     if (context.mounted) Navigator.pop(context);
//                   },
//                   child: const Text('নোটিশ পাঠান'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _NoticeCard extends StatelessWidget {
//   final NoticeModel notice;
//   final NoticeService service;
//   const _NoticeCard({required this.notice, required this.service});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: color.primaryContainer,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(Icons.campaign_rounded, color: color.primary, size: 20),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(notice.title,
//                       style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete_outline, color: Colors.red),
//                   onPressed: () async => await service.deleteNotice(notice.id),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Text(notice.body, style: TextStyle(color: color.onSurface.withOpacity(0.7))),
//             const SizedBox(height: 8),
//             Text(
//               '${notice.createdAt.day}/${notice.createdAt.month}/${notice.createdAt.year}',
//               style: TextStyle(fontSize: 12, color: color.onSurface.withOpacity(0.4)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/notice_service.dart';
import '../../../models/notice_model.dart';
import '../shared/notification_screen.dart';

class NoticeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const NoticeScreen({super.key, this.scaffoldKey});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary =
        isDark ? Colors.white54 : const Color(0xFF6B7280);

    final user = context.read<AuthService>().currentUser!;
    final service = NoticeService();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: textPrimary),
          onPressed: () =>
              widget.scaffoldKey?.currentState?.openDrawer(),
        ),
        title: Text(
          'নোটিশ বোর্ড',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: StreamBuilder<List<NoticeModel>>(
          stream: service.getNotices(user.uid),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: primary),
              );
            }
            final notices = snap.data ?? [];
            if (notices.isEmpty) {
              return _buildEmptyState(primary, textPrimary, textSecondary);
            }
            return ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: notices.length,
              itemBuilder: (ctx, i) => _NoticeCard(
                notice: notices[i],
                service: service,
                isDark: isDark,
                primary: primary,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                index: i,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _showAddNoticeDialog(context, user.uid, service, primary),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'নোটিশ দিন',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      Color primary, Color textPrimary, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.campaign_outlined,
              size: 44,
              color: primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'কোনো নোটিশ নেই',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'নিচের বাটন দিয়ে নোটিশ দিন',
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
        ],
      ),
    );
  }

  void _showAddNoticeDialog(BuildContext context, String landlordId,
      NoticeService service, Color primary) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg =
        isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1A1A1A);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.campaign_rounded,
                        color: primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'নতুন নোটিশ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'শিরোনাম',
                  prefixIcon:
                      Icon(Icons.title_rounded, color: primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primary, width: 2),
                  ),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'শিরোনাম দিন' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: bodyCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'বিস্তারিত',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.notes_rounded, color: primary),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primary, width: 2),
                  ),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'বিস্তারিত লিখুন' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text(
                    'নোটিশ পাঠান',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Notice Card ───────────────────────────────────────────────

class _NoticeCard extends StatelessWidget {
  final NoticeModel notice;
  final NoticeService service;
  final bool isDark;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final int index;

  const _NoticeCard({
    required this.notice,
    required this.service,
    required this.isDark,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    required this.index,
  });

  // Cycle through different icon background colors like Settings screen
  static const List<Color> _iconColors = [
    Color(0xFF2D7A4F), // green
    Color(0xFF0891B2), // teal
    Color(0xFFD97706), // amber
    Color(0xFF5B4FBF), // purple
    Color(0xFF6B7280), // grey
  ];

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final divider =
        isDark ? Colors.white10 : const Color(0xFFE5E7EB);
    final iconBg = _iconColors[index % _iconColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.campaign_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notice.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 11,
                                color: textSecondary.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${notice.createdAt.day}/${notice.createdAt.month}/${notice.createdAt.year}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Delete button
                    GestureDetector(
                      onTap: () =>
                          _confirmDelete(context, service, notice),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Divider ──
                Divider(height: 1, color: divider),

                const SizedBox(height: 12),

                // ── Body ──
                Text(
                  notice.body,
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, NoticeService service, NoticeModel notice) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'নোটিশ মুছবেন?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          '"${notice.title}" নোটিশটি মুছে ফেলা হবে।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('না'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await service.deleteNotice(notice.id);
            },
            child: const Text('মুছুন'),
          ),
        ],
      ),
    );
  }
}