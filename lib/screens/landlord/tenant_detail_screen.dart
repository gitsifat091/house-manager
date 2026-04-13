import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/tenant_model.dart';
import '../../../models/payment_model.dart';
import '../../../widgets/tenant_avatar.dart';
import 'landlord_edit_tenant_screen.dart';

class TenantDetailScreen extends StatelessWidget {
  final TenantModel tenant;
  const TenantDetailScreen({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ভাড়াটিয়ার তথ্য'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LandlordEditTenantScreen(tenant: tenant),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: color.primary),
              child: Column(
                children: [
                  TenantAvatar(
                    tenantName: tenant.name,
                    tenantEmail: tenant.email,
                    radius: 44,
                  ),
                  const SizedBox(height: 12),
                  Text(tenant.name,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${tenant.propertyName} • রুম ${tenant.roomNumber}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal info
                  _SectionTitle(title: 'ব্যক্তিগত তথ্য'),
                  const SizedBox(height: 8),
                  _InfoCard(children: [
                    _InfoRow(Icons.phone_outlined, 'Phone', tenant.phone),
                    _InfoRow(Icons.email_outlined, 'Email',
                        tenant.email.isEmpty ? 'নেই' : tenant.email),
                    _InfoRow(Icons.badge_outlined, 'NID', tenant.nidNumber),
                  ]),

                  const SizedBox(height: 16),

                  // Room info
                  _SectionTitle(title: 'রুমের তথ্য'),
                  const SizedBox(height: 8),
                  _InfoCard(children: [
                    _InfoRow(Icons.home_work_outlined, 'Property',
                        tenant.propertyName),
                    _InfoRow(Icons.door_front_door_outlined, 'রুম নম্বর',
                        tenant.roomNumber),
                    _InfoRow(Icons.currency_exchange_rounded, 'মাসিক ভাড়া',
                        '৳${tenant.rentAmount.toStringAsFixed(0)}'),
                  ]),

                  const SizedBox(height: 16),

                  // Move-in date & time
                  _SectionTitle(title: 'প্রবেশের তথ্য'),
                  const SizedBox(height: 8),
                  _InfoCard(children: [
                    _InfoRow(
                      Icons.calendar_today_outlined,
                      'প্রবেশের তারিখ',
                      _formatDate(tenant.moveInDate),
                    ),
                    _InfoRow(
                      Icons.access_time_rounded,
                      'প্রবেশের সময়',
                      _formatTime(tenant.moveInDate),
                    ),
                    _InfoRow(
                      Icons.timelapse_rounded,
                      'কতদিন আছেন',
                      _daysLiving(tenant.moveInDate),
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // Payment history summary
                  _SectionTitle(title: 'পেমেন্ট সারসংক্ষেপ'),
                  const SizedBox(height: 8),
                  _PaymentSummaryCard(tenantId: tenant.id),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
      'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর',
      'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _daysLiving(DateTime moveIn) {
    final days = DateTime.now().difference(moveIn).inDays;
    if (days < 30) return '$days দিন';
    if (days < 365) return '${days ~/ 30} মাস ${days % 30} দিন';
    return '${days ~/ 365} বছর ${(days % 365) ~/ 30} মাস';
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  final String tenantId;
  const _PaymentSummaryCard({required this.tenantId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('payments')
          .where('tenantId', isEqualTo: tenantId)
          .get(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final payments = snap.data!.docs
            .map((d) => PaymentModel.fromMap(
                d.data() as Map<String, dynamic>, d.id))
            .toList();

        final paidCount =
            payments.where((p) => p.status == PaymentStatus.paid).length;
        final pendingCount =
            payments.where((p) => p.status == PaymentStatus.pending).length;
        final totalPaid = payments
            .where((p) => p.status == PaymentStatus.paid)
            .fold(0.0, (sum, p) => sum + p.amount);

        return _InfoCard(children: [
          _InfoRow(Icons.check_circle_outline, 'পরিশোধ', '$paidCount মাস'),
          _InfoRow(Icons.pending_outlined, 'বাকি', '$pendingCount মাস'),
          _InfoRow(Icons.account_balance_wallet_outlined, 'মোট পরিশোধ',
              '৳${totalPaid.toStringAsFixed(0)}'),
        ]);
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ));
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: children
            .asMap()
            .entries
            .map((e) => Column(
                  children: [
                    e.value,
                    if (e.key < children.length - 1)
                      Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color.primary),
          const SizedBox(width: 12),
          Text('$label ',
              style: TextStyle(
                  fontSize: 13,
                  color: color.onSurface.withOpacity(0.5))),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}