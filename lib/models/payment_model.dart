enum PaymentStatus { paid, pending, overdue, submitted, rejected }

class PaymentModel {
  final String id;
  final String tenantId;
  final String tenantName;
  final String roomId;
  final String roomNumber;
  final String propertyId;
  final String propertyName;
  final String landlordId;
  final double amount;
  final int month;
  final int year;
  final PaymentStatus status;
  final DateTime? paidAt;
  final DateTime? submittedAt;
  final String? note;
  final String? paymentMethod;
  final String? transactionId;
  final String? rejectionReason;

  PaymentModel({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.roomId,
    required this.roomNumber,
    required this.propertyId,
    required this.propertyName,
    required this.landlordId,
    required this.amount,
    required this.month,
    required this.year,
    required this.status,
    this.paidAt,
    this.submittedAt,
    this.note,
    this.paymentMethod,
    this.transactionId,
    this.rejectionReason,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    PaymentStatus status;
    switch (map['status']) {
      case 'paid': status = PaymentStatus.paid; break;
      case 'overdue': status = PaymentStatus.overdue; break;
      case 'submitted': status = PaymentStatus.submitted; break;
      case 'rejected': status = PaymentStatus.rejected; break;
      default: status = PaymentStatus.pending;
    }
    return PaymentModel(
      id: id,
      tenantId: map['tenantId'] ?? '',
      tenantName: map['tenantName'] ?? '',
      roomId: map['roomId'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      propertyId: map['propertyId'] ?? '',
      propertyName: map['propertyName'] ?? '',
      landlordId: map['landlordId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      month: map['month'] ?? 1,
      year: map['year'] ?? DateTime.now().year,
      status: status,
      paidAt: map['paidAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['paidAt'])
          : null,
      submittedAt: map['submittedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['submittedAt'])
          : null,
      note: map['note'],
      paymentMethod: map['paymentMethod'],
      transactionId: map['transactionId'],
      rejectionReason: map['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() => {
    'tenantId': tenantId,
    'tenantName': tenantName,
    'roomId': roomId,
    'roomNumber': roomNumber,
    'propertyId': propertyId,
    'propertyName': propertyName,
    'landlordId': landlordId,
    'amount': amount,
    'month': month,
    'year': year,
    'status': status == PaymentStatus.paid
        ? 'paid'
        : status == PaymentStatus.submitted
            ? 'submitted'
            : status == PaymentStatus.rejected
                ? 'rejected'
                : status == PaymentStatus.overdue
                    ? 'overdue'
                    : 'pending',
    'paidAt': paidAt?.millisecondsSinceEpoch,
    'submittedAt': submittedAt?.millisecondsSinceEpoch,
    'note': note,
    'paymentMethod': paymentMethod,
    'transactionId': transactionId,
    'rejectionReason': rejectionReason,
  };

  String get monthName {
    const months = [
      '', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
      'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর',
      'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
    ];
    return months[month];
  }

  String get statusLabel {
    switch (status) {
      case PaymentStatus.paid: return 'পরিশোধ হয়েছে';
      case PaymentStatus.submitted: return 'যাচাইয়ের অপেক্ষায়';
      case PaymentStatus.rejected: return 'বাতিল হয়েছে';
      case PaymentStatus.overdue: return 'বকেয়া';
      default: return 'বাকি আছে';
    }
  }

  String get statusColorHex {
    switch (status) {
      case PaymentStatus.paid: return 'FF2E7D32';
      case PaymentStatus.submitted: return 'FF1565C0';
      case PaymentStatus.rejected: return 'FFC62828';
      case PaymentStatus.overdue: return 'FFE65100';
      default: return 'FFE65100';
    }
  }

  String get statusBgColorHex {
    switch (status) {
      case PaymentStatus.paid: return 'FFE8F5E9';
      case PaymentStatus.submitted: return 'FFE3F2FD';
      case PaymentStatus.rejected: return 'FFFFEBEE';
      case PaymentStatus.overdue: return 'FFFFF3E0';
      default: return 'FFFFF3E0';
    }
  }
}