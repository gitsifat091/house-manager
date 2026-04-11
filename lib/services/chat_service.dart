import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../models/tenant_model.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;

  // ChatRoom তৈরি বা খোঁজো
  Future<String> getOrCreateChatRoom({
    required String landlordId,
    required String landlordName,
    required TenantModel tenant,
  }) async {
    final existing = await _db
        .collection('chatRooms')
        .where('landlordId', isEqualTo: landlordId)
        .where('tenantId', isEqualTo: tenant.id)
        .get();

    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    // নতুন chatRoom বানাও
    final ref = await _db.collection('chatRooms').add({
      'landlordId': landlordId,
      'landlordName': landlordName,
      'tenantId': tenant.id,
      'tenantName': tenant.name,
      'roomNumber': tenant.roomNumber,
      'lastMessage': null,
      'lastMessageAt': null,
      'unreadLandlord': 0,
      'unreadTenant': 0,
    });

    return ref.id;
  }

  // Landlord এর সব chat
  Stream<List<ChatRoom>> getLandlordChats(String landlordId) {
    return _db
        .collection('chatRooms')
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatRoom.fromMap(d.data(), d.id))
            .toList()
          ..sort((a, b) {
            if (a.lastMessageAt == null) return 1;
            if (b.lastMessageAt == null) return -1;
            return b.lastMessageAt!.compareTo(a.lastMessageAt!);
          }));
  }

  // Tenant এর chat
  Stream<ChatRoom?> getTenantChat(String tenantId) {
    return _db
        .collection('chatRooms')
        .where('tenantId', isEqualTo: tenantId)
        .snapshots()
        .map((snap) => snap.docs.isEmpty
            ? null
            : ChatRoom.fromMap(snap.docs.first.data(), snap.docs.first.id));
  }

  // Messages stream
  Stream<List<MessageModel>> getMessages(String chatRoomId) {
    return _db
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromMap(d.data(), d.id))
            .toList());
  }

  // Message পাঠাও
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String text,
    required bool isLandlord,
  }) async {
    final batch = _db.batch();

    // Message add
    final msgRef = _db
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc();

    batch.set(msgRef, {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'isRead': false,
    });

    // ChatRoom update
    final chatRef = _db.collection('chatRooms').doc(chatRoomId);
    batch.update(chatRef, {
      'lastMessage': text,
      'lastMessageAt': DateTime.now().millisecondsSinceEpoch,
      // Opposite এর unread বাড়াও
      isLandlord ? 'unreadTenant' : 'unreadLandlord':
          FieldValue.increment(1),
    });

    await batch.commit();
  }

  // Messages পড়া হয়েছে mark করো
  Future<void> markRead(String chatRoomId, bool isLandlord) async {
    await _db.collection('chatRooms').doc(chatRoomId).update({
      isLandlord ? 'unreadLandlord' : 'unreadTenant': 0,
    });
  }

  // Unread count
  Stream<int> getTotalUnread(String userId, bool isLandlord) {
    final field = isLandlord ? 'landlordId' : 'tenantId';
    final unreadField = isLandlord ? 'unreadLandlord' : 'unreadTenant';
    return _db
        .collection('chatRooms')
        .where(field, isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.fold<int>(
            0, (sum, doc) => sum + ((doc.data()[unreadField] ?? 0) as int)));
  }
}