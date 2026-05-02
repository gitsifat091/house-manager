// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:provider/provider.dart';
// import '../../../models/user_model.dart';
// import '../../../models/tenant_model.dart';
// import '../../../models/payment_model.dart';
// import '../../../services/auth_service.dart';
// import '../../../widgets/profile_avatar.dart';

// class TenantProfileScreen extends StatelessWidget {
//   final dynamic user; // UserModel
//   const TenantProfileScreen({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;

//     return Scaffold(
//       body: FutureBuilder<QuerySnapshot>(
//         // ── Fetch tenant record by userId ──
        
//         // future: FirebaseFirestore.instance
//         //     .collection('tenants')
//         //     .where('userId', isEqualTo: user.uid)
//         //     .where('isArchived', isEqualTo: false)
//         //     .limit(1)
//         //     .get(),

//         future: FirebaseFirestore.instance
//           .collection('tenants')
//           .where('email', isEqualTo: user.email)
//           .where('isActive', isEqualTo: true)
//           .limit(1)
//           .get(),

//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           // tenant record পাওয়া না গেলে basic profile দেখাবে
//           if (!snap.hasData || snap.data!.docs.isEmpty) {
//             return _BasicProfileView(user: user);
//           }

//           final doc = snap.data!.docs.first;
//           final tenant = TenantModel.fromMap(
//               doc.data() as Map<String, dynamic>, doc.id);

//           return _FullProfileView(user: user, tenant: tenant);
//         },
//       ),
//     );
//   }
// }

// // ── Full Profile (tenant record আছে) ─────────────────────────────────────────

// class _FullProfileView extends StatelessWidget {
//   final dynamic user;
//   final TenantModel tenant;
//   const _FullProfileView({required this.user, required this.tenant});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;

