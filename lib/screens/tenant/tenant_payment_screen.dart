// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import '../../../models/payment_model.dart';
// // import '../../../models/user_model.dart';
// // import '../../../services/pdf_service.dart';
// // import '../../../services/pdf_service.dart';
// // import '../../../models/payment_model.dart';
// // import '../../../services/payment_service.dart';

// // class TenantPaymentScreen extends StatefulWidget {
// //   final UserModel user;
// //   // const TenantPaymentScreen({super.key, required this.user});
// //   final GlobalKey<ScaffoldState>? scaffoldKey;
// //   const TenantPaymentScreen({super.key, required this.user, this.scaffoldKey});

// //   @override
// //   State<TenantPaymentScreen> createState() => _TenantPaymentScreenState();
// // }

// // class _TenantPaymentScreenState extends State<TenantPaymentScreen> {
// //   String? _tenantId;
// //   bool _loading = true;

// //   final List<String> _months = [
// //     '', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
// //     'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর',
// //     'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
// //   ];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadTenantId();
// //   }

// //   void _showSubmitPaymentSheet(BuildContext context, PaymentModel payment) {
// //     final transactionCtrl = TextEditingController();
// //     final noteCtrl = TextEditingController();
// //     String selectedMethod = 'bKash';
// //     final formKey = GlobalKey<FormState>();

// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       shape: const RoundedRectangleBorder(
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
// //       builder: (ctx) => StatefulBuilder(
// //         builder: (ctx, setModalState) => Padding(
// //           padding: EdgeInsets.only(
// //             left: 20, right: 20, top: 20,
// //             bottom: MediaQuery.of(context).viewInsets.bottom + 20,
// //           ),
// //           child: Form(
// //             key: formKey,
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Text('পেমেন্ট জমা দিন',
// //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //                 const SizedBox(height: 4),
// //                 Text('${payment.monthName} ${payment.year} — ৳${payment.amount.toStringAsFixed(0)}',
// //                     style: const TextStyle(color: Colors.grey)),
// //                 const SizedBox(height: 16),

// //                 // Payment method
// //                 const Text('পেমেন্ট পদ্ধতি',
// //                     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
// //                 const SizedBox(height: 8),
// //                 Wrap(
// //                   spacing: 8,
// //                   children: ['bKash', 'Nagad', 'Rocket', 'Bank', 'Cash']
// //                       .map((method) => ChoiceChip(
// //                             label: Text(method),
// //                             selected: selectedMethod == method,
// //                             onSelected: (_) =>
// //                                 setModalState(() => selectedMethod = method),
// //                           ))
// //                       .toList(),
// //                 ),
// //                 const SizedBox(height: 12),

// //                 TextFormField(
// //                   controller: transactionCtrl,
// //                   decoration: InputDecoration(
// //                     labelText: selectedMethod == 'Cash'
// //                         ? 'রসিদ নম্বর (যদি থাকে)'
// //                         : 'Transaction ID',
// //                     hintText: selectedMethod == 'Cash'
// //                         ? 'Optional'
// //                         : 'যেমন: TXN123456',
// //                   ),
// //                   validator: (v) {
// //                     if (selectedMethod != 'Cash' && (v == null || v.isEmpty)) {
// //                       return 'Transaction ID দিন';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 12),

// //                 TextFormField(
// //                   controller: noteCtrl,
// //                   decoration: const InputDecoration(
// //                     labelText: 'নোট (optional)',
// //                     hintText: 'যেকোনো অতিরিক্ত তথ্য',
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),

// //                 SizedBox(
// //                   width: double.infinity,
// //                   height: 50,
// //                   child: FilledButton.icon(
// //                     onPressed: () async {
// //                       if (!formKey.currentState!.validate()) return;
// //                       await PaymentService().submitPayment(
// //                         payment.id,
// //                         paymentMethod: selectedMethod,
// //                         transactionId: transactionCtrl.text.trim().isEmpty
// //                             ? 'Cash Payment'
// //                             : transactionCtrl.text.trim(),
// //                         note: noteCtrl.text.trim().isEmpty
// //                             ? null
// //                             : noteCtrl.text.trim(),
// //                       );
// //                       if (ctx.mounted) Navigator.pop(ctx);
// //                       if (context.mounted) {
// //                         ScaffoldMessenger.of(context).showSnackBar(
// //                           const SnackBar(
// //                             content: Text(
// //                                 'পেমেন্ট জমা হয়েছে। বাড়ীওয়ালার অনুমোদনের অপেক্ষায়।'),
// //                             backgroundColor: Colors.blue,
// //                           ),
// //                         );
// //                       }
// //                     },
// //                     icon: const Icon(Icons.send_rounded),
// //                     label: const Text('পেমেন্ট জমা দিন'),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Future<void> _loadTenantId() async {
// //     final snap = await FirebaseFirestore.instance
// //         .collection('tenants')
// //         .where('email', isEqualTo: widget.user.email)
// //         .where('isActive', isEqualTo: true)
// //         .get();

