import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/utility_model.dart';

class UtilityService {
  final _db = FirebaseFirestore.instance;

  Stream<List<UtilityModel>> getLandlordBills(String landlordId) {
    return _db
        .collection('utilities')
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UtilityModel.fromMap(d.data(), d.id))
            .toList()
          ..sort((a, b) {
            if (a.year != b.year) return b.year.compareTo(a.year);
            return b.month.compareTo(a.month);
          }));
  }

  Stream<List<UtilityModel>> getTenantBills(String tenantId) {
    return _db
        .collection('utilities')
        .where('tenantId', isEqualTo: tenantId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UtilityModel.fromMap(d.data(), d.id))
            .toList()
          ..sort((a, b) {
            if (a.year != b.year) return b.year.compareTo(a.year);
            return b.month.compareTo(a.month);
          }));
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
}