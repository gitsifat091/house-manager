// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/auth_service.dart';
// import '../../services/tenant_service.dart';
// import '../../services/property_service.dart';
// import '../../models/tenant_model.dart';
// import 'add_edit_tenant_screen.dart';
// import 'landlord_edit_tenant_screen.dart';
// import '../shared/notification_screen.dart';
// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../widgets/tenant_avatar.dart';
// import 'tenant_detail_screen.dart';


// enum TenantSortOrder { newest, roomNumber }

// class TenantListScreen extends StatefulWidget {
//   final GlobalKey<ScaffoldState>? scaffoldKey;
//   const TenantListScreen({super.key, this.scaffoldKey});

//   @override
//   State<TenantListScreen> createState() => _TenantListScreenState();
// }

// class _TenantListScreenState extends State<TenantListScreen> {
//   TenantSortOrder _sortOrder = TenantSortOrder.newest;

//   List<TenantModel> _sortTenants(List<TenantModel> tenants) {
//     final list = [...tenants];
//     if (_sortOrder == TenantSortOrder.newest) {
//       // নতুন আগে
//       list.sort((a, b) => b.moveInDate.compareTo(a.moveInDate));
//     } else {
//       // রুম নম্বর অনুযায়ী natural sort
//       list.sort((a, b) => _naturalCompare(a.roomNumber, b.roomNumber));
//     }
//     return list;
//   }

//   // Natural sort — A-1 < A-2 < A-10 < B-1
//   int _naturalCompare(String a, String b) {
//     final regExp = RegExp(r'(\D*)(\d*)');
//     final aMatches = regExp.allMatches(a).toList();
//     final bMatches = regExp.allMatches(b).toList();

//     for (int i = 0; i < aMatches.length && i < bMatches.length; i++) {
//       final aText = aMatches[i].group(1) ?? '';
//       final bText = bMatches[i].group(1) ?? '';
//       final aNum = int.tryParse(aMatches[i].group(2) ?? '') ?? -1;
//       final bNum = int.tryParse(bMatches[i].group(2) ?? '') ?? -1;

//       final textCmp = aText.compareTo(bText);
//       if (textCmp != 0) return textCmp;
//       if (aNum != bNum) return aNum.compareTo(bNum);
//     }
//     return a.compareTo(b);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = context.read<AuthService>().currentUser!;
//     final tenantService = TenantService();
//     final color = Theme.of(context).colorScheme;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.menu_rounded),
//           onPressed: () => widget.scaffoldKey?.currentState?.openDrawer(),
//         ),
//         title: const Text('ভাড়াটিয়া তালিকা'),
//         centerTitle: true,
//         actions: [
//           // Sort button
//           PopupMenuButton<TenantSortOrder>(
//             icon: const Icon(Icons.sort_rounded),
//             tooltip: 'সাজানোর ধরন',
//             onSelected: (val) => setState(() => _sortOrder = val),
//             itemBuilder: (_) => [
//               PopupMenuItem(
//                 value: TenantSortOrder.newest,
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.access_time_rounded,
//                       size: 18,
//                       color: _sortOrder == TenantSortOrder.newest
//                           ? color.primary
//                           : null,
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       'সর্বশেষ আগমন অনুযায়ী',
//                       style: TextStyle(
//                         color: _sortOrder == TenantSortOrder.newest
//                             ? color.primary
//                             : null,
//                         fontWeight: _sortOrder == TenantSortOrder.newest
//                             ? FontWeight.bold
//                             : FontWeight.normal,
//                       ),
//                     ),
//                     if (_sortOrder == TenantSortOrder.newest) ...[
//                       const Spacer(),
//                       Icon(Icons.check_rounded, size: 16, color: color.primary),
//                     ],
//                   ],
//                 ),
//               ),
//               PopupMenuItem(
//                 value: TenantSortOrder.roomNumber,
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.door_front_door_outlined,
//                       size: 18,
//                       color: _sortOrder == TenantSortOrder.roomNumber
//                           ? color.primary
//                           : null,
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       'রুম নম্বর অনুযায়ী',
//                       style: TextStyle(
//                         color: _sortOrder == TenantSortOrder.roomNumber
//                             ? color.primary
//                             : null,
//                         fontWeight: _sortOrder == TenantSortOrder.roomNumber
//                             ? FontWeight.bold
//                             : FontWeight.normal,
//                       ),
//                     ),
//                     if (_sortOrder == TenantSortOrder.roomNumber) ...[
//                       const Spacer(),
//                       Icon(Icons.check_rounded, size: 16, color: color.primary),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           NotificationBell(userId: user.uid),
//         ],
//       ),
//       body: StreamBuilder<List<TenantModel>>(
//         stream: tenantService.getTenants(user.uid),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final raw = (snap.data ?? [])
//               .where((t) => t.isActive)
//               .toList();

