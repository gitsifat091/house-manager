import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/payment_model.dart';
import '../../../models/user_model.dart';
import '../../../services/pdf_service.dart';
import '../../../services/pdf_service.dart';
import '../../../models/payment_model.dart';
import '../../../services/payment_service.dart';

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

  void _showSubmitPaymentSheet(BuildContext context, PaymentModel payment) {
    final transactionCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String selectedMethod = 'bKash';
    final formKey = GlobalKey<FormState>();

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
                const Text('পেমেন্ট জমা দিন',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${payment.monthName} ${payment.year} — ৳${payment.amount.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),

                // Payment method
                const Text('পেমেন্ট পদ্ধতি',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['bKash', 'Nagad', 'Rocket', 'Bank', 'Cash']
                      .map((method) => ChoiceChip(
                            label: Text(method),
                            selected: selectedMethod == method,
                            onSelected: (_) =>
                                setModalState(() => selectedMethod = method),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: transactionCtrl,
                  decoration: InputDecoration(
                    labelText: selectedMethod == 'Cash'
                        ? 'রসিদ নম্বর (যদি থাকে)'
                        : 'Transaction ID',
                    hintText: selectedMethod == 'Cash'
                        ? 'Optional'
                        : 'যেমন: TXN123456',
                  ),
                  validator: (v) {
                    if (selectedMethod != 'Cash' && (v == null || v.isEmpty)) {
                      return 'Transaction ID দিন';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'নোট (optional)',
                    hintText: 'যেকোনো অতিরিক্ত তথ্য',
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      await PaymentService().submitPayment(
                        payment.id,
                        paymentMethod: selectedMethod,
                        transactionId: transactionCtrl.text.trim().isEmpty
                            ? 'Cash Payment'
                            : transactionCtrl.text.trim(),
                        note: noteCtrl.text.trim().isEmpty
                            ? null
                            : noteCtrl.text.trim(),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'পেমেন্ট জমা হয়েছে। বাড়ীওয়ালার অনুমোদনের অপেক্ষায়।'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('পেমেন্ট জমা দিন'),
                  ),
                ),
              ],
            ),
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
                              final isSubmitted = p.status == PaymentStatus.submitted;
                              final isRejected = p.status == PaymentStatus.rejected;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('${_months[p.month]} ${p.year}',
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.bold, fontSize: 15)),
                                                Text('৳${p.amount.toStringAsFixed(0)}',
                                                    style: const TextStyle(fontSize: 14)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Color(int.parse(p.statusBgColorHex, radix: 16)),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(p.statusLabel,
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(int.parse(p.statusColorHex, radix: 16)))),
                                          ),
                                        ],
                                      ),

                                      // Rejection notice
                                      if (isRejected) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFEBEE),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('পেমেন্ট বাতিল হয়েছে',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13)),
                                              if (p.rejectionReason != null)
                                                Text('কারণ: ${p.rejectionReason}',
                                                    style: const TextStyle(
                                                        color: Colors.red, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ],

                                      // Submit button for pending/rejected
                                      if (!isPaid && !isSubmitted) ...[
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          child: FilledButton.icon(
                                            onPressed: () => _showSubmitPaymentSheet(ctx, p),
                                            icon: const Icon(Icons.send_rounded, size: 18),
                                            label: Text(isRejected
                                                ? 'আবার পেমেন্ট জমা দিন'
                                                : 'পেমেন্ট জমা দিন'),
                                          ),
                                        ),
                                      ],

                                      // Submitted info
                                      if (isSubmitted) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE3F2FD),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.hourglass_top_rounded,
                                                  color: Color(0xFF1565C0), size: 18),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('পেমেন্ট যাচাইয়ের অপেক্ষায়',
                                                        style: TextStyle(
                                                            color: Color(0xFF1565C0),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 13)),
                                                    Text(
                                                        'পদ্ধতি: ${p.paymentMethod} • ID: ${p.transactionId}',
                                                        style: const TextStyle(
                                                            color: Color(0xFF1565C0), fontSize: 11)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],

                                      // PDF for paid
                                      if (isPaid) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.check_circle_rounded,
                                                color: Colors.green.shade700, size: 16),
                                            const SizedBox(width: 6),
                                            Text(
                                              'পরিশোধ: ${p.paidAt?.day}/${p.paidAt?.month}/${p.paidAt?.year}',
                                              style: TextStyle(
                                                  fontSize: 12, color: Colors.green.shade700),
                                            ),
                                            const Spacer(),
                                            TextButton.icon(
                                              onPressed: () async {
                                                final pdfBytes =
                                                    await PdfService.generateRentReceipt(
                                                  payment: p,
                                                  landlordName: 'বাড়ীওয়ালা',
                                                  landlordPhone: '',
                                                );
                                                await PdfService.sharePdf(pdfBytes,
                                                    'receipt_${p.month}_${p.year}.pdf');
                                              },
                                              icon: const Icon(Icons.picture_as_pdf_rounded,
                                                  color: Colors.red, size: 18),
                                              label: const Text('Receipt',
                                                  style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      ],
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