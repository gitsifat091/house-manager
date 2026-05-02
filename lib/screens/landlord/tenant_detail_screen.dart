// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../models/tenant_model.dart';
// import '../../../models/payment_model.dart';
// import '../../../widgets/tenant_avatar.dart';
// import 'landlord_edit_tenant_screen.dart';

// class TenantDetailScreen extends StatelessWidget {
//   final TenantModel tenant;
//   const TenantDetailScreen({super.key, required this.tenant});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;

//     return Scaffold(
//       // backgroundColor: color.surfaceVariant.withOpacity(0.3),
//       body: CustomScrollView(
//         slivers: [
//           // ── Hero AppBar ──────────────────────────────────────
//           SliverAppBar(
//             expandedHeight: 240,
//             pinned: true,
//             backgroundColor: color.primary,
//             iconTheme: const IconThemeData(color: Colors.white),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.edit_rounded, color: Colors.white),
//                 onPressed: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => LandlordEditTenantScreen(tenant: tenant),
//                   ),
//                 ),
//               ),
//             ],
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       color.primary,
//                       color.primary.withOpacity(0.75),
//                     ],
//                   ),
//                 ),
//                 child: SafeArea(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const SizedBox(height: 40),
//                       // Avatar with white ring
//                       Container(
//                         padding: const EdgeInsets.all(3),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 2.5),
//                         ),
//                         child: TenantAvatar(
//                           tenantName: tenant.name,
//                           tenantEmail: tenant.email,
//                           radius: 46,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       SelectableText(
//                         tenant.name,
//                         style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       // Property + Room pill
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 14, vertical: 5),
//                         decoration: BoxDecoration(
//                           color: Colors.white24,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.home_work_outlined,
//                                 size: 14, color: Colors.white70),
//                             const SizedBox(width: 5),
//                             Text(
//                               '${tenant.propertyName}  •  রুম ${tenant.roomNumber}',
//                               style: const TextStyle(
//                                   color: Colors.white, fontSize: 13),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // ── Stats Row ────────────────────────────────────────
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//               child: _StatsRow(tenant: tenant),
//             ),
//           ),

//           // ── Content ──────────────────────────────────────────
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _SectionLabel('ব্যক্তিগত তথ্য'),
//                   const SizedBox(height: 8),
//                   _Card(children: [
//                     _Row(Icons.phone_outlined, 'ফোন', tenant.phone),
//                     _Row(Icons.email_outlined, 'Email',
//                         tenant.email.isEmpty ? 'নেই' : tenant.email),
//                     _Row(Icons.badge_outlined, 'NID', tenant.nidNumber),
//                   ]),

//                   const SizedBox(height: 16),

//                   _SectionLabel('রুমের তথ্য'),
//                   const SizedBox(height: 8),
//                   _Card(children: [
//                     _Row(Icons.home_work_outlined, 'Property',
//                         tenant.propertyName),
//                     _Row(Icons.door_front_door_outlined, 'রুম নম্বর',
//                         tenant.roomNumber),
//                     _Row(Icons.currency_exchange_rounded, 'মাসিক ভাড়া',
//                         '৳${tenant.rentAmount.toStringAsFixed(0)}'),
//                   ]),

//                   const SizedBox(height: 16),

//                   _SectionLabel('প্রবেশের তথ্য'),
//                   const SizedBox(height: 8),
//                   _Card(children: [
//                     _Row(Icons.calendar_today_outlined, 'তারিখ',
//                         _formatDate(tenant.moveInDate)),
//                     _Row(Icons.access_time_rounded, 'সময়',
//                         _formatTime(tenant.moveInDate)),
//                     _Row(Icons.timelapse_rounded, 'কতদিন আছেন',
//                         _daysLiving(tenant.moveInDate)),
//                   ]),

//                   const SizedBox(height: 16),

