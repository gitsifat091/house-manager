enum PaymentStatus { paid, pending, overdue }

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
  final String? note;

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
    this.note,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    PaymentStatus status;
    switch (map['status']) {
      case 'paid': status = PaymentStatus.paid; break;
      case 'overdue': status = PaymentStatus.overdue; break;
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
      note: map['note'],
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
        : status == PaymentStatus.overdue
            ? 'overdue'
            : 'pending',
    'paidAt': paidAt?.millisecondsSinceEpoch,
    'note': note,
  };

  String get monthName {
    const months = [
      '', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
      'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর',
      'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
    ];
    return months[month];
  }
}