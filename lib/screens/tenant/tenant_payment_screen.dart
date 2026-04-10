import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/payment_model.dart';
import '../../../models/user_model.dart';
import '../../../services/pdf_service.dart';

class TenantPaymentScreen extends StatefulWidget {
  final UserModel user;
  // const TenantPaymentScreen({super.key, required this.user});
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const TenantPaymentScreen({super.key, required this.user, this.scaffoldKey});

  @override
  State<TenantPaymentScreen> createState() => _TenantPaymentScreenState();
}

class _TenantPaymentScreenState extends State<TenantPaymentScreen> {
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

  Future<void> _loadTenantId() async {
    final snap = await FirebaseFirestore.instance
        .collection('tenants')
        .where('email', isEqualTo: widget.user.email)
        .where('isActive', isEqualTo: true)
        .get();

    if (snap.docs.isNotEmpty) {
      setState(() {
        _tenantId = snap.docs.first.id;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => widget.scaffoldKey?.currentState?.openDrawer(),
        ),
        title: const Text('আমার ভাড়ার ইতিহাস'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tenantId == null
              ? const Center(child: Text('তথ্য পাওয়া যায়নি'))
              : StreamBuilder<List<PaymentModel>>(
                  stream: FirebaseFirestore.instance
                      .collection('payments')
                      .where('tenantId', isEqualTo: _tenantId)
                      .snapshots()
                      .map((snap) => snap.docs
                          .map((d) => PaymentModel.fromMap(d.data(), d.id))
                          .toList()
                        ..sort((a, b) {
                          if (a.year != b.year) return b.year.compareTo(a.year);
                          return b.month.compareTo(a.month);
                        })),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final payments = snap.data ?? [];

                    if (payments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 80,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            const Text('কোনো ভাড়ার রেকর্ড নেই',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }

                    // Summary
                    final paid = payments.where((p) => p.status == PaymentStatus.paid).length;
                    final pending = payments.where((p) => p.status == PaymentStatus.pending).length;
                    final totalPaid = payments
                        .where((p) => p.status == PaymentStatus.paid)
                        .fold(0.0, (sum, p) => sum + p.amount);

                    return Column(
                      children: [
                        // Summary bar
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              _summaryItem('মোট পরিশোধ', '৳${totalPaid.toStringAsFixed(0)}'),
                              Container(width: 1, height: 40, color: Colors.white24,
                                  margin: const EdgeInsets.symmetric(horizontal: 12)),
                              _summaryItem('পরিশোধিত', '$paid মাস'),
                              Container(width: 1, height: 40, color: Colors.white24,
                                  margin: const EdgeInsets.symmetric(horizontal: 12)),
                              _summaryItem('বাকি', '$pending মাস'),
                            ],
                          ),
                        ),

                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: payments.length,
                            itemBuilder: (ctx, i) {
                              final p = payments[i];
                              final isPaid = p.status == PaymentStatus.paid;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isPaid
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                                    child: Icon(
                                      isPaid ? Icons.check_rounded : Icons.pending_rounded,
                                      color: isPaid ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                  title: Text(
                                    '${_months[p.month]} ${p.year}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('৳${p.amount.toStringAsFixed(0)}'),
                                      if (isPaid && p.paidAt != null)
                                        Text(
                                          'পরিশোধ: ${p.paidAt!.day}/${p.paidAt!.month}/${p.paidAt!.year}',
                                          style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                                        ),
                                      if (p.note != null)
                                        Text(p.note!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                  // trailing: Container(
                                  //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  //   decoration: BoxDecoration(
                                  //     color: isPaid ? Colors.green.shade100 : Colors.orange.shade100,
                                  //     borderRadius: BorderRadius.circular(20),
                                  //   ),
                                  //   child: Text(
                                  //     isPaid ? 'পরিশোধ' : 'বাকি',
                                  //     style: TextStyle(
                                  //       fontSize: 12, fontWeight: FontWeight.w500,
                                  //       color: isPaid ? Colors.green.shade800 : Colors.orange.shade800,
                                  //     ),
                                  //   ),
                                  // ),
                                  // ListTile এর trailing এ change করো
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isPaid)
                                        IconButton(
                                          icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 20),
                                          onPressed: () async {
                                            final pdfBytes = await PdfService.generateRentReceipt(
                                              payment: p,
                                              landlordName: 'বাড়ীওয়ালা',
                                              landlordPhone: '',
                                            );
                                            await PdfService.sharePdf(pdfBytes,
                                                'receipt_${p.month}_${p.year}.pdf');
                                          },
                                        ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isPaid ? Colors.green.shade100 : Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          isPaid ? 'পরিশোধ' : 'বাকি',
                                          style: TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.w500,
                                            color: isPaid ? Colors.green.shade800 : Colors.orange.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}