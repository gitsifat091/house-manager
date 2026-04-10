import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tenant_model.dart';
import '../models/room_model.dart';

class TenantService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<TenantModel>> getTenants(String landlordId) {
    return _db
        .collection('tenants')
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TenantModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> addTenant(TenantModel tenant, String landlordId) async {
    // Save tenant
    final ref = await _db.collection('tenants').add({
      ...tenant.toMap(),
      'landlordId': landlordId,
    });

    // Update room status to occupied
    await _db.collection('rooms').doc(tenant.roomId).update({
      'status': 'occupied',
      'tenantId': ref.id,
      'tenantName': tenant.name,
    });
  }

  Future<void> removeTenant(TenantModel tenant) async {
    // Mark tenant inactive
    await _db.collection('tenants').doc(tenant.id).update({'isActive': false});

    // Free the room
    await _db.collection('rooms').doc(tenant.roomId).update({
      'status': 'vacant',
      'tenantId': null,
      'tenantName': null,
    });
  }

  Future<void> deleteTenant(TenantModel tenant) async {
    await _db.collection('tenants').doc(tenant.id).delete();

    // Free the room
    await _db.collection('rooms').doc(tenant.roomId).update({
      'status': 'vacant',
      'tenantId': null,
      'tenantName': null,
    });
  }

  // Get vacant rooms for a landlord's properties
  Future<List<RoomModel>> getVacantRooms(List<String> propertyIds) async {
    if (propertyIds.isEmpty) return [];
    final snap = await _db
        .collection('rooms')
        .where('propertyId', whereIn: propertyIds)
        .where('status', isEqualTo: 'vacant')
        .get();
    return snap.docs.map((d) => RoomModel.fromMap(d.data(), d.id)).toList();
  }
}