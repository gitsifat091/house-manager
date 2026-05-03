// import 'package:flutter/material.dart';
// import '../../models/property_model.dart';
// import '../../models/room_model.dart';
// import '../../services/property_service.dart';
// import 'add_edit_room_screen.dart';

// class RoomListScreen extends StatelessWidget {
//   final PropertyModel property;
//   const RoomListScreen({super.key, required this.property});

//   int _naturalCompare(String a, String b) {
//     final regExp = RegExp(r'(\D*)(\d*)');
//     final aMatches = regExp.allMatches(a).toList();
//     final bMatches = regExp.allMatches(b).toList();

//     for (int i = 0; i < aMatches.length && i < bMatches.length; i++) {
//       final aText = aMatches[i].group(1) ?? '';
//       final bText = bMatches[i].group(1) ?? '';
//       final aNum = int.tryParse(aMatches[i].group(2) ?? '') ?? -1;
//       final bNum = int.tryParse(bMatches[i].group(2) ?? '') ?? -1;

//       final textCmp = aText.compareTo(bText);
//       if (textCmp != 0) return textCmp;
//       if (aNum != bNum) return aNum.compareTo(bNum);
//     }
//     return a.compareTo(b);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final service = PropertyService();
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(property.name),
//         centerTitle: true,
//       ),
//       body: StreamBuilder<List<RoomModel>>(
//         // stream: service.getRooms(property.id),
//         stream: service.getRooms(property.id).map((rooms) {
//           rooms.sort((a, b) => _naturalCompare(a.roomNumber, b.roomNumber));
//           return rooms;
//         }),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final rooms = snap.data ?? [];
//           if (rooms.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.door_front_door_outlined, size: 80,
//                       color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
//                   const SizedBox(height: 16),
//                   const Text('কোনো রুম নেই',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   const Text('নিচের বাটন দিয়ে রুম যোগ করুন'),
//                 ],
//               ),
//             );
//           }
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: rooms.length,
//             itemBuilder: (ctx, i) => _RoomCard(
//               room: rooms[i],
//               service: service,
//               onEdit: () => Navigator.push(context, MaterialPageRoute(
//                 builder: (_) => AddEditRoomScreen(
//                   propertyId: property.id, room: rooms[i],
//                 ),
//               )),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => Navigator.push(context, MaterialPageRoute(
//           builder: (_) => AddEditRoomScreen(propertyId: property.id),
//         )),
//         icon: const Icon(Icons.add),
//         label: const Text('রুম যোগ করুন'),
//       ),
//     );
//   }
// }

// class _RoomCard extends StatelessWidget {
//   final RoomModel room;
//   final PropertyService service;
//   final VoidCallback onEdit;
//   const _RoomCard({required this.room, required this.service, required this.onEdit});