//                   _SectionLabel('পেমেন্ট সারসংক্ষেপ'),
//                   const SizedBox(height: 8),
//                   _PaymentSummaryCard(tenantId: tenant.id),

//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime dt) {
//     const months = [
//       '', 'জানু', 'ফেব্রু', 'মার্চ', 'এপ্রিল',
//       'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টে',
//       'অক্টো', 'নভে', 'ডিসে'
//     ];
//     return '${dt.day} ${months[dt.month]} ${dt.year}';
//   }

//   String _formatTime(DateTime dt) {
//     final h = dt.hour.toString().padLeft(2, '0');
//     final m = dt.minute.toString().padLeft(2, '0');
//     return '$h:$m';
//   }

//   String _daysLiving(DateTime moveIn) {
//     final days = DateTime.now().difference(moveIn).inDays;
//     if (days < 30) return '$days দিন';
//     if (days < 365) return '${days ~/ 30} মাস ${days % 30} দিন';
//     return '${days ~/ 365} বছর ${(days % 365) ~/ 30} মাস';
//   }
// }

// // ── Stats Row ──────────────────────────────────────────────────────────────

// class _StatsRow extends StatelessWidget {
//   final TenantModel tenant;
//   const _StatsRow({required this.tenant});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     final days = DateTime.now().difference(tenant.moveInDate).inDays;

//     return Row(
//       children: [
//         _StatBox(
//           icon: Icons.payments_rounded,
//           label: 'মাসিক ভাড়া',
//           value: '৳${tenant.rentAmount.toStringAsFixed(0)}',
//           color: color,
//         ),
//         const SizedBox(width: 10),
//         _StatBox(
//           icon: Icons.calendar_month_rounded,
//           label: 'বসবাসকাল',
//           value: '$days দিন',
//           color: color,
//         ),
//       ],
//     );
//   }
// }

// class _StatBox extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final ColorScheme color;
//   const _StatBox({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//         decoration: BoxDecoration(
//           // color: color.primary.withOpacity(0.08),
//           color: color.primaryContainer.withOpacity(0.5),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: color.primary.withOpacity(0.15)),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: color.primary.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: color.primary, size: 18),
//             ),
//             const SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label,
//                     style: TextStyle(
//                         fontSize: 10,
//                         color: color.onSurface.withOpacity(0.5))),
//                 Text(value,
//                     style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: color.primary)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Payment Summary ────────────────────────────────────────────────────────

// class _PaymentSummaryCard extends StatelessWidget {
//   final String tenantId;
//   const _PaymentSummaryCard({required this.tenantId});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;

//     return FutureBuilder<QuerySnapshot>(
//       future: FirebaseFirestore.instance
//           .collection('payments')
//           .where('tenantId', isEqualTo: tenantId)
//           .get(),
//       builder: (context, snap) {
//         if (!snap.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final payments = snap.data!.docs
//             .map((d) =>
//             PaymentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
//             .toList();

//         final paidCount =
//             payments.where((p) => p.status == PaymentStatus.paid).length;
//         final pendingCount =
//             payments.where((p) => p.status == PaymentStatus.pending).length;
//         final totalPaid = payments
//             .where((p) => p.status == PaymentStatus.paid)
//             .fold(0.0, (sum, p) => sum + p.amount);

