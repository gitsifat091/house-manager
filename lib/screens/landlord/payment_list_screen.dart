// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../services/auth_service.dart';
// import '../../services/payment_service.dart';
// import '../../services/tenant_service.dart';
// import '../../models/payment_model.dart';
// import '../../models/tenant_model.dart';
// import 'package:provider/provider.dart';
// import '../../../services/auth_service.dart';
// import '../../../services/pdf_service.dart';
// import '../shared/notification_screen.dart';
// import '../../../widgets/tenant_avatar.dart';
// import 'tenant_detail_screen.dart';

// class PaymentListScreen extends StatefulWidget {
//   final GlobalKey<ScaffoldState>? scaffoldKey;
//   const PaymentListScreen({super.key, this.scaffoldKey});

//   @override
//   State<PaymentListScreen> createState() => _PaymentListScreenState();
// }

// class _PaymentListScreenState extends State<PaymentListScreen> {
//   int _selectedMonth = DateTime.now().month;
//   int _selectedYear = DateTime.now().year;
//   bool _generating = false;

//   final List<String> _months = [
//     '', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
//     'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর',
//     'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
//   ];

//   Future<void> _generatePayments(String landlordId) async {
//     setState(() => _generating = true);

//     try {
//       // Get active tenants
//       final snap = await FirebaseFirestore.instance
//           .collection('tenants')
//           .where('landlordId', isEqualTo: landlordId)
//           .where('isActive', isEqualTo: true)
//           .get();

//       final tenants = snap.docs
//           .map((d) => TenantModel.fromMap(d.data(), d.id))
//           .toList();

//       if (tenants.isEmpty) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('কোনো active ভাড়াটিয়া নেই')),
//           );
//         }
//         return;
//       }

//       await PaymentService().generateMonthlyPayments(
//           landlordId, tenants, _selectedMonth, _selectedYear);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 '${_months[_selectedMonth]} $_selectedYear এর payment তৈরি হয়েছে'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _generating = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = context.read<AuthService>().currentUser!;
//     final service = PaymentService();

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.menu_rounded),
//           // onPressed: () => widget.scaffoldKey?.currentState?.openDrawer(),

//           onPressed: () {
//           final now = DateTime.now();
//           if (_selectedYear > now.year ||
//               (_selectedYear == now.year && _selectedMonth > now.month)) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('ভবিষ্যৎ মাসের payment তৈরি করা যাবে না'),
//                 backgroundColor: Colors.orange,
//               ),
//             );
//             return;
//           }
//           _generatePayments(user.uid);
//         },

//         ),
//         title: const Text('ভাড়া সংগ্রহ'),
//         centerTitle: true,
//         actions: [
//           NotificationBell(userId: user.uid),
//           _generating
//               ? const Padding(
//                   padding: EdgeInsets.all(16),
//                   child: SizedBox(
//                       width: 20, height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2)),
//                 )
//               : IconButton(
//                   icon: const Icon(Icons.add_card_rounded),
//                   tooltip: 'এই মাসের payment তৈরি করুন',
//                   onPressed: () => _generatePayments(user.uid),
//                 ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Month/Year selector
//           Container(
//             margin: const EdgeInsets.all(16),
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.surfaceVariant,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.chevron_left_rounded),
//                   onPressed: () {
//                     setState(() {
//                       if (_selectedMonth == 1) {
//                         _selectedMonth = 12;
//                         _selectedYear--;
//                       } else {
//                         _selectedMonth--;
//                       }
//                     });
//                   },
//                 ),
//                 Expanded(
//                   child: Center(
//                     child: Text(
//                       '${_months[_selectedMonth]} $_selectedYear',
//                       style: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.chevron_right_rounded),
//                   onPressed: () {
//                     setState(() {
//                       if (_selectedMonth == 12) {
//                         _selectedMonth = 1;
//                         _selectedYear++;
//                       } else {
//                         _selectedMonth++;
//                       }
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),

//           // Summary
//           _SummaryBar(
//             landlordId: user.uid,
//             month: _selectedMonth,
//             year: _selectedYear,
//             service: service,
//           ),

//           // Payment list
//           Expanded(
//             child: StreamBuilder<List<PaymentModel>>(
//               stream: service.getPayments(user.uid),
//               builder: (context, snap) {
//                 if (snap.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final all = snap.data ?? [];
//                 final payments = all
//                     .where((p) =>
//                         p.month == _selectedMonth && p.year == _selectedYear)
//                     .toList();

