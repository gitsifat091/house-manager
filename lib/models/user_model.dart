enum UserRole { landlord, tenant }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? roomId;       // Only for tenant
  final String? propertyId;   // Only for tenant
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.roomId,
    this.propertyId,
    this.photoUrl, 
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] == 'landlord' ? UserRole.landlord : UserRole.tenant,
      roomId: map['roomId'],
      propertyId: map['propertyId'],
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role == UserRole.landlord ? 'landlord' : 'tenant',
    'roomId': roomId,
    'propertyId': propertyId,
    'photoUrl': photoUrl, 
  };
}