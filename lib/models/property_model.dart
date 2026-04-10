class PropertyModel {
  final String id;
  final String landlordId;
  final String name;
  final String address;
  final int totalRooms;
  final DateTime createdAt;

  PropertyModel({
    required this.id,
    required this.landlordId,
    required this.name,
    required this.address,
    required this.totalRooms,
    required this.createdAt,
  });

  factory PropertyModel.fromMap(Map<String, dynamic> map, String id) {
    return PropertyModel(
      id: id,
      landlordId: map['landlordId'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      totalRooms: map['totalRooms'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() => {
    'landlordId': landlordId,
    'name': name,
    'address': address,
    'totalRooms': totalRooms,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };
}