// //     if (snap.docs.isNotEmpty) {
// //       setState(() {
// //         _tenantId = snap.docs.first.id;
// //         _loading = false;
// //       });
// //     } else {
// //       setState(() => _loading = false);
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         leading: IconButton(
// //           icon: const Icon(Icons.menu_rounded),
// //           onPressed: () => widget.scaffoldKey?.currentState?.openDrawer(),
// //         ),
// //         title: const Text('আমার ভাড়ার ইতিহাস'), centerTitle: true),
// //       body: _loading
// //           ? const Center(child: CircularProgressIndicator())
// //           : _tenantId == null
// //               ? const Center(child: Text('তথ্য পাওয়া যায়নি'))
// //               : StreamBuilder<List<PaymentModel>>(
// //                   stream: FirebaseFirestore.instance
// //                       .collection('payments')
// //                       .where('tenantId', isEqualTo: _tenantId)
// //                       .snapshots()
// //                       .map((snap) => snap.docs
// //                           .map((d) => PaymentModel.fromMap(d.data(), d.id))
// //                           .toList()
// //                         ..sort((a, b) {
// //                           if (a.year != b.year) return b.year.compareTo(a.year);
// //                           return b.month.compareTo(a.month);
// //                         })),
// //                   builder: (context, snap) {
// //                     if (snap.connectionState == ConnectionState.waiting) {
// //                       return const Center(child: CircularProgressIndicator());
// //                     }

// //                     final payments = snap.data ?? [];

// //                     if (payments.isEmpty) {
// //                       return Center(
// //                         child: Column(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             Icon(Icons.receipt_long_outlined, size: 80,
// //                                 color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
// //                             const SizedBox(height: 16),
// //                             const Text('কোনো ভাড়ার রেকর্ড নেই',
// //                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// //                           ],
// //                         ),
// //                       );
// //                     }

// //                     // Summary
// //                     final paid = payments.where((p) => p.status == PaymentStatus.paid).length;
// //                     final pending = payments.where((p) => p.status == PaymentStatus.pending).length;
// //                     final totalPaid = payments
// //                         .where((p) => p.status == PaymentStatus.paid)
// //                         .fold(0.0, (sum, p) => sum + p.amount);

// //                     return Column(
// //                       children: [
// //                         // Summary bar
// //                         Container(
// //                           margin: const EdgeInsets.all(16),
// //                           padding: const EdgeInsets.all(16),
// //                           decoration: BoxDecoration(
// //                             color: Theme.of(context).colorScheme.primary,
// //                             borderRadius: BorderRadius.circular(16),
// //                           ),
// //                           child: Row(
// //                             children: [
// //                               _summaryItem('মোট পরিশোধ', '৳${totalPaid.toStringAsFixed(0)}'),
// //                               Container(width: 1, height: 40, color: Colors.white24,
// //                                   margin: const EdgeInsets.symmetric(horizontal: 12)),
// //                               _summaryItem('পরিশোধিত', '$paid মাস'),
// //                               Container(width: 1, height: 40, color: Colors.white24,
// //                                   margin: const EdgeInsets.symmetric(horizontal: 12)),
// //                               _summaryItem('বাকি', '$pending মাস'),
// //                             ],
// //                           ),
// //                         ),

// //                         Expanded(
// //                           child: ListView.builder(
// //                             padding: const EdgeInsets.symmetric(horizontal: 16),
// //                             itemCount: payments.length,
// //                             itemBuilder: (ctx, i) {
// //                               final p = payments[i];
// //                               final isPaid = p.status == PaymentStatus.paid;
// //                               final isSubmitted = p.status == PaymentStatus.submitted;
// //                               final isRejected = p.status == PaymentStatus.rejected;

// //                               return Card(
// //                                 margin: const EdgeInsets.only(bottom: 10),
// //                                 child: Padding(
// //                                   padding: const EdgeInsets.all(14),
// //                                   child: Column(
// //                                     crossAxisAlignment: CrossAxisAlignment.start,
// //                                     children: [
// //                                       Row(
// //                                         children: [
// //                                           Expanded(
// //                                             child: Column(
// //                                               crossAxisAlignment: CrossAxisAlignment.start,
// //                                               children: [
// //                                                 Text('${_months[p.month]} ${p.year}',
// //                                                     style: const TextStyle(
// //                                                         fontWeight: FontWeight.bold, fontSize: 15)),
// //                                                 Text('৳${p.amount.toStringAsFixed(0)}',
// //                                                     style: const TextStyle(fontSize: 14)),
// //                                               ],
// //                                             ),
// //                                           ),
// //                                           Container(
// //                                             padding: const EdgeInsets.symmetric(
// //                                                 horizontal: 10, vertical: 4),
// //                                             decoration: BoxDecoration(
// //                                               color: Color(int.parse(p.statusBgColorHex, radix: 16)),
// //                                               borderRadius: BorderRadius.circular(20),
// //                                             ),
// //                                             child: Text(p.statusLabel,
// //                                                 style: TextStyle(
// //                                                     fontSize: 11,
// //                                                     fontWeight: FontWeight.w600,
// //                                                     color: Color(int.parse(p.statusColorHex, radix: 16)))),
// //                                           ),
// //                                         ],
// //                                       ),

// //                                       // Rejection notice
// //                                       if (isRejected) ...[
// //                                         const SizedBox(height: 8),
// //                                         Container(
// //                                           padding: const EdgeInsets.all(10),
// //                                           decoration: BoxDecoration(
// //                                             color: const Color(0xFFFFEBEE),
// //                                             borderRadius: BorderRadius.circular(10),
// //                                           ),
// //                                           child: Column(
// //                                             crossAxisAlignment: CrossAxisAlignment.start,
// //                                             children: [
// //                                               const Text('পেমেন্ট বাতিল হয়েছে',
// //                                                   style: TextStyle(
// //                                                       color: Colors.red,
// //                                                       fontWeight: FontWeight.bold,
// //                                                       fontSize: 13)),
// //                                               if (p.rejectionReason != null)
// //                                                 Text('কারণ: ${p.rejectionReason}',
// //                                                     style: const TextStyle(
// //                                                         color: Colors.red, fontSize: 12)),
// //                                             ],
// //                                           ),
// //                                         ),
// //                                       ],

// //                                       // Submit button for pending/rejected
// //                                       if (!isPaid && !isSubmitted) ...[
// //                                         const SizedBox(height: 10),
// //                                         SizedBox(
// //                                           width: double.infinity,
// //                                           child: FilledButton.icon(
// //                                             onPressed: () => _showSubmitPaymentSheet(ctx, p),
// //                                             icon: const Icon(Icons.send_rounded, size: 18),
// //                                             label: Text(isRejected
// //                                                 ? 'আবার পেমেন্ট জমা দিন'
// //                                                 : 'পেমেন্ট জমা দিন'),
// //                                           ),
// //                                         ),
// //                                       ],

// //                                       // Submitted info
// //                                       if (isSubmitted) ...[
// //                                         const SizedBox(height: 8),
// //                                         Container(
// //                                           padding: const EdgeInsets.all(10),
// //                                           decoration: BoxDecoration(
// //                                             color: const Color(0xFFE3F2FD),
// //                                             borderRadius: BorderRadius.circular(10),
// //                                           ),
// //                                           child: Row(
// //                                             children: [
// //                                               const Icon(Icons.hourglass_top_rounded,
// //                                                   color: Color(0xFF1565C0), size: 18),
// //                                               const SizedBox(width: 8),
// //                                               Expanded(
// //                                                 child: Column(
// //                                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                                   children: [
// //                                                     const Text('পেমেন্ট যাচাইয়ের অপেক্ষায়',
// //                                                         style: TextStyle(
// //                                                             color: Color(0xFF1565C0),
// //                                                             fontWeight: FontWeight.bold,
// //                                                             fontSize: 13)),
// //                                                     Text(
// //                                                         'পদ্ধতি: ${p.paymentMethod} • ID: ${p.transactionId}',
// //                                                         style: const TextStyle(
// //                                                             color: Color(0xFF1565C0), fontSize: 11)),
// //                                                   ],
// //                                                 ),
// //                                               ),
// //                                             ],
// //                                           ),
// //                                         ),
// //                                       ],

// //                                       // PDF for paid
// //                                       if (isPaid) ...[
// //                                         const SizedBox(height: 8),
// //                                         Row(
// //                                           children: [
// //                                             Icon(Icons.check_circle_rounded,
// //                                                 color: Colors.green.shade700, size: 16),
// //                                             const SizedBox(width: 6),
// //                                             Text(
// //                                               'পরিশোধ: ${p.paidAt?.day}/${p.paidAt?.month}/${p.paidAt?.year}',
// //                                               style: TextStyle(
// //                                                   fontSize: 12, color: Colors.green.shade700),
// //                                             ),
// //                                             const Spacer(),
// //                                             TextButton.icon(
// //                                               onPressed: () async {
// //                                                 final pdfBytes =
// //                                                     await PdfService.generateRentReceipt(
// //                                                   payment: p,
// //                                                   landlordName: 'বাড়ীওয়ালা',
// //                                                   landlordPhone: '',
// //                                                 );
// //                                                 await PdfService.sharePdf(pdfBytes,
// //                                                     'receipt_${p.month}_${p.year}.pdf');
// //                                               },
// //                                               icon: const Icon(Icons.picture_as_pdf_rounded,
// //                                                   color: Colors.red, size: 18),
// //                                               label: const Text('Receipt',
// //                                                   style: TextStyle(color: Colors.red)),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ],
// //                                     ],
// //                                   ),
// //                                 ),
// //                               );
// //                             },
// //                           ),
// //                         ),
// //                       ],
// //                     );
// //                   },
// //                 ),
// //     );
// //   }

// //   Widget _summaryItem(String label, String value) {
// //     return Expanded(
// //       child: Column(
// //         children: [
// //           Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
// //           Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
// //         ],
// //       ),
// //     );
// //   }
// // }






// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../models/payment_model.dart';
// import '../../../models/user_model.dart';
// import '../../../services/pdf_service.dart';
// import '../../../services/payment_service.dart';

// class TenantPaymentScreen extends StatefulWidget {
//   final UserModel user;
//   final GlobalKey<ScaffoldState>? scaffoldKey;
//   const TenantPaymentScreen({super.key, required this.user, this.scaffoldKey});

//   @override
//   State<TenantPaymentScreen> createState() => _TenantPaymentScreenState();
// }

// class _TenantPaymentScreenState extends State<TenantPaymentScreen> {
//   String? _tenantId;
//   bool _loading = true;

//   final List<String> _months = [
//     '',
//     'জানুয়ারি',
//     'ফেব্রুয়ারি',
//     'মার্চ',
//     'এপ্রিল',
//     'মে',
//     'জুন',
//     'জুলাই',
//     'আগস্ট',
//     'সেপ্টেম্বর',
//     'অক্টোবর',
//     'নভেম্বর',
//     'ডিসেম্বর'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadTenantId();
//   }

//   Future<void> _loadTenantId() async {
//     final snap = await FirebaseFirestore.instance
//         .collection('tenants')
//         .where('email', isEqualTo: widget.user.email)
//         .where('isActive', isEqualTo: true)
//         .get();

//     if (snap.docs.isNotEmpty) {
//       setState(() {
//         _tenantId = snap.docs.first.id;
//         _loading = false;
//       });
//     } else {
//       setState(() => _loading = false);
//     }
//   }

//   void _showSubmitPaymentSheet(BuildContext context, PaymentModel payment) {
//     final transactionCtrl = TextEditingController();
//     final noteCtrl = TextEditingController();
//     String selectedMethod = 'bKash';
//     final formKey = GlobalKey<FormState>();

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (ctx) => StatefulBuilder(
//         builder: (ctx, setModalState) => Padding(
//           padding: EdgeInsets.only(
//             left: 20,
//             right: 20,
//             top: 20,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//           ),
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('পেমেন্ট জমা দিন',
//                     style:
//                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 4),
//                 Text(
//                     '${payment.monthName} ${payment.year} — ৳${payment.amount.toStringAsFixed(0)}',
//                     style: const TextStyle(color: Colors.grey)),
//                 const SizedBox(height: 16),
//                 const Text('পেমেন্ট পদ্ধতি',
//                     style:
//                         TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   children: ['bKash', 'Nagad', 'Rocket', 'Bank', 'Cash']
//                       .map((method) => ChoiceChip(
//                             label: Text(method),
//                             selected: selectedMethod == method,
//                             onSelected: (_) =>
//                                 setModalState(() => selectedMethod = method),
//                           ))
//                       .toList(),
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: transactionCtrl,
//                   decoration: InputDecoration(
//                     labelText: selectedMethod == 'Cash'
//                         ? 'রসিদ নম্বর (যদি থাকে)'
//                         : 'Transaction ID',
//                     hintText:
//                         selectedMethod == 'Cash' ? 'Optional' : 'যেমন: TXN123456',
//                   ),
//                   validator: (v) {
//                     if (selectedMethod != 'Cash' && (v == null || v.isEmpty)) {
//                       return 'Transaction ID দিন';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: noteCtrl,
//                   decoration: const InputDecoration(
//                     labelText: 'নোট (optional)',
//                     hintText: 'যেকোনো অতিরিক্ত তথ্য',
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: FilledButton.icon(
//                     onPressed: () async {
//                       if (!formKey.currentState!.validate()) return;
//                       await PaymentService().submitPayment(
//                         payment.id,
//                         paymentMethod: selectedMethod,
//                         transactionId: transactionCtrl.text.trim().isEmpty
//                             ? 'Cash Payment'
//                             : transactionCtrl.text.trim(),
//                         note: noteCtrl.text.trim().isEmpty
//                             ? null
//                             : noteCtrl.text.trim(),
//                       );
//                       if (ctx.mounted) Navigator.pop(ctx);
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text(
//                                 'পেমেন্ট জমা হয়েছে। বাড়ীওয়ালার অনুমোদনের অপেক্ষায়।'),
//                             backgroundColor: Colors.blue,
//                           ),
//                         );
//                       }
//                     },
//                     icon: const Icon(Icons.send_rounded),
//                     label: const Text('পেমেন্ট জমা দিন'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final primary = Theme.of(context).colorScheme.primary;
//     final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
//     final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
//     final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

//     if (_loading) {
//       return Scaffold(
//         backgroundColor: bg,
//         body: Center(child: CircularProgressIndicator(color: primary)),
//       );
//     }

//     if (_tenantId == null) {
//       return Scaffold(
//         backgroundColor: bg,
//         body: Center(
//           child: Text('তথ্য পাওয়া যায়নি',
//               style: TextStyle(color: textSecondary)),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: bg,
//       body: StreamBuilder<List<PaymentModel>>(
//         stream: FirebaseFirestore.instance
//             .collection('payments')
//             .where('tenantId', isEqualTo: _tenantId)
//             .snapshots()
//             .map((snap) => snap.docs
//                 .map((d) => PaymentModel.fromMap(d.data(), d.id))
//                 .toList()
//               ..sort((a, b) {
//                 if (a.year != b.year) return b.year.compareTo(a.year);
//                 return b.month.compareTo(a.month);
//               })),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator(color: primary));
//           }

//           final payments = snap.data ?? [];

//           // Summary stats
//           final paid =
//               payments.where((p) => p.status == PaymentStatus.paid).length;
//           final pending =
//               payments.where((p) => p.status == PaymentStatus.pending).length;
//           final totalPaid = payments
//               .where((p) => p.status == PaymentStatus.paid)
//               .fold(0.0, (sum, p) => sum + p.amount);

//           return CustomScrollView(
//             physics: const BouncingScrollPhysics(),
//             slivers: [
//               // ── Collapsing AppBar ─────────────────────────────────
//               SliverAppBar(
//                 expandedHeight: 200,
//                 collapsedHeight: 60,
//                 pinned: true,
//                 backgroundColor: bg,
//                 elevation: 0,
//                 leading: IconButton(
//                   icon: Icon(Icons.menu_rounded, color: textPrimary),
//                   onPressed: () =>
//                       widget.scaffoldKey?.currentState?.openDrawer(),
//                 ),
//                 title: Text('ভাড়ার ইতিহাস',
//                     style: TextStyle(
//                         color: textPrimary,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700)),
//                 centerTitle: true,
//                 flexibleSpace: FlexibleSpaceBar(
//                   background: _buildStatsHeader(
//                     primary: primary,
//                     isDark: isDark,
//                     paid: paid,
//                     pending: pending,
//                     totalPaid: totalPaid,
//                     textPrimary: textPrimary,
//                   ),
//                 ),
//               ),

//               // ── Empty State ───────────────────────────────────────
//               if (payments.isEmpty)
//                 SliverFillRemaining(
//                   child: _buildEmptyState(primary, textSecondary),
//                 )
//               else ...[
//                 // ── Payment List ──────────────────────────────────
//                 SliverPadding(
//                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
//                   sliver: SliverList(
//                     delegate: SliverChildBuilderDelegate(
//                       (ctx, i) => _PaymentCard(
//                         payment: payments[i],
//                         months: _months,
//                         isDark: isDark,
//                         primary: primary,
//                         textPrimary: textPrimary,
//                         textSecondary: textSecondary,
//                         onSubmit: () =>
//                             _showSubmitPaymentSheet(ctx, payments[i]),
//                       ),
//                       childCount: payments.length,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildStatsHeader({
//     required Color primary,
//     required bool isDark,
//     required int paid,
//     required int pending,
//     required double totalPaid,
//     required Color textPrimary,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: isDark
//               ? [const Color(0xFF1A3328), const Color(0xFF0F1A14)]
//               : [const Color(0xFFE8F5EE), const Color(0xFFF5FAF7)],
//         ),
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 65, 16, 12),
//           child: Row(
//             children: [
//               _statPill(
//                 icon: Icons.payments_rounded,
//                 label: 'মোট পরিশোধ',
//                 value: '৳${totalPaid.toStringAsFixed(0)}',
//                 color: primary,
//                 isDark: isDark,
//               ),
//               const SizedBox(width: 10),
//               _statPill(
//                 icon: Icons.check_circle_rounded,
//                 label: 'পরিশোধিত',
//                 value: '$paid মাস',
//                 color: const Color(0xFF059669),
//                 isDark: isDark,
//               ),
//               const SizedBox(width: 10),
//               _statPill(
//                 icon: Icons.pending_rounded,
//                 label: 'বাকি',
//                 value: '$pending মাস',
//                 color: const Color(0xFFD97706),
//                 isDark: isDark,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _statPill({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//     required bool isDark,
//   }) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//         decoration: BoxDecoration(
//           color: color.withOpacity(isDark ? 0.15 : 0.1),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: color.withOpacity(0.3)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: color, size: 20),
//             const SizedBox(height: 4),
//             FittedBox(
//               child: Text(value,
//                   style: TextStyle(
//                       fontSize: 13, fontWeight: FontWeight.bold, color: color)),
//             ),
//             Text(label,
//                 style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
//                 overflow: TextOverflow.ellipsis,
//                 textAlign: TextAlign.center),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState(Color primary, Color textSecondary) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 90,
//             height: 90,
//             decoration: BoxDecoration(
//                 color: primary.withOpacity(0.1), shape: BoxShape.circle),
//             child: Icon(Icons.receipt_long_outlined,
//                 size: 46, color: primary.withOpacity(0.5)),
//           ),
//           const SizedBox(height: 20),
//           const Text('কোনো ভাড়ার রেকর্ড নেই',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Text('বাড়ীওয়ালা পেমেন্ট যোগ করলে এখানে দেখাবে',
//               style: TextStyle(fontSize: 14, color: textSecondary)),
//         ],
//       ),
//     );
//   }
// }

// // ── Payment Card ──────────────────────────────────────────────────────────────

// class _PaymentCard extends StatelessWidget {
//   final PaymentModel payment;
//   final List<String> months;
//   final bool isDark;
//   final Color primary;
//   final Color textPrimary;
//   final Color textSecondary;
//   final VoidCallback onSubmit;

//   const _PaymentCard({
//     required this.payment,
//     required this.months,
//     required this.isDark,
//     required this.primary,
//     required this.textPrimary,
//     required this.textSecondary,
//     required this.onSubmit,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
//     final divColor = isDark ? Colors.white10 : const Color(0xFFE5E7EB);

//     final isPaid = payment.status == PaymentStatus.paid;
//     final isSubmitted = payment.status == PaymentStatus.submitted;
//     final isRejected = payment.status == PaymentStatus.rejected;

//     // Status colors
//     Color statusColor;
//     IconData statusIcon;
//     if (isPaid) {
//       statusColor = const Color(0xFF059669);
//       statusIcon = Icons.check_circle_rounded;
//     } else if (isSubmitted) {
//       statusColor = const Color(0xFF0891B2);
//       statusIcon = Icons.hourglass_top_rounded;
//     } else if (isRejected) {
//       statusColor = Colors.red;
//       statusIcon = Icons.cancel_rounded;
//     } else {
//       statusColor = const Color(0xFFD97706);
//       statusIcon = Icons.pending_rounded;
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: cardBg,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.06),
//               blurRadius: 12,
//               offset: const Offset(0, 4))
//         ],
//       ),
//       child: Column(
//         children: [
//           // ── Header Row ──────────────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 // Status icon
//                 Container(
//                   width: 46,
//                   height: 46,
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(isDark ? 0.15 : 0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: statusColor.withOpacity(0.3)),
//                   ),
//                   child: Icon(statusIcon, color: statusColor, size: 22),
//                 ),
//                 const SizedBox(width: 12),
//                 // Month & Amount
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '${months[payment.month]} ${payment.year}',
//                         style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                             color: textPrimary),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         '৳${payment.amount.toStringAsFixed(0)}',
//                         style: TextStyle(
//                             fontSize: 13, color: textSecondary),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Status badge
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(isDark ? 0.2 : 0.1),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: statusColor.withOpacity(0.3)),
//                   ),
//                   child: Text(
//                     payment.statusLabel,
//                     style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                         color: statusColor),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ── Detail Sections ─────────────────────────────────────

//           // Rejection reason
//           if (isRejected) ...[
//             Padding(
//               padding: const EdgeInsets.only(left: 70),
//               child: Divider(height: 1, color: divColor),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(isDark ? 0.12 : 0.06),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.red.withOpacity(0.3)),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(children: [
//                       const Icon(Icons.info_outline_rounded,
//                           color: Colors.red, size: 14),
//                       const SizedBox(width: 6),
//                       const Text('পেমেন্ট বাতিল হয়েছে',
//                           style: TextStyle(
//                               color: Colors.red,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 13)),
//                     ]),
//                     if (payment.rejectionReason != null) ...[
//                       const SizedBox(height: 4),
//                       Text('কারণ: ${payment.rejectionReason}',
//                           style: const TextStyle(
//                               color: Colors.red, fontSize: 12)),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ],

//           // Submitted info
//           if (isSubmitted) ...[
//             Padding(
//               padding: const EdgeInsets.only(left: 70),
//               child: Divider(height: 1, color: divColor),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF0891B2).withOpacity(isDark ? 0.12 : 0.06),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                       color: const Color(0xFF0891B2).withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.hourglass_top_rounded,
//                         color: Color(0xFF0891B2), size: 16),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('পেমেন্ট যাচাইয়ের অপেক্ষায়',
//                               style: TextStyle(
//                                   color: Color(0xFF0891B2),
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 13)),
//                           Text(
//                               'পদ্ধতি: ${payment.paymentMethod} • ID: ${payment.transactionId}',
//                               style: const TextStyle(
//                                   color: Color(0xFF0891B2), fontSize: 11)),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],