//                 if (payments.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.receipt_long_outlined,
//                             size: 80,
//                             color: Theme.of(context)
//                                 .colorScheme
//                                 .primary
//                                 .withOpacity(0.3)),
//                         const SizedBox(height: 16),
//                         const Text('এই মাসের কোনো payment নেই',
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 8),
//                         const Text('উপরের + বাটন চাপুন'),
//                       ],
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   itemCount: payments.length,
//                   itemBuilder: (ctx, i) => _PaymentCard(
//                     payment: payments[i],
//                     service: service,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SummaryBar extends StatelessWidget {
//   final String landlordId;
//   final int month;
//   final int year;
//   final PaymentService service;

//   const _SummaryBar({
//     required this.landlordId,
//     required this.month,
//     required this.year,
//     required this.service,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<PaymentModel>>(
//       stream: service.getPayments(landlordId),
//       builder: (context, snap) {
//         final all = snap.data ?? [];
//         final payments = all.where((p) => p.month == month && p.year == year).toList();

//         double totalPaid = 0;
//         double totalPending = 0;
//         int paidCount = 0;
//         int pendingCount = 0;

//         for (final p in payments) {
//           if (p.status == PaymentStatus.paid) {
//             totalPaid += p.amount;
//             paidCount++;
//           } else {
//             totalPending += p.amount;
//             pendingCount++;
//           }
//         }

//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Row(
//             children: [
//               Expanded(
//                 child: _StatCard(
//                   label: 'পেয়েছি',
//                   value: '৳${totalPaid.toStringAsFixed(0)}',
//                   sub: '$paidCount জন',
//                   color: Colors.green,
//                   icon: Icons.check_circle_rounded,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _StatCard(
//                   label: 'বাকি আছে',
//                   value: '৳${totalPending.toStringAsFixed(0)}',
//                   sub: '$pendingCount জন',
//                   color: Colors.orange,
//                   icon: Icons.pending_rounded,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final String label;
//   final String value;
//   final String sub;
//   final Color color;
//   final IconData icon;

//   const _StatCard({
//     required this.label,
//     required this.value,
//     required this.sub,
//     required this.color,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 28),
//           const SizedBox(width: 10),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label,
//                   style: TextStyle(
//                       fontSize: 12,
//                       color: color,
//                       fontWeight: FontWeight.w500)),
//               Text(value,
//                   style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: color)),
//               Text(sub,
//                   style: TextStyle(fontSize: 11, color: color.withOpacity(0.7))),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // class _PaymentCard extends StatelessWidget {
// //   final PaymentModel payment;
// //   final PaymentService service;
// //   const _PaymentCard({required this.payment, required this.service});

// //   @override
// //   Widget build(BuildContext context) {
// //     final color = Theme.of(context).colorScheme;

// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 10),
// //       child: Padding(
// //         padding: const EdgeInsets.all(14),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(
// //               children: [
// //                 // CircleAvatar(
// //                 //   radius: 22,
// //                 //   backgroundColor: Color(int.parse(payment.statusBgColorHex, radix: 16)),
// //                 //   child: Text(
// //                 //     payment.tenantName.isNotEmpty
// //                 //         ? payment.tenantName[0].toUpperCase()
// //                 //         : '?',
// //                 //     style: TextStyle(
// //                 //         fontWeight: FontWeight.bold,
// //                 //         color: Color(int.parse(payment.statusColorHex, radix: 16))),
// //                 //   ),
// //                 // ),
// //                 TenantAvatar(
// //                   tenantName: payment.tenantName,
// //                   tenantEmail: '', // payment এ email নেই, name দিয়ে fallback
// //                   radius: 22,
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(payment.tenantName,
// //                           style: const TextStyle(
// //                               fontSize: 15, fontWeight: FontWeight.bold)),
// //                       Text('${payment.propertyName} • রুম ${payment.roomNumber}',
// //                           style: TextStyle(
// //                               fontSize: 12,
// //                               color: color.onSurface.withOpacity(0.6))),
// //                     ],
// //                   ),
// //                 ),
// //                 // Status badge
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(
// //                       horizontal: 10, vertical: 4),
// //                   decoration: BoxDecoration(
// //                     color: Color(int.parse(payment.statusBgColorHex, radix: 16)),
// //                     borderRadius: BorderRadius.circular(20),
// //                   ),
// //                   child: Text(payment.statusLabel,
// //                       style: TextStyle(
// //                           fontSize: 11,
// //                           fontWeight: FontWeight.w600,
// //                           color: Color(int.parse(payment.statusColorHex, radix: 16)))),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 10),

// //             // Amount
// //             Text('৳${payment.amount.toStringAsFixed(0)}',
// //                 style: const TextStyle(
// //                     fontSize: 18, fontWeight: FontWeight.bold)),

// //             // Submitted payment details
// //             if (payment.status == PaymentStatus.submitted) ...[
// //               const SizedBox(height: 8),
// //               Container(
// //                 padding: const EdgeInsets.all(12),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFFE3F2FD),
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     const Text('পেমেন্টের তথ্য',
// //                         style: TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             color: Color(0xFF1565C0),
// //                             fontSize: 13)),
// //                     const SizedBox(height: 6),
// //                     _infoRow('পদ্ধতি', payment.paymentMethod ?? ''),
// //                     _infoRow('Transaction ID', payment.transactionId ?? ''),
// //                     if (payment.note != null && payment.note!.isNotEmpty)
// //                       _infoRow('নোট', payment.note!),
// //                     if (payment.submittedAt != null)
// //                       _infoRow('জমা দেওয়া হয়েছে',
// //                           '${payment.submittedAt!.day}/${payment.submittedAt!.month}/${payment.submittedAt!.year}'),
// //                   ],
// //                 ),
// //               ),
// //               const SizedBox(height: 10),
// //               // Approve / Reject buttons
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: OutlinedButton.icon(
// //                       onPressed: () => _rejectPayment(context),
// //                       icon: const Icon(Icons.close_rounded,
// //                           color: Colors.red, size: 18),
// //                       label: const Text('বাতিল',
// //                           style: TextStyle(color: Colors.red)),
// //                       style: OutlinedButton.styleFrom(
// //                           side: const BorderSide(color: Colors.red)),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 8),
// //                   Expanded(
// //                     child: FilledButton.icon(
// //                       onPressed: () => _approvePayment(context),
// //                       icon: const Icon(Icons.check_rounded, size: 18),
// //                       label: const Text('অনুমোদন'),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],

// //             // Rejection reason
// //             if (payment.status == PaymentStatus.rejected &&
// //                 payment.rejectionReason != null) ...[
// //               const SizedBox(height: 8),
// //               Container(
// //                 padding: const EdgeInsets.all(10),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFFFFEBEE),
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     const Icon(Icons.info_outline,
// //                         color: Colors.red, size: 16),
// //                     const SizedBox(width: 8),
// //                     Expanded(
// //                       child: Text('কারণ: ${payment.rejectionReason}',
// //                           style: const TextStyle(
// //                               color: Colors.red, fontSize: 13)),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               SizedBox(
// //                 width: double.infinity,
// //                 child: TextButton(
// //                   onPressed: () => service.markAsPending(payment.id),
// //                   child: const Text('Pending এ ফিরিয়ে দিন'),
// //                 ),
// //               ),
// //             ],

// //             // Paid info
// //             if (payment.status == PaymentStatus.paid) ...[
// //               const SizedBox(height: 6),
// //               Row(
// //                 children: [
// //                   Icon(Icons.check_circle_rounded,
// //                       color: Colors.green.shade700, size: 16),
// //                   const SizedBox(width: 6),
// //                   Text(
// //                     'পরিশোধ: ${payment.paidAt?.day}/${payment.paidAt?.month}/${payment.paidAt?.year}',
// //                     style: TextStyle(
// //                         fontSize: 12, color: Colors.green.shade700),
// //                   ),
// //                   const Spacer(),
// //                   IconButton(
// //                     icon: const Icon(Icons.picture_as_pdf_rounded,
// //                         color: Colors.red, size: 20),
// //                     onPressed: () => _downloadReceipt(context),
// //                     tooltip: 'Receipt',
// //                   ),
// //                   IconButton(
// //                     icon: Icon(Icons.undo_rounded,
// //                         color: color.onSurface.withOpacity(0.4), size: 20),
// //                     onPressed: () => service.markAsPending(payment.id),
// //                     tooltip: 'Pending এ নিন',
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _infoRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 3),
// //       child: Row(
// //         children: [
// //           Text('$label: ',
// //               style: const TextStyle(
// //                   fontSize: 12,
// //                   fontWeight: FontWeight.w500,
// //                   color: Color(0xFF1565C0))),
// //           Expanded(
// //             child: Text(value,
// //                 style: const TextStyle(
// //                     fontSize: 12, color: Color(0xFF1565C0))),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Future<void> _approvePayment(BuildContext context) async {
// //     final confirm = await showDialog<bool>(
// //       context: context,
// //       builder: (_) => AlertDialog(
// //         title: const Text('পেমেন্ট অনুমোদন'),
// //         content: Text(
// //             '${payment.tenantName} এর ৳${payment.amount.toStringAsFixed(0)} পেমেন্ট অনুমোদন করবেন?'),
// //         actions: [
// //           TextButton(
// //               onPressed: () => Navigator.pop(context, false),
// //               child: const Text('না')),
// //           FilledButton(
// //               onPressed: () => Navigator.pop(context, true),
// //               child: const Text('অনুমোদন করুন')),
// //         ],
// //       ),
// //     );
// //     if (confirm == true) await service.approvePayment(payment.id);
// //   }

// //   Future<void> _rejectPayment(BuildContext context) async {
// //     final reasonCtrl = TextEditingController();
// //     final confirm = await showDialog<bool>(
// //       context: context,
// //       builder: (_) => AlertDialog(
// //         title: const Text('পেমেন্ট বাতিল'),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Text('${payment.tenantName} এর পেমেন্ট বাতিলের কারণ লিখুন:'),
// //             const SizedBox(height: 12),
// //             TextField(
// //               controller: reasonCtrl,
// //               decoration: const InputDecoration(
// //                 hintText: 'যেমন: Transaction ID সঠিক নয়',
// //               ),
// //             ),
// //           ],
// //         ),
// //         actions: [
// //           TextButton(
// //               onPressed: () => Navigator.pop(context, false),
// //               child: const Text('না')),
// //           FilledButton(
// //             onPressed: () => Navigator.pop(context, true),
// //             style: FilledButton.styleFrom(backgroundColor: Colors.red),
// //             child: const Text('বাতিল করুন'),
// //           ),
// //         ],
// //       ),
// //     );
// //     if (confirm == true) {
// //       await service.rejectPayment(payment.id,
// //           reasonCtrl.text.trim().isEmpty
// //               ? 'কারণ উল্লেখ করা হয়নি'
// //               : reasonCtrl.text.trim());
// //     }
// //   }

// //   Future<void> _downloadReceipt(BuildContext context) async {
// //     try {
// //       final user = context.read<AuthService>().currentUser!;
// //       final pdfBytes = await PdfService.generateRentReceipt(
// //         payment: payment,
// //         landlordName: user.name,
// //         landlordPhone: user.phone,
// //       );
// //       await PdfService.sharePdf(pdfBytes,
// //           'receipt_${payment.tenantName}_${payment.month}_${payment.year}.pdf');
// //     } catch (e) {
// //       if (context.mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
// //         );
// //       }
// //     }
// //   }
// // }




// class _PaymentCard extends StatelessWidget {
//   final PaymentModel payment;
//   final PaymentService service;
//   const _PaymentCard({required this.payment, required this.service});

//   Future<TenantModel?> _getTenant() async {
//     final snap = await FirebaseFirestore.instance
//         .collection('tenants')
//         .where('name', isEqualTo: payment.tenantName)
//         .where('roomNumber', isEqualTo: payment.roomNumber)
//         .limit(1)
//         .get();
//     if (snap.docs.isEmpty) return null;
//     return TenantModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
//   }

//   String _formatDateTime(DateTime? dt) {
//     if (dt == null) return '';
//     final h = dt.hour.toString().padLeft(2, '0');
//     final m = dt.minute.toString().padLeft(2, '0');
//     return '${dt.day}/${dt.month}/${dt.year}  $h:$m';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     final isPaid = payment.status == PaymentStatus.paid;
//     final isPending = payment.status == PaymentStatus.pending;
//     final isSubmitted = payment.status == PaymentStatus.submitted;
//     final isRejected = payment.status == PaymentStatus.rejected;

//     return GestureDetector(
//       onTap: () async {
//         final tenant = await _getTenant();
//         if (tenant != null && context.mounted) {
//           Navigator.push(context, MaterialPageRoute(
//             builder: (_) => TenantDetailScreen(tenant: tenant),
//           ));
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           color: color.surface,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(14),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── Header row ──────────────────────────────────
//               Row(
//                 children: [
//                   TenantAvatar(
//                     tenantName: payment.tenantName,
//                     tenantEmail: payment.tenantName, // fallback
//                     radius: 24,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(payment.tenantName,
//                             style: const TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 2),
//                         Text(
//                           '${payment.propertyName} • রুম ${payment.roomNumber}',
//                           style: TextStyle(
//                               fontSize: 12,
//                               color: color.onSurface.withOpacity(0.55)),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Status badge
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 5),
//                     decoration: BoxDecoration(
//                       color: Color(int.parse(
//                           payment.statusBgColorHex,
//                           radix: 16)),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       payment.statusLabel,
//                       style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w600,
//                           color: Color(int.parse(
//                               payment.statusColorHex,
//                               radix: 16))),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 12),
//               // ── Amount ──────────────────────────────────────
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: color.primary.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       '৳${payment.amount.toStringAsFixed(0)}',
//                       style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: color.primary),
//                     ),
//                   ),
//                 ],
//               ),

//               // ── Paid info ───────────────────────────────────
//               if (isPaid) ...[
//                 const SizedBox(height: 10),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 12, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.check_circle_rounded,
//                           color: Colors.green.shade600, size: 16),
//                       const SizedBox(width: 6),
//                       Text(
//                         'পরিশোধ: ${_formatDateTime(payment.paidAt)}',
//                         style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.green.shade700,
//                             fontWeight: FontWeight.w500),
//                       ),
//                       const Spacer(),
//                       GestureDetector(
//                         onTap: () => _downloadReceipt(context),
//                         child: Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: BoxDecoration(
//                             color: Colors.red.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(Icons.picture_as_pdf_rounded,
//                               color: Colors.red, size: 18),
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       GestureDetector(
//                         onTap: () => service.markAsPending(payment.id),
//                         child: Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: BoxDecoration(
//                             color: color.onSurface.withOpacity(0.06),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Icon(Icons.undo_rounded,
//                               color: color.onSurface.withOpacity(0.4),
//                               size: 18),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],

//               // ── Submitted details ────────────────────────────
//               if (isSubmitted) ...[
//                 const SizedBox(height: 10),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE3F2FD),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Row(
//                         children: [
//                           Icon(Icons.info_outline,
//                               color: Color(0xFF1565C0), size: 15),
//                           SizedBox(width: 6),
//                           Text('পেমেন্টের তথ্য',
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF1565C0),
//                                   fontSize: 13)),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       _infoRow('পদ্ধতি', payment.paymentMethod ?? ''),
//                       _infoRow('Transaction ID',
//                           payment.transactionId ?? ''),
//                       if (payment.note != null &&
//                           payment.note!.isNotEmpty)
//                         _infoRow('নোট', payment.note!),
//                       if (payment.submittedAt != null)
//                         _infoRow('জমা',
//                             _formatDateTime(payment.submittedAt)),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () => _rejectPayment(context),
//                         icon: const Icon(Icons.close_rounded,
//                             color: Colors.red, size: 18),
//                         label: const Text('বাতিল',
//                             style: TextStyle(color: Colors.red)),
//                         style: OutlinedButton.styleFrom(
//                           side: const BorderSide(color: Colors.red),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: FilledButton.icon(
//                         onPressed: () => _approvePayment(context),
//                         icon: const Icon(Icons.check_rounded, size: 18),
//                         label: const Text('অনুমোদন'),
//                         style: FilledButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],

//               // ── Rejected reason ─────────────────────────────
//               if (isRejected &&
//                   payment.rejectionReason != null) ...[
//                 const SizedBox(height: 10),
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.07),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                         color: Colors.red.withOpacity(0.2)),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.cancel_outlined,
//                           color: Colors.red, size: 16),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           'কারণ: ${payment.rejectionReason}',
//                           style: const TextStyle(
//                               color: Colors.red, fontSize: 12),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton(
//                     onPressed: () =>
//                         service.markAsPending(payment.id),
//                     style: OutlinedButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                     ),
//                     child: const Text('Pending এ ফিরিয়ে দিন'),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _infoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Row(
//         children: [
//           Text('$label: ',
//               style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF1565C0))),
//           Expanded(
//             child: Text(value,
//                 style: const TextStyle(
//                     fontSize: 12, color: Color(0xFF1565C0))),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _approvePayment(BuildContext context) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('পেমেন্ট অনুমোদন'),
//         content: Text(
//             '${payment.tenantName} এর ৳${payment.amount.toStringAsFixed(0)} পেমেন্ট অনুমোদন করবেন?'),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('না')),
//           FilledButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('অনুমোদন করুন')),
//         ],
//       ),
//     );
//     if (confirm == true) await service.approvePayment(payment.id);
//   }

//   Future<void> _rejectPayment(BuildContext context) async {
//     final reasonCtrl = TextEditingController();
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('পেমেন্ট বাতিল'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('${payment.tenantName} এর পেমেন্ট বাতিলের কারণ:'),
//             const SizedBox(height: 12),
//             TextField(
//               controller: reasonCtrl,
//               decoration: const InputDecoration(
//                 hintText: 'যেমন: Transaction ID সঠিক নয়',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('না')),
//           FilledButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: FilledButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('বাতিল করুন'),
//           ),
//         ],
//       ),
//     );
//     if (confirm == true) {
//       await service.rejectPayment(
//           payment.id,
//           reasonCtrl.text.trim().isEmpty
//               ? 'কারণ উল্লেখ করা হয়নি'
//               : reasonCtrl.text.trim());
//     }
//   }

//   Future<void> _downloadReceipt(BuildContext context) async {
//     try {
//       final user = context.read<AuthService>().currentUser!;
//       final pdfBytes = await PdfService.generateRentReceipt(
//         payment: payment,
//         landlordName: user.name,
//         landlordPhone: user.phone,
//       );
//       await PdfService.sharePdf(pdfBytes,
//           'receipt_${payment.tenantName}_${payment.month}_${payment.year}.pdf');
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Error: $e'),
//               backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
// }






import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/payment_service.dart';
import '../../services/tenant_service.dart';
import '../../models/payment_model.dart';
import '../../models/tenant_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/pdf_service.dart';
import '../shared/notification_screen.dart';
import '../../../widgets/tenant_avatar.dart';
import 'tenant_detail_screen.dart';

class PaymentListScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const PaymentListScreen({super.key, this.scaffoldKey});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen>
    with SingleTickerProviderStateMixin {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _generating = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<String> _months = [
    '',
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
    'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর',
    'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
  ];

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

  Future<void> _generatePayments(String landlordId) async {
    final now = DateTime.now();
    if (_selectedYear > now.year ||
        (_selectedYear == now.year && _selectedMonth > now.month)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ভবিষ্যৎ মাসের payment তৈরি করা যাবে না'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _generating = true);
    try {
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
            const SnackBar(content: Text('কোনো active ভাড়াটিয়া নেই')),
          );
        }
        return;
      }

      await PaymentService().generateMonthlyPayments(
          landlordId, tenants, _selectedMonth, _selectedYear);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_months[_selectedMonth]} $_selectedYear এর payment তৈরি হয়েছে'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg =
        isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final cardBg =
        isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary =
        isDark ? Colors.white54 : const Color(0xFF6B7280);

    final user = context.read<AuthService>().currentUser!;
    final service = PaymentService();

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: StreamBuilder<List<PaymentModel>>(
          stream: service.getPayments(user.uid),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(color: primary));
            }

            final all = snap.data ?? [];
            final payments = all
                .where((p) =>
                    p.month == _selectedMonth &&
                    p.year == _selectedYear)
                .toList();

            // Stats
            double totalPaid = 0;
            double totalPending = 0;
            int paidCount = 0;
            int pendingCount = 0;
            int submittedCount = 0;

            for (final p in payments) {
              if (p.status == PaymentStatus.paid) {
                totalPaid += p.amount;
                paidCount++;
              } else if (p.status == PaymentStatus.submitted) {
                submittedCount++;
                totalPending += p.amount;
                pendingCount++;
              } else {
                totalPending += p.amount;
                pendingCount++;
              }
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── App Bar ──────────────────────────────
                SliverAppBar(
                  expandedHeight: 200,
                  collapsedHeight: 60,
                  pinned: true,
                  backgroundColor: bg,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.menu_rounded,
                        color: textPrimary),
                    onPressed: () => widget.scaffoldKey
                        ?.currentState
                        ?.openDrawer(),
                  ),
                  title: Text(
                    'ভাড়া সংগ্রহ',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    NotificationBell(userId: user.uid),
                    _generating
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(
                                Icons.add_card_rounded),
                            tooltip: 'এই মাসের payment তৈরি করুন',
                            color: textPrimary,
                            onPressed: () =>
                                _generatePayments(user.uid),
                          ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeader(
                      primary: primary,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      totalPaid: totalPaid,
                      totalPending: totalPending,
                      paidCount: paidCount,
                      pendingCount: pendingCount,
                      submittedCount: submittedCount,
                    ),
                  ),
                ),

                // ── Month Selector ─────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 8, 16, 4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          // Prev
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              onTap: () {
                                setState(() {
                                  if (_selectedMonth == 1) {
                                    _selectedMonth = 12;
                                    _selectedYear--;
                                  } else {
                                    _selectedMonth--;
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Icon(
                                    Icons.chevron_left_rounded,
                                    color: primary,
                                    size: 26),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _months[_selectedMonth],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  '$_selectedYear',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                          // Next
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              onTap: () {
                                setState(() {
                                  if (_selectedMonth == 12) {
                                    _selectedMonth = 1;
                                    _selectedYear++;
                                  } else {
                                    _selectedMonth++;
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Icon(
                                    Icons.chevron_right_rounded,
                                    color: primary,
                                    size: 26),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Payment list / empty ───────────────────
                payments.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmptyState(
                            primary, textSecondary),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                            16, 8, 16, 32),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => _PaymentCard(
                              payment: payments[i],
                              service: service,
                              isDark: isDark,
                            ),
                            childCount: payments.length,
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

  // ── Header with Stats ─────────────────────────────────────
  Widget _buildHeader({
    required Color primary,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required double totalPaid,
    required double totalPending,
    required int paidCount,
    required int pendingCount,
    required int submittedCount,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A3328),
                  const Color(0xFF0F1A14)
                ]
              : [
                  const Color(0xFFE8F5EE),
                  const Color(0xFFF5FAF7)
                ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 68, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: _statCard(
                  icon: Icons.check_circle_rounded,
                  label: 'পেয়েছি',
                  amount:
                      '৳${totalPaid.toStringAsFixed(0)}',
                  sub: '$paidCount জন পরিশোধ',
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  icon: Icons.pending_rounded,
                  label: 'বাকি আছে',
                  amount:
                      '৳${totalPending.toStringAsFixed(0)}',
                  sub: submittedCount > 0
                      ? '$submittedCount জমা দিয়েছে'
                      : '$pendingCount জন বাকি',
                  color: submittedCount > 0
                      ? const Color(0xFF0891B2)
                      : Colors.orange,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String amount,
    required String sub,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            sub,
            style: TextStyle(fontSize: 9, color: color.withOpacity(0.7)),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Widget _statCard({
  //   required IconData icon,
  //   required String label,
  //   required String amount,
  //   required String sub,
  //   required Color color,
  //   required bool isDark,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.all(14),
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(isDark ? 0.15 : 0.08),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: color.withOpacity(0.3)),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           width: 36,
  //           height: 36,
  //           decoration: BoxDecoration(
  //             color: color.withOpacity(0.2),
  //             shape: BoxShape.circle,
  //           ),
  //           child: Icon(icon, color: color, size: 20),
  //         ),
  //         const SizedBox(width: 10),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(label,
  //                   style: TextStyle(
  //                       fontSize: 11,
  //                       color: color,
  //                       fontWeight: FontWeight.w600)),
  //               Text(amount,
  //                   style: TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.bold,
  //                       color: color)),
  //               Text(sub,
  //                   style: TextStyle(
  //                       fontSize: 10,
  //                       color: color.withOpacity(0.75))),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildEmptyState(Color primary, Color textSecondary) {
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
            child: Icon(Icons.receipt_long_outlined,
                size: 46, color: primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          const Text('এই মাসের কোনো payment নেই',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'উপরের + বাটন চাপুন',
            style:
                TextStyle(fontSize: 14, color: textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Payment Card
// ─────────────────────────────────────────────────────────────
class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final PaymentService service;
  final bool isDark;

  const _PaymentCard({
    required this.payment,
    required this.service,
    required this.isDark,
  });

  Future<TenantModel?> _getTenant() async {
    final snap = await FirebaseFirestore.instance
        .collection('tenants')
        .where('name', isEqualTo: payment.tenantName)
        .where('roomNumber', isEqualTo: payment.roomNumber)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return TenantModel.fromMap(
        snap.docs.first.data(), snap.docs.first.id);
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year}  $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary =
        isDark ? Colors.white54 : const Color(0xFF6B7280);

    final isPaid = payment.status == PaymentStatus.paid;
    final isSubmitted = payment.status == PaymentStatus.submitted;
    final isRejected = payment.status == PaymentStatus.rejected;

    // Status colors
    final statusBg =
        Color(int.parse(payment.statusBgColorHex, radix: 16));
    final statusFg =
        Color(int.parse(payment.statusColorHex, radix: 16));

    return GestureDetector(
      onTap: () async {
        final tenant = await _getTenant();
        if (tenant != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TenantDetailScreen(tenant: tenant),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ─────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: statusFg.withOpacity(0.4),
                          width: 2),
                    ),
                    child: TenantAvatar(
                      tenantName: payment.tenantName,
                      tenantEmail: payment.tenantName,
                      radius: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(payment.tenantName,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textPrimary)),
                        const SizedBox(height: 2),
                        Text(
                          '${payment.propertyName} • রুম ${payment.roomNumber}',
                          style: TextStyle(
                              fontSize: 11,
                              color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(payment.statusLabel,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusFg)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Amount ─────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: primary.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.payments_outlined,
                        size: 14, color: primary),
                    const SizedBox(width: 5),
                    Text(
                      '৳${payment.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: primary),
                    ),
                  ],
                ),
              ),

              // ── Paid info ───────────────────────────────
              if (isPaid) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Colors.green.shade600,
                          size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'পরিশোধ: ${_fmt(payment.paidAt)}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      // PDF button
                      _iconBtn(
                        icon: Icons.picture_as_pdf_rounded,
                        color: Colors.red,
                        onTap: () => _downloadReceipt(context),
                      ),
                      const SizedBox(width: 6),
                      // Undo button
                      _iconBtn(
                        icon: Icons.undo_rounded,
                        color: Colors.grey,
                        onTap: () =>
                            service.markAsPending(payment.id),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Submitted details ───────────────────────
              if (isSubmitted) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF90CAF9)
                            .withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: Color(0xFF1565C0),
                              size: 15),
                          SizedBox(width: 6),
                          Text('পেমেন্টের তথ্য',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1565C0),
                                  fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _infoRow('পদ্ধতি',
                          payment.paymentMethod ?? ''),
                      _infoRow('Transaction ID',
                          payment.transactionId ?? ''),
                      if (payment.note != null &&
                          payment.note!.isNotEmpty)
                        _infoRow('নোট', payment.note!),
                      if (payment.submittedAt != null)
                        _infoRow('জমা', _fmt(payment.submittedAt)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _rejectPayment(context),
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.red, size: 18),
                        label: const Text('বাতিল',
                            style:
                                TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.red),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            _approvePayment(context),
                        icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18),
                        label: const Text('অনুমোদন'),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // ── Rejected reason ─────────────────────────
              if (isRejected &&
                  payment.rejectionReason != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.red.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cancel_outlined,
                          color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'কারণ: ${payment.rejectionReason}',
                          style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        service.markAsPending(payment.id),
                    icon: const Icon(Icons.replay_rounded,
                        size: 16),
                    label:
                        const Text('Pending এ ফিরিয়ে দিন'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label: ',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1565C0))),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1565C0))),
            ),
          ],
        ),
      );

  Future<void> _approvePayment(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('পেমেন্ট অনুমোদন',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            '${payment.tenantName} এর ৳${payment.amount.toStringAsFixed(0)} অনুমোদন করবেন?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('না')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('অনুমোদন করুন')),
        ],
      ),
    );
    if (confirm == true) await service.approvePayment(payment.id);
  }

  Future<void> _rejectPayment(BuildContext context) async {
    final reasonCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('পেমেন্ট বাতিল',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                '${payment.tenantName} এর পেমেন্ট বাতিলের কারণ:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                hintText: 'যেমন: Transaction ID সঠিক নয়',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('না')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('বাতিল করুন'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await service.rejectPayment(
          payment.id,
          reasonCtrl.text.trim().isEmpty
              ? 'কারণ উল্লেখ করা হয়নি'
              : reasonCtrl.text.trim());
    }
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    try {
      final user = context.read<AuthService>().currentUser!;
      final pdfBytes = await PdfService.generateRentReceipt(
        payment: payment,
        landlordName: user.name,
        landlordPhone: user.phone,
      );
      await PdfService.sharePdf(
          pdfBytes,
          'receipt_${payment.tenantName}'
          '_${payment.month}_${payment.year}.pdf');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }
}