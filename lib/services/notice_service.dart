import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notice_model.dart';

class NoticeService {
  final _db = FirebaseFirestore.instance;

  Stream<List<NoticeModel>> getNotices(String landlordId) {
    return _db
        .collection('notices')
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NoticeModel.fromMap(d.data(), d.id))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Future<void> addNotice(NoticeModel notice) async {
    await _db.collection('notices').add(notice.toMap());
  }

  Future<void> deleteNotice(String id) async {
    await _db.collection('notices').doc(id).delete();
  }
}