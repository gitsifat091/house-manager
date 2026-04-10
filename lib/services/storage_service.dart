import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorageService {
  final _picker = ImagePicker();

  Future<Uint8List?> pickImage({bool fromCamera = false}) async {
    final picked = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (picked == null) return null;
    return await picked.readAsBytes();
  }

  // Firestore এ base64 হিসেবে save করো
  Future<String?> uploadProfilePicture({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    try {
      final base64String = base64Encode(imageBytes);
      final dataUrl = 'data:image/jpeg;base64,$base64String';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'photoUrl': dataUrl});

      return dataUrl;
    } catch (e) {
      return null;
    }
  }
}