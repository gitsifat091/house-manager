// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../services/auth_service.dart';
// import '../../../services/maintenance_service.dart';
// import '../../../models/maintenance_model.dart';
// import '../shared/notification_screen.dart'; 
// import '../../../widgets/tenant_avatar.dart';
// import 'tenant_detail_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../models/tenant_model.dart';

// class MaintenanceRequestsScreen extends StatelessWidget {
//   const MaintenanceRequestsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = context.read<AuthService>().currentUser!;
//     final service = MaintenanceService();

//     return Scaffold(
//       appBar: AppBar(title: const Text('মেরামতের অনুরোধ'), centerTitle: true,
//       actions: [
//         NotificationBell(userId: user.uid),
//       ],
//       ),
//       body: StreamBuilder<List<MaintenanceModel>>(
//         stream: service.getRequests(user.uid),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final requests = snap.data ?? [];
//           if (requests.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.build_outlined, size: 80,
//                       color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
//                   const SizedBox(height: 16),
//                   const Text('কোনো অনুরোধ নেই',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             );
//           }
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: requests.length,
//             itemBuilder: (ctx, i) => _MaintenanceCard(
//               req: requests[i], 
//               service: service,
//               landlordId: user.uid,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _MaintenanceCard extends StatelessWidget {
//   final MaintenanceModel req;
//   final MaintenanceService service;
//   final String landlordId; 

//   const _MaintenanceCard({
//     required this.req, 
//     required this.service,
//     required this.landlordId,
//   });

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
//                 // CircleAvatar(
//                 //   radius: 20,
//                 //   backgroundColor: color.primaryContainer,
//                 //   child: Text(req.tenantName[0].toUpperCase(),
//                 //       style: TextStyle(color: color.primary, fontWeight: FontWeight.bold)),
//                 // ),
//                 GestureDetector(
//                   onTap: () async {
//                     final snap = await FirebaseFirestore.instance
//                         .collection('tenants')
//                         .where('landlordId', isEqualTo: landlordId)
//                         .where('name', isEqualTo: req.tenantName)
//                         .get();
//                     if (snap.docs.isNotEmpty && context.mounted) {
//                       final tenant = TenantModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
//                       Navigator.push(context, MaterialPageRoute(
//                         builder: (_) => TenantDetailScreen(tenant: tenant),
//                       ));
//                     }
//                   },
//                   child: TenantAvatar(
//                     tenantName: req.tenantName,
//                     tenantEmail: '',
//                     radius: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(req.tenantName,
//                           style: const TextStyle(fontWeight: FontWeight.bold)),
//                       Text('${req.propertyName} • রুম ${req.roomNumber}',
//                           style: TextStyle(fontSize: 12, color: color.onSurface.withOpacity(0.6))),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Color(int.parse('FF${req.statusColorHex}', radix: 16)).withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(req.statusLabel,
//                       style: TextStyle(fontSize: 12, color: Color(int.parse('FF${req.statusColorHex}', radix: 16)),
//                           fontWeight: FontWeight.w500)),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(req.title,
//                 style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 4),
//             Text(req.description,
//                 style: TextStyle(color: color.onSurface.withOpacity(0.7))),
//             const SizedBox(height: 12),
//             // Status buttons
//             if (req.status != MaintenanceStatus.done)
//               Row(
//                 children: [
//                   if (req.status == MaintenanceStatus.pending)
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () => service.updateStatus(req.id, MaintenanceStatus.inProgress),
//                         child: const Text('কাজ শুরু করুন'),
//                       ),
//                     ),
//                   if (req.status == MaintenanceStatus.pending) const SizedBox(width: 8),
//                   Expanded(
//                     child: FilledButton(
//                       onPressed: () => service.updateStatus(req.id, MaintenanceStatus.done),
//                       child: const Text('সম্পন্ন'),
//                     ),
//                   ),
//                 ],
//               ),
//             const SizedBox(height: 4),
//             Text(
//               '${req.createdAt.day}/${req.createdAt.month}/${req.createdAt.year}',
//               style: TextStyle(fontSize: 11, color: color.onSurface.withOpacity(0.4)),
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
import '../../../services/maintenance_service.dart';
import '../../../models/maintenance_model.dart';
import '../shared/notification_screen.dart';
import '../../../widgets/tenant_avatar.dart';
import 'tenant_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/tenant_model.dart';

class MaintenanceRequestsScreen extends StatefulWidget {
  const MaintenanceRequestsScreen({super.key});

  @override
  State<MaintenanceRequestsScreen> createState() =>
      _MaintenanceRequestsScreenState();
}

