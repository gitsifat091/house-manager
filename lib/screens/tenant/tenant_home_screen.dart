// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../models/tenant_model.dart';
// import '../../../models/room_model.dart';
// import '../../../models/user_model.dart';
// import 'tenant_edit_profile_screen.dart';
// import '../shared/notification_screen.dart';
// import 'package:provider/provider.dart';
// import '../../../services/auth_service.dart';
// import '../../../widgets/profile_avatar.dart';


// class TenantHomeScreen extends StatelessWidget {
//   final UserModel user;
//   // const TenantHomeScreen({super.key, required this.user});
//   final GlobalKey<ScaffoldState>? scaffoldKey;
//   const TenantHomeScreen({super.key, required this.user, this.scaffoldKey});

//   Future<Map<String, dynamic>> _loadData() async {
//     final db = FirebaseFirestore.instance;

//     // Get tenant info by matching email
//     final tenantSnap = await db
//         .collection('tenants')
//         .where('email', isEqualTo: user.email)
//         .where('isActive', isEqualTo: true)
//         .get();

//     if (tenantSnap.docs.isEmpty) {
//       return {'tenant': null, 'room': null};
//     }

//     final tenant = TenantModel.fromMap(tenantSnap.docs.first.data(), tenantSnap.docs.first.id);

//     // Get room info
//     final roomSnap = await db.collection('rooms').doc(tenant.roomId).get();
//     RoomModel? room;
//     if (roomSnap.exists) {
//       room = RoomModel.fromMap(roomSnap.data()!, roomSnap.id);
//     }

//     return {'tenant': tenant, 'room': room};
//   }

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;

//     return Scaffold(
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _loadData(),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final tenant = snap.data?['tenant'] as TenantModel?;
//           final room = snap.data?['room'] as RoomModel?;

//           if (tenant == null) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.info_outline, size: 64, color: color.primary.withOpacity(0.4)),
//                   const SizedBox(height: 16),
//                   const Text('আপনার তথ্য পাওয়া যায়নি', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   const Text('বাড়ীওয়ালার সাথে যোগাযোগ করুন', style: TextStyle(color: Colors.grey)),
//                 ],
//               ),
//             );
//           }

