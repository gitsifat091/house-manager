enum RoomStatus { vacant, occupied }

class RoomModel {
  final String id;
  final String propertyId;
  final String roomNumber;
  final String type;
  final double rentAmount;
  final RoomStatus status;
  final String? tenantId;
  final String? tenantName;

  RoomModel({
    required this.id,
    required this.propertyId,
    required this.roomNumber,
    required this.type,
    required this.rentAmount,
    required this.status,
    this.tenantId,
    this.tenantName,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map, String id) {
    return RoomModel(
      id: id,
      propertyId: map['propertyId'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      type: map['type'] ?? 'Single',
      rentAmount: (map['rentAmount'] ?? 0).toDouble(),
      status: map['status'] == 'occupied' ? RoomStatus.occupied : RoomStatus.vacant,
      tenantId: map['tenantId'],
      tenantName: map['tenantName'],
    );
  }

  Map<String, dynamic> toMap() => {
    'propertyId': propertyId,
    'roomNumber': roomNumber,
    'type': type,
    'rentAmount': rentAmount,
    'status': status == RoomStatus.occupied ? 'occupied' : 'vacant',
    'tenantId': tenantId,
    'tenantName': tenantName,
  };
}