//           final tenants = _sortTenants(raw);

//           if (tenants.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.people_outline, size: 80,
//                       color: color.primary.withOpacity(0.3)),
//                   const SizedBox(height: 16),
//                   const Text('কোনো ভাড়াটিয়া নেই',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   const Text('নিচের বাটন দিয়ে ভাড়াটিয়া যোগ করুন'),
//                 ],
//               ),
//             );
//           }

//           return Column(
//             children: [
//               // Active sort indicator
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 color: color.primaryContainer.withOpacity(0.4),
//                 child: Row(
//                   children: [
//                     Icon(
//                       _sortOrder == TenantSortOrder.newest
//                           ? Icons.access_time_rounded
//                           : Icons.door_front_door_outlined,
//                       size: 14,
//                       color: color.primary,
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       _sortOrder == TenantSortOrder.newest
//                           ? 'সর্বশেষ আগমন অনুযায়ী সাজানো'
//                           : 'রুম নম্বর অনুযায়ী সাজানো',
//                       style: TextStyle(
//                           fontSize: 12,
//                           color: color.primary,
//                           fontWeight: FontWeight.w500),
//                     ),
//                     const Spacer(),
//                     Text('${tenants.length} জন',
//                         style: TextStyle(fontSize: 12, color: color.primary)),
//                   ],
//                 ),
//               ),

//               Expanded(
//                 child: ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: tenants.length,
//                   itemBuilder: (ctx, i) => _TenantCard(
//                     tenant: tenants[i],
//                     service: tenantService,
//                     onEdit: () => Navigator.push(context, MaterialPageRoute(
//                       builder: (_) => LandlordEditTenantScreen(tenant: tenants[i]),
//                     )),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => Navigator.push(context, MaterialPageRoute(
//           builder: (_) => AddEditTenantScreen(landlordId: user.uid),
//         )),
//         icon: const Icon(Icons.person_add_rounded),
//         label: const Text('ভাড়াটিয়া যোগ করুন'),
//       ),
//     );
//   }
// }


// class _TenantCard extends StatelessWidget {
//   final TenantModel tenant;
//   final TenantService service;
//   final VoidCallback onEdit;
//   const _TenantCard({
//     required this.tenant, 
//     required this.service,
//     required this.onEdit,
//   });