//           // Paid info + PDF
//           if (isPaid) ...[
//             Padding(
//               padding: const EdgeInsets.only(left: 70),
//               child: Divider(height: 1, color: divColor),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
//               child: Row(
//                 children: [
//                   Icon(Icons.check_circle_rounded,
//                       color: const Color(0xFF059669), size: 15),
//                   const SizedBox(width: 6),
//                   Text(
//                     'পরিশোধ: ${payment.paidAt?.day}/${payment.paidAt?.month}/${payment.paidAt?.year}',
//                     style: const TextStyle(
//                         fontSize: 12, color: Color(0xFF059669)),
//                   ),
//                   const Spacer(),
//                   TextButton.icon(
//                     onPressed: () async {
//                       final pdfBytes =
//                           await PdfService.generateRentReceipt(
//                         payment: payment,
//                         landlordName: 'বাড়ীওয়ালা',
//                         landlordPhone: '',
//                       );
//                       await PdfService.sharePdf(pdfBytes,
//                           'receipt_${payment.month}_${payment.year}.pdf');
//                     },
//                     style: TextButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 6)),
//                     icon: const Icon(Icons.picture_as_pdf_rounded,
//                         color: Colors.red, size: 16),
//                     label: const Text('Receipt',
//                         style: TextStyle(
//                             color: Colors.red,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 13)),
//                   ),
//                 ],
//               ),
//             ),
//           ],

