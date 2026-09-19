import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/maintenance_model.dart';

class MaintenanceService {
  final _db = FirebaseFirestore.instance;

  static const int pageSize = 100;

  Stream<List<MaintenanceModel>> getRequests(
    String landlordId, {
    int limit = pageSize,
  }) {
    return _db
        .collection('maintenance')
        .where('landlordId', isEqualTo: landlordId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MaintenanceModel.fromMap(d.data(), d.id))
            .toList());
  }

  Stream<List<MaintenanceModel>> getTenantRequests(
    String tenantId, {
    int limit = pageSize,
  }) {
    return _db
        .collection('maintenance')
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MaintenanceModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> addRequest(MaintenanceModel req) async {
    await _db.collection('maintenance').add(req.toMap());
  }

  Future<void> updateStatus(String id, MaintenanceStatus status) async {
    String statusStr;
    switch (status) {
      case MaintenanceStatus.inProgress: statusStr = 'inProgress'; break;
      case MaintenanceStatus.done: statusStr = 'done'; break;
      default: statusStr = 'pending';
    }
    await _db.collection('maintenance').doc(id).update({'status': statusStr});
  }

  Future<void> deleteRequest(String id) async {
    await _db.collection('maintenance').doc(id).delete();
  }
}