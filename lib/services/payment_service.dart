
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';
import '../models/tenant_model.dart';
import 'notification_service.dart';

class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  Stream<List<PaymentModel>> getTenantPayments(String tenantId) {
    return _db
        .collection('payments')
        .where('tenantId', isEqualTo: tenantId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PaymentModel.fromMap(d.data(), d.id))
            .toList()
          ..sort((a, b) {
            if (a.year != b.year) return b.year.compareTo(a.year);
            return b.month.compareTo(a.month);
          }));
  }

  // Tenant submits payment
  Future<void> submitPayment(String paymentId, {
    required String paymentMethod,
    required String transactionId,
    String? note,
  }) async {
    // Get payment info first
    final doc = await _db.collection('payments').doc(paymentId).get();
    final payment = PaymentModel.fromMap(doc.data()!, doc.id);

    await _db.collection('payments').doc(paymentId).update({
      'status': 'submitted',
      'submittedAt': DateTime.now().millisecondsSinceEpoch,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'note': note,
    });

    // Notify landlord
    await NotificationService.notifyLandlord(
      landlordId: payment.landlordId,
      title: '💰 নতুন পেমেন্ট জমা',
      body: '${payment.tenantName} রুম ${payment.roomNumber} এর ভাড়া জমা দিয়েছে',
    );
  }

  Future<void> approvePayment(String paymentId) async {
    final doc = await _db.collection('payments').doc(paymentId).get();
    final payment = PaymentModel.fromMap(doc.data()!, doc.id);

    await _db.collection('payments').doc(paymentId).update({
      'status': 'paid',
      'paidAt': DateTime.now().millisecondsSinceEpoch,
    });

    // Notify tenant
    await NotificationService.notifyTenant(
      tenantId: payment.tenantId,
      title: '✅ পেমেন্ট অনুমোদিত',
      body: '${payment.monthName} ${payment.year} এর ভাড়া পরিশোধ নিশ্চিত হয়েছে',
      type: 'payment_approved',
    );
  }

  Future<void> rejectPayment(String paymentId, String reason) async {
    final doc = await _db.collection('payments').doc(paymentId).get();
    final payment = PaymentModel.fromMap(doc.data()!, doc.id);

    await _db.collection('payments').doc(paymentId).update({
      'status': 'rejected',
      'rejectionReason': reason,
      'submittedAt': null,
      'transactionId': null,
      'paymentMethod': null,
    });

    // Notify tenant
    await NotificationService.notifyTenant(
      tenantId: payment.tenantId,
      title: '❌ পেমেন্ট বাতিল',
      body: 'কারণ: $reason',
      type: 'payment_rejected',
    );
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
    final batch = _db.batch();
    for (final tenant in tenants) {
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