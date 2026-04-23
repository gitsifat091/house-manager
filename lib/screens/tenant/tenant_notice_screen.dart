// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../models/notice_model.dart';
// import '../../../models/user_model.dart';
// import '../../../services/notice_service.dart';

// class TenantNoticeScreen extends StatelessWidget {
//   final UserModel user;
//   // const TenantNoticeScreen({super.key, required this.user});
//   final GlobalKey<ScaffoldState>? scaffoldKey;
//   const TenantNoticeScreen({super.key, required this.user, this.scaffoldKey});

//   Future<String?> _getLandlordId(String email) async {
//     final snap = await FirebaseFirestore.instance
//         .collection('tenants')
//         .where('email', isEqualTo: email)
//         .where('isActive', isEqualTo: true)
//         .get();
//     if (snap.docs.isEmpty) return null;
//     return snap.docs.first.data()['landlordId'] as String?;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.menu_rounded),
//           onPressed: () => scaffoldKey?.currentState?.openDrawer(),
//         ),
//         title: const Text('নোটিশ বোর্ড'), centerTitle: true),
        
//       body: FutureBuilder<String?>(
//         future: _getLandlordId(user.email),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final landlordId = snap.data;
//           if (landlordId == null) {
//             return const Center(child: Text('তথ্য পাওয়া যায়নি'));
//           }
//           return StreamBuilder<List<NoticeModel>>(
//             stream: NoticeService().getNotices(landlordId),
//             builder: (context, snap2) {
//               if (snap2.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               final notices = snap2.data ?? [];
//               if (notices.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.campaign_outlined, size: 80,
//                           color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
//                       const SizedBox(height: 16),
//                       const Text('কোনো নোটিশ নেই',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                 );
//               }
//               return ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: notices.length,
//                 itemBuilder: (ctx, i) {
//                   final notice = notices[i];
//                   final color = Theme.of(context).colorScheme;
//                   return Card(
//                     margin: const EdgeInsets.only(bottom: 12),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: color.primaryContainer,
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Icon(Icons.campaign_rounded, color: color.primary, size: 20),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Text(notice.title,
//                                     style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),
//                           Text(notice.body,
//                               style: TextStyle(color: color.onSurface.withOpacity(0.7))),
//                           const SizedBox(height: 8),
//                           Text(
//                             '${notice.createdAt.day}/${notice.createdAt.month}/${notice.createdAt.year}',
//                             style: TextStyle(fontSize: 12, color: color.onSurface.withOpacity(0.4)),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }







import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/notice_model.dart';
import '../../../models/user_model.dart';
import '../../../services/notice_service.dart';

class TenantNoticeScreen extends StatefulWidget {
  final UserModel user;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const TenantNoticeScreen({super.key, required this.user, this.scaffoldKey});

  @override
  State<TenantNoticeScreen> createState() => _TenantNoticeScreenState();
}

class _TenantNoticeScreenState extends State<TenantNoticeScreen>
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary =
        isDark ? Colors.white54 : const Color(0xFF6B7280);

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
        child: FutureBuilder<String?>(
          future: _getLandlordId(widget.user.email),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: primary),
              );
            }
            final landlordId = snap.data;
            if (landlordId == null) {
              return _buildErrorState(
                  primary, textPrimary, textSecondary);
            }
            return StreamBuilder<List<NoticeModel>>(
              stream: NoticeService().getNotices(landlordId),
              builder: (context, snap2) {
                if (snap2.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: primary),
                  );
                }
                final notices = snap2.data ?? [];
                if (notices.isEmpty) {
                  return _buildEmptyState(
                      primary, textPrimary, textSecondary);
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: notices.length,
                  itemBuilder: (ctx, i) => _TenantNoticeCard(
                    notice: notices[i],
                    isDark: isDark,
                    primary: primary,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    index: i,
                  ),
                );
              },
            );
          },
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
            'বাড়ীওয়ালার কোনো নোটিশ নেই',
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      Color primary, Color textPrimary, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: Colors.orange.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'তথ্য পাওয়া যায়নি',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'সক্রিয় ভাড়াটিয়া হিসেবে যুক্ত আছেন কিনা নিশ্চিত করুন',
            style: TextStyle(fontSize: 13, color: textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Tenant Notice Card (read-only, no delete) ─────────────────

class _TenantNoticeCard extends StatelessWidget {
  final NoticeModel notice;
  final bool isDark;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final int index;

  const _TenantNoticeCard({
    required this.notice,
    required this.isDark,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    required this.index,
  });

  static const List<Color> _iconColors = [
    Color(0xFF2D7A4F),
    Color(0xFF0891B2),
    Color(0xFFD97706),
    Color(0xFF5B4FBF),
    Color(0xFF6B7280),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
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
                // "নতুন" badge — যদি ৩ দিনের মধ্যে হয়
                if (DateTime.now()
                        .difference(notice.createdAt)
                        .inDays <=
                    3)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: primary.withOpacity(0.3), width: 1),
                    ),
                    child: Text(
                      'নতুন',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),
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
    );
  }
}