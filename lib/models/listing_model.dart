import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String id;
  final String landlordId;
  final String landlordName;
  final String landlordPhone;
  final String propertyId;
  final String propertyName;
  final String roomId;
  final String roomNumber;
  final String roomType; // Single, Double, Family, Bachelor
  final double rentAmount;
  final String area; // এলাকা — address থেকে বা আলাদা
  final String address;
  final String division;
  final String district;
  final String thana;

  // ফ্ল্যাট details
  final double? floorSize; // sqft
  final int bedrooms;
  final int bathrooms;
  final int kitchens;
  final bool hasDiningRoom;
  final bool hasBalcony;
  final bool hasParking;
  final bool hasLift;
  final bool hasGenerator;
  final bool isGasPiped;
  final bool hasGasCylinder;
  final bool allowsBachelor;
  final bool allowsFamily;
  final bool allowsStudent;
  final int floor;
  final String description;

  final bool isActive;
  final DateTime createdAt;

  ListingModel({
    required this.id,
    required this.landlordId,
    required this.landlordName,
    required this.landlordPhone,
    required this.propertyId,
    required this.propertyName,
    required this.roomId,
    required this.roomNumber,
    required this.roomType,
    required this.rentAmount,
    required this.area,
    required this.address,
    required this.division,
    required this.district,
    required this.thana,
    this.floorSize,
    this.bedrooms = 1,
    this.bathrooms = 1,
    this.kitchens = 1,
    this.hasDiningRoom = false,
    this.hasBalcony = false,
    this.hasParking = false,
    this.hasLift = false,
    this.hasGenerator = false,
    this.isGasPiped = false,
    this.hasGasCylinder = false,
    this.allowsBachelor = false,
    this.allowsFamily = true,
    this.allowsStudent = false,
    this.floor = 1,
    this.description = '',
    this.isActive = true,
    required this.createdAt,
  });

  factory ListingModel.fromMap(Map<String, dynamic> map, String id) {
    return ListingModel(
      id: id,
      landlordId: map['landlordId'] ?? '',
      landlordName: map['landlordName'] ?? '',
      landlordPhone: map['landlordPhone'] ?? '',
      propertyId: map['propertyId'] ?? '',
      propertyName: map['propertyName'] ?? '',
      roomId: map['roomId'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      roomType: map['roomType'] ?? 'Family',
      rentAmount: (map['rentAmount'] ?? 0).toDouble(),
      area: map['area'] ?? '',
      address: map['address'] ?? '',
      division: map['division'] ?? '',
      district: map['district'] ?? '',
      thana: map['thana'] ?? '',
      floorSize: map['floorSize'] != null ? (map['floorSize'] as num).toDouble() : null,
      bedrooms: map['bedrooms'] ?? 1,
      bathrooms: map['bathrooms'] ?? 1,
      kitchens: map['kitchens'] ?? 1,
      hasDiningRoom: map['hasDiningRoom'] ?? false,
      hasBalcony: map['hasBalcony'] ?? false,
      hasParking: map['hasParking'] ?? false,
      hasLift: map['hasLift'] ?? false,
      hasGenerator: map['hasGenerator'] ?? false,
      isGasPiped: map['isGasPiped'] ?? false,
      hasGasCylinder: map['hasGasCylinder'] ?? false,
      allowsBachelor: map['allowsBachelor'] ?? false,
      allowsFamily: map['allowsFamily'] ?? true,
      allowsStudent: map['allowsStudent'] ?? false,
      floor: map['floor'] ?? 1,
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'landlordId': landlordId,
    'landlordName': landlordName,
    'landlordPhone': landlordPhone,
    'propertyId': propertyId,
    'propertyName': propertyName,
    'roomId': roomId,
    'roomNumber': roomNumber,
    'roomType': roomType,
    'rentAmount': rentAmount,
    'area': area,
    'address': address,
    'division': division,
    'district': district,
    'thana': thana,
    'floorSize': floorSize,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'kitchens': kitchens,
    'hasDiningRoom': hasDiningRoom,
    'hasBalcony': hasBalcony,
    'hasParking': hasParking,
    'hasLift': hasLift,
    'hasGenerator': hasGenerator,
    'isGasPiped': isGasPiped,
    'hasGasCylinder': hasGasCylinder,
    'allowsBachelor': allowsBachelor,
    'allowsFamily': allowsFamily,
    'allowsStudent': allowsStudent,
    'floor': floor,
    'description': description,
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}