//   @override
//   Widget build(BuildContext context) {
//     final isOccupied = room.status == RoomStatus.occupied;
//     final color = Theme.of(context).colorScheme;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Container(
//               width: 52, height: 52,
//               decoration: BoxDecoration(
//                 color: isOccupied
//                     ? color.primaryContainer
//                     : color.surfaceVariant,
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Icon(
//                 isOccupied ? Icons.people_rounded : Icons.door_front_door_outlined,
//                 color: isOccupied ? color.primary : color.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text('রুম ${room.roomNumber}',
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: isOccupied ? Colors.green.shade100 : Colors.orange.shade100,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           isOccupied ? 'ভাড়া হয়েছে' : 'খালি',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: isOccupied ? Colors.green.shade800 : Colors.orange.shade800,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text('${room.type} • ৳${room.rentAmount.toStringAsFixed(0)}/মাস',
//                       style: TextStyle(fontSize: 13, color: color.onSurface.withOpacity(0.6))),
//                   if (isOccupied && room.tenantName != null)
//                     Text('ভাড়াটিয়া: ${room.tenantName}',
//                         style: TextStyle(fontSize: 13, color: color.primary,
//                             fontWeight: FontWeight.w500)),
//                 ],
//               ),
//             ),
//             PopupMenuButton(
//               itemBuilder: (_) => [
//                 const PopupMenuItem(value: 'edit', child: Text('Edit')),
//                 const PopupMenuItem(value: 'delete',
//                     child: Text('Delete', style: TextStyle(color: Colors.red))),
//               ],
//               onSelected: (val) async {
//                 if (val == 'edit') onEdit();
//                 if (val == 'delete') await service.deleteRoom(room.id);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../models/room_model.dart';
import '../../services/property_service.dart';
import 'add_edit_room_screen.dart';

class RoomListScreen extends StatelessWidget {
  final PropertyModel property;
  const RoomListScreen({super.key, required this.property});

  int _naturalCompare(String a, String b) {
    final regExp = RegExp(r'(\D*)(\d*)');
    final aMatches = regExp.allMatches(a).toList();
    final bMatches = regExp.allMatches(b).toList();
    for (int i = 0; i < aMatches.length && i < bMatches.length; i++) {
      final aText = aMatches[i].group(1) ?? '';
      final bText = bMatches[i].group(1) ?? '';
      final aNum = int.tryParse(aMatches[i].group(2) ?? '') ?? -1;
      final bNum = int.tryParse(bMatches[i].group(2) ?? '') ?? -1;
      final textCmp = aText.compareTo(bText);
      if (textCmp != 0) return textCmp;
      if (aNum != bNum) return aNum.compareTo(bNum);
    }
    return a.compareTo(b);
  }

  @override
  Widget build(BuildContext context) {
    final service = PropertyService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? const Color(0xFF0F1A14) : const Color(0xFFF5FAF7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: StreamBuilder<List<RoomModel>>(
        stream: service.getRooms(property.id).map((rooms) {
          rooms.sort((a, b) => _naturalCompare(a.roomNumber, b.roomNumber));
          return rooms;
        }),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primary));
          }

          final rooms = snap.data ?? [];
          final occupied = rooms.where((r) => r.status == RoomStatus.occupied).length;
          final vacant = rooms.length - occupied;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Collapsing AppBar ──
              SliverAppBar(
                expandedHeight: 180,
                collapsedHeight: 60,
                pinned: true,
                backgroundColor: bg,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(property.name,
                    style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeader(
                    primary: primary,
                    isDark: isDark,
                    total: rooms.length,
                    occupied: occupied,
                    vacant: vacant,
                  ),
                ),
              ),

              // ── Empty State ──
              if (rooms.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(primary, textSecondary),
                )
              else ...[
                // ── Section label ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(children: [
                      Container(
                        width: 4, height: 20,
                        decoration: BoxDecoration(
                          color: primary, borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(width: 10),
                      Text('রুম তালিকা',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primary.withOpacity(0.25)),
                        ),
                        child: Text('${rooms.length} টি রুম',
                            style: TextStyle(
                                fontSize: 12, color: primary, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  ),
                ),

                // ── Room List ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _RoomCard(
                        room: rooms[i],
                        service: service,
                        isDark: isDark,
                        primary: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        index: i,
                        onEdit: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => AddEditRoomScreen(
                            propertyId: property.id, room: rooms[i],
                          ),
                        )),
                      ),
                      childCount: rooms.length,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => AddEditRoomScreen(propertyId: property.id),
          )),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text('রুম যোগ করুন', style: TextStyle(fontWeight: FontWeight.w700)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required Color primary,
    required bool isDark,
    required int total,
    required int occupied,
    required int vacant,
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
          padding: const EdgeInsets.fromLTRB(16, 64, 16, 12),
          child: Row(children: [
            _statCard(icon: Icons.door_front_door_rounded, label: 'মোট রুম',
                value: '$total', color: primary, isDark: isDark),
            const SizedBox(width: 10),
            _statCard(icon: Icons.people_rounded, label: 'ভাড়া দেওয়া',
                value: '$occupied', color: const Color(0xFF059669), isDark: isDark),
            const SizedBox(width: 10),
            _statCard(icon: Icons.door_back_door_outlined, label: 'খালি',
                value: '$vacant', color: const Color(0xFFD97706), isDark: isDark),
          ]),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
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
            Text(value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(fontSize: 9, color: color.withOpacity(0.8)),
                overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
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
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.door_front_door_outlined,
                size: 50, color: primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          const Text('কোনো রুম নেই',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('নিচের বাটন দিয়ে রুম যোগ করুন',
              style: TextStyle(fontSize: 14, color: textSecondary)),
        ],
      ),
    );
  }
}

// ── Room Card ─────────────────────────────────────────────────────────────────

class _RoomCard extends StatelessWidget {
  final RoomModel room;
  final PropertyService service;
  final bool isDark;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final int index;
  final VoidCallback onEdit;

  const _RoomCard({
    required this.room,
    required this.service,
    required this.isDark,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    required this.index,
    required this.onEdit,
  });

  static const List<Color> _iconColors = [
    Color(0xFF059669), // green — occupied
    Color(0xFFD97706), // amber — vacant
  ];

  @override
  Widget build(BuildContext context) {
    final isOccupied = room.status == RoomStatus.occupied;
    final cardBg = isDark ? const Color(0xFF1A2C22) : Colors.white;
    final divider = isDark ? Colors.white10 : const Color(0xFFE5E7EB);

    final statusColor = isOccupied ? const Color(0xFF059669) : const Color(0xFFD97706);
    final statusBg = isOccupied
        ? const Color(0xFF059669).withOpacity(0.12)
        : const Color(0xFFD97706).withOpacity(0.12);
    final iconBg = isOccupied ? const Color(0xFF059669) : const Color(0xFFD97706);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {}, // future: room detail screen
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // ── Icon ──
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: iconBg.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Icon(
                    isOccupied
                        ? Icons.people_rounded
                        : Icons.door_front_door_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // ── Info ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('রুম ${room.roomNumber}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: statusColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              isOccupied ? 'ভাড়া হয়েছে' : 'খালি',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.category_outlined,
                              size: 12, color: textSecondary.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text('${room.type}',
                              style: TextStyle(
                                  fontSize: 12, color: textSecondary)),
                          const SizedBox(width: 10),
                          Icon(Icons.payments_outlined,
                              size: 12, color: primary.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text('৳${room.rentAmount.toStringAsFixed(0)}/মাস',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      if (isOccupied && room.tenantName != null) ...[
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                size: 12,
                                color: const Color(0xFF059669).withOpacity(0.8)),
                            const SizedBox(width: 4),
                            Text(room.tenantName!,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF059669),
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Menu ──
                PopupMenuButton(
                  icon: Icon(Icons.more_vert_rounded,
                      color: textSecondary.withOpacity(0.6), size: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 18, color: primary),
                        const SizedBox(width: 10),
                        const Text('Edit'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ]),
                    ),
                  ],
                  onSelected: (val) async {
                    if (val == 'edit') onEdit();
                    if (val == 'delete') await service.deleteRoom(room.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}