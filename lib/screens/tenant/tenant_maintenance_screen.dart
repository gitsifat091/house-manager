// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import '../../../models/maintenance_model.dart';
// // import '../../../models/user_model.dart';
// // import '../../../services/maintenance_service.dart';

// // class TenantMaintenanceScreen extends StatefulWidget {
// //   final UserModel user;
// //   // const TenantMaintenanceScreen({super.key, required this.user});
// //   final GlobalKey<ScaffoldState>? scaffoldKey;
// //   const TenantMaintenanceScreen({super.key, required this.user, this.scaffoldKey});

// //   @override
// //   State<TenantMaintenanceScreen> createState() => _TenantMaintenanceScreenState();
// // }

// // class _TenantMaintenanceScreenState extends State<TenantMaintenanceScreen> {
// //   Map<String, dynamic>? _tenantData;
// //   bool _loading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadTenant();
// //   }

// //   Future<void> _loadTenant() async {
// //     final snap = await FirebaseFirestore.instance
// //         .collection('tenants')
// //         .where('email', isEqualTo: widget.user.email)
// //         .where('isActive', isEqualTo: true)
// //         .get();

// //     if (snap.docs.isNotEmpty) {
// //       setState(() {
// //         _tenantData = {...snap.docs.first.data(), 'id': snap.docs.first.id};
// //         _loading = false;
// //       });
// //     } else {
// //       setState(() => _loading = false);
// //     }
// //   }

// //   void _showAddRequestDialog() {
// //     final titleCtrl = TextEditingController();
// //     final descCtrl = TextEditingController();
// //     final formKey = GlobalKey<FormState>();

// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       shape: const RoundedRectangleBorder(
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
// //       builder: (_) => Padding(
// //         padding: EdgeInsets.only(
// //           left: 20, right: 20, top: 20,
// //           bottom: MediaQuery.of(context).viewInsets.bottom + 20,
// //         ),
// //         child: Form(
// //           key: formKey,
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               const Text('মেরামতের অনুরোধ',
// //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //               const SizedBox(height: 16),
// //               TextFormField(
// //                 controller: titleCtrl,
// //                 decoration: const InputDecoration(
// //                   labelText: 'সমস্যার শিরোনাম',
// //                   hintText: 'যেমন: পানির লাইন লিক করছে',
// //                 ),
// //                 validator: (v) => v!.isEmpty ? 'শিরোনাম দিন' : null,
// //               ),
// //               const SizedBox(height: 12),
// //               TextFormField(
// //                 controller: descCtrl,
// //                 maxLines: 3,
// //                 decoration: const InputDecoration(
// //                   labelText: 'বিস্তারিত বিবরণ',
// //                   hintText: 'সমস্যাটি বিস্তারিত লিখুন',
// //                 ),
// //                 validator: (v) => v!.isEmpty ? 'বিবরণ দিন' : null,
// //               ),
// //               const SizedBox(height: 16),
// //               SizedBox(
// //                 width: double.infinity, height: 50,
// //                 child: FilledButton(
// //                   onPressed: () async {
// //                     if (!formKey.currentState!.validate()) return;
// //                     final req = MaintenanceModel(
// //                       id: '',
// //                       tenantId: _tenantData!['id'],
// //                       tenantName: _tenantData!['name'],
// //                       roomNumber: _tenantData!['roomNumber'],
// //                       propertyId: _tenantData!['propertyId'],
// //                       propertyName: _tenantData!['propertyName'],
// //                       landlordId: _tenantData!['landlordId'],
// //                       title: titleCtrl.text.trim(),
// //                       description: descCtrl.text.trim(),
// //                       status: MaintenanceStatus.pending,
// //                       createdAt: DateTime.now(),
// //                     );
// //                     await MaintenanceService().addRequest(req);
// //                     if (context.mounted) Navigator.pop(context);
// //                   },
// //                   child: const Text('অনুরোধ পাঠান'),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         leading: IconButton(
// //           icon: const Icon(Icons.menu_rounded),
// //           onPressed: () => widget.scaffoldKey?.currentState?.openDrawer(),
// //         ),
// //         title: const Text('মেরামতের অনুরোধ'), centerTitle: true),
// //       body: _loading
// //           ? const Center(child: CircularProgressIndicator())
// //           : _tenantData == null
// //               ? const Center(child: Text('তথ্য পাওয়া যায়নি'))
// //               : StreamBuilder<List<MaintenanceModel>>(
// //                   stream: MaintenanceService().getTenantRequests(_tenantData!['id']),
// //                   builder: (context, snap) {
// //                     if (snap.connectionState == ConnectionState.waiting) {
// //                       return const Center(child: CircularProgressIndicator());
// //                     }
// //                     final requests = snap.data ?? [];
// //                     if (requests.isEmpty) {
// //                       return Center(
// //                         child: Column(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             Icon(Icons.build_outlined, size: 80,
// //                                 color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
// //                             const SizedBox(height: 16),
// //                             const Text('কোনো অনুরোধ নেই',
// //                                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //                             const SizedBox(height: 8),
// //                             const Text('নিচের বাটন দিয়ে অনুরোধ পাঠান'),
// //                           ],
// //                         ),
// //                       );
// //                     }
// //                     return ListView.builder(
// //                       padding: const EdgeInsets.all(16),
// //                       itemCount: requests.length,
// //                       itemBuilder: (ctx, i) {
// //                         final req = requests[i];
// //                         final color = Theme.of(context).colorScheme;
// //                         return Card(
// //                           margin: const EdgeInsets.only(bottom: 12),
// //                           child: Padding(
// //                             padding: const EdgeInsets.all(14),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Row(
// //                                   children: [
// //                                     Expanded(
// //                                       child: Text(req.title,
// //                                           style: const TextStyle(
// //                                               fontSize: 15, fontWeight: FontWeight.bold)),
// //                                     ),
// //                                     Container(
// //                                       padding: const EdgeInsets.symmetric(
// //                                           horizontal: 10, vertical: 4),
// //                                       decoration: BoxDecoration(
// //                                         color: Color(int.parse('FF${req.statusColorHex}', radix: 16)).withOpacity(0.15),
// //                                         borderRadius: BorderRadius.circular(20),
// //                                       ),
// //                                       child: Text(req.statusLabel,
// //                                           style: TextStyle(fontSize: 12, color: Color(int.parse('FF${req.statusColorHex}', radix: 16)),
// //                                               fontWeight: FontWeight.w500)),
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 const SizedBox(height: 6),
// //                                 Text(req.description,
// //                                     style: TextStyle(
// //                                         color: color.onSurface.withOpacity(0.7))),
// //                                 const SizedBox(height: 6),
// //                                 Text(
// //                                   '${req.createdAt.day}/${req.createdAt.month}/${req.createdAt.year}',
// //                                   style: TextStyle(
// //                                       fontSize: 11,
// //                                       color: color.onSurface.withOpacity(0.4)),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         );
// //                       },
// //                     );
// //                   },
// //                 ),
// //       floatingActionButton: _tenantData == null
// //           ? null
// //           : FloatingActionButton.extended(
// //               onPressed: _showAddRequestDialog,
// //               icon: const Icon(Icons.add),
// //               label: const Text('অনুরোধ পাঠান'),
// //             ),
// //     );
// //   }
// // }






// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../models/maintenance_model.dart';
// import '../../../models/user_model.dart';
// import '../../../services/maintenance_service.dart';

// class TenantMaintenanceScreen extends StatefulWidget {
//   final UserModel user;
//   final GlobalKey<ScaffoldState>? scaffoldKey;
//   const TenantMaintenanceScreen(
//       {super.key, required this.user, this.scaffoldKey});

//   @override
//   State<TenantMaintenanceScreen> createState() =>
//       _TenantMaintenanceScreenState();
// }

// class _TenantMaintenanceScreenState extends State<TenantMaintenanceScreen>
//     with SingleTickerProviderStateMixin {
//   Map<String, dynamic>? _tenantData;
//   bool _loading = true;

//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeAnim =
//         CurvedAnimation(parent: _animController, curve: Curves.easeOut);
//     _loadTenant();
//   }

//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadTenant() async {
//     final snap = await FirebaseFirestore.instance
//         .collection('tenants')
//         .where('email', isEqualTo: widget.user.email)
//         .where('isActive', isEqualTo: true)
//         .get();

//     if (snap.docs.isNotEmpty) {
//       setState(() {
//         _tenantData = {...snap.docs.first.data(), 'id': snap.docs.first.id};
//         _loading = false;
//       });
//     } else {
//       setState(() => _loading = false);
//     }
//     _animController.forward();
//   }

//   void _showAddRequestDialog() {
//     final titleCtrl = TextEditingController();
//     final descCtrl = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final primary = Theme.of(context).colorScheme.primary;
//     final sheetBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
//     final textPrimary =
//         isDark ? Colors.white : const Color(0xFF1A1A1A);

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: sheetBg,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (_) => Padding(
//         padding: EdgeInsets.only(
//           left: 20,
//           right: 20,
//           top: 24,
//           bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//         ),
//         child: Form(
//           key: formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Handle bar
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Sheet header
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: primary.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Icon(Icons.build_rounded,
//                         color: primary, size: 22),
//                   ),
//                   const SizedBox(width: 12),
//                   Text(
//                     'মেরামতের অনুরোধ',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w700,
//                       color: textPrimary,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),

//               TextFormField(
//                 controller: titleCtrl,
//                 decoration: InputDecoration(
//                   labelText: 'সমস্যার শিরোনাম',
//                   hintText: 'যেমন: পানির লাইন লিক করছে',
//                   prefixIcon:
//                       Icon(Icons.title_rounded, color: primary),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: primary, width: 2),
//                   ),
//                 ),
//                 validator: (v) =>
//                     v!.isEmpty ? 'শিরোনাম দিন' : null,
//               ),
//               const SizedBox(height: 14),

//               TextFormField(
//                 controller: descCtrl,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   labelText: 'বিস্তারিত বিবরণ',
//                   hintText: 'সমস্যাটি বিস্তারিত লিখুন',
//                   prefixIcon: Padding(
//                     padding: const EdgeInsets.only(bottom: 48),
//                     child: Icon(Icons.notes_rounded, color: primary),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: primary, width: 2),
//                   ),
//                 ),
//                 validator: (v) =>
//                     v!.isEmpty ? 'বিবরণ দিন' : null,
//               ),
//               const SizedBox(height: 20),

//               SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: FilledButton.icon(
//                   style: FilledButton.styleFrom(
//                     backgroundColor: primary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   icon: const Icon(Icons.send_rounded, size: 18),
//                   label: const Text(
//                     'অনুরোধ পাঠান',
//                     style: TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                   onPressed: () async {
//                     if (!formKey.currentState!.validate()) return;
//                     final req = MaintenanceModel(
//                       id: '',
//                       tenantId: _tenantData!['id'],
//                       tenantName: _tenantData!['name'],
//                       roomNumber: _tenantData!['roomNumber'],
//                       propertyId: _tenantData!['propertyId'],
//                       propertyName: _tenantData!['propertyName'],
//                       landlordId: _tenantData!['landlordId'],
//                       title: titleCtrl.text.trim(),
//                       description: descCtrl.text.trim(),
//                       status: MaintenanceStatus.pending,
//                       createdAt: DateTime.now(),
//                     );
//                     await MaintenanceService().addRequest(req);
//                     if (context.mounted) Navigator.pop(context);
//                   },
//                 ),
//               ),
//             ],
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
//     final textSecondary =
//         isDark ? Colors.white54 : const Color(0xFF6B7280);

//     return Scaffold(
//       backgroundColor: bg,
//       appBar: AppBar(
//         backgroundColor: bg,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.menu_rounded, color: textPrimary),
//           onPressed: () =>
//               widget.scaffoldKey?.currentState?.openDrawer(),
//         ),
//         title: Text(
//           'মেরামতের অনুরোধ',
//           style: TextStyle(
//             color: textPrimary,
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: _loading
//           ? Center(child: CircularProgressIndicator(color: primary))
//           : _tenantData == null
//               ? _buildErrorState(primary, textPrimary, textSecondary)
//               : FadeTransition(
//                   opacity: _fadeAnim,
//                   child: StreamBuilder<List<MaintenanceModel>>(
//                     stream: MaintenanceService()
//                         .getTenantRequests(_tenantData!['id']),
//                     builder: (context, snap) {
//                       if (snap.connectionState ==
//                           ConnectionState.waiting) {
//                         return Center(
//                           child:
//                               CircularProgressIndicator(color: primary),
//                         );
//                       }
//                       final requests = snap.data ?? [];
//                       if (requests.isEmpty) {
//                         return _buildEmptyState(
//                             primary, textPrimary, textSecondary);
//                       }

//                       // Summary counts
//                       final pendingCount = requests
//                           .where((r) =>
//                               r.status == MaintenanceStatus.pending)
//                           .length;
//                       final inProgressCount = requests
//                           .where((r) =>
//                               r.status == MaintenanceStatus.inProgress)
//                           .length;
//                       final doneCount = requests
//                           .where(
//                               (r) => r.status == MaintenanceStatus.done)
//                           .length;

//                       return Column(
//                         children: [
//                           // ── Summary row ──
//                           Padding(
//                             padding: const EdgeInsets.fromLTRB(
//                                 16, 8, 16, 4),
//                             child: Row(
//                               children: [
//                                 _StatBadge(
//                                   label: 'মোট',
//                                   count: requests.length,
//                                   color: primary,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 _StatBadge(
//                                   label: 'অপেক্ষমাণ',
//                                   count: pendingCount,
//                                   color: const Color(0xFFD97706),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 _StatBadge(
//                                   label: 'চলছে',
//                                   count: inProgressCount,
//                                   color: const Color(0xFF0891B2),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 _StatBadge(
//                                   label: 'সম্পন্ন',
//                                   count: doneCount,
//                                   color: const Color(0xFF16A34A),
//                                 ),
//                               ],
//                             ),
//                           ),

//                           // ── List ──
//                           Expanded(
//                             child: ListView.builder(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 8),
//                               itemCount: requests.length,
//                               itemBuilder: (ctx, i) =>
//                                   _TenantMaintenanceCard(
//                                 req: requests[i],
//                                 isDark: isDark,
//                                 primary: primary,
//                                 textPrimary: textPrimary,
//                                 textSecondary: textSecondary,
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//       floatingActionButton: _tenantData == null
//           ? null
//           : FloatingActionButton.extended(
//               onPressed: _showAddRequestDialog,
//               backgroundColor: primary,
//               foregroundColor: Colors.white,
//               elevation: 4,
//               icon: const Icon(Icons.add_rounded),
//               label: const Text(
//                 'অনুরোধ পাঠান',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//     );
//   }

//   Widget _buildEmptyState(
//       Color primary, Color textPrimary, Color textSecondary) {
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
//             child: Icon(
//               Icons.build_outlined,
//               size: 44,
//               color: primary.withOpacity(0.6),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'কোনো অনুরোধ নেই',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: textPrimary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'নিচের বাটন দিয়ে অনুরোধ পাঠান',
//             style: TextStyle(fontSize: 14, color: textSecondary),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(
//       Color primary, Color textPrimary, Color textSecondary) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 90,
//             height: 90,
//             decoration: BoxDecoration(
//               color: Colors.orange.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.error_outline_rounded,
//               size: 44,
//               color: Colors.orange.withOpacity(0.7),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'তথ্য পাওয়া যায়নি',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: textPrimary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'সক্রিয় ভাড়াটিয়া হিসেবে যুক্ত আছেন কিনা নিশ্চিত করুন',
//             style: TextStyle(fontSize: 13, color: textSecondary),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Stat Badge (read-only summary, no filter tap needed) ──────

// class _StatBadge extends StatelessWidget {
//   final String label;
//   final int count;
//   final Color color;

//   const _StatBadge({
//     required this.label,
//     required this.count,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: color.withOpacity(0.3),
//             width: 1.5,
//           ),
//         ),
//         child: Column(
//           children: [
//             Text(
//               '$count',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w600,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Tenant Maintenance Card (read-only, no status buttons) ────

// class _TenantMaintenanceCard extends StatelessWidget {
//   final MaintenanceModel req;
//   final bool isDark;
//   final Color primary;
//   final Color textPrimary;
//   final Color textSecondary;

//   const _TenantMaintenanceCard({
//     required this.req,
//     required this.isDark,
//     required this.primary,
//     required this.textPrimary,
//     required this.textSecondary,
//   });

//   Color get _statusColor =>
//       Color(int.parse('FF${req.statusColorHex}', radix: 16));

//   IconData get _statusIcon {
//     switch (req.status) {
//       case MaintenanceStatus.pending:
//         return Icons.hourglass_empty_rounded;
//       case MaintenanceStatus.inProgress:
//         return Icons.construction_rounded;
//       case MaintenanceStatus.done:
//         return Icons.check_circle_outline_rounded;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
//     final divider =
//         isDark ? Colors.white10 : const Color(0xFFE5E7EB);
//     final statusColor = _statusColor;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: cardBg,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         // Left border accent — status color
//         border: Border(
//           left: BorderSide(color: statusColor, width: 4),
//         ),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── Title + Status badge ──
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: primary.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Icon(
//                       Icons.build_circle_outlined,
//                       size: 18,
//                       color: primary,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       req.title,
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w700,
//                         color: textPrimary,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   // Status badge
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 5),
//                     decoration: BoxDecoration(
//                       color: statusColor.withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: statusColor.withOpacity(0.3),
//                         width: 1,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(_statusIcon,
//                             size: 12, color: statusColor),
//                         const SizedBox(width: 4),
//                         Text(
//                           req.statusLabel,
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                             color: statusColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 12),
//               Divider(height: 1, color: divider),
//               const SizedBox(height: 12),

//               // ── Description ──
//               Text(
//                 req.description,
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: textSecondary,
//                   height: 1.5,
//                 ),
//               ),

//               const SizedBox(height: 10),

//               // ── Date ──
//               Row(
//                 children: [
//                   Icon(
//                     Icons.calendar_today_rounded,
//                     size: 11,
//                     color: textSecondary.withOpacity(0.7),
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     '${req.createdAt.day}/${req.createdAt.month}/${req.createdAt.year}',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: textSecondary.withOpacity(0.7),
//                     ),
//                   ),

//                   // "সম্পন্ন" হলে একটা ছোট done indicator
//                   if (req.status == MaintenanceStatus.done) ...[
//                     const Spacer(),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF16A34A).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.verified_rounded,
//                             size: 12,
//                             color: Color(0xFF16A34A),
//                           ),
//                           SizedBox(width: 4),
//                           Text(
//                             'কাজ হয়েছে',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF16A34A),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }







import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/maintenance_model.dart';
import '../../../models/user_model.dart';
import '../../../services/maintenance_service.dart';
 
class TenantMaintenanceScreen extends StatefulWidget {
  final UserModel user;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const TenantMaintenanceScreen(
      {super.key, required this.user, this.scaffoldKey});
 
  @override
  State<TenantMaintenanceScreen> createState() =>
      _TenantMaintenanceScreenState();
}
 
class _TenantMaintenanceScreenState extends State<TenantMaintenanceScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _tenantData;
  bool _loading = true;
 
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
 
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _loadTenant();
  }
 
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
 
  Future<void> _loadTenant() async {
    final snap = await FirebaseFirestore.instance
        .collection('tenants')
        .where('email', isEqualTo: widget.user.email)
        .where('isActive', isEqualTo: true)
        .get();
 
    if (snap.docs.isNotEmpty) {
      setState(() {
        _tenantData = {...snap.docs.first.data(), 'id': snap.docs.first.id};
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
    _animController.forward();
  }
 
  void _showAddRequestDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final sheetBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1A1A1A);
 
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
 
              // Sheet header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.build_rounded,
                        color: primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'মেরামতের অনুরোধ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
 
              TextFormField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'সমস্যার শিরোনাম',
                  hintText: 'যেমন: পানির লাইন লিক করছে',
                  prefixIcon:
                      Icon(Icons.title_rounded, color: primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primary, width: 2),
                  ),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'শিরোনাম দিন' : null,
              ),
              const SizedBox(height: 14),
 
              TextFormField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'বিস্তারিত বিবরণ',
                  hintText: 'সমস্যাটি বিস্তারিত লিখুন',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: Icon(Icons.notes_rounded, color: primary),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primary, width: 2),
                  ),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'বিবরণ দিন' : null,
              ),
              const SizedBox(height: 20),
 
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text(
                    'অনুরোধ পাঠান',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final req = MaintenanceModel(
                      id: '',
                      tenantId: _tenantData!['id'],
                      tenantName: _tenantData!['name'],
                      roomNumber: _tenantData!['roomNumber'],
                      propertyId: _tenantData!['propertyId'],
                      propertyName: _tenantData!['propertyName'],
                      landlordId: _tenantData!['landlordId'],
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      status: MaintenanceStatus.pending,
                      createdAt: DateTime.now(),
                    );
                    await MaintenanceService().addRequest(req);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
            ],
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
    final textSecondary =
        isDark ? Colors.white54 : const Color(0xFF6B7280);
 
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: textPrimary),
          onPressed: () =>
              widget.scaffoldKey?.currentState?.openDrawer(),
        ),
        title: Text(
          'মেরামতের অনুরোধ',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: primary))
          : _tenantData == null
              ? _buildErrorState(primary, textPrimary, textSecondary)
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: StreamBuilder<List<MaintenanceModel>>(
                    stream: MaintenanceService()
                        .getTenantRequests(_tenantData!['id']),
                    builder: (context, snap) {
                      if (snap.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child:
                              CircularProgressIndicator(color: primary),
                        );
                      }
                      final requests = snap.data ?? [];
                      if (requests.isEmpty) {
                        return _buildEmptyState(
                            primary, textPrimary, textSecondary);
                      }
 
                      // Summary counts
                      final pendingCount = requests
                          .where((r) =>
                              r.status == MaintenanceStatus.pending)
                          .length;
                      final inProgressCount = requests
                          .where((r) =>
                              r.status == MaintenanceStatus.inProgress)
                          .length;
                      final doneCount = requests
                          .where(
                              (r) => r.status == MaintenanceStatus.done)
                          .length;
 
                      return Column(
                        children: [
                          // ── Summary row ──
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16, 8, 16, 4),
                            child: Row(
                              children: [
                                _StatBadge(
                                  label: 'মোট',
                                  count: requests.length,
                                  color: primary,
                                ),
                                const SizedBox(width: 8),
                                _StatBadge(
                                  label: 'অপেক্ষমাণ',
                                  count: pendingCount,
                                  color: const Color(0xFFD97706),
                                ),
                                const SizedBox(width: 8),
                                _StatBadge(
                                  label: 'চলছে',
                                  count: inProgressCount,
                                  color: const Color(0xFF0891B2),
                                ),
                                const SizedBox(width: 8),
                                _StatBadge(
                                  label: 'সম্পন্ন',
                                  count: doneCount,
                                  color: const Color(0xFF16A34A),
                                ),
                              ],
                            ),
                          ),
 
                          // ── List ──
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: requests.length,
                              itemBuilder: (ctx, i) =>
                                  _TenantMaintenanceCard(
                                req: requests[i],
                                isDark: isDark,
                                primary: primary,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
      floatingActionButton: _tenantData == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _showAddRequestDialog,
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'অনুরোধ পাঠান',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
    );
  }
 
  Widget _buildEmptyState(
      Color primary, Color textPrimary, Color textSecondary) {
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
            child: Icon(
              Icons.build_outlined,
              size: 44,
              color: primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'কোনো অনুরোধ নেই',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'নিচের বাটন দিয়ে অনুরোধ পাঠান',
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
        ],
      ),
    );
  }
 
  Widget _buildErrorState(
      Color primary, Color textPrimary, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: Colors.orange.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'তথ্য পাওয়া যায়নি',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'সক্রিয় ভাড়াটিয়া হিসেবে যুক্ত আছেন কিনা নিশ্চিত করুন',
            style: TextStyle(fontSize: 13, color: textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
 
// ── Stat Badge (read-only summary, no filter tap needed) ──────
 
class _StatBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
 
  const _StatBadge({
    required this.label,
    required this.count,
    required this.color,
  });
 
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
// ── Tenant Maintenance Card (read-only, no status buttons) ────
 
class _TenantMaintenanceCard extends StatelessWidget {
  final MaintenanceModel req;
  final bool isDark;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
 
  const _TenantMaintenanceCard({
    required this.req,
    required this.isDark,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
  });
 
  Color get _statusColor =>
      Color(int.parse('FF${req.statusColorHex}', radix: 16));
 
  IconData get _statusIcon {
    switch (req.status) {
      case MaintenanceStatus.pending:
        return Icons.hourglass_empty_rounded;
      case MaintenanceStatus.inProgress:
        return Icons.construction_rounded;
      case MaintenanceStatus.done:
        return Icons.check_circle_outline_rounded;
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final divider =
        isDark ? Colors.white10 : const Color(0xFFE5E7EB);
    final statusColor = _statusColor;
 
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        // Left border accent — status color
        border: Border(
          left: BorderSide(color: statusColor, width: 4),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title + Status badge ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.build_circle_outlined,
                      size: 18,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      req.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon,
                            size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          req.statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
 
              const SizedBox(height: 12),
              Divider(height: 1, color: divider),
              const SizedBox(height: 12),
 
              // ── Description ──
              Text(
                req.description,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
 
              const SizedBox(height: 10),
 
              // ── Date ──
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 11,
                    color: textSecondary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${req.createdAt.day}/${req.createdAt.month}/${req.createdAt.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary.withOpacity(0.7),
                    ),
                  ),
 
                  // "সম্পন্ন" হলে একটা ছোট done indicator
                  if (req.status == MaintenanceStatus.done) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 12,
                            color: Color(0xFF16A34A),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'কাজ হয়েছে',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}













