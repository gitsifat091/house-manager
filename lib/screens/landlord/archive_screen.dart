// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../services/auth_service.dart';
// import '../../../models/tenant_model.dart';
// import '../../../models/payment_model.dart';

// class ArchiveScreen extends StatelessWidget {
//   const ArchiveScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = context.read<AuthService>().currentUser!;

//     return Scaffold(
//       appBar: AppBar(title: const Text('আর্কাইভ'), centerTitle: true),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('tenants')
//             .where('landlordId', isEqualTo: user.uid)
//             .where('isActive', isEqualTo: false)
//             .snapshots(),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final tenants = (snap.data?.docs ?? [])
//               .map((d) => TenantModel.fromMap(d.data() as Map<String, dynamic>, d.id))
//               .toList()
//             ..sort((a, b) => b.moveInDate.compareTo(a.moveInDate));

//           if (tenants.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 100, height: 100,
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.primaryContainer,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.archive_outlined, size: 48,
//                         color: Theme.of(context).colorScheme.primary),
//                   ),
//                   const SizedBox(height: 20),
//                   const Text('আর্কাইভ খালি',
//                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   Text('রুম খালি করলে ভাড়াটিয়ার তথ্য এখানে আসবে',
//                       style: TextStyle(color: Colors.grey.shade600),
//                       textAlign: TextAlign.center),
//                 ],
//               ),
//             );
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: tenants.length,
//             itemBuilder: (ctx, i) => _ArchivedTenantCard(
//               tenant: tenants[i],
//               landlordId: user.uid,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _ArchivedTenantCard extends StatelessWidget {
//   final TenantModel tenant;
//   final String landlordId;
//   const _ArchivedTenantCard({required this.tenant, required this.landlordId});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Theme(
//         data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//         child: ExpansionTile(
//           leading: CircleAvatar(
//             backgroundColor: Colors.grey.shade200,
//             child: Text(
//               tenant.name[0].toUpperCase(),
//               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
//             ),
//           ),
//           title: Text(tenant.name,
//               style: const TextStyle(fontWeight: FontWeight.bold)),
//           subtitle: Text('${tenant.propertyName} • রুম ${tenant.roomNumber}',
//               style: TextStyle(fontSize: 12, color: color.onSurface.withOpacity(0.6))),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Text('আর্কাইভড',
//                     style: TextStyle(fontSize: 11, color: Colors.grey)),
//               ),
//               const Icon(Icons.expand_more),
//             ],
//           ),
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Divider(),
//                   const SizedBox(height: 8),

//                   // Info grid
//                   _infoRow(Icons.phone_outlined, 'Phone', tenant.phone),
//                   _infoRow(Icons.email_outlined, 'Email',
//                       tenant.email.isEmpty ? 'নেই' : tenant.email),
//                   _infoRow(Icons.badge_outlined, 'NID', tenant.nidNumber),
//                   _infoRow(Icons.home_work_outlined, 'Property', tenant.propertyName),
//                   _infoRow(Icons.door_front_door_outlined, 'রুম', tenant.roomNumber),
//                   _infoRow(Icons.currency_exchange_rounded, 'মাসিক ভাড়া',
//                       '৳${tenant.rentAmount.toStringAsFixed(0)}'),
//                   _infoRow(Icons.calendar_today_outlined, 'প্রবেশের তারিখ',
//                       '${tenant.moveInDate.day}/${tenant.moveInDate.month}/${tenant.moveInDate.year}'),

//                   const SizedBox(height: 12),

//                   // Payment history
//                   Text('পেমেন্ট ইতিহাস',
//                       style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: color.primary)),
//                   const SizedBox(height: 8),

//                   _PaymentHistory(tenantId: tenant.id),

//                   const SizedBox(height: 12),

//                   // Action buttons
//                   Row(
//                     children: [
//                       // Restore button
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: () => _restoreTenant(context),
//                           icon: const Icon(Icons.restore_rounded, size: 18),
//                           label: const Text('পুনরায় যোগ করুন'),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       // Permanent delete
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: () => _permanentDelete(context),
//                           icon: const Icon(Icons.delete_forever_rounded,
//                               size: 18, color: Colors.red),
//                           label: const Text('মুছে ফেলুন',
//                               style: TextStyle(color: Colors.red)),
//                           style: OutlinedButton.styleFrom(
//                               side: const BorderSide(color: Colors.red)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _infoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           Icon(icon, size: 16, color: Colors.grey),
//           const SizedBox(width: 8),
//           Text('$label: ', style: const TextStyle(
//               fontSize: 13, fontWeight: FontWeight.w500)),
//           Expanded(child: Text(value,
//               style: const TextStyle(fontSize: 13, color: Colors.grey))),
//         ],
//       ),
//     );
//   }