//     return CustomScrollView(
//       slivers: [
//         // ── Hero AppBar ──────────────────────────────────────
//         SliverAppBar(
//           expandedHeight: 250,
//           pinned: true,
//           backgroundColor: color.primary,
//           iconTheme: const IconThemeData(color: Colors.white),
//           title: const Text('আমার প্রোফাইল',
//               style: TextStyle(color: Colors.white, fontSize: 16)),
//           flexibleSpace: FlexibleSpaceBar(
//             background: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [color.primary, color.primary.withOpacity(0.75)],
//                 ),
//               ),
//               child: SafeArea(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const SizedBox(height: 36),
//                     // Profile avatar (editable)
//                     Consumer<AuthService>(
//                       builder: (context, auth, _) => Container(
//                         padding: const EdgeInsets.all(3),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 2.5),
//                         ),
//                         child: ProfileAvatar(
//                           name: auth.currentUser?.name ?? user.name,
//                           photoUrl: auth.currentUser?.photoUrl,
//                           userId: user.uid,
//                           radius: 46,
//                           editable: true,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       user.name,
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     // Property + Room pill
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 14, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: Colors.white24,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(Icons.home_work_outlined,
//                               size: 14, color: Colors.white70),
//                           const SizedBox(width: 5),
//                           Text(
//                             '${tenant.propertyName}  •  রুম ${tenant.roomNumber}',
//                             style: const TextStyle(
//                                 color: Colors.white, fontSize: 13),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),

//         // ── Stats Row ────────────────────────────────────────
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//             child: _StatsRow(tenant: tenant),
//           ),
//         ),

//         // ── Content ──────────────────────────────────────────
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _SectionLabel('ব্যক্তিগত তথ্য'),
//                 const SizedBox(height: 8),
//                 _InfoCard(children: [
//                   _InfoRow(Icons.phone_outlined, 'ফোন', user.phone),
//                   _InfoRow(Icons.email_outlined, 'Email', user.email),
//                   _InfoRow(Icons.badge_outlined, 'NID',
//                       tenant.nidNumber.isNotEmpty ? tenant.nidNumber : 'নেই'),
//                 ]),

//                 const SizedBox(height: 16),

//                 _SectionLabel('রুমের তথ্য'),
//                 const SizedBox(height: 8),
//                 _InfoCard(children: [
//                   _InfoRow(Icons.home_work_outlined, 'Property',
//                       tenant.propertyName),
//                   _InfoRow(Icons.door_front_door_outlined, 'রুম নম্বর',
//                       tenant.roomNumber),
//                   _InfoRow(Icons.currency_exchange_rounded, 'মাসিক ভাড়া',
//                       '৳${tenant.rentAmount.toStringAsFixed(0)}'),
//                 ]),

//                 const SizedBox(height: 16),

//                 _SectionLabel('প্রবেশের তথ্য'),
//                 const SizedBox(height: 8),
//                 _InfoCard(children: [
//                   _InfoRow(Icons.calendar_today_outlined, 'তারিখ',
//                       _formatDate(tenant.moveInDate)),
//                   _InfoRow(Icons.access_time_rounded, 'সময়',
//                       _formatTime(tenant.moveInDate)),
//                   _InfoRow(Icons.timelapse_rounded, 'কতদিন আছেন',
//                       _daysLiving(tenant.moveInDate)),
//                 ]),

//                 const SizedBox(height: 16),

//                 _SectionLabel('পেমেন্ট সারসংক্ষেপ'),
//                 const SizedBox(height: 8),
//                 _PaymentSummaryCard(tenantId: tenant.id),

//                 const SizedBox(height: 24),

//                 // Logout
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: OutlinedButton.icon(
//                     onPressed: () => _confirmLogout(context),
//                     icon: const Icon(Icons.logout_rounded, color: Colors.red),
//                     label: const Text('Logout',
//                         style: TextStyle(
//                             color: Colors.red, fontWeight: FontWeight.w600)),
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: Colors.red),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 32),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   String _formatDate(DateTime dt) {
//     const months = [
//       '', 'জানু', 'ফেব্রু', 'মার্চ', 'এপ্রিল',
//       'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টে',
//       'অক্টো', 'নভে', 'ডিসে'
//     ];
//     return '${dt.day} ${months[dt.month]} ${dt.year}';
//   }

//   String _formatTime(DateTime dt) {
//     final h = dt.hour.toString().padLeft(2, '0');
//     final m = dt.minute.toString().padLeft(2, '0');
//     return '$h:$m';
//   }

//   String _daysLiving(DateTime moveIn) {
//     final days = DateTime.now().difference(moveIn).inDays;
//     if (days < 30) return '$days দিন';
//     if (days < 365) return '${days ~/ 30} মাস ${days % 30} দিন';
//     return '${days ~/ 365} বছর ${(days % 365) ~/ 30} মাস';
//   }

//   void _confirmLogout(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Logout করবেন?',
//             style: TextStyle(fontWeight: FontWeight.w700)),
//         content: const Text('আপনি কি নিশ্চিতভাবে logout করতে চান?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('না'),
//           ),
//           FilledButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.of(context).popUntil((route) => route.isFirst);
//               context.read<AuthService>().logout();
//             },
//             child: const Text('হ্যাঁ, Logout'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Basic Profile (tenant record নেই — room assign হয়নি) ──────────────────────

// class _BasicProfileView extends StatelessWidget {
//   final dynamic user;
//   const _BasicProfileView({required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;

//     return CustomScrollView(
//       slivers: [
//         SliverAppBar(
//           expandedHeight: 220,
//           pinned: true,
//           backgroundColor: color.primary,
//           iconTheme: const IconThemeData(color: Colors.white),
//           title: const Text('আমার প্রোফাইল',
//               style: TextStyle(color: Colors.white, fontSize: 16)),
//           flexibleSpace: FlexibleSpaceBar(
//             background: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [color.primary, color.primary.withOpacity(0.75)],
//                 ),
//               ),
//               child: SafeArea(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const SizedBox(height: 36),
//                     Consumer<AuthService>(
//                       builder: (context, auth, _) => Container(
//                         padding: const EdgeInsets.all(3),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 2.5),
//                         ),
//                         child: ProfileAvatar(
//                           name: auth.currentUser?.name ?? user.name,
//                           photoUrl: auth.currentUser?.photoUrl,
//                           userId: user.uid,
//                           radius: 46,
//                           editable: true,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(user.name,
//                         style: const TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white)),
//                     const SizedBox(height: 6),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 14, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: Colors.white24,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Text('ভাড়াটিয়া',
//                           style: TextStyle(color: Colors.white, fontSize: 13)),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),

//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Room not assigned notice
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(color: Colors.orange.withOpacity(0.3)),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.orange.withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Icon(Icons.info_outline_rounded,
//                             color: Colors.orange, size: 20),
//                       ),
//                       const SizedBox(width: 12),
//                       const Expanded(
//                         child: Text(
//                           'এখনো কোনো রুম assign করা হয়নি। বাড়ীওয়ালার সাথে যোগাযোগ করুন।',
//                           style: TextStyle(fontSize: 13, color: Colors.orange),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 _SectionLabel('যোগাযোগের তথ্য'),
//                 const SizedBox(height: 8),
//                 _InfoCard(children: [
//                   _InfoRow(Icons.email_outlined, 'Email', user.email),
//                   _InfoRow(Icons.phone_outlined, 'Phone', user.phone),
//                 ]),

//                 const SizedBox(height: 24),

//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: OutlinedButton.icon(
//                     onPressed: () => _confirmLogout(context),
//                     icon: const Icon(Icons.logout_rounded, color: Colors.red),
//                     label: const Text('Logout',
//                         style: TextStyle(
//                             color: Colors.red, fontWeight: FontWeight.w600)),
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: Colors.red),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _confirmLogout(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Logout করবেন?',
//             style: TextStyle(fontWeight: FontWeight.w700)),
//         content: const Text('আপনি কি নিশ্চিতভাবে logout করতে চান?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('না'),
//           ),
//           FilledButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.of(context).popUntil((route) => route.isFirst);
//               context.read<AuthService>().logout();
//             },
//             child: const Text('হ্যাঁ, Logout'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Stats Row ──────────────────────────────────────────────────────────────────

// class _StatsRow extends StatelessWidget {
//   final TenantModel tenant;
//   const _StatsRow({required this.tenant});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     final days = DateTime.now().difference(tenant.moveInDate).inDays;

//     return Row(
//       children: [
//         _StatBox(
//           icon: Icons.payments_rounded,
//           label: 'মাসিক ভাড়া',
//           value: '৳${tenant.rentAmount.toStringAsFixed(0)}',
//           color: color,
//         ),
//         const SizedBox(width: 10),
//         _StatBox(
//           icon: Icons.calendar_month_rounded,
//           label: 'বসবাসকাল',
//           value: days < 30 ? '$days দিন' : '${days ~/ 30} মাস',
//           color: color,
//         ),
//       ],
//     );
//   }
// }

// class _StatBox extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final ColorScheme color;
//   const _StatBox({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//         decoration: BoxDecoration(
//           color: color.primaryContainer.withOpacity(0.5),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: color.primary.withOpacity(0.15)),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: color.primary.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: color.primary, size: 18),
//             ),
//             const SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label,
//                     style: TextStyle(
//                         fontSize: 10,
//                         color: color.onSurface.withOpacity(0.5))),
//                 Text(value,
//                     style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: color.primary)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Payment Summary ────────────────────────────────────────────────────────────

// class _PaymentSummaryCard extends StatelessWidget {
//   final String tenantId;
//   const _PaymentSummaryCard({required this.tenantId});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;

//     return FutureBuilder<QuerySnapshot>(
//       future: FirebaseFirestore.instance
//           .collection('payments')
//           .where('tenantId', isEqualTo: tenantId)
//           .get(),
//       builder: (context, snap) {
//         if (!snap.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final payments = snap.data!.docs
//             .map((d) =>
//                 PaymentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
//             .toList();

//         final paidCount =
//             payments.where((p) => p.status == PaymentStatus.paid).length;
//         final pendingCount =
//             payments.where((p) => p.status == PaymentStatus.pending).length;
//         final totalPaid = payments
//             .where((p) => p.status == PaymentStatus.paid)
//             .fold(0.0, (sum, p) => sum + p.amount);

//         return Row(
//           children: [
//             _PayBox(
//               label: 'পরিশোধ',
//               value: '$paidCount মাস',
//               icon: Icons.check_circle_outline,
//               bg: Colors.green.withOpacity(0.1),
//               iconColor: Colors.green,
//               textColor: Colors.green.shade700,
//             ),
//             const SizedBox(width: 10),
//             _PayBox(
//               label: 'বাকি',
//               value: '$pendingCount মাস',
//               icon: Icons.pending_outlined,
//               bg: Colors.orange.withOpacity(0.1),
//               iconColor: Colors.orange,
//               textColor: Colors.orange.shade700,
//             ),
//             const SizedBox(width: 10),
//             _PayBox(
//               label: 'মোট দেওয়া',
//               value: '৳${totalPaid.toStringAsFixed(0)}',
//               icon: Icons.account_balance_wallet_outlined,
//               bg: color.primary.withOpacity(0.08),
//               iconColor: color.primary,
//               textColor: color.primary,
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class _PayBox extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color bg;
//   final Color iconColor;
//   final Color textColor;
//   const _PayBox({
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.bg,
//     required this.iconColor,
//     required this.textColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
//         decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: iconColor, size: 22),
//             const SizedBox(height: 6),
//             Text(value,
//                 style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.bold,
//                     color: textColor)),
//             const SizedBox(height: 2),
//             Text(label,
//                 style: TextStyle(
//                     fontSize: 10, color: textColor.withOpacity(0.7))),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Shared Widgets ─────────────────────────────────────────────────────────────

// class _SectionLabel extends StatelessWidget {
//   final String text;
//   const _SectionLabel(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: TextStyle(
//         fontSize: 13,
//         fontWeight: FontWeight.bold,
//         color: Theme.of(context).colorScheme.primary,
//         letterSpacing: 0.3,
//       ),
//     );
//   }
// }

// class _InfoCard extends StatelessWidget {
//   final List<Widget> children;
//   const _InfoCard({required this.children});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     return Container(
//       decoration: BoxDecoration(
//         color: color.surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color.outlineVariant.withOpacity(0.5)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: children
//             .asMap()
//             .entries
//             .map((e) => Column(
//                   children: [
//                     e.value,
//                     if (e.key < children.length - 1)
//                       Divider(
//                         height: 1,
//                         indent: 16,
//                         endIndent: 16,
//                         color: color.outlineVariant.withOpacity(0.5),
//                       ),
//                   ],
//                 ))
//             .toList(),
//       ),
//     );
//   }
// }

// class _InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   const _InfoRow(this.icon, this.label, this.value);

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: color.primary.withOpacity(0.8)),
//           const SizedBox(width: 12),
//           Text(label,
//               style: TextStyle(
//                   fontSize: 13, color: color.onSurface.withOpacity(0.5))),
//           Expanded(
//             child: Text(
//               value,
//               textAlign: TextAlign.right,
//               style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../models/tenant_model.dart';
import '../../../models/payment_model.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/profile_avatar.dart';

class TenantProfileScreen extends StatelessWidget {
  final dynamic user;
  const TenantProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('tenants')
            .where('email', isEqualTo: user.email)
            .where('isActive', isEqualTo: true)
            .limit(1)
            .get(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return _BasicProfileView(user: user);
          }
          final doc = snap.data!.docs.first;
          final tenant = TenantModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          return _FullProfileView(user: user, tenant: tenant);
        },
      ),
    );
  }
}