//           return CustomScrollView(
//             slivers: [
//               // Header
//               SliverAppBar(
//                 leading: IconButton(
//                   icon: const Icon(Icons.menu_rounded),
//                   onPressed: () => scaffoldKey?.currentState?.openDrawer(),
//                 ),
//                 expandedHeight: 180,
//                 pinned: true,
//                 actions: [
//                   NotificationBell(userId: user.uid),
//                   IconButton(
//                     icon: const Icon(Icons.edit_rounded, color: Colors.white),
//                     onPressed: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => TenantEditProfileScreen(user: user),
//                       ),
//                     ),
//                   ),
//                 ],
//                 flexibleSpace: FlexibleSpaceBar(
//                   background: Container(
//                     decoration: BoxDecoration(
//                       color: color.primary,
//                     ),
//                     child: SafeArea(
//                       child: Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Consumer<AuthService>(
//                               builder: (context, auth, _) => ProfileAvatar(
//                                 name: tenant.name,
//                                 photoUrl: auth.currentUser?.photoUrl,
//                                 userId: auth.currentUser?.uid ?? '',
//                                 radius: 28,
//                                 editable: false,
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Text('স্বাগতম, ${tenant.name}!',
//                                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
//                             Text(tenant.phone,
//                                 style: const TextStyle(fontSize: 13, color: Colors.white70)),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               SliverPadding(
//                 padding: const EdgeInsets.all(16),
//                 sliver: SliverList(
//                   delegate: SliverChildListDelegate([
//                     // Room info card
//                     _SectionTitle(title: 'আমার রুম'),
//                     const SizedBox(height: 10),
//                     _RoomInfoCard(tenant: tenant, room: room),
//                     const SizedBox(height: 20),

//                     // Rent info
//                     _SectionTitle(title: 'ভাড়ার তথ্য'),
//                     const SizedBox(height: 10),
//                     _RentInfoCard(tenant: tenant),
//                     const SizedBox(height: 20),

//                     // Quick info
//                     _SectionTitle(title: 'বিস্তারিত'),
//                     const SizedBox(height: 10),
//                     _InfoRow(icon: Icons.badge_outlined, label: 'NID', value: tenant.nidNumber),
//                     _InfoRow(icon: Icons.calendar_today_outlined, label: 'প্রবেশের তারিখ',
//                         value: '${tenant.moveInDate.day}/${tenant.moveInDate.month}/${tenant.moveInDate.year}'),
//                     _InfoRow(icon: Icons.home_work_outlined, label: 'Property', value: tenant.propertyName),
//                     _InfoRow(icon: Icons.email_outlined, label: 'Email', value: tenant.email.isEmpty ? 'নেই' : tenant.email),
//                     const SizedBox(height: 20),
//                   ]),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class _SectionTitle extends StatelessWidget {
//   final String title;
//   const _SectionTitle({required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Text(title, style: TextStyle(
//       fontSize: 15, fontWeight: FontWeight.bold,
//       color: Theme.of(context).colorScheme.primary,
//     ));
//   }
// }

// class _RoomInfoCard extends StatelessWidget {
//   final TenantModel tenant;
//   final RoomModel? room;
//   const _RoomInfoCard({required this.tenant, this.room});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.primaryContainer,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 56, height: 56,
//             decoration: BoxDecoration(
//               color: color.primary,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: const Icon(Icons.door_front_door_rounded, color: Colors.white, size: 28),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('রুম ${tenant.roomNumber}',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color.primary)),
//                 Text(room?.type ?? '', style: TextStyle(color: color.primary.withOpacity(0.7))),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade100,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text('ভাড়া চলছে', style: TextStyle(
//                       fontSize: 12, color: Colors.green.shade800, fontWeight: FontWeight.w500)),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _RentInfoCard extends StatelessWidget {
//   final TenantModel tenant;
//   const _RentInfoCard({required this.tenant});

//   @override
//   Widget build(BuildContext context) {
//     // Check this month's payment
//     final now = DateTime.now();
//     return FutureBuilder<bool>(
//       future: _checkPayment(tenant.id, now.month, now.year),
//       builder: (context, snap) {
//         final isPaid = snap.data ?? false;
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: isPaid ? Colors.green.shade200 : Colors.orange.shade200,
//             ),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
//                 color: isPaid ? Colors.green : Colors.orange,
//                 size: 36,
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       isPaid ? 'এই মাসের ভাড়া পরিশোধ হয়েছে' : 'এই মাসের ভাড়া বাকি আছে',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: isPaid ? Colors.green.shade800 : Colors.orange.shade800,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'মাসিক ভাড়া: ৳${tenant.rentAmount.toStringAsFixed(0)}',
//                       style: TextStyle(
//                         color: isPaid ? Colors.green.shade700 : Colors.orange.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<bool> _checkPayment(String tenantId, int month, int year) async {
//     final snap = await FirebaseFirestore.instance
//         .collection('payments')
//         .where('tenantId', isEqualTo: tenantId)
//         .where('month', isEqualTo: month)
//         .where('year', isEqualTo: year)
//         .where('status', isEqualTo: 'paid')
//         .get();
//     return snap.docs.isNotEmpty;
//   }
// }

// // class _InfoRow extends StatelessWidget {
// //   final IconData icon;
// //   final String label;
// //   final String value;
// //   const _InfoRow({required this.icon, required this.label, required this.value});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 12),
// //       child: Row(
// //         children: [
// //           Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
// //           const SizedBox(width: 12),
// //           Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
// //           Expanded(child: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)))),
// //         ],
// //       ),
// //     );
// //   }
// // }

// class _InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   const _InfoRow({required this.icon, required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: color.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: color.outlineVariant.withOpacity(0.4)),
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
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.primary.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, size: 18, color: color.primary),
//           ),
//           const SizedBox(width: 12),
//           Text('$label',
//               style: TextStyle(
//                   fontSize: 12,
//                   color: color.onSurface.withOpacity(0.5))),
//           const Spacer(),
//           Text(value,
//               style: const TextStyle(
//                   fontSize: 14, fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/tenant_model.dart';
import '../../../models/room_model.dart';
import '../../../models/user_model.dart';
import 'tenant_edit_profile_screen.dart';
import '../shared/notification_screen.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/profile_avatar.dart';

