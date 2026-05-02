// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../widgets/profile_avatar.dart';

// class LandlordInfoScreen extends StatelessWidget {
//   final String tenantUserId;
//   const LandlordInfoScreen({super.key, required this.tenantUserId});

//   Future<Map<String, dynamic>?> _fetchLandlordInfo() async {
//     // Step 1: tenants collection থেকে landlordId বের করো
//     final tenantSnap = await FirebaseFirestore.instance
//         .collection('tenants')
//         .where('uid', isEqualTo: tenantUserId)
//         .where('isActive', isEqualTo: true)
//         .limit(1)
//         .get();

//     if (tenantSnap.docs.isEmpty) return null;

//     final landlordId = tenantSnap.docs.first['landlordId'] as String?;
//     if (landlordId == null) return null;

//     // Step 2: users collection থেকে landlord info আনো
//     final landlordSnap = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(landlordId)
//         .get();

//     if (!landlordSnap.exists) return null;
//     return landlordSnap.data();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       body: FutureBuilder<Map<String, dynamic>?>(
//         future: _fetchLandlordInfo(),
//         builder: (context, snap) {
//           // Loading
//           if (snap.connectionState == ConnectionState.waiting) {
//             return Scaffold(
//               appBar: AppBar(
//                 title: const Text('বাড়িওয়ালার তথ্য'),
//                 backgroundColor: color.primary,
//                 foregroundColor: Colors.white,
//               ),
//               body: Center(child: CircularProgressIndicator(color: color.primary)),
//             );
//           }

//           // Error / No data
//           if (!snap.hasData || snap.data == null) {
//             return Scaffold(
//               appBar: AppBar(
//                 title: const Text('বাড়িওয়ালার তথ্য'),
//                 backgroundColor: color.primary,
//                 foregroundColor: Colors.white,
//               ),
//               body: Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.home_work_outlined,
//                         size: 64, color: color.primary.withOpacity(0.4)),
//                     const SizedBox(height: 16),
//                     const Text('বাড়িওয়ালার তথ্য পাওয়া যায়নি',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                     const SizedBox(height: 8),
//                     Text('আপনি এখনো কোনো বাড়িতে assign হননি',
//                         style: TextStyle(fontSize: 13, color: color.onSurface.withOpacity(0.5))),
//                   ],
//                 ),
//               ),
//             );
//           }

//           final data     = snap.data!;
//           final name     = data['name']     as String? ?? 'অজানা';
//           final email    = data['email']    as String? ?? 'নেই';
//           final phone    = data['phone']    as String? ?? 'নেই';
//           final photoUrl = data['photoUrl'] as String?;
//           final uid      = data['uid']      as String? ?? '';

//           return CustomScrollView(
//             slivers: [
//               // ── App Bar with gradient header ──────────────────────────────
//               SliverAppBar(
//                 expandedHeight: 240,
//                 pinned: true,
//                 backgroundColor: color.primary,
//                 iconTheme: const IconThemeData(color: Colors.white),
//                 title: const Text(
//                   'বাড়িওয়ালার তথ্য',
//                   style: TextStyle(color: Colors.white, fontSize: 16,
//                       fontWeight: FontWeight.w600),
//                 ),
//                 flexibleSpace: FlexibleSpaceBar(
//                   background: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: isDark
//                             ? [const Color(0xFF1A3328), const Color(0xFF0F2018)]
//                             : [color.primary, color.primary.withOpacity(0.75)],
//                       ),
//                     ),
//                     child: SafeArea(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const SizedBox(height: 32),
//                           // Profile Photo
//                           Container(
//                             padding: const EdgeInsets.all(3),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(color: Colors.white, width: 2.5),
//                             ),
//                             child: ProfileAvatar(
//                               name: name,
//                               photoUrl: photoUrl,
//                               userId: uid,
//                               radius: 44,
//                               editable: false,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             name,
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 14, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.white24,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: const Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.home_work_rounded,
//                                     size: 13, color: Colors.white),
//                                 SizedBox(width: 5),
//                                 Text('বাড়িওয়ালা',
//                                     style: TextStyle(
//                                         fontSize: 12, color: Colors.white,
//                                         fontWeight: FontWeight.w500)),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               // ── Info Cards ────────────────────────────────────────────────
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'যোগাযোগের তথ্য',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: color.primary,
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       _InfoTile(
//                         icon: Icons.person_outline_rounded,
//                         label: 'নাম',
//                         value: name,
//                         color: color,
//                       ),
//                       const SizedBox(height: 10),
//                       _InfoTile(
//                         icon: Icons.phone_outlined,
//                         label: 'Phone',
//                         value: phone,
//                         color: color,
//                       ),
//                       const SizedBox(height: 10),
//                       _InfoTile(
//                         icon: Icons.email_outlined,
//                         label: 'Email',
//                         value: email,
//                         color: color,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// // ── Info Tile ─────────────────────────────────────────────────────────────────

// class _InfoTile extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final ColorScheme color;

//   const _InfoTile({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: color.outlineVariant.withOpacity(0.5)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: color.primary.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color.primary, size: 20),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                       fontSize: 11, color: color.onSurface.withOpacity(0.5)),
//                 ),
//                 const SizedBox(height: 2),
//                 SelectableText(
//                   value,
//                   style: const TextStyle(
//                       fontSize: 15, fontWeight: FontWeight.w600),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }