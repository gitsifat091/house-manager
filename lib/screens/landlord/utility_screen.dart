// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../services/auth_service.dart';
// import '../../../services/utility_service.dart';
// import '../../../models/utility_model.dart';
// import '../../../models/tenant_model.dart';
// import '../shared/notification_screen.dart';
// import '../../../models/tenant_model.dart';
// import '../../../widgets/tenant_avatar.dart';
// import 'tenant_detail_screen.dart';

// class UtilityScreen extends StatefulWidget {
//   const UtilityScreen({super.key});

//   @override
//   State<UtilityScreen> createState() => _UtilityScreenState();
// }

// class _UtilityScreenState extends State<UtilityScreen> {
//   int _selectedMonth = DateTime.now().month;
//   int _selectedYear = DateTime.now().year;

//   final List<String> _months = [
//     '', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
//     'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর',
//     'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final user = context.read<AuthService>().currentUser!;
//     final service = UtilityService();

//     return Scaffold(
//       appBar: AppBar(title: const Text('ইউটিলিটি বিল'), centerTitle: true),
//       body: Column(
//         children: [
//           // Month selector
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
//                   onPressed: () => setState(() {
//                     if (_selectedMonth == 1) { _selectedMonth = 12; _selectedYear--; }
//                     else { _selectedMonth--; }
//                   }),
//                 ),
//                 Expanded(
//                   child: Center(
//                     child: Text('${_months[_selectedMonth]} $_selectedYear',
//                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.chevron_right_rounded),
//                   onPressed: () => setState(() {
//                     if (_selectedMonth == 12) { _selectedMonth = 1; _selectedYear++; }
//                     else { _selectedMonth++; }
//                   }),
//                 ),
//               ],
//             ),
//           ),

//           // Bill list
//           Expanded(
//   child: StreamBuilder<List<UtilityModel>>(
//     stream: service.getLandlordBills(user.uid),
//     builder: (context, snap) {
//       if (snap.connectionState == ConnectionState.waiting) {
//         return const Center(child: CircularProgressIndicator());
//       }
//       final all = snap.data ?? [];
//       final bills = all.where((b) =>
//           b.month == _selectedMonth && b.year == _selectedYear).toList();

//       if (bills.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text('💡', style: TextStyle(fontSize: 64)),
//               const SizedBox(height: 16),
//               const Text('এই মাসের কোনো বিল নেই',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               const Text('নিচের + বাটন দিয়ে বিল যোগ করুন'),
//             ],
//           ),
//         );
//       }

//       // Summary
//       final totalBills = bills.fold(0.0, (sum, b) => sum + b.amount);
//       final paidBills = bills.where((b) => b.isPaid).fold(0.0, (sum, b) => sum + b.amount);

//       // Group by tenant
//       final Map<String, List<UtilityModel>> grouped = {};
//       for (final bill in bills) {
//         final key = '${bill.tenantId}_${bill.tenantName}_${bill.roomNumber}';
//         grouped.putIfAbsent(key, () => []).add(bill);
//       }

//       return Column(
//         children: [
//           // Summary row
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//             child: Row(
//               children: [
//                 Expanded(child: _StatCard(
//                   label: 'মোট বিল', value: '৳${totalBills.toStringAsFixed(0)}',
//                   color: Colors.blue, icon: Icons.receipt_outlined,
//                 )),
//                 const SizedBox(width: 10),
//                 Expanded(child: _StatCard(
//                   label: 'পরিশোধ', value: '৳${paidBills.toStringAsFixed(0)}',
//                   color: Colors.green, icon: Icons.check_circle_outline,
//                 )),
//                 const SizedBox(width: 10),
//                 Expanded(child: _StatCard(
//                   label: 'বাকি',
//                   value: '৳${(totalBills - paidBills).toStringAsFixed(0)}',
//                   color: Colors.orange, icon: Icons.pending_outlined,
//                 )),
//               ],
//             ),
//           ),

//           // Grouped list
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: grouped.length,
//               itemBuilder: (ctx, i) {
//                 final entry = grouped.entries.elementAt(i);
//                 final tenantBills = entry.value;
//                 final tenantName = tenantBills.first.tenantName;
//                 final roomNumber = tenantBills.first.roomNumber;
//                 final tenantTotal = tenantBills.fold(0.0, (s, b) => s + b.amount);
//                 final tenantPaid = tenantBills.where((b) => b.isPaid).fold(0.0, (s, b) => s + b.amount);
//                 final allPaid = tenantBills.every((b) => b.isPaid);

