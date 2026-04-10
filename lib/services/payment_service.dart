import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';
import '../models/tenant_model.dart';

class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get all payments for landlord
  Stream<List<PaymentModel>> getPayments(String landlordId) {
    return _db
        .collection('payments')
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PaymentModel.fromMap(d.data(), d.id))
            .toList()
          ..sort((a, b) {
            if (a.year != b.year) return b.year.compareTo(a.year);
            return b.month.compareTo(a.month);
          }));
  }

  // Mark as paid
  Future<void> markAsPaid(String paymentId, {String? note}) async {
    await _db.collection('payments').doc(paymentId).update({
      'status': 'paid',
      'paidAt': DateTime.now().millisecondsSinceEpoch,
      'note': note,
    });
  }

  // Mark as pending
  Future<void> markAsPending(String paymentId) async {
    await _db.collection('payments').doc(paymentId).update({
      'status': 'pending',
      'paidAt': null,
    });
  }

  // Generate monthly payments for all active tenants
  Future<void> generateMonthlyPayments(
      String landlordId, List<TenantModel> tenants, int month, int year) async {
    final batch = _db.batch();

    for (final tenant in tenants) {
      // Check if payment already exists
      final existing = await _db
          .collection('payments')
          .where('tenantId', isEqualTo: tenant.id)
          .where('month', isEqualTo: month)
          .where('year', isEqualTo: year)
          .get();

      if (existing.docs.isEmpty) {
        final ref = _db.collection('payments').doc();
        final payment = PaymentModel(
          id: ref.id,
          tenantId: tenant.id,
          tenantName: tenant.name,
          roomId: tenant.roomId,
          roomNumber: tenant.roomNumber,
          propertyId: tenant.propertyId,
          propertyName: tenant.propertyName,
          landlordId: landlordId,
          amount: tenant.rentAmount,
          month: month,
          year: year,
          status: PaymentStatus.pending,
        );
        batch.set(ref, payment.toMap());
      }
    }

    await batch.commit();
  }

  // Get summary
  Future<Map<String, dynamic>> getPaymentSummary(
      String landlordId, int month, int year) async {
    final snap = await _db
        .collection('payments')
        .where('landlordId', isEqualTo: landlordId)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .get();

    double totalDue = 0;
    double totalPaid = 0;
    int pendingCount = 0;
    int paidCount = 0;

    for (final doc in snap.docs) {
      final p = PaymentModel.fromMap(doc.data(), doc.id);
      totalDue += p.amount;
      if (p.status == PaymentStatus.paid) {
        totalPaid += p.amount;
        paidCount++;
      } else {
        pendingCount++;
      }
    }

    return {
      'totalDue': totalDue,
      'totalPaid': totalPaid,
      'totalPending': totalDue - totalPaid,
      'pendingCount': pendingCount,
      'paidCount': paidCount,
    };
  }
}