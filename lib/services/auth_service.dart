import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'public_profile_service.dart';
import 'tenant_identity_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = true;
  String? _loadError;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  /// Set when we are authenticated but could not load the profile.
  ///
  /// This is not the same as being signed out, and the UI must not treat it
  /// that way: dropping someone on the login screen after a lost connection
  /// invites them to register a second account for an email they already own.
  String? get loadError => _loadError;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      _isLoading = false;
    } else {
      await _loadUserData(firebaseUser.uid);
    }
    notifyListeners();
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!);
        _loadError = null;
      } else {
        // Authenticated with no profile document. That is a half-finished
        // registration, not a session: sign out so the email is usable again
        // rather than leaving the account in a state it cannot recover from.
        _currentUser = null;
        _loadError = 'আপনার প্রোফাইল পাওয়া যায়নি। আবার register করুন।';
        await _auth.signOut();
      }
    } catch (e) {
      // A dropped connection or a denied read is not a sign-out. Keep the
      // session we already have; only report a failure when there is nothing
      // to fall back on.
      if (_currentUser == null || _currentUser!.uid != uid) {
        _loadError =
            'তথ্য load করা যায়নি। ইন্টারনেট সংযোগ দেখে আবার চেষ্টা করুন।';
      }
    }
    await _publishPublicProfile();
    await _linkTenancies();
    _isLoading = false;
    notifyListeners();
  }

  /// Keeps publicProfiles/{uid} in step with this account.
  ///
  /// Also backfills it: accounts created before public profiles existed get
  /// one the first time they sign in, so no migration has to run over the
  /// whole user collection.
  Future<void> _publishPublicProfile() async {
    final user = _currentUser;
    if (user == null) return;
    try {
      await PublicProfileService.publish(
        uid: user.uid,
        name: user.name,
        photoUrl: user.photoUrl,
      );
    } catch (_) {
      // Cosmetic; never block sign-in on it.
    }
  }

  /// Re-attempts the profile load after a failure.
  Future<void> retryLoad() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      _loadError = null;
      notifyListeners();
      return;
    }
    _isLoading = true;
    _loadError = null;
    notifyListeners();
    await _loadUserData(firebaseUser.uid);
  }

  /// Attaches any unowned tenant records to this account.
  ///
  /// Runs once per sign-in. Records a landlord creates later are picked up by
  /// TenantIdentityService.activeTenancy, which retries the claim when its uid
  /// lookup finds nothing.
  Future<void> _linkTenancies() async {
    final user = _currentUser;
    if (user == null || user.role != UserRole.tenant) return;
    try {
      await TenantIdentityService.claimTenancies(
        uid: user.uid,
        email: user.email,
      );
    } catch (_) {
      // Never let this block sign-in; screens retry the claim on demand.
    }
  }

  // Register
  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    final normalisedEmail = email.trim().toLowerCase();

    final UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
        email: normalisedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return _getErrorMessage('unknown');
    }

    final user = UserModel(
      uid: cred.user!.uid,
      name: name,
      email: normalisedEmail,
      phone: phone,
      role: role,
    );

    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
      await PublicProfileService.publish(uid: user.uid, name: user.name);
    } catch (e) {
      // The account exists in Auth but has no profile, so it could never sign
      // in — and the email would stay claimed, so the person could not
      // register again either. Undo it and let them retry.
      try {
        await cred.user?.delete();
      } catch (_) {
        // Deletion can fail; sign out at least, so the app does not sit in a
        // session with no profile behind it.
        await _auth.signOut();
      }
      return 'অ্যাকাউন্ট তৈরি করা যায়নি। ইন্টারনেট সংযোগ দেখে আবার চেষ্টা করুন।';
    }

    _currentUser = user;
    _loadError = null;
    notifyListeners();
    return null; // success
  }

  // Login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _loadError = null;
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return _getErrorMessage('unknown');
    }
  }

  // Logout
  Future<void> logout() async {
    TenantIdentityService.reset();
    PublicProfileService.reset();
    await _auth.signOut();
    _currentUser = null;
    _loadError = null;
    notifyListeners();
  }

  // এই method যোগ করো
  // Future<String?> sendPasswordReset(String email) async {
  //   try {
  //     await _auth.sendPasswordResetEmail(email: email);
  //     return null; // success
  //   } on FirebaseAuthException catch (e) {
  //     return _getErrorMessage(e.code);
  //   }
  // }

  // এই method যোগ করো
  Future<void> updateProfilePicture(String photoUrl) async {
    if (_currentUser == null) return;
    await _db.collection('users').doc(_currentUser!.uid).update({
      'photoUrl': photoUrl,
    });
    await PublicProfileService.updatePhoto(
      uid: _currentUser!.uid,
      photoUrl: photoUrl,
    );
    _currentUser = UserModel(
      uid: _currentUser!.uid,
      name: _currentUser!.name,
      email: _currentUser!.email,
      phone: _currentUser!.phone,
      role: _currentUser!.role,
      photoUrl: photoUrl,
    );
    notifyListeners();
  }

  // ── Password Change (current password verify করে) ──
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser!;
      // Re-authenticate first
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      // Now update password
      await user.updatePassword(newPassword);
      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password': return 'বর্তমান password সঠিক নয়।';
        case 'weak-password': return 'নতুন password কমপক্ষে ৬ character হতে হবে।';
        case 'requires-recent-login': return 'আবার login করে চেষ্টা করুন।';
        default: return 'কিছু একটা সমস্যা হয়েছে। আবার চেষ্টা করুন।';
      }
    }
  }

  // ── Forgot Password ──
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found': return 'এই email এ কোনো account নেই।';
        case 'invalid-email': return 'সঠিক email দিন।';
        default: return 'কিছু একটা সমস্যা হয়েছে।';
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      // Projects with email enumeration protection on — the default for
      // new ones — return invalid-credential rather than naming which half
      // was wrong, so one message has to cover both.
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Email অথবা password ভুল হয়েছে।';
      case 'network-request-failed':
        return 'ইন্টারনেট সংযোগ নেই। সংযোগ দেখে আবার চেষ্টা করুন।';
      case 'too-many-requests':
        return 'অনেকবার চেষ্টা করা হয়েছে। কিছুক্ষণ পর আবার চেষ্টা করুন।';
      case 'user-not-found': return 'এই email এ কোনো account নেই।';
      case 'wrong-password': return 'Password ভুল হয়েছে।';
      case 'email-already-in-use': return 'এই email আগে থেকেই registered।';
      case 'weak-password': return 'Password কমপক্ষে ৬ character হতে হবে।';
      case 'invalid-email': return 'Email address সঠিক নয়।';
      default: return 'কিছু একটা সমস্যা হয়েছে। আবার চেষ্টা করো।';
    }
  }
}