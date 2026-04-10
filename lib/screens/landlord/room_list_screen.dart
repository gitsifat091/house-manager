import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../models/room_model.dart';
import '../../services/property_service.dart';
import 'add_edit_room_screen.dart';

class RoomListScreen extends StatelessWidget {
  final PropertyModel property;
  const RoomListScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final service = PropertyService();
    return Scaffold(
      appBar: AppBar(
        title: Text(property.name),
        centerTitle: true,
      ),
      body: StreamBuilder<List<RoomModel>>(
        stream: service.getRooms(property.id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final rooms = snap.data ?? [];
          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.door_front_door_outlined, size: 80,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('কোনো রুম নেই',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('নিচের বাটন দিয়ে রুম যোগ করুন'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            itemBuilder: (ctx, i) => _RoomCard(
              room: rooms[i],
              service: service,
              onEdit: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => AddEditRoomScreen(
                  propertyId: property.id, room: rooms[i],
                ),
              )),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => AddEditRoomScreen(propertyId: property.id),
        )),
        icon: const Icon(Icons.add),
        label: const Text('রুম যোগ করুন'),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomModel room;
  final PropertyService service;
  final VoidCallback onEdit;
  const _RoomCard({required this.room, required this.service, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isOccupied = room.status == RoomStatus.occupied;
    final color = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: isOccupied
                    ? color.primaryContainer
                    : color.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isOccupied ? Icons.people_rounded : Icons.door_front_door_outlined,
                color: isOccupied ? color.primary : color.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('রুম ${room.roomNumber}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOccupied ? Colors.green.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOccupied ? 'ভাড়া হয়েছে' : 'খালি',
                          style: TextStyle(
                            fontSize: 11,
                            color: isOccupied ? Colors.green.shade800 : Colors.orange.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${room.type} • ৳${room.rentAmount.toStringAsFixed(0)}/মাস',
                      style: TextStyle(fontSize: 13, color: color.onSurface.withOpacity(0.6))),
                  if (isOccupied && room.tenantName != null)
                    Text('ভাড়াটিয়া: ${room.tenantName}',
                        style: TextStyle(fontSize: 13, color: color.primary,
                            fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            PopupMenuButton(
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
              onSelected: (val) async {
                if (val == 'edit') onEdit();
                if (val == 'delete') await service.deleteRoom(room.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}