//   Future<void> _restoreTenant(BuildContext context) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('পুনরায় যোগ করবেন?'),
//         content: Text(
//             '${tenant.name} কে active tenant হিসেবে ফিরিয়ে আনা হবে।\n\n'
//             'তবে রুম ${tenant.roomNumber} যদি অন্য কেউ নিয়ে থাকে, conflict হতে পারে।'),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('বাতিল')),
//           FilledButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('হ্যাঁ, ফিরিয়ে আনুন')),
//         ],
//       ),
//     );

//     if (confirm != true) return;

//     final db = FirebaseFirestore.instance;
//     // Restore tenant
//     await db.collection('tenants').doc(tenant.id).update({'isActive': true});
//     // Mark room occupied again
//     await db.collection('rooms').doc(tenant.roomId).update({
//       'status': 'occupied',
//       'tenantId': tenant.id,
//       'tenantName': tenant.name,
//     });

//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('${tenant.name} কে ফিরিয়ে আনা হয়েছে'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   }

//   Future<void> _permanentDelete(BuildContext context) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('চিরতরে মুছে ফেলবেন?'),
//         content: Text(
//             '${tenant.name} এর সব তথ্য permanently মুছে যাবে।\n\n'
//             'এই কাজ আর undo করা যাবে না।'),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('বাতিল')),
//           FilledButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: FilledButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('হ্যাঁ, মুছে ফেলুন'),
//           ),
//         ],
//       ),
//     );

//     if (confirm != true) return;

//     await FirebaseFirestore.instance
//         .collection('tenants')
//         .doc(tenant.id)
//         .delete();

//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('মুছে ফেলা হয়েছে')),
//       );
//     }
//   }
// }

// class _PaymentHistory extends StatelessWidget {
//   final String tenantId;
//   const _PaymentHistory({required this.tenantId});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<QuerySnapshot>(
//       future: FirebaseFirestore.instance
//           .collection('payments')
//           .where('tenantId', isEqualTo: tenantId)
//           .get(),
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const SizedBox(
//             height: 40,
//             child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
//           );
//         }

//         final payments = (snap.data?.docs ?? [])
//             .map((d) => PaymentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
//             .toList()
//           ..sort((a, b) {
//             if (a.year != b.year) return b.year.compareTo(a.year);
//             return b.month.compareTo(a.month);
//           });

//         if (payments.isEmpty) {
//           return const Text('কোনো payment রেকর্ড নেই',
//               style: TextStyle(color: Colors.grey, fontSize: 13));
//         }

//         final paidCount = payments.where((p) => p.status == PaymentStatus.paid).length;
//         final totalPaid = payments
//             .where((p) => p.status == PaymentStatus.paid)
//             .fold(0.0, (sum, p) => sum + p.amount);

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Summary
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.green.shade50,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.green.shade200),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.check_circle_rounded,
//                       color: Colors.green.shade700, size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     'মোট $paidCount মাস পরিশোধ • ৳${totalPaid.toStringAsFixed(0)}',
//                     style: TextStyle(
//                         color: Colors.green.shade700,
//                         fontWeight: FontWeight.w500,
//                         fontSize: 13),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 8),

//             // Payment list (last 6)
//             ...payments.take(6).map((p) {
//               const months = ['', 'জান', 'ফেব', 'মার্চ', 'এপ্রি',
//                 'মে', 'জুন', 'জুলা', 'আগ', 'সেপ্ট', 'অক্ট', 'নভে', 'ডিসে'];
//               final isPaid = p.status == PaymentStatus.paid;
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 6),
//                 child: Row(
//                   children: [
//                     Icon(
//                       isPaid ? Icons.check_circle_rounded : Icons.cancel_rounded,
//                       color: isPaid ? Colors.green : Colors.orange,
//                       size: 16,
//                     ),
//                     const SizedBox(width: 8),
//                     Text('${months[p.month]} ${p.year}',
//                         style: const TextStyle(fontSize: 13)),
//                     const Spacer(),
//                     Text('৳${p.amount.toStringAsFixed(0)}',
//                         style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                             color: isPaid ? Colors.green.shade700 : Colors.orange.shade700)),
//                   ],
//                 ),
//               );
//             }),

//             if (payments.length > 6)
//               Text('+ আরও ${payments.length - 6} টি রেকর্ড',
//                   style: const TextStyle(fontSize: 12, color: Colors.grey)),
//           ],
//         );
//       },
//     );
//   }
// }







