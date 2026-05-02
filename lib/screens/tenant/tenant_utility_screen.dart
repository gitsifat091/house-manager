// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import '../../../models/utility_model.dart';
// // import '../../../models/user_model.dart';
// // import '../../../services/utility_service.dart';
// // import '../../../services/utility_service.dart';

// // class TenantUtilityScreen extends StatefulWidget {
// //   final UserModel user;
// //   const TenantUtilityScreen({super.key, required this.user});

// //   @override
// //   State<TenantUtilityScreen> createState() => _TenantUtilityScreenState();
// // }

// // class _TenantUtilityScreenState extends State<TenantUtilityScreen> {
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

// //   void _showSubmitSheet(BuildContext context, UtilityModel bill) {
// //     String selectedMethod = 'bKash';
// //     final noteCtrl = TextEditingController();

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
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text('${bill.typeLabel} জমা দিন',
// //                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //               const SizedBox(height: 4),
// //               Text('৳${bill.amount.toStringAsFixed(0)}',
// //                   style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
// //               const SizedBox(height: 16),

// //               const Text('পেমেন্ট পদ্ধতি',
// //                   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
// //               const SizedBox(height: 8),
// //               Wrap(
// //                 spacing: 8,
// //                 children: ['bKash', 'Nagad', 'Rocket', 'Bank', 'Cash']
// //                     .map((method) => ChoiceChip(
// //                           label: Text(method),
// //                           selected: selectedMethod == method,
// //                           onSelected: (_) => setModalState(() => selectedMethod = method),
// //                         ))
// //                     .toList(),
// //               ),
// //               const SizedBox(height: 12),

// //               TextField(
// //                 controller: noteCtrl,
// //                 decoration: const InputDecoration(
// //                   labelText: 'Transaction ID বা নোট (optional)',
// //                   hintText: 'যেমন: TXN123456',
// //                 ),
// //               ),
// //               const SizedBox(height: 16),

// //               SizedBox(
// //                 width: double.infinity,
// //                 height: 50,
// //                 child: FilledButton.icon(
// //                   onPressed: () async {
// //                     await UtilityService().submitBill(
// //                       bill.id,
// //                       paymentMethod: selectedMethod,
// //                       note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
// //                     );
// //                     if (ctx.mounted) {
// //                       Navigator.pop(ctx);
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         const SnackBar(
// //                           content: Text('জমা দেওয়া হয়েছে। বাড়ীওয়ালার অনুমোদনের অপেক্ষায়।'),
// //                           backgroundColor: Colors.blue,
// //                         ),
// //                       );
// //                     }
// //                   },
// //                   icon: const Icon(Icons.send_rounded),
// //                   label: const Text('জমা দিন'),
// //                 ),
// //               ),
// //             ],
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
// //       setState(() { _tenantId = snap.docs.first.id; _loading = false; });
// //     } else {
// //       setState(() => _loading = false);
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('আমার বিলসমূহ'), centerTitle: true),
// //       body: _loading
// //           ? const Center(child: CircularProgressIndicator())
// //           : _tenantId == null
// //               ? const Center(child: Text('তথ্য পাওয়া যায়নি'))
// //               : StreamBuilder<List<UtilityModel>>(
// //                   stream: UtilityService().getTenantBills(_tenantId!),
// //                   builder: (context, snap) {
// //                     if (snap.connectionState == ConnectionState.waiting) {
// //                       return const Center(child: CircularProgressIndicator());
// //                     }
// //                     final bills = snap.data ?? [];

// //                     if (bills.isEmpty) {
// //                       return Center(
// //                         child: Column(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             const Text('💡', style: TextStyle(fontSize: 64)),
// //                             const SizedBox(height: 16),
// //                             const Text('কোনো বিল নেই',
// //                                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //                           ],
// //                         ),
// //                       );
// //                     }

// //                     // Total summary
// //                     final totalDue = bills.where((b) => !b.isPaid)
// //                         .fold(0.0, (sum, b) => sum + b.amount);
// //                     final totalPaid = bills.where((b) => b.isPaid)
// //                         .fold(0.0, (sum, b) => sum + b.amount);

// //                     // Group by month
// //                     final Map<String, List<UtilityModel>> grouped = {};
// //                     for (final bill in bills) {
// //                       final key = '${_months[bill.month]} ${bill.year}';
// //                       grouped.putIfAbsent(key, () => []).add(bill);
// //                     }

// //                     return Column(
// //                       children: [
// //                         // Summary
// //                         Container(
// //                           margin: const EdgeInsets.all(16),
// //                           padding: const EdgeInsets.all(16),
// //                           decoration: BoxDecoration(
// //                             color: Theme.of(context).colorScheme.primary,
// //                             borderRadius: BorderRadius.circular(16),
// //                           ),
// //                           child: Row(
// //                             children: [
// //                               _summaryItem('মোট বাকি', '৳${totalDue.toStringAsFixed(0)}'),
// //                               Container(width: 1, height: 40, color: Colors.white24,
// //                                   margin: const EdgeInsets.symmetric(horizontal: 12)),
// //                               _summaryItem('মোট পরিশোধ', '৳${totalPaid.toStringAsFixed(0)}'),
// //                             ],
// //                           ),
// //                         ),

// //                         Expanded(
// //                           child: ListView(
// //                             padding: const EdgeInsets.symmetric(horizontal: 16),
// //                             children: grouped.entries.map((entry) {
// //                               return Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Padding(
// //                                     padding: const EdgeInsets.only(bottom: 8, top: 4),
// //                                     child: Text(entry.key,
// //                                         style: TextStyle(
// //                                           fontSize: 14, fontWeight: FontWeight.bold,
// //                                           color: Theme.of(context).colorScheme.primary,
// //                                         )),
// //                                   ),
// //                                   ...entry.value.map((bill) {
// //                                     final color = Theme.of(context).colorScheme;
// //                                     return Card(
// //                                       margin: const EdgeInsets.only(bottom: 8),
// //                                       child: ListTile(
// //                                         leading: Container(
// //                                           width: 44, height: 44,
// //                                           decoration: BoxDecoration(
// //                                             color: color.surfaceVariant,
// //                                             borderRadius: BorderRadius.circular(10),
// //                                           ),
// //                                           child: Center(
// //                                             child: Text(bill.typeIcon,
// //                                                 style: const TextStyle(fontSize: 22)),
// //                                           ),
// //                                         ),
// //                                         title: Text(bill.typeLabel,
// //                                             style: const TextStyle(fontWeight: FontWeight.bold)),
// //                                         subtitle: Text('৳${bill.amount.toStringAsFixed(0)}'),
// //                                         // trailing: Container(
// //                                         //   padding: const EdgeInsets.symmetric(
// //                                         //       horizontal: 10, vertical: 4),
// //                                         //   decoration: BoxDecoration(
// //                                         //     color: bill.isPaid
// //                                         //         ? Colors.green.shade100
// //                                         //         : Colors.orange.shade100,
// //                                         //     borderRadius: BorderRadius.circular(20),
// //                                         //   ),
// //                                         //   child: Text(
// //                                         //     bill.isPaid ? 'পরিশোধ' : 'বাকি',
// //                                         //     style: TextStyle(
// //                                         //       fontSize: 12, fontWeight: FontWeight.w500,
// //                                         //       color: bill.isPaid
// //                                         //           ? Colors.green.shade800
// //                                         //           : Colors.orange.shade800,
// //                                         //     ),
// //                                         //   ),
// //                                         // ),
// //                                         trailing: bill.isPaid
// //                                           ? Container(
// //                                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// //                                               decoration: BoxDecoration(
// //                                                 color: Colors.green.shade100,
// //                                                 borderRadius: BorderRadius.circular(20),
// //                                               ),
// //                                               child: Text('পরিশোধ',
// //                                                   style: TextStyle(fontSize: 12, color: Colors.green.shade800, fontWeight: FontWeight.w500)),
// //                                             )
// //                                           : bill.isSubmitted
// //                                               ? Container(
// //                                                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// //                                                   decoration: BoxDecoration(
// //                                                     color: Colors.blue.shade100,
// //                                                     borderRadius: BorderRadius.circular(20),
// //                                                   ),
// //                                                   child: Text('যাচাই চলছে',
// //                                                       style: TextStyle(fontSize: 12, color: Colors.blue.shade800, fontWeight: FontWeight.w500)),
// //                                                 )
// //                                               : GestureDetector(
// //                                                   onTap: () => _showSubmitSheet(context, bill),
// //                                                   child: Container(
// //                                                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// //                                                     decoration: BoxDecoration(
// //                                                       color: Colors.orange.shade100,
// //                                                       borderRadius: BorderRadius.circular(20),
// //                                                     ),
// //                                                     child: Text('জমা দিন',
// //                                                         style: TextStyle(fontSize: 12, color: Colors.orange.shade800, fontWeight: FontWeight.w500)),
// //                                                   ),
// //                                                 ),
// //                                       ),
// //                                     );
// //                                   }),
// //                                 ],
// //                               );
// //                             }).toList(),
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
// //           Text(value, style: const TextStyle(
// //               color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
// //           Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
// //         ],
// //       ),
// //     );
// //   }
// // }






// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../models/utility_model.dart';
// import '../../../models/user_model.dart';
// import '../../../services/utility_service.dart';

// class TenantUtilityScreen extends StatefulWidget {
//   final UserModel user;
//   const TenantUtilityScreen({super.key, required this.user});

//   @override
//   State<TenantUtilityScreen> createState() => _TenantUtilityScreenState();
// }

// class _TenantUtilityScreenState extends State<TenantUtilityScreen>
//     with SingleTickerProviderStateMixin {
//   String? _tenantId;
//   bool _loading = true;

//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;

//   final List<String> _months = [
//     '',
//     'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
//     'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর',
//     'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeAnim =
//         CurvedAnimation(parent: _animController, curve: Curves.easeOut);
//     _loadTenantId();
//   }

//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
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
//     _animController.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final primary = Theme.of(context).colorScheme.primary;
//     final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
//     final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
//     final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
//     final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

//     if (_loading) {
//       return Scaffold(
//         backgroundColor: bg,
//         body: Center(child: CircularProgressIndicator(color: primary)),
//       );
//     }

//     return Scaffold(
//       backgroundColor: bg,
//       body: FadeTransition(
//         opacity: _fadeAnim,
//         child: _tenantId == null
//             ? _buildNoData(primary, textSecondary, bg)
//             : StreamBuilder<List<UtilityModel>>(
//                 stream: UtilityService().getTenantBills(_tenantId!),
//                 builder: (context, snap) {
//                   if (snap.connectionState == ConnectionState.waiting) {
//                     return Center(
//                         child: CircularProgressIndicator(color: primary));
//                   }

//                   final bills = snap.data ?? [];

//                   // Stats
//                   final totalDue = bills
//                       .where((b) => !b.isPaid)
//                       .fold(0.0, (sum, b) => sum + b.amount);
//                   final totalPaid = bills
//                       .where((b) => b.isPaid)
//                       .fold(0.0, (sum, b) => sum + b.amount);
//                   final totalSubmitted = bills
//                       .where((b) => b.isSubmitted && !b.isPaid)
//                       .fold(0.0, (sum, b) => sum + b.amount);

//                   // Group by month/year
//                   final Map<String, List<UtilityModel>> grouped = {};
//                   for (final bill in bills) {
//                     final key =
//                         '${_months[bill.month]} ${bill.year}';
//                     grouped.putIfAbsent(key, () => []).add(bill);
//                   }

//                   return CustomScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     slivers: [
//                       // ── App Bar ────────────────────────
//                       SliverAppBar(
//                         expandedHeight: 200,
//                         collapsedHeight: 60,
//                         pinned: true,
//                         backgroundColor: bg,
//                         elevation: 0,
//                         leading: IconButton(
//                           icon: Icon(
//                               Icons.arrow_back_ios_new_rounded,
//                               size: 20,
//                               color: textPrimary),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                         title: Text(
//                           'আমার বিলসমূহ',
//                           style: TextStyle(
//                             color: textPrimary,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                         centerTitle: true,
//                         flexibleSpace: FlexibleSpaceBar(
//                           background: _buildHeader(
//                             primary: primary,
//                             isDark: isDark,
//                             textPrimary: textPrimary,
//                             totalDue: totalDue,
//                             totalPaid: totalPaid,
//                             totalSubmitted: totalSubmitted,
//                             count: bills.length,
//                           ),
//                         ),
//                       ),

//                       // ── Content ────────────────────────
//                       bills.isEmpty
//                           ? SliverFillRemaining(
//                               child: _buildEmptyState(
//                                   primary, textSecondary),
//                             )
//                           : SliverPadding(
//                               padding: const EdgeInsets.fromLTRB(
//                                   16, 8, 16, 32),
//                               sliver: SliverList(
//                                 delegate:
//                                     SliverChildBuilderDelegate(
//                                   (ctx, i) {
//                                     final entry =
//                                         grouped.entries
//                                             .elementAt(i);
//                                     return _MonthGroup(
//                                       monthLabel: entry.key,
//                                       bills: entry.value,
//                                       isDark: isDark,
//                                       cardBg: cardBg,
//                                       textPrimary: textPrimary,
//                                       textSecondary:
//                                           textSecondary,
//                                       primary: primary,
//                                       onSubmit: (bill) =>
//                                           _showSubmitSheet(
//                                               context, bill),
//                                     );
//                                   },
//                                   childCount: grouped.length,
//                                 ),
//                               ),
//                             ),
//                     ],
//                   );
//                 },
//               ),
//       ),
//     );
//   }

//   // ── Gradient Header ───────────────────────────────────────
//   Widget _buildHeader({
//     required Color primary,
//     required bool isDark,
//     required Color textPrimary,
//     required double totalDue,
//     required double totalPaid,
//     required double totalSubmitted,
//     required int count,
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
//               Expanded(
//                 child: _statCard(
//                   icon: Icons.pending_rounded,
//                   label: 'বাকি',
//                   amount: '৳${totalDue.toStringAsFixed(0)}',
//                   sub: 'অপরিশোধিত',
//                   color: Colors.orange,
//                   isDark: isDark,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _statCard(
//                   icon: Icons.hourglass_top_rounded,
//                   label: 'যাচাই চলছে',
//                   amount: '৳${totalSubmitted.toStringAsFixed(0)}',
//                   sub: 'অনুমোদনের অপেক্ষায়',
//                   color: const Color(0xFF0891B2),
//                   isDark: isDark,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _statCard(
//                   icon: Icons.check_circle_rounded,
//                   label: 'পরিশোধ',
//                   amount: '৳${totalPaid.toStringAsFixed(0)}',
//                   sub: 'পরিশোধিত',
//                   color: Colors.green,
//                   isDark: isDark,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _statCard({
//     required IconData icon,
//     required String label,
//     required String amount,
//     required String sub,
//     required Color color,
//     required bool isDark,
//   }) {
//     return Container(
//       padding:
//           const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//       decoration: BoxDecoration(
//         color: color.withOpacity(isDark ? 0.15 : 0.1),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(height: 4),
//           FittedBox(
//             child: Text(amount,
//                 style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.bold,
//                     color: color)),
//           ),
//           Text(label,
//               style: TextStyle(
//                   fontSize: 9, color: color.withOpacity(0.8)),
//               overflow: TextOverflow.ellipsis),
//         ],
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
//               color: primary.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(Icons.bolt_outlined,
//                 size: 46, color: primary.withOpacity(0.5)),
//           ),
//           const SizedBox(height: 20),
//           const Text('কোনো বিল নেই',
//               style: TextStyle(
//                   fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Text('বাড়ীওয়ালা বিল যোগ করলে এখানে দেখাবে',
//               style:
//                   TextStyle(fontSize: 14, color: textSecondary)),
//         ],
//       ),
//     );
//   }

//   Widget _buildNoData(
//       Color primary, Color textSecondary, Color bg) {
//     return Scaffold(
//       backgroundColor: bg,
//       appBar: AppBar(
//         backgroundColor: bg,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new_rounded,
//               color: primary),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text('আমার বিলসমূহ',
//             style: TextStyle(
//                 color: primary, fontWeight: FontWeight.w700)),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.person_off_outlined,
//                 size: 70, color: primary.withOpacity(0.4)),
//             const SizedBox(height: 16),
//             const Text('তথ্য পাওয়া যায়নি',
//                 style: TextStyle(
//                     fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             Text('বাড়ীওয়ালার সাথে যোগাযোগ করুন',
//                 style: TextStyle(
//                     fontSize: 14, color: textSecondary)),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Submit Sheet ──────────────────────────────────────────
//   void _showSubmitSheet(BuildContext context, UtilityModel bill) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final primary = Theme.of(context).colorScheme.primary;
//     final sheetBg =
//         isDark ? const Color(0xFF1A2C22) : Colors.white;
//     final textPrimary =
//         isDark ? Colors.white : const Color(0xFF1A1A1A);
//     final textSecondary =
//         isDark ? Colors.white54 : const Color(0xFF6B7280);

//     String selectedMethod = 'bKash';
//     final noteCtrl = TextEditingController();

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: sheetBg,
//       shape: const RoundedRectangleBorder(
//           borderRadius:
//               BorderRadius.vertical(top: Radius.circular(24))),
//       builder: (ctx) => StatefulBuilder(
//         builder: (ctx, setModalState) => Padding(
//           padding: EdgeInsets.only(
//             left: 20,
//             right: 20,
//             top: 8,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Handle
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   margin: const EdgeInsets.only(bottom: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),

//               // Bill info
//               Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: primary.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(14),
//                   border: Border.all(
//                       color: primary.withOpacity(0.2)),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 44,
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: primary.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Center(
//                         child: Text(bill.typeIcon,
//                             style: const TextStyle(fontSize: 22)),
//                       ),
//                     ),
//                     const SizedBox(width: 14),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                         children: [
//                           Text(bill.typeLabel,
//                               style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: textPrimary)),
//                           Text('জমা দেওয়ার জন্য',
//                               style: TextStyle(
//                                   fontSize: 12,
//                                   color: textSecondary)),
//                         ],
//                       ),
//                     ),
//                     Text(
//                       '৳${bill.amount.toStringAsFixed(0)}',
//                       style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: primary),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Payment method
//               Text('পেমেন্ট পদ্ধতি',
//                   style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: textSecondary,
//                       letterSpacing: 0.5)),
//               const SizedBox(height: 10),
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: ['bKash', 'Nagad', 'Rocket', 'Bank', 'Cash']
//                     .map((method) {
//                   final isSelected = selectedMethod == method;
//                   return GestureDetector(
//                     onTap: () => setModalState(
//                         () => selectedMethod = method),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 180),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 10),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? primary
//                             : primary.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: isSelected
//                               ? primary
//                               : primary.withOpacity(0.2),
//                         ),
//                       ),
//                       child: Text(
//                         method,
//                         style: TextStyle(
//                           color: isSelected
//                               ? Colors.white
//                               : textPrimary,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 16),

//               // Note
//               Text('Transaction ID / নোট (optional)',
//                   style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: textSecondary,
//                       letterSpacing: 0.5)),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: noteCtrl,
//                 style: TextStyle(color: textPrimary),
//                 decoration: InputDecoration(
//                   hintText: 'যেমন: TXN123456',
//                   hintStyle: TextStyle(
//                       color: textSecondary.withOpacity(0.6)),
//                   prefixIcon:
//                       const Icon(Icons.receipt_outlined, size: 20),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                           color: primary.withOpacity(0.3))),
//                   enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                           color: primary.withOpacity(0.3))),
//                   focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide:
//                           BorderSide(color: primary, width: 2)),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Submit button
//               GestureDetector(
//                 onTap: () async {
//                   await UtilityService().submitBill(
//                     bill.id,
//                     paymentMethod: selectedMethod,
//                     note: noteCtrl.text.trim().isEmpty
//                         ? null
//                         : noteCtrl.text.trim(),
//                   );
//                   if (ctx.mounted) {
//                     Navigator.pop(ctx);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text(
//                           'জমা দেওয়া হয়েছে। বাড়ীওয়ালার অনুমোদনের অপেক্ষায়।',
//                         ),
//                         backgroundColor: Colors.blue,
//                       ),
//                     );
//                   }
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   height: 54,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [primary, primary.withOpacity(0.8)],
//                       begin: Alignment.centerLeft,
//                       end: Alignment.centerRight,
//                     ),
//                     borderRadius: BorderRadius.circular(14),
//                     boxShadow: [
//                       BoxShadow(
//                         color: primary.withOpacity(0.4),
//                         blurRadius: 14,
//                         offset: const Offset(0, 5),
//                       )
//                     ],
//                   ),
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.send_rounded,
//                           color: Colors.white, size: 20),
//                       SizedBox(width: 10),
//                       Text('জমা দিন',
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700)),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  Month Group Widget
// // ─────────────────────────────────────────────────────────────
// class _MonthGroup extends StatelessWidget {
//   final String monthLabel;
//   final List<UtilityModel> bills;
//   final bool isDark;
//   final Color cardBg;
//   final Color textPrimary;
//   final Color textSecondary;
//   final Color primary;
//   final void Function(UtilityModel) onSubmit;

