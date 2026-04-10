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

    return Scaffold(
      appBar: AppBar(title: const Text('আর্কাইভ'), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tenants')
            .where('landlordId', isEqualTo: user.uid)
            .where('isActive', isEqualTo: false)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tenants = (snap.data?.docs ?? [])
              .map((d) => TenantModel.fromMap(d.data() as Map<String, dynamic>, d.id))
              .toList()
            ..sort((a, b) => b.moveInDate.compareTo(a.moveInDate));

          if (tenants.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.archive_outlined, size: 48,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 20),
                  const Text('আর্কাইভ খালি',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('রুম খালি করলে ভাড়াটিয়ার তথ্য এখানে আসবে',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tenants.length,
            itemBuilder: (ctx, i) => _ArchivedTenantCard(
              tenant: tenants[i],
              landlordId: user.uid,
            ),
          );
        },
      ),
    );
  }
}

class _ArchivedTenantCard extends StatelessWidget {
  final TenantModel tenant;
  final String landlordId;
  const _ArchivedTenantCard({required this.tenant, required this.landlordId});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Text(
              tenant.name[0].toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
          ),
          title: Text(tenant.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${tenant.propertyName} • রুম ${tenant.roomNumber}',
              style: TextStyle(fontSize: 12, color: color.onSurface.withOpacity(0.6))),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('আর্কাইভড',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ),
              const Icon(Icons.expand_more),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),

                  // Info grid
                  _infoRow(Icons.phone_outlined, 'Phone', tenant.phone),
                  _infoRow(Icons.email_outlined, 'Email',
                      tenant.email.isEmpty ? 'নেই' : tenant.email),
                  _infoRow(Icons.badge_outlined, 'NID', tenant.nidNumber),
                  _infoRow(Icons.home_work_outlined, 'Property', tenant.propertyName),
                  _infoRow(Icons.door_front_door_outlined, 'রুম', tenant.roomNumber),
                  _infoRow(Icons.currency_exchange_rounded, 'মাসিক ভাড়া',
                      '৳${tenant.rentAmount.toStringAsFixed(0)}'),
                  _infoRow(Icons.calendar_today_outlined, 'প্রবেশের তারিখ',
                      '${tenant.moveInDate.day}/${tenant.moveInDate.month}/${tenant.moveInDate.year}'),

                  const SizedBox(height: 12),

                  // Payment history
                  Text('পেমেন্ট ইতিহাস',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color.primary)),
                  const SizedBox(height: 8),

                  _PaymentHistory(tenantId: tenant.id),

                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    children: [
                      // Restore button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _restoreTenant(context),
                          icon: const Icon(Icons.restore_rounded, size: 18),
                          label: const Text('পুনরায় যোগ করুন'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Permanent delete
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _permanentDelete(context),
                          icon: const Icon(Icons.delete_forever_rounded,
                              size: 18, color: Colors.red),
                          label: const Text('মুছে ফেলুন',
                              style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red)),
                        ),
                      ),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500)),
          Expanded(child: Text(value,
              style: const TextStyle(fontSize: 13, color: Colors.grey))),
        ],
      ),
    );
  }

  Future<void> _restoreTenant(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('পুনরায় যোগ করবেন?'),
        content: Text(
            '${tenant.name} কে active tenant হিসেবে ফিরিয়ে আনা হবে।\n\n'
            'তবে রুম ${tenant.roomNumber} যদি অন্য কেউ নিয়ে থাকে, conflict হতে পারে।'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('বাতিল')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('হ্যাঁ, ফিরিয়ে আনুন')),
        ],
      ),
    );

    if (confirm != true) return;

    final db = FirebaseFirestore.instance;
    // Restore tenant
    await db.collection('tenants').doc(tenant.id).update({'isActive': true});
    // Mark room occupied again
    await db.collection('rooms').doc(tenant.roomId).update({
      'status': 'occupied',
      'tenantId': tenant.id,
      'tenantName': tenant.name,
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tenant.name} কে ফিরিয়ে আনা হয়েছে'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _permanentDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('চিরতরে মুছে ফেলবেন?'),
        content: Text(
            '${tenant.name} এর সব তথ্য permanently মুছে যাবে।\n\n'
            'এই কাজ আর undo করা যাবে না।'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('বাতিল')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('হ্যাঁ, মুছে ফেলুন'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('tenants')
        .doc(tenant.id)
        .delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('মুছে ফেলা হয়েছে')),
      );
    }
  }
}

class _PaymentHistory extends StatelessWidget {
  final String tenantId;
  const _PaymentHistory({required this.tenantId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('payments')
          .where('tenantId', isEqualTo: tenantId)
          .get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final payments = (snap.data?.docs ?? [])
            .map((d) => PaymentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList()
          ..sort((a, b) {
            if (a.year != b.year) return b.year.compareTo(a.year);
            return b.month.compareTo(a.month);
          });

        if (payments.isEmpty) {
          return const Text('কোনো payment রেকর্ড নেই',
              style: TextStyle(color: Colors.grey, fontSize: 13));
        }

        final paidCount = payments.where((p) => p.status == PaymentStatus.paid).length;
        final totalPaid = payments
            .where((p) => p.status == PaymentStatus.paid)
            .fold(0.0, (sum, p) => sum + p.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'মোট $paidCount মাস পরিশোধ • ৳${totalPaid.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Payment list (last 6)
            ...payments.take(6).map((p) {
              const months = ['', 'জান', 'ফেব', 'মার্চ', 'এপ্রি',
                'মে', 'জুন', 'জুলা', 'আগ', 'সেপ্ট', 'অক্ট', 'নভে', 'ডিসে'];
              final isPaid = p.status == PaymentStatus.paid;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      isPaid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: isPaid ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text('${months[p.month]} ${p.year}',
                        style: const TextStyle(fontSize: 13)),
                    const Spacer(),
                    Text('৳${p.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isPaid ? Colors.green.shade700 : Colors.orange.shade700)),
                  ],
                ),
              );
            }),

            if (payments.length > 6)
              Text('+ আরও ${payments.length - 6} টি রেকর্ড',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        );
      },
    );
  }
}