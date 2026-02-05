import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/constants/firebase_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload game thumbnail
  Future<String> uploadThumbnail(String gameId, File imageFile) async {
    try {
      final ref = _storage
          .ref()
          .child(FirebaseConstants.thumbnailsPath)
          .child('$gameId.jpg');

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Görsel yüklenemedi: $e');
    }
  }

  // Upload user avatar
  Future<String> uploadAvatar(String userId, File imageFile) async {
    try {
      final ref = _storage
          .ref()
          .child(FirebaseConstants.avatarsPath)
          .child('$userId.jpg');

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Profil fotoğrafı yüklenemedi: $e');
    }
  }

  // Delete file
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Dosya silinemedi: $e');
    }
  }
}
