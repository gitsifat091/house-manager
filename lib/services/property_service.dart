import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';
import '../models/room_model.dart';

class PropertyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Properties ──────────────────────────────

  Stream<List<PropertyModel>> getProperties(String landlordId) {
    return _db
        .collection('properties')
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PropertyModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> addProperty(PropertyModel property) async {
    await _db.collection('properties').add(property.toMap());
  }

  Future<void> updateProperty(PropertyModel property) async {
    await _db.collection('properties').doc(property.id).update(property.toMap());
  }

  Future<void> deleteProperty(String propertyId) async {
    // Delete all rooms first
    final rooms = await _db
        .collection('rooms')
        .where('propertyId', isEqualTo: propertyId)
        .get();
    for (var doc in rooms.docs) {
      await doc.reference.delete();
    }
    await _db.collection('properties').doc(propertyId).delete();
  }

  // ── Rooms ────────────────────────────────────

  Stream<List<RoomModel>> getRooms(String propertyId) {
    return _db
        .collection('rooms')
        .where('propertyId', isEqualTo: propertyId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => RoomModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> addRoom(RoomModel room) async {
    await _db.collection('rooms').add(room.toMap());
  }

  Future<void> updateRoom(RoomModel room) async {
    await _db.collection('rooms').doc(room.id).update(room.toMap());
  }

  Future<void> deleteRoom(String roomId) async {
    await _db.collection('rooms').doc(roomId).delete();
  }

  // Summary for dashboard
  Future<Map<String, int>> getPropertySummary(String landlordId) async {
    final properties = await _db
        .collection('properties')
        .where('landlordId', isEqualTo: landlordId)
        .get();

    int totalRooms = 0;
    int occupiedRooms = 0;

    for (var prop in properties.docs) {
      final rooms = await _db
          .collection('rooms')
          .where('propertyId', isEqualTo: prop.id)
          .get();
      totalRooms += rooms.docs.length;
      occupiedRooms += rooms.docs
          .where((r) => r.data()['status'] == 'occupied')
          .length;
    }

    return {
      'totalProperties': properties.docs.length,
      'totalRooms': totalRooms,
      'occupiedRooms': occupiedRooms,
      'vacantRooms': totalRooms - occupiedRooms,
    };
  }
}