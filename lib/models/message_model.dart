class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.isRead = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      text: map['text'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'senderName': senderName,
    'text': text,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'isRead': isRead,
  };
}

class ChatRoom {
  final String id;
  final String landlordId;
  final String landlordName;
  final String tenantId;
  final String tenantName;
  final String roomNumber;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  ChatRoom({
    required this.id,
    required this.landlordId,
    required this.landlordName,
    required this.tenantId,
    required this.tenantName,
    required this.roomNumber,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      landlordId: map['landlordId'] ?? '',
      landlordName: map['landlordName'] ?? '',
      tenantId: map['tenantId'] ?? '',
      tenantName: map['tenantName'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      lastMessage: map['lastMessage'],
      lastMessageAt: map['lastMessageAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageAt'])
          : null,
      unreadCount: map['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'landlordId': landlordId,
    'landlordName': landlordName,
    'tenantId': tenantId,
    'tenantName': tenantName,
    'roomNumber': roomNumber,
    'lastMessage': lastMessage,
    'lastMessageAt': lastMessageAt?.millisecondsSinceEpoch,
    'unreadCount': unreadCount,
  };
}