import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../../../services/utility_service.dart';
import '../../../models/utility_model.dart';
import '../../../models/tenant_model.dart';
import '../shared/notification_screen.dart';
import '../../../models/tenant_model.dart';
import '../../../widgets/tenant_avatar.dart';
import 'tenant_detail_screen.dart';

class UtilityScreen extends StatefulWidget {
  const UtilityScreen({super.key});

  @override
  State<UtilityScreen> createState() => _UtilityScreenState();
}

class _UtilityScreenState extends State<UtilityScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final List<String> _months = [
    '', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
    'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর',
    'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;
    final service = UtilityService();

    return Scaffold(
      appBar: AppBar(title: const Text('ইউটিলিটি বিল'), centerTitle: true),
      body: Column(
        children: [
          // Month selector
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => setState(() {
                    if (_selectedMonth == 1) { _selectedMonth = 12; _selectedYear--; }
                    else { _selectedMonth--; }
                  }),
                ),
                Expanded(
                  child: Center(
                    child: Text('${_months[_selectedMonth]} $_selectedYear',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () => setState(() {
                    if (_selectedMonth == 12) { _selectedMonth = 1; _selectedYear++; }
                    else { _selectedMonth++; }
                  }),
                ),
              ],
            ),
          ),

          // Bill list
          Expanded(
  child: StreamBuilder<List<UtilityModel>>(
    stream: service.getLandlordBills(user.uid),
    builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      final all = snap.data ?? [];
      final bills = all.where((b) =>
          b.month == _selectedMonth && b.year == _selectedYear).toList();

      if (bills.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💡', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text('এই মাসের কোনো বিল নেই',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('নিচের + বাটন দিয়ে বিল যোগ করুন'),
            ],
          ),
        );
      }

      // Summary
      final totalBills = bills.fold(0.0, (sum, b) => sum + b.amount);
      final paidBills = bills.where((b) => b.isPaid).fold(0.0, (sum, b) => sum + b.amount);

      // Group by tenant
      final Map<String, List<UtilityModel>> grouped = {};
      for (final bill in bills) {
        final key = '${bill.tenantId}_${bill.tenantName}_${bill.roomNumber}';
        grouped.putIfAbsent(key, () => []).add(bill);
      }

      return Column(
        children: [
          // Summary row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(child: _StatCard(
                  label: 'মোট বিল', value: '৳${totalBills.toStringAsFixed(0)}',
                  color: Colors.blue, icon: Icons.receipt_outlined,
                )),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(
                  label: 'পরিশোধ', value: '৳${paidBills.toStringAsFixed(0)}',
                  color: Colors.green, icon: Icons.check_circle_outline,
                )),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(
                  label: 'বাকি',
                  value: '৳${(totalBills - paidBills).toStringAsFixed(0)}',
                  color: Colors.orange, icon: Icons.pending_outlined,
                )),
              ],
            ),
          ),

          // Grouped list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: grouped.length,
              itemBuilder: (ctx, i) {
                final entry = grouped.entries.elementAt(i);
                final tenantBills = entry.value;
                final tenantName = tenantBills.first.tenantName;
                final roomNumber = tenantBills.first.roomNumber;
                final tenantTotal = tenantBills.fold(0.0, (s, b) => s + b.amount);
                final tenantPaid = tenantBills.where((b) => b.isPaid).fold(0.0, (s, b) => s + b.amount);
                final allPaid = tenantBills.every((b) => b.isPaid);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: allPaid
                          ? Colors.green.withOpacity(0.4)
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Tenant header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: allPaid
                              ? Colors.green.withOpacity(0.08)
                              : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                        ),
                        child: Row(
                          children: [
                            // CircleAvatar(
                            //   radius: 18,
                            //   backgroundColor: Theme.of(context).colorScheme.primary,
                            //   child: Text(
                            //     tenantName.isNotEmpty ? tenantName[0].toUpperCase() : '?',
                            //     style: const TextStyle(
                            //         color: Colors.white,
                            //         fontWeight: FontWeight.bold,
                            //         fontSize: 14),
                            //   ),
                            // ),
                            GestureDetector(
                              onTap: () async {
                                final snap = await FirebaseFirestore.instance
                                    .collection('tenants')
                                    .doc(tenantBills.first.tenantId)
                                    .get();
                                if (snap.exists && context.mounted) {
                                  final tenant = TenantModel.fromMap(snap.data()!, snap.id);
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => TenantDetailScreen(tenant: tenant),
                                  ));
                                }
                              },
                              child: TenantAvatar(
                                tenantName: tenantName,
                                tenantEmail: '',
                                radius: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tenantName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  Text('রুম $roomNumber',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6))),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('৳${tenantTotal.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                Text(
                                  allPaid
                                      ? 'সম্পূর্ণ পরিশোধ'
                                      : 'বাকি: ৳${(tenantTotal - tenantPaid).toStringAsFixed(0)}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: allPaid
                                          ? Colors.green.shade700
                                          : Colors.orange.shade700,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Bill items
                      ...tenantBills.map((bill) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(bill.typeIcon,
                                    style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                                      child: Text(bill.typeLabel,
                                          style: const TextStyle(fontSize: 14)),
                                      ),
                                      Text('৳${bill.amount.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: bill.isPaid
                                              ? Colors.green.shade100
                                              : Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          bill.isPaid ? 'পরিশোধ' : 'বাকি',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: bill.isPaid
                                                ? Colors.green.shade800
                                                : Colors.orange.shade800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      // Action buttons
                                      bill.isPaid
                                          ? IconButton(
                                              icon: Icon(Icons.undo_rounded,
                                                  size: 18,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.4)),
                                              onPressed: () =>
                                                  service.markUnpaid(bill.id),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            )
                                          : IconButton(
                                              icon: Icon(Icons.check_circle_outline,
                                                  size: 18,
                                                  color: Colors.green.shade600),
                                              onPressed: () =>
                                                  service.markPaid(bill.id),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red, size: 18),
                                        onPressed: () =>
                                            service.deleteBill(bill.id),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                )),

                                // "সব পরিশোধ" button
                                if (!allPaid)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          for (final bill in tenantBills) {
                                            if (!bill.isPaid) {
                                              await service.markPaid(bill.id);
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.done_all_rounded, size: 18),
                                        label: const Text('সব পরিশোধ করুন'),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBillDialog(context, user.uid),
        icon: const Icon(Icons.add),
        label: const Text('বিল যোগ করুন'),
      ),
    );
  }

  void _showAddBillDialog(BuildContext context, String landlordId) async {
    // Load tenants
    final snap = await FirebaseFirestore.instance
        .collection('tenants')
        .where('landlordId', isEqualTo: landlordId)
        .where('isActive', isEqualTo: true)
        .get();

    final tenants = snap.docs
        .map((d) => TenantModel.fromMap(d.data(), d.id))
        .toList();

    if (tenants.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('কোনো active ভাড়াটিয়া নেই')));
      }
      return;
    }

    TenantModel? selectedTenant = tenants.first;
    UtilityType selectedType = UtilityType.electricity;
    final amountCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('নতুন বিল যোগ করুন',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Tenant dropdown
                DropdownButtonFormField<TenantModel>(
                  value: selectedTenant,
                  decoration: const InputDecoration(labelText: 'ভাড়াটিয়া'),
                  items: tenants.map((t) => DropdownMenuItem(
                    value: t,
                    child: Text('${t.name} (রুম ${t.roomNumber})'),
                  )).toList(),
                  onChanged: (t) => setModalState(() => selectedTenant = t),
                ),
                const SizedBox(height: 12),

                // Type selector
                const Text('বিলের ধরন',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: UtilityType.values.map((type) {
                    final labels = ['গ্যাস', 'বিদ্যুৎ', 'পানি', 'অন্যান্য'];
                    final icons = ['🔥', '⚡', '💧', '📋'];
                    final idx = UtilityType.values.indexOf(type);
                    return ChoiceChip(
                      label: Text('${icons[idx]} ${labels[idx]}'),
                      selected: selectedType == type,
                      onSelected: (_) => setModalState(() => selectedType = type),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'পরিমাণ (৳)',
                    hintText: 'যেমন: 500',
                  ),
                  validator: (v) {
                    if (v!.isEmpty) return 'পরিমাণ দিন';
                    if (double.tryParse(v) == null) return 'সঠিক পরিমাণ দিন';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity, height: 50,
                  child: FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final bill = UtilityModel(
                        id: '',
                        tenantId: selectedTenant!.id,
                        tenantName: selectedTenant!.name,
                        roomNumber: selectedTenant!.roomNumber,
                        propertyId: selectedTenant!.propertyId,
                        propertyName: selectedTenant!.propertyName,
                        landlordId: landlordId,
                        type: selectedType,
                        amount: double.parse(amountCtrl.text.trim()),
                        month: _selectedMonth,
                        year: _selectedYear,
                        createdAt: DateTime.now(),
                      );
                      await UtilityService().addBill(bill);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('বিল Save করুন'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  final UtilityModel bill;
  final UtilityService service;
  const _BillCard({required this.bill, required this.service});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(bill.typeIcon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bill.typeLabel,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('${bill.tenantName} • রুম ${bill.roomNumber}',
                      style: TextStyle(fontSize: 12, color: color.onSurface.withOpacity(0.6))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('৳${bill.amount.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      //   decoration: BoxDecoration(
                      //     color: bill.isPaid ? Colors.green.shade100 : Colors.orange.shade100,
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),
                      //   child: Text(
                      //     bill.isPaid ? 'পরিশোধ' : 'বাকি',
                      //     style: TextStyle(
                      //       fontSize: 11, fontWeight: FontWeight.w500,
                      //       color: bill.isPaid ? Colors.green.shade800 : Colors.orange.shade800,
                      //     ),
                      //   ),
                      // ),
                      // _BillCard এ status pill:
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: bill.isPaid
                              ? Colors.green.shade100
                              : bill.isSubmitted
                                  ? Colors.blue.shade100
                                  : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          bill.isPaid ? 'পরিশোধ' : bill.isSubmitted ? 'যাচাই চলছে' : 'বাকি',
                          style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500,
                            color: bill.isPaid
                                ? Colors.green.shade800
                                : bill.isSubmitted
                                    ? Colors.blue.shade800
                                    : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Column(
            //   children: [
            //     bill.isPaid
            //         ? IconButton(
            //             icon: Icon(Icons.undo_rounded, color: color.onSurface.withOpacity(0.4)),
            //             onPressed: () => service.markUnpaid(bill.id),
            //           )
            //         : FilledButton.tonal(
            //             onPressed: () => service.markPaid(bill.id),
            //             style: FilledButton.styleFrom(
            //                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
            //             child: const Text('পরিশোধ', style: TextStyle(fontSize: 12)),
            //           ),
            //     IconButton(
            //       icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            //       onPressed: () => service.deleteBill(bill.id),
            //     ),
            //   ],
            // ),
            // Replace করো:
            Column(
              children: [
                bill.isPaid
                    ? IconButton(
                        icon: Icon(Icons.undo_rounded,
                            size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                        onPressed: () => service.markUnpaid(bill.id),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    : bill.isSubmitted
                        // যাচাইয়ের অপেক্ষায় — approve/reject
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: Colors.red, size: 18),
                                onPressed: () => service.rejectBill(bill.id),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'বাতিল',
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline_rounded,
                                    color: Colors.green, size: 18),
                                onPressed: () => service.approveBill(bill.id),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'অনুমোদন',
                              ),
                            ],
                          )
                        // Pending — কোনো action নেই (tenant submit করবে)
                        : const SizedBox(width: 36),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  onPressed: () => service.deleteBill(bill.id),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}