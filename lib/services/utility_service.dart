import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/utility_model.dart';

class UtilityService {
  final _db = FirebaseFirestore.instance;

  static const int landlordPageSize = 200;
  static const int tenantPageSize = 60;

  Stream<List<UtilityModel>> getLandlordBills(
    String landlordId, {
    int limit = landlordPageSize,
  }) {
    return _db
        .collection('utilities')
        .where('landlordId', isEqualTo: landlordId)
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UtilityModel.fromMap(d.data(), d.id))
            .toList());
  }

  Stream<List<UtilityModel>> getTenantBills(
    String tenantId, {
    int limit = tenantPageSize,
  }) {
    return _db
        .collection('utilities')
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UtilityModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> addBill(UtilityModel bill) async {
    await _db.collection('utilities').add(bill.toMap());
  }

  Future<void> markPaid(String id) async {
    await _db.collection('utilities').doc(id).update({'isPaid': true});
  }

  Future<void> markUnpaid(String id) async {
    await _db.collection('utilities').doc(id).update({'isPaid': false});
  }

  Future<void> deleteBill(String id) async {
    await _db.collection('utilities').doc(id).delete();
  }

  // Tenant bill submit করবে
  Future<void> submitBill(String id, {
    required String paymentMethod,
    String? note,
  }) async {
    await _db.collection('utilities').doc(id).update({
      'isSubmitted': true,
      'paymentMethod': paymentMethod,
      'submissionNote': note,
    });
  }

  // Landlord approve করবে
  Future<void> approveBill(String id) async {
    await _db.collection('utilities').doc(id).update({
      'isPaid': true,
      'isSubmitted': false,
    });
  }

  // Landlord reject করবে
  Future<void> rejectBill(String id) async {
    await _db.collection('utilities').doc(id).update({
      'isSubmitted': false,
      'paymentMethod': null,
      'submissionNote': null,
    });
  }
}