class _FullProfileView extends StatelessWidget {
  final dynamic user;
  final TenantModel tenant;
  const _FullProfileView({required this.user, required this.tenant});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250, pinned: true,
          backgroundColor: color.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('আমার প্রোফাইল', style: TextStyle(color: Colors.white, fontSize: 16)),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [color.primary, color.primary.withOpacity(0.75)],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 36),
                    Consumer<AuthService>(
                      builder: (context, auth, _) => Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5)),
                        child: ProfileAvatar(
                          name: auth.currentUser?.name ?? user.name,
                          photoUrl: auth.currentUser?.photoUrl,
                          userId: user.uid, radius: 46, editable: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.home_work_outlined, size: 14, color: Colors.white70),
                          const SizedBox(width: 5),
                          Text('${tenant.propertyName}  •  রুম ${tenant.roomNumber}',
                              style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _StatsRow(tenant: tenant),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel('ব্যক্তিগত তথ্য'),
                const SizedBox(height: 8),
                _InfoCard(children: [
                  _InfoRow(Icons.phone_outlined, 'ফোন', user.phone),
                  _InfoRow(Icons.email_outlined, 'Email', user.email),
                  _InfoRow(Icons.badge_outlined, 'NID', tenant.nidNumber.isNotEmpty ? tenant.nidNumber : 'নেই'),
                ]),
                const SizedBox(height: 16),
                _SectionLabel('রুমের তথ্য'),
                const SizedBox(height: 8),
                _InfoCard(children: [
                  _InfoRow(Icons.home_work_outlined, 'Property', tenant.propertyName),
                  _InfoRow(Icons.door_front_door_outlined, 'রুম নম্বর', tenant.roomNumber),
                  _InfoRow(Icons.currency_exchange_rounded, 'মাসিক ভাড়া', '৳${tenant.rentAmount.toStringAsFixed(0)}'),
                ]),
                const SizedBox(height: 16),
                _SectionLabel('প্রবেশের তথ্য'),
                const SizedBox(height: 8),
                _InfoCard(children: [
                  _InfoRow(Icons.calendar_today_outlined, 'তারিখ', _formatDate(tenant.moveInDate)),
                  _InfoRow(Icons.access_time_rounded, 'সময়', _formatTime(tenant.moveInDate)),
                  _InfoRow(Icons.timelapse_rounded, 'কতদিন আছেন', _daysLiving(tenant.moveInDate)),
                ]),
                const SizedBox(height: 16),
                _SectionLabel('পেমেন্ট সারসংক্ষেপ'),
                const SizedBox(height: 8),
                _PaymentSummaryCard(tenantId: tenant.id),
                const SizedBox(height: 16),
                _SectionLabel('বাড়ীওয়ালার তথ্য'),
                const SizedBox(height: 8),
                _LandlordInfoCard(landlordId: tenant.landlordId),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['', 'জানু', 'ফেব্রু', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টে', 'অক্টো', 'নভে', 'ডিসে'];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _daysLiving(DateTime moveIn) {
    final days = DateTime.now().difference(moveIn).inDays;
    if (days < 30) return '$days দিন';
    if (days < 365) return '${days ~/ 30} মাস ${days % 30} দিন';
    return '${days ~/ 365} বছর ${(days % 365) ~/ 30} মাস';
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout করবেন?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('আপনি কি নিশ্চিতভাবে logout করতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('না')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.read<AuthService>().logout();
            },
            child: const Text('হ্যাঁ, Logout'),
          ),
        ],
      ),
    );
  }
}