//   Future<String?> _getTenantPhoto(String email) async {
//     try {
//       final snap = await FirebaseFirestore.instance
//           .collection('users')
//           .where('email', isEqualTo: email)
//           .get();
//       if (snap.docs.isEmpty) return null;
//       return snap.docs.first.data()['photoUrl'] as String?;
//     } catch (_) {
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: color.surface,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: color.primary.withOpacity(0.07),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(18),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(18),
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => TenantDetailScreen(tenant: tenant),
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             child: Row(
//               children: [
//                 // Avatar with green ring
//                 Container(
//                   padding: const EdgeInsets.all(2),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: color.primary.withOpacity(0.4), width: 2),
//                   ),
//                   child: TenantAvatar(
//                     tenantName: tenant.name,
//                     tenantEmail: tenant.email,
//                     radius: 26,
//                   ),
//                 ),
//                 const SizedBox(width: 14),

//                 // Info
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               tenant.name,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           // Rent badge
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                             decoration: BoxDecoration(
//                               color: color.primary.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Text(
//                               '৳${tenant.rentAmount.toStringAsFixed(0)}',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: color.primary,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 3),
//                       Text(
//                         tenant.phone,
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: color.onSurface.withOpacity(0.55),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           _chip(context, Icons.home_outlined, tenant.propertyName),
//                           const SizedBox(width: 6),
//                           _chip(context, Icons.door_front_door_outlined, 'রুম ${tenant.roomNumber}'),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Menu
//                 PopupMenuButton(
//                   icon: Icon(Icons.more_vert_rounded,
//                       color: color.onSurface.withOpacity(0.45)),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                   itemBuilder: (_) => [
//                     const PopupMenuItem(value: 'edit', child: Text('তথ্য সম্পাদনা')),
//                     const PopupMenuItem(
//                       value: 'remove',
//                       child: Text('রুম খালি করুন',
//                           style: TextStyle(color: Colors.orange)),
//                     ),
//                     const PopupMenuItem(
//                       value: 'delete',
//                       child: Text('Delete',
//                           style: TextStyle(color: Colors.red)),
//                     ),
//                   ],
//                   onSelected: (val) async {
//                     if (val == 'edit') onEdit();
//                     if (val == 'remove') {
//                       final confirm = await _confirm(context,
//                           'রুম খালি করবেন?', '${tenant.name} কে রুম থেকে সরানো হবে।');
//                       if (confirm) await service.removeTenant(tenant);
//                     }
//                     if (val == 'delete') {
//                       final confirm = await _confirm(context,
//                           'Delete করবেন?', '${tenant.name} এর সব তথ্য মুছে যাবে।');
//                       if (confirm) await service.deleteTenant(tenant);
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }



//   Widget _chip(BuildContext context, IconData icon, String label) {
//     final color = Theme.of(context).colorScheme;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.primaryContainer.withOpacity(0.6),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: color.primary),
//           const SizedBox(width: 4),
//           Text(label,
//               style: TextStyle(
//                   fontSize: 11,
//                   color: color.primary,
//                   fontWeight: FontWeight.w500)),
//         ],
//       ),
//     );
//   }

//   Future<bool> _confirm(BuildContext context, String title, String content) async {
//     return await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(title),
//         content: Text(content),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('না')),
//           FilledButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('হ্যাঁ'),
//           ),
//         ],
//       ),
//     ) ?? false;
//   }
// }






import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/tenant_service.dart';
import '../../models/tenant_model.dart';
import 'add_edit_tenant_screen.dart';
import 'landlord_edit_tenant_screen.dart';
import '../shared/notification_screen.dart';
import '../../../widgets/tenant_avatar.dart';
import 'tenant_detail_screen.dart';

enum TenantSortOrder { newest, roomNumber }

class TenantListScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const TenantListScreen({super.key, this.scaffoldKey});

  @override
  State<TenantListScreen> createState() => _TenantListScreenState();
}

