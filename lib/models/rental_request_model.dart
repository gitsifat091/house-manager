import 'package:cloud_firestore/cloud_firestore.dart';

enum RentalRequestStatus { pending, accepted, rejected }

class RentalRequestModel {
  final String id;
  final String listingId;
  final String landlordId;
  final String propertyId;
  final String propertyName;
  final String roomId;
  final String roomNumber;
  final double rentAmount;

  // Tenant info
  final String tenantUserId; // Firebase Auth uid (যদি logged in থাকে)
  final String tenantName;
  final String tenantPhone;
  final String tenantEmail;
  final String tenantNid;
  final String message; // optional message to landlord

  final RentalRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  RentalRequestModel({
    required this.id,
    required this.listingId,
    required this.landlordId,
    required this.propertyId,
    required this.propertyName,
    required this.roomId,
    required this.roomNumber,
    required this.rentAmount,
    required this.tenantUserId,
    required this.tenantName,
    required this.tenantPhone,
    required this.tenantEmail,
    required this.tenantNid,
    this.message = '',
    this.status = RentalRequestStatus.pending,
    required this.createdAt,
    this.respondedAt,
  });

  factory RentalRequestModel.fromMap(Map<String, dynamic> map, String id) {
    RentalRequestStatus status;
    switch (map['status']) {
      case 'accepted': status = RentalRequestStatus.accepted; break;
      case 'rejected': status = RentalRequestStatus.rejected; break;
      default: status = RentalRequestStatus.pending;
    }
    return RentalRequestModel(
      id: id,
      listingId: map['listingId'] ?? '',
      landlordId: map['landlordId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      propertyName: map['propertyName'] ?? '',
      roomId: map['roomId'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      rentAmount: (map['rentAmount'] ?? 0).toDouble(),
      tenantUserId: map['tenantUserId'] ?? '',
      tenantName: map['tenantName'] ?? '',
      tenantPhone: map['tenantPhone'] ?? '',
      tenantEmail: map['tenantEmail'] ?? '',
      tenantNid: map['tenantNid'] ?? '',
      message: map['message'] ?? '',
      status: status,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      respondedAt: map['respondedAt'] != null
          ? (map['respondedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'listingId': listingId,
    'landlordId': landlordId,
    'propertyId': propertyId,
    'propertyName': propertyName,
    'roomId': roomId,
    'roomNumber': roomNumber,
    'rentAmount': rentAmount,
    'tenantUserId': tenantUserId,
    'tenantName': tenantName,
    'tenantPhone': tenantPhone,
    'tenantEmail': tenantEmail,
    'tenantNid': tenantNid,
    'message': message,
    'status': status == RentalRequestStatus.accepted
        ? 'accepted'
        : status == RentalRequestStatus.rejected
            ? 'rejected'
            : 'pending',
    'createdAt': Timestamp.fromDate(createdAt),
    'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
  };

  String get statusLabel {
    switch (status) {
      case RentalRequestStatus.accepted: return 'গৃহীত';
      case RentalRequestStatus.rejected: return 'প্রত্যাখ্যাত';
      default: return 'অপেক্ষমাণ';
    }
  }
}