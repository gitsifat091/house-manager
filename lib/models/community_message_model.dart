import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole; // 'landlord' or 'tenant'
  final String message;
  final DateTime createdAt;

  CommunityMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.createdAt,
  });

  factory CommunityMessage.fromMap(Map<String, dynamic> map, String id) {
    return CommunityMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? '',
      message: map['message'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}