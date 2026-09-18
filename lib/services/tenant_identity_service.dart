import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tenant_model.dart';

/// Resolves "which tenant record belongs to the signed-in user".
///
/// The tenant record is linked to the account by `userId` (the Firebase Auth
/// uid) — never by email. Email is mutable, case-sensitive in Firestore
/// queries, and typed by hand by the landlord, so it cannot carry identity.
///
/// Records created before this linkage existed (or created by a landlord for
/// someone who had not registered yet) carry no `userId`. Those are claimed
/// lazily: [claimTenancies] finds records matching the user's email, and only
/// those with no owner yet, and stamps the uid onto them. After that first
/// claim the email is never consulted again for identity.
class TenantIdentityService {
  TenantIdentityService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> get _tenants =>
      _db.collection('tenants');

  /// When we last ran a claim pass per uid. A tenant with no tenancy would
  /// otherwise re-run the claim on every screen open; a short cooldown keeps
  /// that cheap while still noticing a record the landlord adds mid-session.
  static final Map<String, DateTime> _lastClaimAttempt = <String, DateTime>{};
  static const Duration _claimCooldown = Duration(seconds: 30);

  /// Last value we wrote to users/{uid}.tenantDocId, so we only write when it
  /// actually changes rather than on every resolve.
  static final Map<String, String> _pointerCache = <String, String>{};

  /// The user's current tenancy, or null if they have none.
  ///
  /// Falls back to a claim pass when the uid lookup comes up empty, which
  /// covers both legacy records and a landlord adding this tenant while they
  /// are already signed in.
  static Future<TenantModel?> activeTenancy({
    required String uid,
    required String email,
  }) async {
    final direct = await _activeByUid(uid);
    if (direct != null) return direct;

    final claimed = await claimTenancies(uid: uid, email: email);
    if (claimed == 0) return null;

    return _activeByUid(uid);
  }

  static Future<TenantModel?> _activeByUid(String uid) async {
    if (uid.isEmpty) return null;
    final snap = await _tenants
        .where('userId', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) {
      await _syncUserPointer(uid, '');
      return null;
    }
    final doc = snap.docs.first;
    await _syncUserPointer(uid, doc.id);
    return TenantModel.fromMap(doc.data(), doc.id);
  }

  /// Mirrors the resolved tenant document id onto users/{uid}.tenantDocId.
  ///
  /// Security rules cannot run a query, so they cannot ask "does this user
  /// have a tenancy?" on their own. This pointer gives them a single document
  /// to read instead, which is what lets the rules for payments, utilities,
  /// maintenance and chat authorise a tenant cheaply.
  static Future<void> _syncUserPointer(String uid, String tenantDocId) async {
    if (uid.isEmpty) return;
    if (_pointerCache[uid] == tenantDocId) return;
    _pointerCache[uid] = tenantDocId;
    try {
      await _db
          .collection('users')
          .doc(uid)
          .set({'tenantDocId': tenantDocId}, SetOptions(merge: true));
    } on FirebaseException {
      _pointerCache.remove(uid); // retry on the next resolve
    }
  }

  /// Live view of the user's current tenancy.
  static Stream<TenantModel?> watchActiveTenancy(String uid) {
    if (uid.isEmpty) return Stream<TenantModel?>.value(null);
    return _tenants
        .where('userId', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty
            ? null
            : TenantModel.fromMap(snap.docs.first.data(), snap.docs.first.id));
  }

  /// The user's past tenancies, most recent move-in first.
  static Stream<List<TenantModel>> watchPastTenancies(String uid) {
    if (uid.isEmpty) return Stream<List<TenantModel>>.value(const []);
    return _tenants
        .where('userId', isEqualTo: uid)
        .where('isActive', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TenantModel.fromMap(d.data(), d.id))
            .toList()
          ..sort((a, b) => b.moveInDate.compareTo(a.moveInDate)));
  }

  /// Links any unowned tenant records for [email] to [uid].
  ///
  /// Only records with no `userId` are touched — a record already owned by
  /// someone else is never reassigned, so knowing an email is not enough to
  /// take over an existing tenancy. Also backfills `emailLower` so later
  /// lookups have a normalised field to match on.
  ///
  /// Returns the number of records claimed.
  static Future<int> claimTenancies({
    required String uid,
    required String email,
    bool force = false,
  }) async {
    if (uid.isEmpty || email.trim().isEmpty) return 0;
    final last = _lastClaimAttempt[uid];
    if (!force &&
        last != null &&
        DateTime.now().difference(last) < _claimCooldown) {
      return 0;
    }
    _lastClaimAttempt[uid] = DateTime.now();

    final lower = TenantModel.normaliseEmail(email);

    // Legacy records have no `emailLower`, and their `email` was stored with
    // whatever casing was typed — so match on all three shapes.
    final candidates = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    for (final query in <Query<Map<String, dynamic>>>[
      _tenants.where('emailLower', isEqualTo: lower),
      _tenants.where('email', isEqualTo: email.trim()),
      _tenants.where('email', isEqualTo: lower),
    ]) {
      try {
        final snap = await query.get();
        for (final doc in snap.docs) {
          candidates[doc.id] = doc;
        }
      } on FirebaseException {
        // A denied or failed lookup should not break sign-in.
        continue;
      }
    }

    final batch = _db.batch();
    var claimed = 0;
    for (final doc in candidates.values) {
      final owner = (doc.data()['userId'] ?? '') as String;
      if (owner.isNotEmpty) continue; // already owned — never reassign
      batch.update(doc.reference, {'userId': uid, 'emailLower': lower});
      claimed++;
    }

    if (claimed == 0) return 0;
    try {
      await batch.commit();
      _pointerCache.remove(uid); // a new tenancy may have appeared
    } on FirebaseException {
      _lastClaimAttempt.remove(uid); // let the next call retry immediately
      return 0;
    }
    return claimed;
  }

  /// Looks up the Auth uid registered against [email], if any.
  ///
  /// Used when a landlord adds a tenant by hand: if that person already has an
  /// account we can link the record immediately instead of waiting for them to
  /// sign in and claim it.
  static Future<String> uidForEmail(String email) async {
    final lower = TenantModel.normaliseEmail(email);
    if (lower.isEmpty) return '';
    // Accounts created before emails were normalised stored them as typed.
    for (final candidate in <String>{lower, email.trim()}) {
      try {
        final snap = await _db
            .collection('users')
            .where('email', isEqualTo: candidate)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) return snap.docs.first.id;
      } on FirebaseException {
        // fall through — the record stays unlinked and is claimed at sign-in
      }
    }
    return '';
  }

  /// Clears session state on sign-out so the next user starts fresh.
  static void reset() {
    _lastClaimAttempt.clear();
    _pointerCache.clear();
  }
}