//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 14),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.surface,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: allPaid
//                           ? Colors.green.withOpacity(0.4)
//                           : Theme.of(context).colorScheme.outlineVariant,
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       // Tenant header
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 14, vertical: 12),
//                         decoration: BoxDecoration(
//                           color: allPaid
//                               ? Colors.green.withOpacity(0.08)
//                               : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
//                           borderRadius: const BorderRadius.vertical(
//                               top: Radius.circular(16)),
//                         ),
//                         child: Row(
//                           children: [
//                             // CircleAvatar(
//                             //   radius: 18,
//                             //   backgroundColor: Theme.of(context).colorScheme.primary,
//                             //   child: Text(
//                             //     tenantName.isNotEmpty ? tenantName[0].toUpperCase() : '?',
//                             //     style: const TextStyle(
//                             //         color: Colors.white,
//                             //         fontWeight: FontWeight.bold,
//                             //         fontSize: 14),
//                             //   ),
//                             // ),
//                             GestureDetector(
//                               onTap: () async {
//                                 final snap = await FirebaseFirestore.instance
//                                     .collection('tenants')
//                                     .doc(tenantBills.first.tenantId)
//                                     .get();
//                                 if (snap.exists && context.mounted) {
//                                   final tenant = TenantModel.fromMap(snap.data()!, snap.id);
//                                   Navigator.push(context, MaterialPageRoute(
//                                     builder: (_) => TenantDetailScreen(tenant: tenant),
//                                   ));
//                                 }
//                               },
//                               child: TenantAvatar(
//                                 tenantName: tenantName,
//                                 tenantEmail: '',
//                                 radius: 18,
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(tenantName,
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 15)),
//                                   Text('রুম $roomNumber',
//                                       style: TextStyle(
//                                           fontSize: 12,
//                                           color: Theme.of(context)
//                                               .colorScheme
//                                               .onSurface
//                                               .withOpacity(0.6))),
//                                 ],
//                               ),
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text('৳${tenantTotal.toStringAsFixed(0)}',
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 15)),
//                                 Text(
//                                   allPaid
//                                       ? 'সম্পূর্ণ পরিশোধ'
//                                       : 'বাকি: ৳${(tenantTotal - tenantPaid).toStringAsFixed(0)}',
//                                   style: TextStyle(
//                                       fontSize: 11,
//                                       color: allPaid
//                                           ? Colors.green.shade700
//                                           : Colors.orange.shade700,
//                                       fontWeight: FontWeight.w500),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Bill items
//                       ...tenantBills.map((bill) => Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 14, vertical: 8),
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 36, height: 36,
//                               decoration: BoxDecoration(
//                                 color: Theme.of(context)
//                                     .colorScheme
//                                     .surfaceVariant,
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Center(
//                                 child: Text(bill.typeIcon,
//                                     style: const TextStyle(fontSize: 18)),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                                       child: Text(bill.typeLabel,
//                                           style: const TextStyle(fontSize: 14)),
//                                       ),
//                                       Text('৳${bill.amount.toStringAsFixed(0)}',
//                                           style: const TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 14)),
//                                       const SizedBox(width: 8),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 8, vertical: 2),
//                                         decoration: BoxDecoration(
//                                           color: bill.isPaid
//                                               ? Colors.green.shade100
//                                               : Colors.orange.shade100,
//                                           borderRadius: BorderRadius.circular(20),
//                                         ),
//                                         child: Text(
//                                           bill.isPaid ? 'পরিশোধ' : 'বাকি',
//                                           style: TextStyle(
//                                             fontSize: 11,
//                                             fontWeight: FontWeight.w500,
//                                             color: bill.isPaid
//                                                 ? Colors.green.shade800
//                                                 : Colors.orange.shade800,
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(width: 4),
//                                       // Action buttons
//                                       bill.isPaid
//                                           ? IconButton(
//                                               icon: Icon(Icons.undo_rounded,
//                                                   size: 18,
//                                                   color: Theme.of(context)
//                                                       .colorScheme
//                                                       .onSurface
//                                                       .withOpacity(0.4)),
//                                               onPressed: () =>
//                                                   service.markUnpaid(bill.id),
//                                               padding: EdgeInsets.zero,
//                                               constraints: const BoxConstraints(),
//                                             )
//                                           : IconButton(
//                                               icon: Icon(Icons.check_circle_outline,
//                                                   size: 18,
//                                                   color: Colors.green.shade600),
//                                               onPressed: () =>
//                                                   service.markPaid(bill.id),
//                                               padding: EdgeInsets.zero,
//                                               constraints: const BoxConstraints(),
//                                             ),
//                                       IconButton(
//                                         icon: const Icon(Icons.delete_outline,
//                                             color: Colors.red, size: 18),
//                                         onPressed: () =>
//                                             service.deleteBill(bill.id),
//                                         padding: EdgeInsets.zero,
//                                         constraints: const BoxConstraints(),
//                                       ),
//                                     ],
//                                   ),
//                                 )),

//                                 // "সব পরিশোধ" button
//                                 if (!allPaid)
//                                   Padding(
//                                     padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
//                                     child: SizedBox(
//                                       width: double.infinity,
//                                       child: OutlinedButton.icon(
//                                         onPressed: () async {
//                                           for (final bill in tenantBills) {
//                                             if (!bill.isPaid) {
//                                               await service.markPaid(bill.id);
//                                             }
//                                           }
//                                         },
//                                         icon: const Icon(Icons.done_all_rounded, size: 18),
//                                         label: const Text('সব পরিশোধ করুন'),
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _showAddBillDialog(context, user.uid),
//         icon: const Icon(Icons.add),
//         label: const Text('বিল যোগ করুন'),
//       ),
//     );
//   }

//   void _showAddBillDialog(BuildContext context, String landlordId) async {
//     // Load tenants
//     final snap = await FirebaseFirestore.instance
//         .collection('tenants')
//         .where('landlordId', isEqualTo: landlordId)
//         .where('isActive', isEqualTo: true)
//         .get();

//     final tenants = snap.docs
//         .map((d) => TenantModel.fromMap(d.data(), d.id))
//         .toList();

//     if (tenants.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('কোনো active ভাড়াটিয়া নেই')));
//       }
//       return;
//     }

//     TenantModel? selectedTenant = tenants.first;
//     UtilityType selectedType = UtilityType.electricity;
//     final amountCtrl = TextEditingController();
//     final formKey = GlobalKey<FormState>();

//     if (!mounted) return;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (ctx) => StatefulBuilder(
//         builder: (ctx, setModalState) => Padding(
//           padding: EdgeInsets.only(
//             left: 20, right: 20, top: 20,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//           ),
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('নতুন বিল যোগ করুন',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 16),

//                 // Tenant dropdown
//                 DropdownButtonFormField<TenantModel>(
//                   value: selectedTenant,
//                   decoration: const InputDecoration(labelText: 'ভাড়াটিয়া'),
//                   items: tenants.map((t) => DropdownMenuItem(
//                     value: t,
//                     child: Text('${t.name} (রুম ${t.roomNumber})'),
//                   )).toList(),
//                   onChanged: (t) => setModalState(() => selectedTenant = t),
//                 ),
//                 const SizedBox(height: 12),

//                 // Type selector
//                 const Text('বিলের ধরন',
//                     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   children: UtilityType.values.map((type) {
//                     final labels = ['গ্যাস', 'বিদ্যুৎ', 'পানি', 'অন্যান্য'];
//                     final icons = ['🔥', '⚡', '💧', '📋'];
//                     final idx = UtilityType.values.indexOf(type);
//                     return ChoiceChip(
//                       label: Text('${icons[idx]} ${labels[idx]}'),
//                       selected: selectedType == type,
//                       onSelected: (_) => setModalState(() => selectedType = type),
//                     );
//                   }).toList(),
//                 ),
//                 const SizedBox(height: 12),

//                 TextFormField(
//                   controller: amountCtrl,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     labelText: 'পরিমাণ (৳)',
//                     hintText: 'যেমন: 500',
//                   ),
//                   validator: (v) {
//                     if (v!.isEmpty) return 'পরিমাণ দিন';
//                     if (double.tryParse(v) == null) return 'সঠিক পরিমাণ দিন';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 SizedBox(
//                   width: double.infinity, height: 50,
//                   child: FilledButton(
//                     onPressed: () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final bill = UtilityModel(
//                         id: '',
//                         tenantId: selectedTenant!.id,
//                         tenantName: selectedTenant!.name,
//                         roomNumber: selectedTenant!.roomNumber,
//                         propertyId: selectedTenant!.propertyId,
//                         propertyName: selectedTenant!.propertyName,
//                         landlordId: landlordId,
//                         type: selectedType,
//                         amount: double.parse(amountCtrl.text.trim()),
//                         month: _selectedMonth,
//                         year: _selectedYear,
//                         createdAt: DateTime.now(),
//                       );
//                       await UtilityService().addBill(bill);
//                       if (ctx.mounted) Navigator.pop(ctx);
//                     },
//                     child: const Text('বিল Save করুন'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;
//   final IconData icon;
//   const _StatCard({required this.label, required this.value, required this.color, required this.icon});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(height: 4),
//           Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
//           Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
//         ],
//       ),
//     );
//   }
// }

// class _BillCard extends StatelessWidget {
//   final UtilityModel bill;
//   final UtilityService service;
//   const _BillCard({required this.bill, required this.service});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Row(
//           children: [
//             Container(
//               width: 48, height: 48,
//               decoration: BoxDecoration(
//                 color: color.surfaceVariant,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Center(
//                 child: Text(bill.typeIcon, style: const TextStyle(fontSize: 24)),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(bill.typeLabel,
//                       style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
//                   Text('${bill.tenantName} • রুম ${bill.roomNumber}',
//                       style: TextStyle(fontSize: 12, color: color.onSurface.withOpacity(0.6))),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Text('৳${bill.amount.toStringAsFixed(0)}',
//                           style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
//                       const SizedBox(width: 8),
//                       // Container(
//                       //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                       //   decoration: BoxDecoration(
//                       //     color: bill.isPaid ? Colors.green.shade100 : Colors.orange.shade100,
//                       //     borderRadius: BorderRadius.circular(20),
//                       //   ),
//                       //   child: Text(
//                       //     bill.isPaid ? 'পরিশোধ' : 'বাকি',
//                       //     style: TextStyle(
//                       //       fontSize: 11, fontWeight: FontWeight.w500,
//                       //       color: bill.isPaid ? Colors.green.shade800 : Colors.orange.shade800,
//                       //     ),
//                       //   ),
//                       // ),
//                       // _BillCard এ status pill:
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: bill.isPaid
//                               ? Colors.green.shade100
//                               : bill.isSubmitted
//                                   ? Colors.blue.shade100
//                                   : Colors.orange.shade100,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           bill.isPaid ? 'পরিশোধ' : bill.isSubmitted ? 'যাচাই চলছে' : 'বাকি',
//                           style: TextStyle(
//                             fontSize: 11, fontWeight: FontWeight.w500,
//                             color: bill.isPaid
//                                 ? Colors.green.shade800
//                                 : bill.isSubmitted
//                                     ? Colors.blue.shade800
//                                     : Colors.orange.shade800,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // Column(
//             //   children: [
//             //     bill.isPaid
//             //         ? IconButton(
//             //             icon: Icon(Icons.undo_rounded, color: color.onSurface.withOpacity(0.4)),
//             //             onPressed: () => service.markUnpaid(bill.id),
//             //           )
//             //         : FilledButton.tonal(
//             //             onPressed: () => service.markPaid(bill.id),
//             //             style: FilledButton.styleFrom(
//             //                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
//             //             child: const Text('পরিশোধ', style: TextStyle(fontSize: 12)),
//             //           ),
//             //     IconButton(
//             //       icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
//             //       onPressed: () => service.deleteBill(bill.id),
//             //     ),
//             //   ],
//             // ),
//             // Replace করো:
//             Column(
//               children: [
//                 bill.isPaid
//                     ? IconButton(
//                         icon: Icon(Icons.undo_rounded,
//                             size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
//                         onPressed: () => service.markUnpaid(bill.id),
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                       )
//                     : bill.isSubmitted
//                         // যাচাইয়ের অপেক্ষায় — approve/reject
//                         ? Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.close_rounded, color: Colors.red, size: 18),
//                                 onPressed: () => service.rejectBill(bill.id),
//                                 padding: EdgeInsets.zero,
//                                 constraints: const BoxConstraints(),
//                                 tooltip: 'বাতিল',
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.check_circle_outline_rounded,
//                                     color: Colors.green, size: 18),
//                                 onPressed: () => service.approveBill(bill.id),
//                                 padding: EdgeInsets.zero,
//                                 constraints: const BoxConstraints(),
//                                 tooltip: 'অনুমোদন',
//                               ),
//                             ],
//                           )
//                         // Pending — কোনো action নেই (tenant submit করবে)
//                         : const SizedBox(width: 36),
//                 IconButton(
//                   icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
//                   onPressed: () => service.deleteBill(bill.id),
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../../../services/utility_service.dart';
import '../../../models/utility_model.dart';
import '../../../models/tenant_model.dart';
import '../shared/notification_screen.dart';
import '../../../widgets/tenant_avatar.dart';
import 'tenant_detail_screen.dart';

