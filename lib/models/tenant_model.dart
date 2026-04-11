class TenantModel {
  final String id;
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
  final bool isActive;
  final bool hasEdited;
  final String landlordId;  // ← যোগ করো

  TenantModel({
    required this.id,
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
    this.isActive = true,
    this.hasEdited = false,
    required this.landlordId,  // ← যোগ করো
  });

  factory TenantModel.fromMap(Map<String, dynamic> map, String id) {
    return TenantModel(
      id: id,
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
      isActive: map['isActive'] ?? true,
      hasEdited: map['hasEdited'] ?? false,
      landlordId: map['landlordId'] ?? '',  // ← যোগ করো
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'email': email,
    'nidNumber': nidNumber,
    'propertyId': propertyId,
    'propertyName': propertyName,
    'roomId': roomId,
    'roomNumber': roomNumber,
    'rentAmount': rentAmount,
    'moveInDate': moveInDate.millisecondsSinceEpoch,
    'isActive': isActive,
    'hasEdited': hasEdited,
    'landlordId': landlordId,  // ← যোগ করো
  };
}