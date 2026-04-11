import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rule_model.dart';

class RulesService {
  final _db = FirebaseFirestore.instance;

  Stream<List<RuleModel>> getRules(String landlordId) {
    return _db
        .collection('rules')
        .where('landlordId', isEqualTo: landlordId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => RuleModel.fromMap(d.data(), d.id))
            .toList()
          ..sort((a, b) => a.category.index.compareTo(b.category.index)));
  }

  Future<void> addRule(RuleModel rule) async {
    await _db.collection('rules').add(rule.toMap());
  }

  Future<void> updateRule(RuleModel rule) async {
    await _db.collection('rules').doc(rule.id).update(rule.toMap());
  }

  Future<void> deleteRule(String id) async {
    await _db.collection('rules').doc(id).update({'isActive': false});
  }

  // Pre-loaded আইনী নিয়মগুলো
  static List<Map<String, dynamic>> get defaultLegalRules => [
    {
      'title': 'ভাড়া চুক্তি আইন',
      'description': 'বাংলাদেশের ভাড়াটিয়া আইন অনুযায়ী, ভাড়া বৃদ্ধি করতে হলে কমপক্ষে ৩ মাস আগে নোটিশ দিতে হবে।',
      'category': 'legal',
    },
    {
      'title': 'বাসস্থানের অধিকার',
      'description': 'ভাড়াটিয়াকে উচ্ছেদ করতে হলে আদালতের আদেশ ছাড়া জোরপূর্বক বের করা যাবে না। কমপক্ষে ২ মাসের নোটিশ দিতে হবে।',
      'category': 'legal',
    },
    {
      'title': 'মেরামতের দায়িত্ব',
      'description': 'বাড়ির মূল কাঠামো, ছাদ, পানির লাইন, বিদ্যুৎ সংযোগ মেরামতের দায়িত্ব বাড়ীওয়ালার।',
      'category': 'legal',
    },
    {
      'title': 'জামানত ফেরত',
      'description': 'ভাড়াটিয়া চলে গেলে ১ মাসের মধ্যে জামানত (সিকিউরিটি ডিপোজিট) ফেরত দিতে হবে।',
      'category': 'legal',
    },
  ];
}