//   const _MonthGroup({
//     required this.monthLabel,
//     required this.bills,
//     required this.isDark,
//     required this.cardBg,
//     required this.textPrimary,
//     required this.textSecondary,
//     required this.primary,
//     required this.onSubmit,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Month header
//         Padding(
//           padding: const EdgeInsets.only(bottom: 10, top: 4),
//           child: Row(
//             children: [
//               Container(
//                 width: 4,
//                 height: 16,
//                 decoration: BoxDecoration(
//                   color: primary,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(monthLabel,
//                   style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: primary)),
//             ],
//           ),
//         ),

//         // Bill cards
//         Container(
//           decoration: BoxDecoration(
//             color: cardBg,
//             borderRadius: BorderRadius.circular(18),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.06),
//                 blurRadius: 12,
//                 offset: const Offset(0, 4),
//               )
//             ],
//           ),
//           child: Column(
//             children: bills.asMap().entries.map((entry) {
//               final idx = entry.key;
//               final bill = entry.value;
//               final isLast = idx == bills.length - 1;

//               return Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(14),
//                     child: Row(
//                       children: [
//                         // Icon
//                         Container(
//                           width: 46,
//                           height: 46,
//                           decoration: BoxDecoration(
//                             color: isDark
//                                 ? Colors.white.withOpacity(0.07)
//                                 : Colors.grey.shade100,
//                             borderRadius:
//                                 BorderRadius.circular(12),
//                           ),
//                           child: Center(
//                             child: Text(bill.typeIcon,
//                                 style: const TextStyle(
//                                     fontSize: 22)),
//                           ),
//                         ),
//                         const SizedBox(width: 14),

