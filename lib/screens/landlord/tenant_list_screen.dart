import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/tenant_service.dart';
import '../../services/property_service.dart';
import '../../models/tenant_model.dart';
import 'add_edit_tenant_screen.dart';
import 'landlord_edit_tenant_screen.dart';

class TenantListScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const TenantListScreen({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;
    final tenantService = TenantService();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => scaffoldKey?.currentState?.openDrawer(),
        ),
        title: const Text('ভাড়াটিয়া তালিকা'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<TenantModel>>(
        stream: tenantService.getTenants(user.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tenants = (snap.data ?? [])
              .where((t) => t.isActive)
              .toList();

          if (tenants.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 80,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('কোনো ভাড়াটিয়া নেই',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('নিচের বাটন দিয়ে ভাড়াটিয়া যোগ করুন'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tenants.length,
            itemBuilder: (ctx, i) => _TenantCard(
              tenant: tenants[i],
              service: tenantService,
            ),
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

class _TenantCard extends StatelessWidget {
  final TenantModel tenant;
  final TenantService service;
  const _TenantCard({required this.tenant, required this.service});

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
                if (val == 'edit') {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => LandlordEditTenantScreen(tenant: tenant),
                  ));
                }
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