import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../../../models/tenant_model.dart';
import '../../../models/payment_model.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ──
          SliverAppBar(
            pinned: true,
            backgroundColor: bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('আর্কাইভ',
                style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            centerTitle: true,
          ),

          // ── Body ──
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tenants')
                .where('landlordId', isEqualTo: user.uid)
                .where('isActive', isEqualTo: false)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: primary)),
                );
              }

              final tenants = (snap.data?.docs ?? [])
                  .map((d) => TenantModel.fromMap(d.data() as Map<String, dynamic>, d.id))
                  .toList()
                ..sort((a, b) => b.moveInDate.compareTo(a.moveInDate));

              if (tenants.isEmpty) {
                return SliverFillRemaining(child: _emptyState(context, primary, isDark));
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _ArchivedCard(
                      tenant: tenants[i],
                      landlordId: user.uid,
                      index: i,
                      isDark: isDark,
                      primary: primary,
                    ),
                    childCount: tenants.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, Color primary, bool isDark) {
    final textSecondary = isDark ? Colors.white38 : const Color(0xFF6B7280);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: primary.withOpacity(0.2), width: 2),
            ),
            child: Icon(Icons.archive_outlined, size: 48, color: primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          const Text('আর্কাইভ খালি',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('রুম খালি করলে ভাড়াটিয়ার তথ্য এখানে আসবে',
              style: TextStyle(fontSize: 14, color: textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Archived Tenant Card ──────────────────────────────────────────────────────

class _ArchivedCard extends StatefulWidget {
  final TenantModel tenant;
  final String landlordId;
  final int index;
  final bool isDark;
  final Color primary;

  const _ArchivedCard({
    required this.tenant,
    required this.landlordId,
    required this.index,
    required this.isDark,
    required this.primary,
  });

  @override
  State<_ArchivedCard> createState() => _ArchivedCardState();
}

class _ArchivedCardState extends State<_ArchivedCard> {
  bool _expanded = false;

  static const List<Color> _avatarColors = [
    Color(0xFF2D7A4F), Color(0xFF0891B2), Color(0xFFD97706),
    Color(0xFF5B4FBF), Color(0xFF059669), Color(0xFFDC2626),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final primary = widget.primary;
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final divider = isDark ? Colors.white10 : const Color(0xFFE5E7EB);
    final avatarColor = _avatarColors[widget.index % _avatarColors.length];

    // moveOutDate — Firestore map থেকে পড়া (nullable)
    final tenant = widget.tenant;
    final moveOutDate = _getMoveOutDate(tenant);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // ── Collapsed Header ──
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: _expanded
                ? const BorderRadius.vertical(top: Radius.circular(18))
                : BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: avatarColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: avatarColor.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name + property
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tenant.name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.home_work_outlined, size: 12, color: textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text('${tenant.propertyName} • রুম ${tenant.roomNumber}',
                                  style: TextStyle(fontSize: 12, color: textSecondary),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // moveOutDate badge
                        if (moveOutDate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red.withOpacity(0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.logout_rounded, size: 11, color: Colors.red),
                                const SizedBox(width: 4),
                                Text(
                                  'ছেড়েছেন: ${_formatDate(moveOutDate)}',
                                  style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('আর্কাইভড',
                                style: TextStyle(fontSize: 11, color: textSecondary)),
                          ),
                      ],
                    ),
                  ),

                  // Expand icon
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: textSecondary, size: 24),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded Detail ──
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildDetail(
              context: context,
              tenant: tenant,
              moveOutDate: moveOutDate,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              divider: divider,
              primary: primary,
              isDark: isDark,
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  // ── moveOutDate পড়া (TenantModel এ না থাকলে extra field হিসেবে) ──
  DateTime? _getMoveOutDate(TenantModel tenant) {
    // try {
    //   // TenantModel এ moveOutDate field থাকলে সরাসরি পড়া যাবে।
    //   // না থাকলে নিচের try-catch এ null return হবে।
    //   // ignore: unnecessary_type_check
    //   final dynamic t = tenant;
    //   if (t.moveOutDate != null) return t.moveOutDate as DateTime;
    // } catch (_) {}
    // return null;
    return tenant.moveOutDate; // ← সরাসরি access
  }

  String _formatDate(DateTime date) {
    const months = ['', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
      'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  Widget _buildDetail({
    required BuildContext context,
    required TenantModel tenant,
    required DateTime? moveOutDate,
    required Color textPrimary,
    required Color textSecondary,
    required Color divider,
    required Color primary,
    required bool isDark,
  }) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;

    return Column(
      children: [
        Divider(height: 1, color: divider),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── ব্যক্তিগত তথ্য ──
              _sectionLabel('ব্যক্তিগত তথ্য', textSecondary),
              _infoCard(isDark: isDark, children: [
                _infoRow(Icons.phone_outlined, 'ফোন', tenant.phone,
                    const Color(0xFF059669), textPrimary, textSecondary, divider, showDivider: true),
                _infoRow(Icons.email_outlined, 'Email',
                    tenant.email.isEmpty ? 'নেই' : tenant.email,
                    const Color(0xFF0891B2), textPrimary, textSecondary, divider, showDivider: true),
                _infoRow(Icons.badge_outlined, 'NID', tenant.nidNumber,
                    const Color(0xFF5B4FBF), textPrimary, textSecondary, divider, showDivider: false),
              ]),
              const SizedBox(height: 12),

              // ── রুমের তথ্য ──
              _sectionLabel('রুমের তথ্য', textSecondary),
              _infoCard(isDark: isDark, children: [
                _infoRow(Icons.home_work_outlined, 'Property', tenant.propertyName,
                    primary, textPrimary, textSecondary, divider, showDivider: true),
                _infoRow(Icons.door_front_door_outlined, 'রুম নম্বর', tenant.roomNumber,
                    const Color(0xFF0891B2), textPrimary, textSecondary, divider, showDivider: true),
                _infoRow(Icons.currency_exchange_rounded, 'মাসিক ভাড়া',
                    '৳${tenant.rentAmount.toStringAsFixed(0)}',
                    const Color(0xFF059669), textPrimary, textSecondary, divider, showDivider: false),
              ]),
              const SizedBox(height: 12),

              // ── প্রবেশ ও বিদায়ের তথ্য ──
              _sectionLabel('বসবাসের তথ্য', textSecondary),
              _infoCard(isDark: isDark, children: [
                _infoRow(
                  Icons.login_rounded,
                  'প্রবেশের তারিখ',
                  _formatDate(tenant.moveInDate),
                  const Color(0xFF059669), textPrimary, textSecondary, divider,
                  showDivider: moveOutDate != null,
                ),
                if (moveOutDate != null)
                  _infoRow(
                    Icons.logout_rounded,
                    'ছেড়ে যাওয়ার তারিখ',
                    _formatDate(moveOutDate),
                    Colors.red, textPrimary, textSecondary, divider,
                    showDivider: true,
                  ),
                _infoRow(
                  Icons.timelapse_rounded,
                  'বসবাসকাল',
                  _stayDuration(tenant.moveInDate, moveOutDate),
                  const Color(0xFFD97706), textPrimary, textSecondary, divider,
                  showDivider: false,
                ),
              ]),
              const SizedBox(height: 12),

              // ── পেমেন্ট ইতিহাস ──
              _sectionLabel('পেমেন্ট ইতিহাস', textSecondary),
              _PaymentSection(tenantId: tenant.id, isDark: isDark, primary: primary),
              const SizedBox(height: 16),

              // ── Action Buttons ──
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      icon: Icons.restore_rounded,
                      label: 'পুনরায় যোগ করুন',
                      color: primary,
                      filled: true,
                      onTap: () => _restoreTenant(context, tenant),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.delete_forever_rounded,
                      label: 'মুছে ফেলুন',
                      color: Colors.red,
                      filled: false,
                      onTap: () => _permanentDelete(context, tenant),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _stayDuration(DateTime moveIn, DateTime? moveOut) {
    final end = moveOut ?? DateTime.now();
    final days = end.difference(moveIn).inDays;
    if (days < 30) return '$days দিন';
    final months = (days / 30).floor();
    if (months < 12) return '$months মাস';
    final years = (months / 12).floor();
    final remMonths = months % 12;
    return remMonths > 0 ? '$years বছর $remMonths মাস' : '$years বছর';
  }

  Widget _sectionLabel(String title, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: color, letterSpacing: 0.5)),
      );

  Widget _infoCard({required bool isDark, required List<Widget> children}) {
    final cardBg = isDark ? const Color(0xFF243320) : const Color(0xFFF9FAFB);
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
    Color textPrimary,
    Color textSecondary,
    Color dividerColor, {
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontSize: 11, color: textSecondary)),
                    const SizedBox(height: 1),
                    Text(value,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 62),
            child: Divider(height: 1, color: dividerColor),
          ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: filled ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: filled
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.6), width: 1.5),
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: filled ? Colors.white : color, size: 18),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: filled ? Colors.white : color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _restoreTenant(BuildContext context, TenantModel tenant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('পুনরায় যোগ করবেন?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            '${tenant.name} কে active tenant হিসেবে ফিরিয়ে আনা হবে।\n\n'
            'তবে রুম ${tenant.roomNumber} যদি অন্য কেউ নিয়ে থাকে, conflict হতে পারে।'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('বাতিল')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('হ্যাঁ, ফিরিয়ে আনুন')),
        ],
      ),
    );
    if (confirm != true) return;

    final db = FirebaseFirestore.instance;
    await db.collection('tenants').doc(tenant.id).update({
      'isActive': true,
      'moveOutDate': null, // restore করলে moveOutDate clear
    });
    await db.collection('rooms').doc(tenant.roomId).update({
      'status': 'occupied',
      'tenantId': tenant.id,
      'tenantName': tenant.name,
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${tenant.name} কে ফিরিয়ে আনা হয়েছে'),
        backgroundColor: Colors.green,
      ));
    }
  }

  Future<void> _permanentDelete(BuildContext context, TenantModel tenant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('চিরতরে মুছে ফেলবেন?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('${tenant.name} এর সব তথ্য permanently মুছে যাবে।\n\nএই কাজ আর undo করা যাবে না।'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('বাতিল')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('হ্যাঁ, মুছে ফেলুন'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await FirebaseFirestore.instance.collection('tenants').doc(tenant.id).delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('মুছে ফেলা হয়েছে')));
    }
  }
}