class _BasicProfileView extends StatelessWidget {
  final dynamic user;
  const _BasicProfileView({required this.user});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220, pinned: true,
          backgroundColor: color.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('আমার প্রোফাইল', style: TextStyle(color: Colors.white, fontSize: 16)),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [color.primary, color.primary.withOpacity(0.75)],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 36),
                    Consumer<AuthService>(
                      builder: (context, auth, _) => Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5)),
                        child: ProfileAvatar(
                          name: auth.currentUser?.name ?? user.name,
                          photoUrl: auth.currentUser?.photoUrl,
                          userId: user.uid, radius: 46, editable: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: const Text('ভাড়াটিয়া', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('এখনো কোনো রুম assign করা হয়নি। বাড়ীওয়ালার সাথে যোগাযোগ করুন।',
                            style: TextStyle(fontSize: 13, color: Colors.orange)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionLabel('যোগাযোগের তথ্য'),
                const SizedBox(height: 8),
                _InfoCard(children: [
                  _InfoRow(Icons.email_outlined, 'Email', user.email),
                  _InfoRow(Icons.phone_outlined, 'Phone', user.phone),
                ]),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout করবেন?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('আপনি কি নিশ্চিতভাবে logout করতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('না')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.read<AuthService>().logout();
            },
            child: const Text('হ্যাঁ, Logout'),
          ),
        ],
      ),
    );
  }
}


