import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tenant_model.dart';
import '../models/room_model.dart';

class TenantService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const int pageSize = 200;

  Stream<List<TenantModel>> getTenants(
    String landlordId, {
    int limit = pageSize,
  }) {
    return _db
        .collection('tenants')
        .where('landlordId', isEqualTo: landlordId)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TenantModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> addTenant(TenantModel tenant, String landlordId) async {
    // The record stays unowned until that person signs in and claims it.
    // Looking their uid up here would mean querying other people's user
    // records by email, which is exactly what publicProfiles exists to stop.
    // TenantIdentityService.claimTenancies does the linking at sign-in.
    final ref = await _db.collection('tenants').add({
      ...tenant.toMap(),
      'userId': tenant.userId,
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