class TenantHomeScreen extends StatelessWidget {
  final UserModel user;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const TenantHomeScreen({super.key, required this.user, this.scaffoldKey});

  Future<Map<String, dynamic>> _loadData() async {
    final db = FirebaseFirestore.instance;
    final tenantSnap = await db
        .collection('tenants')
        .where('email', isEqualTo: user.email)
        .where('isActive', isEqualTo: true)
        .get();

    if (tenantSnap.docs.isEmpty) return {'tenant': null, 'room': null};

    final tenant =
        TenantModel.fromMap(tenantSnap.docs.first.data(), tenantSnap.docs.first.id);
    final roomSnap = await db.collection('rooms').doc(tenant.roomId).get();
    RoomModel? room;
    if (roomSnap.exists) room = RoomModel.fromMap(roomSnap.data()!, roomSnap.id);

    return {'tenant': tenant, 'room': room};
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadData(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primary));
          }

          final tenant = snap.data?['tenant'] as TenantModel?;
          final room = snap.data?['room'] as RoomModel?;

          if (tenant == null) {
            return _buildNotFound(context, primary, textSecondary);
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Collapsing AppBar ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                collapsedHeight: 60,
                pinned: true,
                backgroundColor: bg,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.menu_rounded, color: isDark ? Colors.white : textPrimary),
                  onPressed: () => scaffoldKey?.currentState?.openDrawer(),
                ),
                title: Text(
                  'হোম',
                  style: TextStyle(
                      color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                centerTitle: true,
                actions: [
                  NotificationBell(userId: user.uid),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: textPrimary, size: 20),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TenantEditProfileScreen(user: user)),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeader(
                    context: context,
                    tenant: tenant,
                    primary: primary,
                    isDark: isDark,
                    textPrimary: textPrimary,
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── রুমের তথ্য ──
                    _sectionHeader('🚪  আমার রুম', textSecondary),
                    _RoomCard(tenant: tenant, room: room, primary: primary, isDark: isDark),
                    const SizedBox(height: 16),

                    // ── ভাড়ার তথ্য ──
                    _sectionHeader('💳  ভাড়ার তথ্য', textSecondary),
                    _RentStatusCard(tenant: tenant, primary: primary, isDark: isDark),
                    const SizedBox(height: 16),

                    // ── বিস্তারিত ──
                    _sectionHeader('📋  বিস্তারিত', textSecondary),
                    _DetailsCard(
                      tenant: tenant,
                      primary: primary,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Header background ──────────────────────────────────────────────────────
  Widget _buildHeader({
    required BuildContext context,
    required TenantModel tenant,
    required Color primary,
    required bool isDark,
    required Color textPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A3328), const Color(0xFF0F1A14)]
              : [const Color(0xFFE8F5EE), const Color(0xFFF5FAF7)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
          child: Row(
            children: [
              Consumer<AuthService>(
                builder: (context, auth, _) => ProfileAvatar(
                  name: tenant.name,
                  photoUrl: auth.currentUser?.photoUrl,
                  userId: auth.currentUser?.uid ?? '',
                  radius: 30,
                  editable: false,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'স্বাগতম, ${tenant.name.split(' ')[0]}!',
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tenant.phone,
                      style: TextStyle(color: textPrimary.withOpacity(0.6), fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: primary.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        'ভাড়াটিয়া',
                        style: TextStyle(
                            color: primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound(
      BuildContext context, Color primary, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
                color: primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.info_outline_rounded,
                size: 46, color: primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          const Text('আপনার তথ্য পাওয়া যায়নি',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('বাড়ীওয়ালার সাথে যোগাযোগ করুন',
              style: TextStyle(fontSize: 14, color: textSecondary)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
        child: Text(title,
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
      );
}

// ── Room Card ─────────────────────────────────────────────────────────────────

class _RoomCard extends StatelessWidget {
  final TenantModel tenant;
  final RoomModel? room;
  final Color primary;
  final bool isDark;
  const _RoomCard(
      {required this.tenant,
      required this.room,
      required this.primary,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: primary.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Icon(Icons.door_front_door_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'রুম ${tenant.roomNumber}',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    room?.type ?? '',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _badge(
                          label: 'ভাড়া চলছে',
                          color: const Color(0xFF059669),
                          icon: Icons.check_circle_rounded),
                      const SizedBox(width: 8),
                      _badge(
                          label: '৳${tenant.rentAmount.toStringAsFixed(0)}/মাস',
                          color: primary,
                          icon: Icons.payments_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Rent Status Card ──────────────────────────────────────────────────────────

class _RentStatusCard extends StatelessWidget {
  final TenantModel tenant;
  final Color primary;
  final bool isDark;
  const _RentStatusCard(
      {required this.tenant, required this.primary, required this.isDark});

  Future<bool> _checkPayment(String tenantId, int month, int year) async {
    final snap = await FirebaseFirestore.instance
        .collection('payments')
        .where('tenantId', isEqualTo: tenantId)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .where('status', isEqualTo: 'paid')
        .get();
    return snap.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;

    return FutureBuilder<bool>(
      future: _checkPayment(tenant.id, now.month, now.year),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(
            height: 80,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: CircularProgressIndicator(color: primary)),
          );
        }

        final isPaid = snap.data ?? false;
        final statusColor = isPaid ? const Color(0xFF059669) : const Color(0xFFD97706);
        final statusBg = isDark
            ? statusColor.withOpacity(0.15)
            : statusColor.withOpacity(0.07);

        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Icon(
                    isPaid
                        ? Icons.check_circle_rounded
                        : Icons.pending_rounded,
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPaid
                            ? 'এই মাসের ভাড়া পরিশোধ হয়েছে'
                            : 'এই মাসের ভাড়া বাকি আছে',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: statusColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'মাসিক ভাড়া: ৳${tenant.rentAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 13,
                            color: statusColor.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: statusColor.withOpacity(0.5),
                          blurRadius: 6)
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Details Card ──────────────────────────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  final TenantModel tenant;
  final Color primary;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  const _DetailsCard({
    required this.tenant,
    required this.primary,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final divColor = isDark ? Colors.white10 : const Color(0xFFE5E7EB);

    final items = [
      _DetailItem(Icons.badge_outlined, 'NID', tenant.nidNumber,
          const Color(0xFF5B4FBF)),
      _DetailItem(
          Icons.calendar_today_outlined,
          'প্রবেশের তারিখ',
          '${tenant.moveInDate.day}/${tenant.moveInDate.month}/${tenant.moveInDate.year}',
          const Color(0xFF0891B2)),
      _DetailItem(Icons.home_work_outlined, 'Property', tenant.propertyName,
          primary),
      _DetailItem(
          Icons.email_outlined,
          'Email',
          tenant.email.isEmpty ? 'নেই' : tenant.email,
          const Color(0xFFD97706)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.label,
                              style: TextStyle(
                                  fontSize: 11, color: textSecondary)),
                          const SizedBox(height: 2),
                          Text(item.value,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 70),
                  child: Divider(height: 1, color: divColor),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DetailItem(this.icon, this.label, this.value, this.color);
}