class _StatsRow extends StatelessWidget {
  final TenantModel tenant;
  const _StatsRow({required this.tenant});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final days = DateTime.now().difference(tenant.moveInDate).inDays;
    return Row(
      children: [
        _StatBox(icon: Icons.payments_rounded, label: 'মাসিক ভাড়া',
            value: '৳${tenant.rentAmount.toStringAsFixed(0)}', color: color),
        const SizedBox(width: 10),
        _StatBox(icon: Icons.calendar_month_rounded, label: 'বসবাসকাল',
            value: days < 30 ? '$days দিন' : '${days ~/ 30} মাস', color: color),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme color;
  const _StatBox({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.primary.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: color.onSurface.withOpacity(0.5))),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  final String tenantId;
  const _PaymentSummaryCard({required this.tenantId});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('payments').where('tenantId', isEqualTo: tenantId).get(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final payments = snap.data!.docs
            .map((d) => PaymentModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
        final paidCount = payments.where((p) => p.status == PaymentStatus.paid).length;
        final pendingCount = payments.where((p) => p.status == PaymentStatus.pending).length;
        final totalPaid = payments.where((p) => p.status == PaymentStatus.paid).fold(0.0, (s, p) => s + p.amount);
        return Row(
          children: [
            _PayBox(label: 'পরিশোধ', value: '$paidCount মাস', icon: Icons.check_circle_outline,
                bg: Colors.green.withOpacity(0.1), iconColor: Colors.green, textColor: Colors.green.shade700),
            const SizedBox(width: 10),
            _PayBox(label: 'বাকি', value: '$pendingCount মাস', icon: Icons.pending_outlined,
                bg: Colors.orange.withOpacity(0.1), iconColor: Colors.orange, textColor: Colors.orange.shade700),
            const SizedBox(width: 10),
            _PayBox(label: 'মোট দেওয়া', value: '৳${totalPaid.toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet_outlined,
                bg: color.primary.withOpacity(0.08), iconColor: color.primary, textColor: color.primary),
          ],
        );
      },
    );
  }
}

class _PayBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color bg, iconColor, textColor;
  const _PayBox({required this.label, required this.value, required this.icon,
      required this.bg, required this.iconColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}


class _LandlordInfoCard extends StatelessWidget {
  final String landlordId;
  const _LandlordInfoCard({required this.landlordId});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(landlordId).get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.surface, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.outlineVariant.withOpacity(0.5)),
            ),
            child: Center(child: CircularProgressIndicator(color: color.primary, strokeWidth: 2)),
          );
        }
        if (!snap.hasData || !snap.data!.exists) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.surface, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.outlineVariant.withOpacity(0.5)),
            ),
            child: Text('তথ্য পাওয়া যায়নি', style: TextStyle(color: color.onSurface.withOpacity(0.5))),
          );
        }
        final data = snap.data!.data() as Map<String, dynamic>;
        final name = data['name'] ?? '';
        final phone = data['phone'] ?? '';
        final email = data['email'] ?? '';

        return Container(
          decoration: BoxDecoration(
            color: color.surface, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.outlineVariant.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: color.primary.withOpacity(0.06),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22, backgroundColor: color.primary,
                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'ব',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(name,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color.onSurface)),
                          Text('বাড়ীওয়ালা',
                              style: TextStyle(fontSize: 11, color: color.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 12, color: color.primary),
                          const SizedBox(width: 4),
                          Text('যাচাইকৃত',
                              style: TextStyle(fontSize: 11, color: color.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Phone
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 18, color: color.primary.withOpacity(0.8)),
                    const SizedBox(width: 12),
                    Text('ফোন', style: TextStyle(fontSize: 13, color: color.onSurface.withOpacity(0.5))),
                    Expanded(
                      child: SelectableText(phone.isNotEmpty ? phone : 'নেই',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: color.outlineVariant.withOpacity(0.5)),
              // Email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Icon(Icons.email_outlined, size: 18, color: color.primary.withOpacity(0.8)),
                    const SizedBox(width: 12),
                    Text('Email', style: TextStyle(fontSize: 13, color: color.onSurface.withOpacity(0.5))),
                    Expanded(
                      child: SelectableText(email.isNotEmpty ? email : 'নেই',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              // Hint
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Icon(Icons.touch_app_outlined, size: 12, color: color.onSurface.withOpacity(0.3)),
                    const SizedBox(width: 4),
                    Text('ট্যাপ করে ধরলে কপি করা যাবে',
                        style: TextStyle(fontSize: 11, color: color.onSurface.withOpacity(0.35))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary, letterSpacing: 0.3));
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: color.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.outlineVariant.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: children.asMap().entries.map((e) => Column(
          children: [
            e.value,
            if (e.key < children.length - 1)
              Divider(height: 1, indent: 16, endIndent: 16, color: color.outlineVariant.withOpacity(0.5)),
          ],
        )).toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color.primary.withOpacity(0.8)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 13, color: color.onSurface.withOpacity(0.5))),
          Expanded(
            child: SelectableText(value, textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}