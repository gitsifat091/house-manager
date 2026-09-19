
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';
import '../models/tenant_model.dart';

class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Default ceiling for a landlord's payment list.
  ///
  /// Every one of these streams used to be unbounded and sorted in Dart, so a
  /// screen showing one month still downloaded every payment ever recorded.
  /// Firestore bills per document read, so that cost grew forever.
  static const int landlordPageSize = 200;
  static const int tenantPageSize = 60;

  /// Payments for a landlord, newest period first.
  ///
  /// Pass [month] and [year] to let Firestore do the filtering. That path is
  /// equality-only, so it needs no composite index and returns one month
  /// instead of the whole history.
  Stream<List<PaymentModel>> getPayments(
    String landlordId, {
    int? month,
    int? year,
    int limit = landlordPageSize,
  }) {
    Query<Map<String, dynamic>> query =
        _db.collection('payments').where('landlordId', isEqualTo: landlordId);

    if (month != null && year != null) {
      query = query.where('month', isEqualTo: month).where('year', isEqualTo: year);
    } else {
      query = query
          .orderBy('year', descending: true)
          .orderBy('month', descending: true);
    }

    return query.limit(limit).snapshots().map((snap) => snap.docs
        .map((d) => PaymentModel.fromMap(d.data(), d.id))
        .toList()
      // Firestore has ordered by period already; this only settles ties
      // within it, which it cannot do because the time is spread across two
      // nullable fields.
      ..sort((a, b) {
        if (a.year != b.year) return b.year.compareTo(a.year);
        if (a.month != b.month) return b.month.compareTo(a.month);
        final aTime = a.paidAt ?? a.submittedAt ?? DateTime(a.year, a.month);
        final bTime = b.paidAt ?? b.submittedAt ?? DateTime(b.year, b.month);
        return bTime.compareTo(aTime);
      }));
  }

  /// A tenant's own payments, newest first. The default covers five years of
  /// monthly rent.
  Stream<List<PaymentModel>> getTenantPayments(
    String tenantId, {
    int limit = tenantPageSize,
  }) {
    return _db
        .collection('payments')
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PaymentModel.fromMap(d.data(), d.id))
            .toList());
  }

  // Tenant submits payment
  // Notifications for these transitions are produced by Cloud Functions
  // watching the payments collection, not written here. The app has no
  // credentials to send a push, and letting clients write the notifications
  // collection meant anyone could address one to anyone.
  // See functions/src/index.ts.

  Future<void> submitPayment(String paymentId, {
    required String paymentMethod,
    required String transactionId,
    String? note,
  }) async {
    await _db.collection('payments').doc(paymentId).update({
      'status': 'submitted',
      'submittedAt': DateTime.now().millisecondsSinceEpoch,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'note': note,
    });
  }

  Future<void> approvePayment(String paymentId) async {
    await _db.collection('payments').doc(paymentId).update({
      'status': 'paid',
      'paidAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> rejectPayment(String paymentId, String reason) async {
    await _db.collection('payments').doc(paymentId).update({
      'status': 'rejected',
      'rejectionReason': reason,
      'submittedAt': null,
      'transactionId': null,
      'paymentMethod': null,
    });
  }

  // Reset to pending
  Future<void> markAsPending(String paymentId) async {
    await _db.collection('payments').doc(paymentId).update({
      'status': 'pending',
      'paidAt': null,
      'submittedAt': null,
      'transactionId': null,
      'paymentMethod': null,
      'rejectionReason': null,
    });
  }

  Future<void> generateMonthlyPayments(
      String landlordId, List<TenantModel> tenants, int month, int year) async {
    
    // Future month এ payment তৈরি করা যাবে না
    final now = DateTime.now();
    final selectedMonth = DateTime(year, month);
    final currentMonth = DateTime(now.year, now.month);
    if (selectedMonth.isAfter(currentMonth)) {
      return; // Future month — skip
    }
    
    final batch = _db.batch();
    for (final tenant in tenants) {

      // Tenant যে মাসে join করেছে তার আগে payment তৈরি করা যাবে না
      final moveIn = tenant.moveInDate;
      final moveInMonth = DateTime(moveIn.year, moveIn.month);
      if (selectedMonth.isBefore(moveInMonth)) {
        continue; // এই tenant এর আগে join করেনি — skip
      }

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

  Future<Map<String, dynamic>> getPaymentSummary(
      String landlordId, int month, int year) async {
    final snap = await _db
        .collection('payments')
        .where('landlordId', isEqualTo: landlordId)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .get();

    double totalDue = 0, totalPaid = 0;
    int pendingCount = 0, paidCount = 0, submittedCount = 0;

    for (final doc in snap.docs) {
      final p = PaymentModel.fromMap(doc.data(), doc.id);
      totalDue += p.amount;
      if (p.status == PaymentStatus.paid) {
        totalPaid += p.amount;
        paidCount++;
      } else if (p.status == PaymentStatus.submitted) {
        submittedCount++;
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
      'submittedCount': submittedCount,
    };
  }
}