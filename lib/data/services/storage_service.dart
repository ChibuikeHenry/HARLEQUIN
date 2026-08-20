import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadBusinessLogo({
    required String businessId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final extension = _extensionFromFileName(fileName);
    final ref = _storage.ref().child('businesses/$businessId/logo.$extension');
    await ref.putData(
      bytes,
      SettableMetadata(contentType: _contentType(extension)),
    );
    return ref.getDownloadURL();
  }

  String _extensionFromFileName(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) {
      return 'jpg';
    }
    final ext = parts.last.toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' || 'png' || 'webp' || 'gif' => ext,
      _ => 'jpg',
    };
  }

  String _contentType(String extension) => switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/jpeg',
      };
}
