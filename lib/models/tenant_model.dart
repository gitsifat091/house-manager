import 'package:cloud_firestore/cloud_firestore.dart';

class TenantModel {
  final String id;

  /// Firebase Auth uid of the tenant this record belongs to.
  ///
  /// This is the identity link — every tenant-side screen resolves "who am I"
  /// through this field, never through email. Empty means the tenant has not
  /// registered (or not yet been claimed); see TenantIdentityService.
  final String userId;

  final String name;
  final String phone;
  final String email;
  final String nidNumber;
  final String propertyId;
  final String propertyName;
  final String roomId;
  final String roomNumber;
  final double rentAmount;
  final DateTime moveInDate;  
  final DateTime? moveOutDate;
  final bool isActive;
  final bool hasEdited;
  final String landlordId;

  TenantModel({
    required this.id,
    this.userId = '',
    required this.name,
    required this.phone,
    required this.email,
    required this.nidNumber,
    required this.propertyId,
    required this.propertyName,
    required this.roomId,
    required this.roomNumber,
    required this.rentAmount,
    required this.moveInDate,
    this.moveOutDate,
    this.isActive = true,
    this.hasEdited = false,
    required this.landlordId,  
  });

  factory TenantModel.fromMap(Map<String, dynamic> map, String id) {
    return TenantModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      nidNumber: map['nidNumber'] ?? '',
      propertyId: map['propertyId'] ?? '',
      propertyName: map['propertyName'] ?? '',
      roomId: map['roomId'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      rentAmount: (map['rentAmount'] ?? 0).toDouble(),
      moveInDate: DateTime.fromMillisecondsSinceEpoch(map['moveInDate'] ?? 0),
      moveOutDate: map['moveOutDate'] != null
        ? (map['moveOutDate'] as Timestamp).toDate()
        : null,
      isActive: map['isActive'] ?? true,
      hasEdited: map['hasEdited'] ?? false,
      landlordId: map['landlordId'] ?? '',  // ← যোগ করো
    );
  }

  /// Normalised email used for lookups. Always derived, never stored by hand,
  /// so it cannot drift out of sync with [email].
  static String normaliseEmail(String email) => email.trim().toLowerCase();

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'name': name,
    'phone': phone,
    'email': email,
    'emailLower': normaliseEmail(email),
    'nidNumber': nidNumber,
    'propertyId': propertyId,
    'propertyName': propertyName,
    'roomId': roomId,
    'roomNumber': roomNumber,
    'rentAmount': rentAmount,
    'moveInDate': moveInDate.millisecondsSinceEpoch,
    'moveOutDate': moveOutDate != null
      ? Timestamp.fromDate(moveOutDate!)
      : null,
    'isActive': isActive,
    'hasEdited': hasEdited,
    'landlordId': landlordId,  // ← যোগ করো
  };
}