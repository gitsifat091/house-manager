import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/tenant_service.dart';
import '../../services/property_service.dart';
import '../../models/tenant_model.dart';
import 'add_edit_tenant_screen.dart';
import 'landlord_edit_tenant_screen.dart';
import '../shared/notification_screen.dart';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/auth_service.dart';
// import '../../services/tenant_service.dart';
// import '../../models/tenant_model.dart';
// import 'add_edit_tenant_screen.dart';
// import 'landlord_edit_tenant_screen.dart';
// import '../shared/notification_screen.dart';

enum TenantSortOrder { newest, roomNumber }

class TenantListScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const TenantListScreen({super.key, this.scaffoldKey});

  @override
  State<TenantListScreen> createState() => _TenantListScreenState();
}

class _TenantListScreenState extends State<TenantListScreen> {
  TenantSortOrder _sortOrder = TenantSortOrder.newest;

  List<TenantModel> _sortTenants(List<TenantModel> tenants) {
    final list = [...tenants];
    if (_sortOrder == TenantSortOrder.newest) {
      // নতুন আগে
      list.sort((a, b) => b.moveInDate.compareTo(a.moveInDate));
    } else {
      // রুম নম্বর অনুযায়ী natural sort
      list.sort((a, b) => _naturalCompare(a.roomNumber, b.roomNumber));
    }
    return list;
  }

  // Natural sort — A-1 < A-2 < A-10 < B-1
  int _naturalCompare(String a, String b) {
    final regExp = RegExp(r'(\D*)(\d*)');
    final aMatches = regExp.allMatches(a).toList();
    final bMatches = regExp.allMatches(b).toList();

    for (int i = 0; i < aMatches.length && i < bMatches.length; i++) {
      final aText = aMatches[i].group(1) ?? '';
      final bText = bMatches[i].group(1) ?? '';
      final aNum = int.tryParse(aMatches[i].group(2) ?? '') ?? -1;
      final bNum = int.tryParse(bMatches[i].group(2) ?? '') ?? -1;

      final textCmp = aText.compareTo(bText);
      if (textCmp != 0) return textCmp;
      if (aNum != bNum) return aNum.compareTo(bNum);
    }
    return a.compareTo(b);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;
    final tenantService = TenantService();
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => widget.scaffoldKey?.currentState?.openDrawer(),
        ),
        title: const Text('ভাড়াটিয়া তালিকা'),
        centerTitle: true,
        actions: [
          // Sort button
          PopupMenuButton<TenantSortOrder>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'সাজানোর ধরন',
            onSelected: (val) => setState(() => _sortOrder = val),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: TenantSortOrder.newest,
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: _sortOrder == TenantSortOrder.newest
                          ? color.primary
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'সর্বশেষ আগমন অনুযায়ী',
                      style: TextStyle(
                        color: _sortOrder == TenantSortOrder.newest
                            ? color.primary
                            : null,
                        fontWeight: _sortOrder == TenantSortOrder.newest
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (_sortOrder == TenantSortOrder.newest) ...[
                      const Spacer(),
                      Icon(Icons.check_rounded, size: 16, color: color.primary),
                    ],
                  ],
                ),
              ),
              PopupMenuItem(
                value: TenantSortOrder.roomNumber,
                child: Row(
                  children: [
                    Icon(
                      Icons.door_front_door_outlined,
                      size: 18,
                      color: _sortOrder == TenantSortOrder.roomNumber
                          ? color.primary
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'রুম নম্বর অনুযায়ী',
                      style: TextStyle(
                        color: _sortOrder == TenantSortOrder.roomNumber
                            ? color.primary
                            : null,
                        fontWeight: _sortOrder == TenantSortOrder.roomNumber
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (_sortOrder == TenantSortOrder.roomNumber) ...[
                      const Spacer(),
                      Icon(Icons.check_rounded, size: 16, color: color.primary),
                    ],
                  ],
                ),
              ),
            ],
          ),
          NotificationBell(userId: user.uid),
        ],
      ),
      body: StreamBuilder<List<TenantModel>>(
        stream: tenantService.getTenants(user.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final raw = (snap.data ?? [])
              .where((t) => t.isActive)
              .toList();

          final tenants = _sortTenants(raw);

          if (tenants.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 80,
                      color: color.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('কোনো ভাড়াটিয়া নেই',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('নিচের বাটন দিয়ে ভাড়াটিয়া যোগ করুন'),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Active sort indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: color.primaryContainer.withOpacity(0.4),
                child: Row(
                  children: [
                    Icon(
                      _sortOrder == TenantSortOrder.newest
                          ? Icons.access_time_rounded
                          : Icons.door_front_door_outlined,
                      size: 14,
                      color: color.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _sortOrder == TenantSortOrder.newest
                          ? 'সর্বশেষ আগমন অনুযায়ী সাজানো'
                          : 'রুম নম্বর অনুযায়ী সাজানো',
                      style: TextStyle(
                          fontSize: 12,
                          color: color.primary,
                          fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text('${tenants.length} জন',
                        style: TextStyle(fontSize: 12, color: color.primary)),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tenants.length,
                  itemBuilder: (ctx, i) => _TenantCard(
                    tenant: tenants[i],
                    service: tenantService,
                    onEdit: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => LandlordEditTenantScreen(tenant: tenants[i]),
                    )),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => AddEditTenantScreen(landlordId: user.uid),
        )),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('ভাড়াটিয়া যোগ করুন'),
      ),
    );
  }
}
// class TenantListScreen extends StatelessWidget {
//   final GlobalKey<ScaffoldState>? scaffoldKey;
//   const TenantListScreen({super.key, this.scaffoldKey});

//   @override
//   Widget build(BuildContext context) {
//     final user = context.read<AuthService>().currentUser!;
//     final tenantService = TenantService();

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.menu_rounded),
//           onPressed: () => scaffoldKey?.currentState?.openDrawer(),
//         ),
//         title: const Text('ভাড়াটিয়া তালিকা'),
//         centerTitle: true,
//       ),
//       body: StreamBuilder<List<TenantModel>>(
//         stream: tenantService.getTenants(user.uid),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final tenants = (snap.data ?? [])
//               .where((t) => t.isActive)
//               .toList();

