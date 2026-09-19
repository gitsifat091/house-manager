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

  /// How many messages a chat loads at a time. The screen raises its own
  /// limit to reach further back.
  static const int messagePageSize = 50;
  static const int roomPageSize = 100;

  // Landlord এর সব chat
  Stream<List<ChatRoom>> getLandlordChats(
    String landlordId, {
    int limit = roomPageSize,
  }) {
    return _db
        .collection('chatRooms')
        .where('landlordId', isEqualTo: landlordId)
        .orderBy('lastMessageAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatRoom.fromMap(d.data(), d.id))
            .toList());
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

  /// The most recent [limit] messages, oldest first for display.
  ///
  /// This used to stream every message a room had ever held, so a long
  /// conversation re-downloaded its whole history on every open. Ordering
  /// descending and reversing gets the newest ones under a limit; the screen
  /// raises the limit to load older.
  Stream<List<MessageModel>> getMessages(
    String chatRoomId, {
    int limit = messagePageSize,
  }) {
    return _db
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromMap(d.data(), d.id))
            .toList()
            .reversed
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