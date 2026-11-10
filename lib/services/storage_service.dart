import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:campusfix/core/constants/app_constants.dart';

class UploadedImage {
  const UploadedImage({required this.url, required this.path});

  final String url;
  final String path;
}

class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<UploadedImage> uploadIncidentImage({
    required String incidentId,
    required File file,
  }) async {
    final extension = _extensionOf(file.path);
    final path = '${AppConstants.incidentImagesFolder}/$incidentId/'
        '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final ref = _storage.ref(path);
    await ref.putFile(
      file,
      SettableMetadata(contentType: _contentTypeFor(extension)),
    );
    final url = await ref.getDownloadURL();
    return UploadedImage(url: url, path: path);
  }

  Future<void> deleteImage(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      await _storage.ref(path).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }

  String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return 'jpg';
    final ext = path.substring(dot + 1).toLowerCase();
    return const ['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(ext)
        ? ext
        : 'jpg';
  }

  String _contentTypeFor(String extension) => switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'heic' => 'image/heic',
        _ => 'image/jpeg',
      };
}
