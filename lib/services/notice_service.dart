import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notice_model.dart';

class NoticeService {
  final _db = FirebaseFirestore.instance;

  static const int pageSize = 100;

  Stream<List<NoticeModel>> getNotices(
    String landlordId, {
    int limit = pageSize,
  }) {
    return _db
        .collection('notices')
        .where('landlordId', isEqualTo: landlordId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NoticeModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> addNotice(NoticeModel notice) async {
    await _db.collection('notices').add(notice.toMap());
  }

  Future<void> deleteNotice(String id) async {
    await _db.collection('notices').doc(id).delete();
  }
}