//         return Row(
//           children: [
//             _PayBox(
//               label: 'পরিশোধ',
//               value: '$paidCount মাস',
//               icon: Icons.check_circle_outline,
//               bg: Colors.green.withOpacity(0.1),
//               iconColor: Colors.green,
//               textColor: Colors.green.shade700,
//             ),
//             const SizedBox(width: 10),
//             _PayBox(
//               label: 'বাকি',
//               value: '$pendingCount মাস',
//               icon: Icons.pending_outlined,
//               bg: Colors.orange.withOpacity(0.1),
//               iconColor: Colors.orange,
//               textColor: Colors.orange.shade700,
//             ),
//             const SizedBox(width: 10),
//             _PayBox(
//               label: 'মোট দেওয়া',
//               value: '৳${totalPaid.toStringAsFixed(0)}',
//               icon: Icons.account_balance_wallet_outlined,
//               bg: color.primary.withOpacity(0.08),
//               iconColor: color.primary,
//               textColor: color.primary,
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class _PayBox extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color bg;
//   final Color iconColor;
//   final Color textColor;
//   const _PayBox({
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.bg,
//     required this.iconColor,
//     required this.textColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
//         decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: iconColor, size: 22),
//             const SizedBox(height: 6),
//             Text(value,
//                 style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.bold,
//                     color: textColor)),
//             const SizedBox(height: 2),
//             Text(label,
//                 style: TextStyle(
//                     fontSize: 10,
//                     color: textColor.withOpacity(0.7))),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Shared Widgets ─────────────────────────────────────────────────────────

// class _SectionLabel extends StatelessWidget {
//   final String text;
//   const _SectionLabel(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Text(text,
//         style: TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.bold,
//           color: Theme.of(context).colorScheme.primary,
//           letterSpacing: 0.3,
//         ));
//   }
// }

// class _Card extends StatelessWidget {
//   final List<Widget> children;
//   const _Card({required this.children});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     return Container(
//       decoration: BoxDecoration(
//         color: color.surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color.outlineVariant.withOpacity(0.5)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),

//       child: Column(
//         children: children
//             .asMap()
//             .entries
//             .map((e) => Column(
//           children: [
//             e.value,
//             if (e.key < children.length - 1)
//               Divider(
//                   height: 1,
//                   indent: 16,
//                   endIndent: 16,
//                   color: color.outlineVariant.withOpacity(0.5)),
//           ],
//         ))
//             .toList(),
//       ),
//     );
//   }
// }