class _TenantListScreenState extends State<TenantListScreen>
    with SingleTickerProviderStateMixin {
  TenantSortOrder _sortOrder = TenantSortOrder.newest;

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

  List<TenantModel> _sortTenants(List<TenantModel> tenants) {
    final list = [...tenants];
    if (_sortOrder == TenantSortOrder.newest) {
      list.sort((a, b) => b.moveInDate.compareTo(a.moveInDate));
    } else {
      list.sort(
          (a, b) => _naturalCompare(a.roomNumber, b.roomNumber));
    }
    return list;
  }

  int _naturalCompare(String a, String b) {
    final regExp = RegExp(r'(\D*)(\d*)');
    final aMatches = regExp.allMatches(a).toList();
    final bMatches = regExp.allMatches(b).toList();
    for (int i = 0;
        i < aMatches.length && i < bMatches.length;
        i++) {
      final aText = aMatches[i].group(1) ?? '';
      final bText = bMatches[i].group(1) ?? '';
      final aNum =
          int.tryParse(aMatches[i].group(2) ?? '') ?? -1;
      final bNum =
          int.tryParse(bMatches[i].group(2) ?? '') ?? -1;
      final textCmp = aText.compareTo(bText);
      if (textCmp != 0) return textCmp;
      if (aNum != bNum) return aNum.compareTo(bNum);
    }
    return a.compareTo(b);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark
        ? const Color(0xFF0F1A14)
        : const Color(0xFFF5FAF7);
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary =
        isDark ? Colors.white54 : const Color(0xFF6B7280);

    final user = context.read<AuthService>().currentUser!;
    final tenantService = TenantService();

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: StreamBuilder<List<TenantModel>>(
          stream: tenantService.getTenants(user.uid),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: bg,
                body: Center(
                  child: CircularProgressIndicator(color: primary),
                ),
              );
            }

            final raw = (snap.data ?? [])
                .where((t) => t.isActive)
                .toList();
            final tenants = _sortTenants(raw);

            // Stats
            final totalRent = tenants.fold<double>(
                0, (sum, t) => sum + t.rentAmount);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── App Bar ────────────────────────────────
                SliverAppBar(
                  expandedHeight: 185,
                  collapsedHeight: 60,
                  pinned: true,
                  backgroundColor: bg,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.menu_rounded,
                        color: textPrimary),
                    onPressed: () => widget.scaffoldKey
                        ?.currentState
                        ?.openDrawer(),
                  ),
                  title: Text(
                    'ভাড়াটিয়া তালিকা',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    PopupMenuButton<TenantSortOrder>(
                      icon: Icon(Icons.sort_rounded,
                          color: textPrimary),
                      tooltip: 'সাজানোর ধরন',
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      onSelected: (val) =>
                          setState(() => _sortOrder = val),
                      itemBuilder: (_) => [
                        _sortMenuItem(
                          value: TenantSortOrder.newest,
                          icon: Icons.access_time_rounded,
                          label: 'সর্বশেষ আগমন',
                          primary: primary,
                        ),
                        _sortMenuItem(
                          value: TenantSortOrder.roomNumber,
                          icon: Icons.door_front_door_outlined,
                          label: 'রুম নম্বর',
                          primary: primary,
                        ),
                      ],
                    ),
                    NotificationBell(userId: user.uid),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildStatsHeader(
                      primary: primary,
                      isDark: isDark,
                      tenants: tenants,
                      totalRent: totalRent,
                      textPrimary: textPrimary,
                    ),
                  ),
                ),

                if (tenants.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(primary, textSecondary),
                  )
                else ...[
                  // ── Sort indicator ──────────────────────
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(
                          16, 8, 16, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _sortOrder ==
                                    TenantSortOrder.newest
                                ? Icons.access_time_rounded
                                : Icons
                                    .door_front_door_outlined,
                            size: 14,
                            color: primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _sortOrder ==
                                    TenantSortOrder.newest
                                ? 'সর্বশেষ আগমন অনুযায়ী সাজানো'
                                : 'রুম নম্বর অনুযায়ী সাজানো',
                            style: TextStyle(
                                fontSize: 12,
                                color: primary,
                                fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.15),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${tenants.length} জন',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: primary,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Tenant list ─────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 12, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _TenantCard(
                          tenant: tenants[i],
                          service: tenantService,
                          isDark: isDark,
                          onEdit: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LandlordEditTenantScreen(
                                      tenant: tenants[i]),
                            ),
                          ),
                        ),
                        childCount: tenants.length,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      floatingActionButton: Builder(builder: (ctx) {
        final user = ctx.read<AuthService>().currentUser!;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(ctx)
                    .colorScheme
                    .primary
                    .withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) =>
                    AddEditTenantScreen(landlordId: user.uid),
              ),
            ),
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('ভাড়াটিয়া যোগ করুন',
                style: TextStyle(fontWeight: FontWeight.w700)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
        );
      }),
    );
  }

  // ── Stats Header ──────────────────────────────────────────
  Widget _buildStatsHeader({
    required Color primary,
    required bool isDark,
    required List<TenantModel> tenants,
    required double totalRent,
    required Color textPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A3328),
                  const Color(0xFF0F1A14)
                ]
              : [
                  const Color(0xFFE8F5EE),
                  const Color(0xFFF5FAF7)
                ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(16, 65, 16, 12),
          child: Row(
            children: [
              _statPill(
                icon: Icons.people_rounded,
                label: 'ভাড়াটিয়া',
                value: '${tenants.length} জন',
                color: primary,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _statPill(
                icon: Icons.payments_rounded,
                label: 'মাসিক ভাড়া',
                value:
                    '৳${totalRent.toStringAsFixed(0)}',
                color: const Color(0xFF0891B2),
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _statPill(
                icon: Icons.home_rounded,
                label: 'Properties',
                value: tenants
                    .map((t) => t.propertyName)
                    .toSet()
                    .length
                    .toString(),
                color: const Color(0xFFD97706),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Widget _statPill({
  //   required IconData icon,
  //   required String label,
  //   required String value,
  //   required Color color,
  //   required bool isDark,
  // }) {
  //   return Expanded(
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(
  //           horizontal: 8, vertical: 8),
  //       decoration: BoxDecoration(
  //         color: color.withOpacity(isDark ? 0.15 : 0.1),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(
  //             color: color.withOpacity(0.25), width: 1),
  //       ),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Icon(icon, color: color, size: 18),
  //           const SizedBox(width: 6),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(value,
  //                     style: TextStyle(
  //                         color: color,
  //                         fontSize: 12,
  //                         fontWeight: FontWeight.bold),
  //                     overflow: TextOverflow.ellipsis),
  //                 Text(label,
  //                     style: TextStyle(
  //                         color: color.withOpacity(0.8),
  //                         fontSize: 9),
  //                     overflow: TextOverflow.ellipsis),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // ── Empty State ────────────────────────────────────────────
  Widget _buildEmptyState(Color primary, Color textSecondary) {
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
            child: Icon(Icons.people_outline_rounded,
                size: 46, color: primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          const Text('কোনো ভাড়াটিয়া নেই',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('নিচের বাটন দিয়ে ভাড়াটিয়া যোগ করুন',
              style:
                  TextStyle(fontSize: 14, color: textSecondary)),
        ],
      ),
    );
  }

  PopupMenuItem<TenantSortOrder> _sortMenuItem({
    required TenantSortOrder value,
    required IconData icon,
    required String label,
    required Color primary,
  }) {
    final selected = _sortOrder == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon,
              size: 18, color: selected ? primary : null),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color: selected ? primary : null,
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.normal)),
          if (selected) ...[
            const Spacer(),
            Icon(Icons.check_rounded,
                size: 16, color: primary),
          ],
        ],
      ),
    );
  }
}

// ── Tenant Card ───────────────────────────────────────────────

class _TenantCard extends StatelessWidget {
  final TenantModel tenant;
  final TenantService service;
  final bool isDark;
  final VoidCallback onEdit;

  const _TenantCard({
    required this.tenant,
    required this.service,
    required this.isDark,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary =
        isDark ? Colors.white54 : const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TenantDetailScreen(tenant: tenant),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar with ring
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: primary.withOpacity(0.4),
                            width: 2),
                      ),
                      child: TenantAvatar(
                        tenantName: tenant.name,
                        tenantEmail: tenant.email,
                        radius: 26,
                      ),
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  tenant.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                  overflow:
                                      TextOverflow.ellipsis,
                                ),
                              ),
                              // Rent badge
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4),
                                decoration: BoxDecoration(
                                  color: primary
                                      .withOpacity(0.12),
                                  borderRadius:
                                      BorderRadius.circular(
                                          20),
                                  border: Border.all(
                                      color: primary
                                          .withOpacity(0.25)),
                                ),
                                child: Text(
                                  '৳${tenant.rentAmount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: primary,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.phone_outlined,
                                  size: 12,
                                  color: textSecondary
                                      .withOpacity(0.7)),
                              const SizedBox(width: 4),
                              Text(
                                tenant.phone,
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

                    // Menu
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert_rounded,
                          color: textSecondary.withOpacity(0.6),
                          size: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14)),
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'edit',
                            child: Text('তথ্য সম্পাদনা')),
                        const PopupMenuItem(
                          value: 'remove',
                          child: Text('রুম খালি করুন',
                              style: TextStyle(
                                  color: Colors.orange)),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete',
                              style: TextStyle(
                                  color: Colors.red)),
                        ),
                      ],
                      onSelected: (val) async {
                        if (val == 'edit') onEdit();
                        if (val == 'remove') {
                          final confirm = await _confirm(
                            context,
                            'রুম খালি করবেন?',
                            '${tenant.name} কে রুম থেকে সরানো হবে।',
                          );
                          if (confirm)
                            await service
                                .removeTenant(tenant);
                        }
                        if (val == 'delete') {
                          final confirm = await _confirm(
                            context,
                            'Delete করবেন?',
                            '${tenant.name} এর সব তথ্য মুছে যাবে।',
                          );
                          if (confirm)
                            await service
                                .deleteTenant(tenant);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Bottom info row ────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: primary.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      _infoChip(
                        context,
                        Icons.home_outlined,
                        tenant.propertyName,
                        primary,
                        textSecondary,
                      ),
                      const SizedBox(width: 8),
                      _infoChip(
                        context,
                        Icons.door_front_door_outlined,
                        'রুম ${tenant.roomNumber}',
                        primary,
                        textSecondary,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 11,
                              color:
                                  textSecondary.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            '${tenant.moveInDate.day}/${tenant.moveInDate.month}/${tenant.moveInDate.year}',
                            style: TextStyle(
                                fontSize: 11,
                                color: textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(BuildContext context, IconData icon,
      String label, Color primary, Color textSecondary) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
              fontSize: 11,
              color: primary,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Future<bool> _confirm(
      BuildContext context, String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700)),
            content: Text(content),
            actions: [
              TextButton(
                  onPressed: () =>
                      Navigator.pop(context, false),
                  child: const Text('না')),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(context, true),
                child: const Text('হ্যাঁ'),
              ),
            ],
          ),
        ) ??
        false;
  }
}