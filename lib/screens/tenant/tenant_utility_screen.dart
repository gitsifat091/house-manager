import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/utility_model.dart';
import '../../../models/user_model.dart';
import '../../../services/utility_service.dart';
import '../../../services/utility_service.dart';

class TenantUtilityScreen extends StatefulWidget {
  final UserModel user;
  const TenantUtilityScreen({super.key, required this.user});

  @override
  State<TenantUtilityScreen> createState() => _TenantUtilityScreenState();
}

class _TenantUtilityScreenState extends State<TenantUtilityScreen> {
  String? _tenantId;
  bool _loading = true;

  final List<String> _months = [
    '', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
    'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর',
    'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
  ];

  @override
  void initState() {
    super.initState();
    _loadTenantId();
  }

  void _showSubmitSheet(BuildContext context, UtilityModel bill) {
    String selectedMethod = 'bKash';
    final noteCtrl = TextEditingController();

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${bill.typeLabel} জমা দিন',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('৳${bill.amount.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              const Text('পেমেন্ট পদ্ধতি',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['bKash', 'Nagad', 'Rocket', 'Bank', 'Cash']
                    .map((method) => ChoiceChip(
                          label: Text(method),
                          selected: selectedMethod == method,
                          onSelected: (_) => setModalState(() => selectedMethod = method),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Transaction ID বা নোট (optional)',
                  hintText: 'যেমন: TXN123456',
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () async {
                    await UtilityService().submitBill(
                      bill.id,
                      paymentMethod: selectedMethod,
                      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('জমা দেওয়া হয়েছে। বাড়ীওয়ালার অনুমোদনের অপেক্ষায়।'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('জমা দিন'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadTenantId() async {
    final snap = await FirebaseFirestore.instance
        .collection('tenants')
        .where('email', isEqualTo: widget.user.email)
        .where('isActive', isEqualTo: true)
        .get();

    if (snap.docs.isNotEmpty) {
      setState(() { _tenantId = snap.docs.first.id; _loading = false; });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('আমার বিলসমূহ'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tenantId == null
              ? const Center(child: Text('তথ্য পাওয়া যায়নি'))
              : StreamBuilder<List<UtilityModel>>(
                  stream: UtilityService().getTenantBills(_tenantId!),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final bills = snap.data ?? [];

                    if (bills.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 64)),
                            const SizedBox(height: 16),
                            const Text('কোনো বিল নেই',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }

                    // Total summary
                    final totalDue = bills.where((b) => !b.isPaid)
                        .fold(0.0, (sum, b) => sum + b.amount);
                    final totalPaid = bills.where((b) => b.isPaid)
                        .fold(0.0, (sum, b) => sum + b.amount);

                    // Group by month
                    final Map<String, List<UtilityModel>> grouped = {};
                    for (final bill in bills) {
                      final key = '${_months[bill.month]} ${bill.year}';
                      grouped.putIfAbsent(key, () => []).add(bill);
                    }

                    return Column(
                      children: [
                        // Summary
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              _summaryItem('মোট বাকি', '৳${totalDue.toStringAsFixed(0)}'),
                              Container(width: 1, height: 40, color: Colors.white24,
                                  margin: const EdgeInsets.symmetric(horizontal: 12)),
                              _summaryItem('মোট পরিশোধ', '৳${totalPaid.toStringAsFixed(0)}'),
                            ],
                          ),
                        ),

                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: grouped.entries.map((entry) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                                    child: Text(entry.key,
                                        style: TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        )),
                                  ),
                                  ...entry.value.map((bill) {
                                    final color = Theme.of(context).colorScheme;
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: Container(
                                          width: 44, height: 44,
                                          decoration: BoxDecoration(
                                            color: color.surfaceVariant,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(bill.typeIcon,
                                                style: const TextStyle(fontSize: 22)),
                                          ),
                                        ),
                                        title: Text(bill.typeLabel,
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text('৳${bill.amount.toStringAsFixed(0)}'),
                                        // trailing: Container(
                                        //   padding: const EdgeInsets.symmetric(
                                        //       horizontal: 10, vertical: 4),
                                        //   decoration: BoxDecoration(
                                        //     color: bill.isPaid
                                        //         ? Colors.green.shade100
                                        //         : Colors.orange.shade100,
                                        //     borderRadius: BorderRadius.circular(20),
                                        //   ),
                                        //   child: Text(
                                        //     bill.isPaid ? 'পরিশোধ' : 'বাকি',
                                        //     style: TextStyle(
                                        //       fontSize: 12, fontWeight: FontWeight.w500,
                                        //       color: bill.isPaid
                                        //           ? Colors.green.shade800
                                        //           : Colors.orange.shade800,
                                        //     ),
                                        //   ),
                                        // ),
                                        trailing: bill.isPaid
                                          ? Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text('পরিশোধ',
                                                  style: TextStyle(fontSize: 12, color: Colors.green.shade800, fontWeight: FontWeight.w500)),
                                            )
                                          : bill.isSubmitted
                                              ? Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade100,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Text('যাচাই চলছে',
                                                      style: TextStyle(fontSize: 12, color: Colors.blue.shade800, fontWeight: FontWeight.w500)),
                                                )
                                              : GestureDetector(
                                                  onTap: () => _showSubmitSheet(context, bill),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange.shade100,
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text('জমা দিন',
                                                        style: TextStyle(fontSize: 12, color: Colors.orange.shade800, fontWeight: FontWeight.w500)),
                                                  ),
                                                ),
                                      ),
                                    );
                                  }),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}