// ── Payment Section ───────────────────────────────────────────────────────────

class _PaymentSection extends StatelessWidget {
  final String tenantId;
  final bool isDark;
  final Color primary;
  const _PaymentSection({required this.tenantId, required this.isDark, required this.primary});

  @override
  Widget build(BuildContext context) {
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('payments')
          .where('tenantId', isEqualTo: tenantId)
          .get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        }

        final payments = (snap.data?.docs ?? [])
            .map((d) => PaymentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList()
          ..sort((a, b) {
            if (a.year != b.year) return b.year.compareTo(a.year);
            return b.month.compareTo(a.month);
          });

        if (payments.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF243320) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
            ),
            child: Text('কোনো payment রেকর্ড নেই',
                style: TextStyle(color: textSecondary, fontSize: 13)),
          );
        }

        final paidCount = payments.where((p) => p.status == PaymentStatus.paid).length;
        final pendingCount = payments.where((p) => p.status != PaymentStatus.paid).length;
        final totalPaid = payments
            .where((p) => p.status == PaymentStatus.paid)
            .fold(0.0, (sum, p) => sum + p.amount);

        return Column(
          children: [
            // Summary chips
            Row(
              children: [
                _chip(Icons.check_circle_outline_rounded, '$paidCount মাস পরিশোধ',
                    Colors.green, isDark),
                const SizedBox(width: 8),
                _chip(Icons.pending_outlined, '$pendingCount বাকি',
                    const Color(0xFFD97706), isDark),
                const SizedBox(width: 8),
                _chip(Icons.account_balance_wallet_outlined,
                    '৳${totalPaid.toStringAsFixed(0)}', primary, isDark),
              ],
            ),
            const SizedBox(height: 10),

            // Payment list (last 6)
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF243320) : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  ...payments.take(6).toList().asMap().entries.map((entry) {
                    final i = entry.key;
                    final p = entry.value;
                    const months = ['', 'জান', 'ফেব', 'মার্চ', 'এপ্রি',
                      'মে', 'জুন', 'জুলা', 'আগ', 'সেপ্ট', 'অক্ট', 'নভে', 'ডিসে'];
                    final isPaid = p.status == PaymentStatus.paid;
                    final isLast = i == (payments.length > 6 ? 5 : payments.length - 1);

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          child: Row(
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: (isPaid ? Colors.green : const Color(0xFFD97706)).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isPaid ? Icons.check_rounded : Icons.schedule_rounded,
                                  color: isPaid ? Colors.green : const Color(0xFFD97706),
                                  size: 17,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('${months[p.month]} ${p.year}',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                              ),
                              Text('৳${p.amount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isPaid ? Colors.green : const Color(0xFFD97706))),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(height: 1,
                              color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
                              indent: 56),
                      ],
                    );
                  }),
                  if (payments.length > 6)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                      child: Text('+ আরও ${payments.length - 6} টি রেকর্ড',
                          style: TextStyle(fontSize: 12, color: textSecondary)),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _chip(IconData icon, String label, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label,
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}