// class _Row extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   const _Row(this.icon, this.label, this.value);

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: color.primary.withOpacity(0.8)),
//           const SizedBox(width: 12),
//           Text(label,
//               style: TextStyle(
//                   fontSize: 13, color: color.onSurface.withOpacity(0.5))),
//           Expanded(
//             child: Text(value,
//                 textAlign: TextAlign.right,
//                 style: const TextStyle(
//                     fontSize: 13, fontWeight: FontWeight.w600)),
//           ),
//         ],
//       ),
//     );
//   }
// }









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
      // backgroundColor: color.surfaceVariant.withOpacity(0.3),
      body: CustomScrollView(
        slivers: [
          // ── Hero AppBar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: color.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LandlordEditTenantScreen(tenant: tenant),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.primary,
                      color.primary.withOpacity(0.75),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar with white ring
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: TenantAvatar(
                          tenantName: tenant.name,
                          tenantEmail: tenant.email,
                          radius: 46,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tenant.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Property + Room pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.home_work_outlined,
                                size: 14, color: Colors.white70),
                            const SizedBox(width: 5),
                            Text(
                              '${tenant.propertyName}  •  রুম ${tenant.roomNumber}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Stats Row ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _StatsRow(tenant: tenant),
            ),
          ),

          // ── Content ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('ব্যক্তিগত তথ্য'),
                  const SizedBox(height: 8),
                  _Card(children: [
                    _Row(Icons.phone_outlined, 'ফোন', tenant.phone, selectable: true),
                    _Row(Icons.email_outlined, 'Email',
                        tenant.email.isEmpty ? 'নেই' : tenant.email, selectable: true),
                    _Row(Icons.badge_outlined, 'NID', tenant.nidNumber, selectable: true),
                  ]),

                  const SizedBox(height: 16),

                  _SectionLabel('রুমের তথ্য'),
                  const SizedBox(height: 8),
                  _Card(children: [
                    _Row(Icons.home_work_outlined, 'Property',
                        tenant.propertyName),
                    _Row(Icons.door_front_door_outlined, 'রুম নম্বর',
                        tenant.roomNumber),
                    _Row(Icons.currency_exchange_rounded, 'মাসিক ভাড়া',
                        '৳${tenant.rentAmount.toStringAsFixed(0)}'),
                  ]),

                  const SizedBox(height: 16),

                  _SectionLabel('প্রবেশের তথ্য'),
                  const SizedBox(height: 8),
                  _Card(children: [
                    _Row(Icons.calendar_today_outlined, 'তারিখ',
                        _formatDate(tenant.moveInDate)),
                    _Row(Icons.access_time_rounded, 'সময়',
                        _formatTime(tenant.moveInDate)),
                    _Row(Icons.timelapse_rounded, 'কতদিন আছেন',
                        _daysLiving(tenant.moveInDate)),
                  ]),

                  const SizedBox(height: 16),

                  _SectionLabel('পেমেন্ট সারসংক্ষেপ'),
                  const SizedBox(height: 8),
                  _PaymentSummaryCard(tenantId: tenant.id),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'জানু', 'ফেব্রু', 'মার্চ', 'এপ্রিল',
      'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টে',
      'অক্টো', 'নভে', 'ডিসে'
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

// ── Stats Row ──────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final TenantModel tenant;
  const _StatsRow({required this.tenant});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final days = DateTime.now().difference(tenant.moveInDate).inDays;

    return Row(
      children: [
        _StatBox(
          icon: Icons.payments_rounded,
          label: 'মাসিক ভাড়া',
          value: '৳${tenant.rentAmount.toStringAsFixed(0)}',
          color: color,
        ),
        const SizedBox(width: 10),
        _StatBox(
          icon: Icons.calendar_month_rounded,
          label: 'বসবাসকাল',
          value: '$days দিন',
          color: color,
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme color;
  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          // color: color.primary.withOpacity(0.08),
          color: color.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.primary.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 10,
                        color: color.onSurface.withOpacity(0.5))),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Payment Summary ────────────────────────────────────────────────────────

class _PaymentSummaryCard extends StatelessWidget {
  final String tenantId;
  const _PaymentSummaryCard({required this.tenantId});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

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
            .map((d) =>
            PaymentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList();

        final paidCount =
            payments.where((p) => p.status == PaymentStatus.paid).length;
        final pendingCount =
            payments.where((p) => p.status == PaymentStatus.pending).length;
        final totalPaid = payments
            .where((p) => p.status == PaymentStatus.paid)
            .fold(0.0, (sum, p) => sum + p.amount);

        return Row(
          children: [
            _PayBox(
              label: 'পরিশোধ',
              value: '$paidCount মাস',
              icon: Icons.check_circle_outline,
              bg: Colors.green.withOpacity(0.1),
              iconColor: Colors.green,
              textColor: Colors.green.shade700,
            ),
            const SizedBox(width: 10),
            _PayBox(
              label: 'বাকি',
              value: '$pendingCount মাস',
              icon: Icons.pending_outlined,
              bg: Colors.orange.withOpacity(0.1),
              iconColor: Colors.orange,
              textColor: Colors.orange.shade700,
            ),
            const SizedBox(width: 10),
            _PayBox(
              label: 'মোট দেওয়া',
              value: '৳${totalPaid.toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet_outlined,
              bg: color.primary.withOpacity(0.08),
              iconColor: color.primary,
              textColor: color.primary,
            ),
          ],
        );
      },
    );
  }
}

class _PayBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color bg;
  final Color iconColor;
  final Color textColor;
  const _PayBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.bg,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: textColor.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.3,
        ));
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
                  color: color.outlineVariant.withOpacity(0.5)),
          ],
        ))
            .toList(),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool selectable;
  const _Row(this.icon, this.label, this.value, {this.selectable = false});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color.primary.withOpacity(0.8)),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 13, color: color.onSurface.withOpacity(0.5))),
          Expanded(
            child: selectable
                ? SelectableText(
                    value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  )
                : Text(
                    value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }
}