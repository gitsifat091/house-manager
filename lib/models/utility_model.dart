enum UtilityType { gas, electricity, water, other }

class UtilityModel {
  final String id;
  final String tenantId;
  final String tenantName;
  final String roomNumber;
  final String propertyId;
  final String propertyName;
  final String landlordId;
  final UtilityType type;
  final double amount;
  final int month;
  final int year;
  final bool isPaid;
  final DateTime createdAt;
  // existing fields এর সাথে যোগ করো:
  final bool isSubmitted;
  final String? submissionNote;
  final String? paymentMethod;

  UtilityModel({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.roomNumber,
    required this.propertyId,
    required this.propertyName,
    required this.landlordId,
    required this.type,
    required this.amount,
    required this.month,
    required this.year,
    this.isPaid = false,
    required this.createdAt,
    this.isSubmitted = false,
    this.submissionNote,
    this.paymentMethod,
  });

  factory UtilityModel.fromMap(Map<String, dynamic> map, String id) {
    UtilityType type;
    switch (map['type']) {
      case 'gas': type = UtilityType.gas; break;
      case 'electricity': type = UtilityType.electricity; break;
      case 'water': type = UtilityType.water; break;
      default: type = UtilityType.other;
    }
    return UtilityModel(
      id: id,
      tenantId: map['tenantId'] ?? '',
      tenantName: map['tenantName'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      propertyId: map['propertyId'] ?? '',
      propertyName: map['propertyName'] ?? '',
      landlordId: map['landlordId'] ?? '',
      type: type,
      amount: (map['amount'] ?? 0).toDouble(),
      month: map['month'] ?? 1,
      year: map['year'] ?? DateTime.now().year,
      isPaid: map['isPaid'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      isSubmitted: map['isSubmitted'] ?? false,
      submissionNote: map['submissionNote'],
      paymentMethod: map['paymentMethod'],
    );
  }

  Map<String, dynamic> toMap() => {
    'tenantId': tenantId,
    'tenantName': tenantName,
    'roomNumber': roomNumber,
    'propertyId': propertyId,
    'propertyName': propertyName,
    'landlordId': landlordId,
    'type': type == UtilityType.gas
        ? 'gas'
        : type == UtilityType.electricity
            ? 'electricity'
            : type == UtilityType.water
                ? 'water'
                : 'other',
    'amount': amount,
    'month': month,
    'year': year,
    'isPaid': isPaid,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'isSubmitted': isSubmitted,
    'submissionNote': submissionNote,
    'paymentMethod': paymentMethod,
  };

  String get typeLabel {
    switch (type) {
      case UtilityType.gas: return 'গ্যাস বিল';
      case UtilityType.electricity: return 'বিদ্যুৎ বিল';
      case UtilityType.water: return 'পানির বিল';
      default: return 'অন্যান্য';
    }
  }

  String get typeIcon {
    switch (type) {
      case UtilityType.gas: return '🔥';
      case UtilityType.electricity: return '⚡';
      case UtilityType.water: return '💧';
      default: return '📋';
    }
  }
}