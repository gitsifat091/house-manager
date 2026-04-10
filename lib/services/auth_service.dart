import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

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
      }
    } catch (e) {
      _currentUser = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  // Register
  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: cred.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
      );

      await _db.collection('users').doc(user.uid).set(user.toMap());
      _currentUser = user;
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    }
  }

  // Login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // এই method যোগ করো
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    }
  }

  // এই method যোগ করো
  Future<void> updateProfilePicture(String photoUrl) async {
    if (_currentUser == null) return;
    await _db.collection('users').doc(_currentUser!.uid).update({
      'photoUrl': photoUrl,
    });
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

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found': return 'এই email এ কোনো account নেই।';
      case 'wrong-password': return 'Password ভুল হয়েছে।';
      case 'email-already-in-use': return 'এই email আগে থেকেই registered।';
      case 'weak-password': return 'Password কমপক্ষে ৬ character হতে হবে।';
      case 'invalid-email': return 'Email address সঠিক নয়।';
      default: return 'কিছু একটা সমস্যা হয়েছে। আবার চেষ্টা করো।';
    }
  }
}