class _MaintenanceRequestsScreenState extends State<MaintenanceRequestsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Filter state
  MaintenanceStatus? _selectedFilter; // null = সব দেখাবে

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
    final service = MaintenanceService();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'মেরামতের অনুরোধ',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          NotificationBell(userId: user.uid),
          const SizedBox(width: 4),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: StreamBuilder<List<MaintenanceModel>>(
          stream: service.getRequests(user.uid),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: primary),
              );
            }

            final allRequests = snap.data ?? [];

            // Apply filter
            final requests = _selectedFilter == null
                ? allRequests
                : allRequests
                    .where((r) => r.status == _selectedFilter)
                    .toList();

            // Count by status
            final pendingCount = allRequests
                .where((r) => r.status == MaintenanceStatus.pending)
                .length;
            final inProgressCount = allRequests
                .where((r) => r.status == MaintenanceStatus.inProgress)
                .length;
            final doneCount = allRequests
                .where((r) => r.status == MaintenanceStatus.done)
                .length;

            return Column(
              children: [
                // ── Summary Cards ──────────────────────────────
                if (allRequests.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        _SummaryChip(
                          label: 'সব',
                          count: allRequests.length,
                          color: primary,
                          isSelected: _selectedFilter == null,
                          onTap: () =>
                              setState(() => _selectedFilter = null),
                        ),
                        const SizedBox(width: 8),
                        _SummaryChip(
                          label: 'অপেক্ষমাণ',
                          count: pendingCount,
                          color: const Color(0xFFD97706),
                          isSelected:
                              _selectedFilter == MaintenanceStatus.pending,
                          onTap: () => setState(() =>
                              _selectedFilter = MaintenanceStatus.pending),
                        ),
                        const SizedBox(width: 8),
                        _SummaryChip(
                          label: 'চলছে',
                          count: inProgressCount,
                          color: const Color(0xFF0891B2),
                          isSelected: _selectedFilter ==
                              MaintenanceStatus.inProgress,
                          onTap: () => setState(() =>
                              _selectedFilter =
                                  MaintenanceStatus.inProgress),
                        ),
                        const SizedBox(width: 8),
                        _SummaryChip(
                          label: 'সম্পন্ন',
                          count: doneCount,
                          color: const Color(0xFF16A34A),
                          isSelected:
                              _selectedFilter == MaintenanceStatus.done,
                          onTap: () => setState(
                              () => _selectedFilter = MaintenanceStatus.done),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // ── List ────────────────────────────────────────
                Expanded(
                  child: requests.isEmpty
                      ? _buildEmptyState(
                          primary, textPrimary, textSecondary, allRequests.isEmpty)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          itemCount: requests.length,
                          itemBuilder: (ctx, i) => _MaintenanceCard(
                            req: requests[i],
                            service: service,
                            landlordId: user.uid,
                            isDark: isDark,
                            primary: primary,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color primary, Color textPrimary,
      Color textSecondary, bool noData) {
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
              Icons.build_outlined,
              size: 44,
              color: primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            noData ? 'কোনো অনুরোধ নেই' : 'এই ফিল্টারে কিছু নেই',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          if (!noData) ...[
            const SizedBox(height: 8),
            Text(
              'অন্য ফিল্টার বেছে নিন',
              style: TextStyle(fontSize: 14, color: textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Summary Filter Chip ───────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(isSelected ? 1 : 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white.withOpacity(0.9)
                      : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Maintenance Card ──────────────────────────────────────────

class _MaintenanceCard extends StatelessWidget {
  final MaintenanceModel req;
  final MaintenanceService service;
  final String landlordId;
  final bool isDark;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;

  const _MaintenanceCard({
    required this.req,
    required this.service,
    required this.landlordId,
    required this.isDark,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
  });

  Color get _statusColor =>
      Color(int.parse('FF${req.statusColorHex}', radix: 16));

  IconData get _statusIcon {
    switch (req.status) {
      case MaintenanceStatus.pending:
        return Icons.hourglass_empty_rounded;
      case MaintenanceStatus.inProgress:
        return Icons.construction_rounded;
      case MaintenanceStatus.done:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final divider =
        isDark ? Colors.white10 : const Color(0xFFE5E7EB);
    final statusColor = _statusColor;
    final isDone = req.status == MaintenanceStatus.done;

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
        // Left border accent based on status
        border: Border(
          left: BorderSide(
            color: statusColor,
            width: 4,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tenant avatar — tappable
                  GestureDetector(
                    onTap: () async {
                      final snap = await FirebaseFirestore.instance
                          .collection('tenants')
                          .where('landlordId', isEqualTo: landlordId)
                          .where('name', isEqualTo: req.tenantName)
                          .get();
                      if (snap.docs.isNotEmpty && context.mounted) {
                        final tenant = TenantModel.fromMap(
                          snap.docs.first.data(),
                          snap.docs.first.id,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TenantDetailScreen(tenant: tenant),
                          ),
                        );
                      }
                    },
                    child: TenantAvatar(
                      tenantName: req.tenantName,
                      tenantEmail: '',
                      radius: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.tenantName,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${req.propertyName} • রুম ${req.roomNumber}',
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
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon,
                            size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          req.statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Divider(height: 1, color: divider),
              const SizedBox(height: 14),

              // ── Issue Info ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.build_circle_outlined,
                      size: 18,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          req.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Date ──
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 11,
                    color: textSecondary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${req.createdAt.day}/${req.createdAt.month}/${req.createdAt.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),

              // ── Action Buttons ──
              if (!isDone) ...[
                const SizedBox(height: 12),
                Divider(height: 1, color: divider),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (req.status == MaintenanceStatus.pending) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: const Color(0xFF0891B2)
                                    .withOpacity(0.6)),
                            foregroundColor: const Color(0xFF0891B2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                              Icons.construction_rounded,
                              size: 16),
                          label: const Text(
                            'কাজ শুরু করুন',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          onPressed: () => service.updateStatus(
                              req.id, MaintenanceStatus.inProgress),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16),
                        label: const Text(
                          'সম্পন্ন',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () => service.updateStatus(
                            req.id, MaintenanceStatus.done),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}