//           // Submit button
//           if (!isPaid && !isSubmitted) ...[
//             Padding(
//               padding: const EdgeInsets.only(left: 70),
//               child: Divider(height: 1, color: divColor),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 42,
//                 child: FilledButton.icon(
//                   onPressed: onSubmit,
//                   icon: const Icon(Icons.send_rounded, size: 16),
//                   label: Text(
//                     isRejected ? 'আবার পেমেন্ট জমা দিন' : 'পেমেন্ট জমা দিন',
//                     style: const TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                   style: FilledButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10)),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }







import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/payment_model.dart';
import '../../../models/user_model.dart';
import '../../../services/pdf_service.dart';
import '../../../services/payment_service.dart';
// import '../../../services/email_service.dart';
 
class TenantPaymentScreen extends StatefulWidget {
  final UserModel user;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const TenantPaymentScreen({super.key, required this.user, this.scaffoldKey});
 
  @override
  State<TenantPaymentScreen> createState() => _TenantPaymentScreenState();
}
 
class _TenantPaymentScreenState extends State<TenantPaymentScreen> {
  String? _tenantId;
  bool _loading = true;
 
  final List<String> _months = [
    '',
    'জানুয়ারি',
    'ফেব্রুয়ারি',
    'মার্চ',
    'এপ্রিল',
    'মে',
    'জুন',
    'জুলাই',
    'আগস্ট',
    'সেপ্টেম্বর',
    'অক্টোবর',
    'নভেম্বর',
    'ডিসেম্বর'
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
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('পেমেন্ট জমা দিন',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                    '${payment.monthName} ${payment.year} — ৳${payment.amount.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                const Text('পেমেন্ট পদ্ধতি',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                    hintText:
                        selectedMethod == 'Cash' ? 'Optional' : 'যেমন: TXN123456',
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
 
                      // Payment confirmation email পাঠাও
                      // if (widget.user.email.isNotEmpty) {
                      //   EmailService.sendPaymentSubmittedEmail(
                      //     toName: widget.user.name,
                      //     toEmail: widget.user.email,
                      //     monthName: payment.monthName,
                      //     year: payment.year,
                      //     amount: payment.amount,
                      //     propertyName: payment.propertyName,
                      //     roomNumber: payment.roomNumber,
                      //     paymentMethod: selectedMethod,
                      //     transactionId: transactionCtrl.text.trim().isEmpty
                      //         ? 'Cash Payment'
                      //         : transactionCtrl.text.trim(),
                      //   );
                      // }
 
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
 
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);
 
    if (_loading) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(child: CircularProgressIndicator(color: primary)),
      );
    }
 
    if (_tenantId == null) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Text('তথ্য পাওয়া যায়নি',
              style: TextStyle(color: textSecondary)),
        ),
      );
    }
 
    return Scaffold(
      backgroundColor: bg,
      body: StreamBuilder<List<PaymentModel>>(
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
            return Center(child: CircularProgressIndicator(color: primary));
          }
 
          final payments = snap.data ?? [];
 
          // Summary stats
          final paid =
              payments.where((p) => p.status == PaymentStatus.paid).length;
          final pending =
              payments.where((p) => p.status == PaymentStatus.pending).length;
          final totalPaid = payments
              .where((p) => p.status == PaymentStatus.paid)
              .fold(0.0, (sum, p) => sum + p.amount);
 
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Collapsing AppBar ─────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                collapsedHeight: 60,
                pinned: true,
                backgroundColor: bg,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.menu_rounded, color: textPrimary),
                  onPressed: () =>
                      widget.scaffoldKey?.currentState?.openDrawer(),
                ),
                title: Text('ভাড়ার ইতিহাস',
                    style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildStatsHeader(
                    primary: primary,
                    isDark: isDark,
                    paid: paid,
                    pending: pending,
                    totalPaid: totalPaid,
                    textPrimary: textPrimary,
                  ),
                ),
              ),
 
              // ── Empty State ───────────────────────────────────────
              if (payments.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(primary, textSecondary),
                )
              else ...[
                // ── Payment List ──────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _PaymentCard(
                        payment: payments[i],
                        months: _months,
                        isDark: isDark,
                        primary: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onSubmit: () =>
                            _showSubmitPaymentSheet(ctx, payments[i]),
                      ),
                      childCount: payments.length,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
 
  Widget _buildStatsHeader({
    required Color primary,
    required bool isDark,
    required int paid,
    required int pending,
    required double totalPaid,
    required Color textPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A3328), const Color(0xFF0F1A14)]
              : [const Color(0xFFE8F5EE), const Color(0xFFF5FAF7)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 65, 16, 12),
          child: Row(
            children: [
              _statPill(
                icon: Icons.payments_rounded,
                label: 'মোট পরিশোধ',
                value: '৳${totalPaid.toStringAsFixed(0)}',
                color: primary,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _statPill(
                icon: Icons.check_circle_rounded,
                label: 'পরিশোধিত',
                value: '$paid মাস',
                color: const Color(0xFF059669),
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _statPill(
                icon: Icons.pending_rounded,
                label: 'বাকি',
                value: '$pending মাস',
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
              child: Text(value,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: color)),
            ),
            Text(label,
                style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
 
  Widget _buildEmptyState(Color primary, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
                color: primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.receipt_long_outlined,
                size: 46, color: primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          const Text('কোনো ভাড়ার রেকর্ড নেই',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('বাড়ীওয়ালা পেমেন্ট যোগ করলে এখানে দেখাবে',
              style: TextStyle(fontSize: 14, color: textSecondary)),
        ],
      ),
    );
  }
}
 
// ── Payment Card ──────────────────────────────────────────────────────────────
 
class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final List<String> months;
  final bool isDark;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onSubmit;
 
  const _PaymentCard({
    required this.payment,
    required this.months,
    required this.isDark,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    required this.onSubmit,
  });
 
  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final divColor = isDark ? Colors.white10 : const Color(0xFFE5E7EB);
 
    final isPaid = payment.status == PaymentStatus.paid;
    final isSubmitted = payment.status == PaymentStatus.submitted;
    final isRejected = payment.status == PaymentStatus.rejected;
 
    // Status colors
    Color statusColor;
    IconData statusIcon;
    if (isPaid) {
      statusColor = const Color(0xFF059669);
      statusIcon = Icons.check_circle_rounded;
    } else if (isSubmitted) {
      statusColor = const Color(0xFF0891B2);
      statusIcon = Icons.hourglass_top_rounded;
    } else if (isRejected) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel_rounded;
    } else {
      statusColor = const Color(0xFFD97706);
      statusIcon = Icons.pending_rounded;
    }
 
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // ── Header Row ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                // Month & Amount
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${months[payment.month]} ${payment.year}',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '৳${payment.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 13, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    payment.statusLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor),
                  ),
                ),
              ],
            ),
          ),
 
          // ── Detail Sections ─────────────────────────────────────
 
          // Rejection reason
          if (isRejected) ...[
            Padding(
              padding: const EdgeInsets.only(left: 70),
              child: Divider(height: 1, color: divColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(isDark ? 0.12 : 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Colors.red, size: 14),
                      const SizedBox(width: 6),
                      const Text('পেমেন্ট বাতিল হয়েছে',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ]),
                    if (payment.rejectionReason != null) ...[
                      const SizedBox(height: 4),
                      Text('কারণ: ${payment.rejectionReason}',
                          style: const TextStyle(
                              color: Colors.red, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
          ],
 
          // Submitted info
          if (isSubmitted) ...[
            Padding(
              padding: const EdgeInsets.only(left: 70),
              child: Divider(height: 1, color: divColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0891B2).withOpacity(isDark ? 0.12 : 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF0891B2).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_top_rounded,
                        color: Color(0xFF0891B2), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('পেমেন্ট যাচাইয়ের অপেক্ষায়',
                              style: TextStyle(
                                  color: Color(0xFF0891B2),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          Text(
                              'পদ্ধতি: ${payment.paymentMethod} • ID: ${payment.transactionId}',
                              style: const TextStyle(
                                  color: Color(0xFF0891B2), fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
 
          // Paid info + PDF
          if (isPaid) ...[
            Padding(
              padding: const EdgeInsets.only(left: 70),
              child: Divider(height: 1, color: divColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: const Color(0xFF059669), size: 15),
                  const SizedBox(width: 6),
                  Text(
                    'পরিশোধ: ${payment.paidAt?.day}/${payment.paidAt?.month}/${payment.paidAt?.year}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF059669)),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      final pdfBytes =
                          await PdfService.generateRentReceipt(
                        payment: payment,
                        landlordName: 'বাড়ীওয়ালা',
                        landlordPhone: '',
                      );
                      await PdfService.sharePdf(pdfBytes,
                          'receipt_${payment.month}_${payment.year}.pdf');
                    },
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6)),
                    icon: const Icon(Icons.picture_as_pdf_rounded,
                        color: Colors.red, size: 16),
                    label: const Text('Receipt',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
 
          // Submit button
          if (!isPaid && !isSubmitted) ...[
            Padding(
              padding: const EdgeInsets.only(left: 70),
              child: Divider(height: 1, color: divColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: FilledButton.icon(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: Text(
                    isRejected ? 'আবার পেমেন্ট জমা দিন' : 'পেমেন্ট জমা দিন',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}