class UtilityScreen extends StatefulWidget {
  // const UtilityScreen({super.key});
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const UtilityScreen({super.key, this.scaffoldKey});

  @override
  State<UtilityScreen> createState() => _UtilityScreenState();
}

class _UtilityScreenState extends State<UtilityScreen>
    with SingleTickerProviderStateMixin {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

    final user = context.read<AuthService>().currentUser!;
    final service = UtilityService();

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: StreamBuilder<List<UtilityModel>>(
          stream: service.getLandlordBills(user.uid),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primary));
            }

            final all = snap.data ?? [];
            final bills = all
                .where((b) =>
                    b.month == _selectedMonth && b.year == _selectedYear)
                .toList();

            // Stats
            final totalBills =
                bills.fold(0.0, (sum, b) => sum + b.amount);
            final paidBills = bills
                .where((b) => b.isPaid)
                .fold(0.0, (sum, b) => sum + b.amount);
            final pendingBills = totalBills - paidBills;

            // Group by tenant
            final Map<String, List<UtilityModel>> grouped = {};
            for (final bill in bills) {
              final key =
                  '${bill.tenantId}_${bill.tenantName}_${bill.roomNumber}';
              grouped.putIfAbsent(key, () => []).add(bill);
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
                  // automaticallyImplyLeading: false,
                  leading: IconButton(              // ← এটা যোগ করো
                    icon: Icon(Icons.menu_rounded, color: textPrimary),
                    onPressed: () => widget.scaffoldKey?.currentState?.openDrawer(),
                  ),
                  title: Text(
                    'ইউটিলিটি বিল',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    NotificationBell(userId: user.uid),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeader(
                      primary: primary,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      totalBills: totalBills,
                      paidBills: paidBills,
                      pendingBills: pendingBills,
                      count: bills.length,
                    ),
                  ),
                ),

                // ── Month Selector ─────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              onTap: () => setState(() {
                                if (_selectedMonth == 1) {
                                  _selectedMonth = 12;
                                  _selectedYear--;
                                } else {
                                  _selectedMonth--;
                                }
                              }),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Icon(Icons.chevron_left_rounded,
                                    color: primary, size: 26),
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
                                Text('$_selectedYear',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: textSecondary)),
                              ],
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              onTap: () => setState(() {
                                if (_selectedMonth == 12) {
                                  _selectedMonth = 1;
                                  _selectedYear++;
                                } else {
                                  _selectedMonth++;
                                }
                              }),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Icon(Icons.chevron_right_rounded,
                                    color: primary, size: 26),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Content ────────────────────────────
                bills.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmptyState(primary, textSecondary),
                      )
                    : SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) {
                              final entry =
                                  grouped.entries.elementAt(i);
                              final tenantBills = entry.value;
                              return _TenantBillGroup(
                                tenantBills: tenantBills,
                                service: service,
                                isDark: isDark,
                                cardBg: cardBg,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                primary: primary,
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
      floatingActionButton: Builder(builder: (ctx) {
        final user = ctx.read<AuthService>().currentUser!;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () =>
                _showAddBillDialog(context, user.uid),
            backgroundColor: Theme.of(ctx).colorScheme.primary,  // ← এটা যোগ করো
            foregroundColor: Colors.white,                     // ← এটা যোগ করো
            elevation: 4,                                        // ← এটা যোগ করো    
            icon: const Icon(Icons.add_rounded),
            label: const Text('বিল যোগ করুন',
                style: TextStyle(fontWeight: FontWeight.w700)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
        );
      }),
    );
  }

  // ── Gradient Header with Stats ────────────────────────────
  Widget _buildHeader({
    required Color primary,
    required bool isDark,
    required Color textPrimary,
    required double totalBills,
    required double paidBills,
    required double pendingBills,
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
                  icon: Icons.receipt_long_rounded,
                  label: 'মোট বিল',
                  amount: '৳${totalBills.toStringAsFixed(0)}',
                  sub: '$count টি বিল',
                  // color: const Color(0xFF0891B2),
                  color: primary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  icon: Icons.check_circle_rounded,
                  label: 'পরিশোধ',
                  amount: '৳${paidBills.toStringAsFixed(0)}',
                  sub: 'পরিশোধিত',
                  // color: Colors.green,
                  color: const Color(0xFF059669),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  icon: Icons.pending_rounded,
                  label: 'বাকি',
                  amount: '৳${pendingBills.toStringAsFixed(0)}',
                  sub: 'অপরিশোধিত',
                  // color: Colors.orange,
                  color: const Color(0xFFD97706),
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
            child: Text(amount,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: color.withOpacity(0.8)),
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
          const Text('এই মাসের কোনো বিল নেই',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('নিচের + বাটন দিয়ে বিল যোগ করুন',
              style: TextStyle(fontSize: 14, color: textSecondary)),
        ],
      ),
    );
  }

  // ── Add Bill Dialog ───────────────────────────────────────
  void _showAddBillDialog(BuildContext context, String landlordId) async {
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final sheetBg =
        isDark ? const Color(0xFF1A2C22) : Colors.white;
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary =
        isDark ? Colors.white54 : const Color(0xFF6B7280);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            // bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
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

                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bolt_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text('নতুন বিল যোগ করুন',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary)),
                  ],
                ),
                const SizedBox(height: 20),

                // Tenant
                Text('ভাড়াটিয়া বেছে নিন',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                        letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: primary.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14),
                  child: DropdownButtonFormField<TenantModel>(
                    value: selectedTenant,
                    isExpanded: true,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true),
                    dropdownColor: sheetBg,
                    items: tenants
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                  '${t.name}  •  রুম ${t.roomNumber}',
                                  style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: (t) =>
                        setModalState(() => selectedTenant = t),
                  ),
                ),
                const SizedBox(height: 16),

                // Bill type
                Text('বিলের ধরন',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                        letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: UtilityType.values.map((type) {
                    final labels = [
                      'গ্যাস', 'বিদ্যুৎ', 'পানি', 'অন্যান্য'
                    ];
                    final icons = ['🔥', '⚡', '💧', '📋'];
                    final idx = UtilityType.values.indexOf(type);
                    final isSelected = selectedType == type;
                    return GestureDetector(
                      onTap: () =>
                          setModalState(() => selectedType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
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
                          '${icons[idx]} ${labels[idx]}',
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

                // Amount
                Text('পরিমাণ',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                        letterSpacing: 0.5)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'যেমন: 500',
                    hintStyle: TextStyle(
                        color: textSecondary.withOpacity(0.6)),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('৳',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary)),
                    ),
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
                  validator: (v) {
                    if (v!.isEmpty) return 'পরিমাণ দিন';
                    if (double.tryParse(v) == null)
                      return 'সঠিক পরিমাণ দিন';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Save button
                GestureDetector(
                  onTap: () async {
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
                      amount:
                          double.parse(amountCtrl.text.trim()),
                      month: _selectedMonth,
                      year: _selectedYear,
                      createdAt: DateTime.now(),
                    );
                    await UtilityService().addBill(bill);
                    if (ctx.mounted) Navigator.pop(ctx);
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
                        Icon(Icons.save_rounded,
                            color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text('বিল Save করুন',
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Tenant Bill Group Card
// ─────────────────────────────────────────────────────────────
class _TenantBillGroup extends StatelessWidget {
  final List<UtilityModel> tenantBills;
  final UtilityService service;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color primary;

  const _TenantBillGroup({
    required this.tenantBills,
    required this.service,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final tenantName = tenantBills.first.tenantName;
    final roomNumber = tenantBills.first.roomNumber;
    final tenantTotal =
        tenantBills.fold(0.0, (s, b) => s + b.amount);
    final tenantPaid = tenantBills
        .where((b) => b.isPaid)
        .fold(0.0, (s, b) => s + b.amount);
    final allPaid = tenantBills.every((b) => b.isPaid);
    final hasSubmitted =
        tenantBills.any((b) => b.isSubmitted && !b.isPaid);

    final headerColor = allPaid
        ? Colors.green
        : hasSubmitted
            ? const Color(0xFF0891B2)
            : primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Column(
        children: [
          // ── Tenant Header ─────────────────────────────
          GestureDetector(
            onTap: () async {
              final snap = await FirebaseFirestore.instance
                  .collection('tenants')
                  .doc(tenantBills.first.tenantId)
                  .get();
              if (snap.exists && context.mounted) {
                final tenant =
                    TenantModel.fromMap(snap.data()!, snap.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          TenantDetailScreen(tenant: tenant)),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: headerColor.withOpacity(isDark ? 0.15 : 0.08),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18)),
                border: Border(
                  bottom: BorderSide(
                      color: headerColor.withOpacity(0.15)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: headerColor.withOpacity(0.5),
                          width: 2),
                    ),
                    child: TenantAvatar(
                      tenantName: tenantName,
                      tenantEmail: '',
                      radius: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tenantName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: textPrimary)),
                        Text('রুম $roomNumber',
                            style: TextStyle(
                                fontSize: 12,
                                color: textSecondary)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '৳${tenantTotal.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: textPrimary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              headerColor.withOpacity(0.15),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          allPaid
                              ? 'সম্পূর্ণ পরিশোধ'
                              : 'বাকি: ৳${(tenantTotal - tenantPaid).toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 11,
                              color: headerColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Bill Items ────────────────────────────────
          ...tenantBills.asMap().entries.map((entry) {
            final idx = entry.key;
            final bill = entry.value;
            final isLast = idx == tenantBills.length - 1;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      // Bill type icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.grey.shade100,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(bill.typeIcon,
                              style: const TextStyle(
                                  fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(bill.typeLabel,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textPrimary)),
                      ),
                      // Amount
                      Text(
                        '৳${bill.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: textPrimary),
                      ),
                      const SizedBox(width: 8),
                      // Status badge
                      _statusBadge(bill),
                      const SizedBox(width: 6),
                      // Actions
                      _actionButtons(bill),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                      height: 1,
                      indent: 68,
                      color: isDark
                          ? Colors.white10
                          : Colors.grey.shade100),
              ],
            );
          }),

          // ── Mark All Paid button ──────────────────────
          if (!allPaid) ...[
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 4, 16, 14),
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
                  icon: const Icon(Icons.done_all_rounded,
                      size: 18),
                  label: const Text('সব পরিশোধ করুন'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10),
                  ),
                ),
              ),
            ),
          ] else
            const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _statusBadge(UtilityModel bill) {
    Color bg;
    Color fg;
    String label;

    if (bill.isPaid) {
      bg = Colors.green.shade100;
      fg = Colors.green.shade800;
      label = 'পরিশোধ';
    } else if (bill.isSubmitted) {
      bg = Colors.blue.shade100;
      fg = Colors.blue.shade800;
      label = 'যাচাই';
    } else {
      bg = Colors.orange.shade100;
      fg = Colors.orange.shade800;
      label = 'বাকি';
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: fg)),
    );
  }

  Widget _actionButtons(UtilityModel bill) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (bill.isPaid)
          _iconBtn(
            icon: Icons.undo_rounded,
            color: Colors.grey,
            onTap: () => service.markUnpaid(bill.id),
          )
        else if (bill.isSubmitted) ...[
          _iconBtn(
            icon: Icons.close_rounded,
            color: Colors.red,
            onTap: () => service.rejectBill(bill.id),
          ),
          const SizedBox(width: 4),
          _iconBtn(
            icon: Icons.check_rounded,
            color: Colors.green,
            onTap: () => service.approveBill(bill.id),
          ),
        ] else
          _iconBtn(
            icon: Icons.check_circle_outline,
            color: Colors.green,
            onTap: () => service.markPaid(bill.id),
          ),
        const SizedBox(width: 4),
        _iconBtn(
          icon: Icons.delete_outline_rounded,
          color: Colors.red,
          onTap: () => service.deleteBill(bill.id),
        ),
      ],
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
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 15),
      ),
    );
  }
}