//           if (tenants.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.people_outline, size: 80,
//                       color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
//                   const SizedBox(height: 16),
//                   const Text('কোনো ভাড়াটিয়া নেই',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   const Text('নিচের বাটন দিয়ে ভাড়াটিয়া যোগ করুন'),
//                 ],
//               ),
//             );
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: tenants.length,
//             itemBuilder: (ctx, i) => _TenantCard(
//               tenant: tenants[i],
//               service: tenantService,
//             ),
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

class _TenantCard extends StatelessWidget {
  final TenantModel tenant;
  final TenantService service;
  final VoidCallback onEdit;
  const _TenantCard({
    required this.tenant, 
    required this.service,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.primaryContainer,
              child: Text(
                tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                    color: color.primary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tenant.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(tenant.phone,
                      style: TextStyle(fontSize: 13, color: color.onSurface.withOpacity(0.6))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _chip(context, Icons.home_outlined, tenant.propertyName),
                      const SizedBox(width: 6),
                      _chip(context, Icons.door_front_door_outlined, 'রুম ${tenant.roomNumber}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('৳${tenant.rentAmount.toStringAsFixed(0)}/মাস',
                      style: TextStyle(fontSize: 13, color: color.primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            PopupMenuButton(
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('তথ্য সম্পাদনা')),  // ← নতুন
                const PopupMenuItem(value: 'remove',
                    child: Text('রুম খালি করুন', style: TextStyle(color: Colors.orange))),
                const PopupMenuItem(value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
              onSelected: (val) async {
                // if (val == 'edit') {
                //   Navigator.push(context, MaterialPageRoute(
                //     builder: (_) => LandlordEditTenantScreen(tenant: tenant),
                //   ));
                // }
                if (val == 'edit') onEdit();
                if (val == 'remove') {
                  final confirm = await _confirm(context,
                      'রুম খালি করবেন?', '${tenant.name} কে রুম থেকে সরানো হবে।');
                  if (confirm) await service.removeTenant(tenant);
                }
                if (val == 'delete') {
                  final confirm = await _confirm(context,
                      'Delete করবেন?', '${tenant.name} এর সব তথ্য মুছে যাবে।');
                  if (confirm) await service.deleteTenant(tenant);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, IconData icon, String label) {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color.onSurfaceVariant)),
        ],
      ),
    );
  }

  Future<bool> _confirm(BuildContext context, String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('না')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('হ্যাঁ'),
          ),
        ],
      ),
    ) ?? false;
  }
}