//                         // Info
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                             children: [
//                               Text(bill.typeLabel,
//                                   style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight:
//                                           FontWeight.bold,
//                                       color: textPrimary)),
//                               const SizedBox(height: 2),
//                               Text(
//                                 '৳${bill.amount.toStringAsFixed(0)}',
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: primary),
//                               ),
//                             ],
//                           ),
//                         ),

//                         // Status / Action
//                         _buildTrailing(context, bill),
//                       ],
//                     ),
//                   ),
//                   if (!isLast)
//                     Divider(
//                         height: 1,
//                         indent: 74,
//                         color: isDark
//                             ? Colors.white10
//                             : Colors.grey.shade100),
//                 ],
//               );
//             }).toList(),
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   Widget _buildTrailing(BuildContext context, UtilityModel bill) {
//     if (bill.isPaid) {
//       return Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: Colors.green.shade100,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.check_circle_rounded,
//                 color: Colors.green.shade700, size: 14),
//             const SizedBox(width: 4),
//             Text('পরিশোধ',
//                 style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.green.shade800)),
//           ],
//         ),
//       );
//     }

//     if (bill.isSubmitted) {
//       return Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: Colors.blue.shade100,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.hourglass_top_rounded,
//                 color: Colors.blue.shade700, size: 13),
//             const SizedBox(width: 4),
//             Text('যাচাই চলছে',
//                 style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.blue.shade800)),
//           ],
//         ),
//       );
//     }

//     // Pending — জমা দিন button
//     return GestureDetector(
//       onTap: () => onSubmit(bill),
//       child: Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//         decoration: BoxDecoration(
//           color: primary,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: primary.withOpacity(0.35),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             )
//           ],
//         ),
//         child: const Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.upload_rounded,
//                 color: Colors.white, size: 15),
//             SizedBox(width: 5),
//             Text('জমা দিন',
//                 style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.white)),
//           ],
//         ),
//       ),
//     );
//   }
// }







import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/utility_model.dart';
import '../../../models/user_model.dart';
import '../../../services/utility_service.dart';
 
class TenantUtilityScreen extends StatefulWidget {
  final UserModel user;
  const TenantUtilityScreen({super.key, required this.user});
 
  @override
  State<TenantUtilityScreen> createState() => _TenantUtilityScreenState();
}
 
class _TenantUtilityScreenState extends State<TenantUtilityScreen>
    with SingleTickerProviderStateMixin {
  String? _tenantId;
  bool _loading = true;
 
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
    _loadTenantId();
  }
 
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
    _animController.forward();
  }
 
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);
 
    if (_loading) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(child: CircularProgressIndicator(color: primary)),
      );
    }
 
    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: _tenantId == null
            ? _buildNoData(primary, textSecondary, bg)
            : StreamBuilder<List<UtilityModel>>(
                stream: UtilityService().getTenantBills(_tenantId!),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(color: primary));
                  }
 
                  final bills = snap.data ?? [];
 
                  // Stats
                  final totalDue = bills
                      .where((b) => !b.isPaid)
                      .fold(0.0, (sum, b) => sum + b.amount);
                  final totalPaid = bills
                      .where((b) => b.isPaid)
                      .fold(0.0, (sum, b) => sum + b.amount);
                  final totalSubmitted = bills
                      .where((b) => b.isSubmitted && !b.isPaid)
                      .fold(0.0, (sum, b) => sum + b.amount);
 
                  // Group by month/year
                  final Map<String, List<UtilityModel>> grouped = {};
                  for (final bill in bills) {
                    final key =
                        '${_months[bill.month]} ${bill.year}';
                    grouped.putIfAbsent(key, () => []).add(bill);
                  }
 
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // ── App Bar ────────────────────────
                      SliverAppBar(
                        expandedHeight: 200,
                        collapsedHeight: 60,
                        pinned: true,
                        backgroundColor: bg,
                        elevation: 0,
                        leading: IconButton(
                          icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                        title: Text(
                          'আমার বিলসমূহ',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        centerTitle: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: _buildHeader(
                            primary: primary,
                            isDark: isDark,
                            textPrimary: textPrimary,
                            totalDue: totalDue,
                            totalPaid: totalPaid,
                            totalSubmitted: totalSubmitted,
                            count: bills.length,
                          ),
                        ),
                      ),
 
                      // ── Content ────────────────────────
                      bills.isEmpty
                          ? SliverFillRemaining(
                              child: _buildEmptyState(
                                  primary, textSecondary),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 8, 16, 32),
                              sliver: SliverList(
                                delegate:
                                    SliverChildBuilderDelegate(
                                  (ctx, i) {
                                    final entry =
                                        grouped.entries
                                            .elementAt(i);
                                    return _MonthGroup(
                                      monthLabel: entry.key,
                                      bills: entry.value,
                                      isDark: isDark,
                                      cardBg: cardBg,
                                      textPrimary: textPrimary,
                                      textSecondary:
                                          textSecondary,
                                      primary: primary,
                                      onSubmit: (bill) =>
                                          _showSubmitSheet(
                                              context, bill),
                                    );
                                  },
                                  childCount: grouped.length,
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
 
  // ── Gradient Header ───────────────────────────────────────
  Widget _buildHeader({
    required Color primary,
    required bool isDark,
    required Color textPrimary,
    required double totalDue,
    required double totalPaid,
    required double totalSubmitted,
    required int count,
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
              Expanded(
                child: _statCard(
                  icon: Icons.pending_rounded,
                  label: 'বাকি',
                  amount: '৳${totalDue.toStringAsFixed(0)}',
                  sub: 'অপরিশোধিত',
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  icon: Icons.hourglass_top_rounded,
                  label: 'যাচাই চলছে',
                  amount: '৳${totalSubmitted.toStringAsFixed(0)}',
                  sub: 'অনুমোদনের অপেক্ষায়',
                  color: const Color(0xFF0891B2),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  icon: Icons.check_circle_rounded,
                  label: 'পরিশোধ',
                  amount: '৳${totalPaid.toStringAsFixed(0)}',
                  sub: 'পরিশোধিত',
                  color: Colors.green,
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
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
            child: Text(amount,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ),
          Text(label,
              style: TextStyle(
                  fontSize: 9, color: color.withOpacity(0.8)),
              overflow: TextOverflow.ellipsis),
        ],
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
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bolt_outlined,
                size: 46, color: primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          const Text('কোনো বিল নেই',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('বাড়ীওয়ালা বিল যোগ করলে এখানে দেখাবে',
              style:
                  TextStyle(fontSize: 14, color: textSecondary)),
        ],
      ),
    );
  }
 
  Widget _buildNoData(
      Color primary, Color textSecondary, Color bg) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('আমার বিলসমূহ',
            style: TextStyle(
                color: primary, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off_outlined,
                size: 70, color: primary.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text('তথ্য পাওয়া যায়নি',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('বাড়ীওয়ালার সাথে যোগাযোগ করুন',
                style: TextStyle(
                    fontSize: 14, color: textSecondary)),
          ],
        ),
      ),
    );
  }
 
  // ── Submit Sheet ──────────────────────────────────────────
  void _showSubmitSheet(BuildContext context, UtilityModel bill) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final sheetBg =
        isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary =
        isDark ? Colors.white54 : const Color(0xFF6B7280);
 
    String selectedMethod = 'bKash';
    final noteCtrl = TextEditingController();
 
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
 
              // Bill info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(bill.typeIcon,
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(bill.typeLabel,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary)),
                          Text('জমা দেওয়ার জন্য',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary)),
                        ],
                      ),
                    ),
                    Text(
                      '৳${bill.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
 
              // Payment method
              Text('পেমেন্ট পদ্ধতি',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textSecondary,
                      letterSpacing: 0.5)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['bKash', 'Nagad', 'Rocket', 'Bank', 'Cash']
                    .map((method) {
                  final isSelected = selectedMethod == method;
                  return GestureDetector(
                    onTap: () => setModalState(
                        () => selectedMethod = method),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primary
                            : primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? primary
                              : primary.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        method,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
 
              // Note
              Text('Transaction ID / নোট (optional)',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textSecondary,
                      letterSpacing: 0.5)),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtrl,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'যেমন: TXN123456',
                  hintStyle: TextStyle(
                      color: textSecondary.withOpacity(0.6)),
                  prefixIcon:
                      const Icon(Icons.receipt_outlined, size: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: primary.withOpacity(0.3))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: primary.withOpacity(0.3))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: primary, width: 2)),
                ),
              ),
              const SizedBox(height: 20),
 
              // Submit button
              GestureDetector(
                onTap: () async {
                  await UtilityService().submitBill(
                    bill.id,
                    paymentMethod: selectedMethod,
                    note: noteCtrl.text.trim().isEmpty
                        ? null
                        : noteCtrl.text.trim(),
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'জমা দেওয়া হয়েছে। বাড়ীওয়ালার অনুমোদনের অপেক্ষায়।',
                        ),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, primary.withOpacity(0.8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text('জমা দিন',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────
//  Month Group Widget
// ─────────────────────────────────────────────────────────────
class _MonthGroup extends StatelessWidget {
  final String monthLabel;
  final List<UtilityModel> bills;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color primary;
  final void Function(UtilityModel) onSubmit;
 
  const _MonthGroup({
    required this.monthLabel,
    required this.bills,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
    required this.onSubmit,
  });
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(monthLabel,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primary)),
            ],
          ),
        ),
 
        // Bill cards
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: bills.asMap().entries.map((entry) {
              final idx = entry.key;
              final bill = entry.value;
              final isLast = idx == bills.length - 1;
 
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.07)
                                : Colors.grey.shade100,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(bill.typeIcon,
                                style: const TextStyle(
                                    fontSize: 22)),
                          ),
                        ),
                        const SizedBox(width: 14),
 
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(bill.typeLabel,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: textPrimary)),
                              const SizedBox(height: 2),
                              Text(
                                '৳${bill.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: primary),
                              ),
                            ],
                          ),
                        ),
 
                        // Status / Action
                        _buildTrailing(context, bill),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                        height: 1,
                        indent: 74,
                        color: isDark
                            ? Colors.white10
                            : Colors.grey.shade100),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
 
  Widget _buildTrailing(BuildContext context, UtilityModel bill) {
    if (bill.isPaid) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded,
                color: Colors.green.shade700, size: 14),
            const SizedBox(width: 4),
            Text('পরিশোধ',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800)),
          ],
        ),
      );
    }
 
    if (bill.isSubmitted) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_top_rounded,
                color: Colors.blue.shade700, size: 13),
            const SizedBox(width: 4),
            Text('যাচাই চলছে',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800)),
          ],
        ),
      );
    }
 
    // Pending — জমা দিন button
    return GestureDetector(
      onTap: () => onSubmit(bill),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.upload_rounded,
                color: Colors.white, size: 15),
            SizedBox(width: 5),
            Text('জমা দিন',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}













