import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Upload attendance photo
  Future<String> uploadAttendancePhoto({
    required String userId,
    required String recordId,
    required File file,
  }) async {
    final fileName = '${_uuid.v4()}.jpg';
    final path =
        '${AppConstants.attendancePhotosPath}/$userId/$recordId/$fileName';

    final ref = _storage.ref().child(path);

    // Upload with metadata
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {
        'userId': userId,
        'recordId': recordId,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );

    await ref.putFile(file, metadata);

    return await ref.getDownloadURL();
  }

  // Upload multiple attendance photos
  Future<List<String>> uploadAttendancePhotos({
    required String userId,
    required String recordId,
    required List<File> files,
  }) async {
    final urls = <String>[];

    for (final file in files) {
      final url = await uploadAttendancePhoto(
        userId: userId,
        recordId: recordId,
        file: file,
      );
      urls.add(url);
    }

    return urls;
  }

  // Delete attendance photo
  Future<void> deleteAttendancePhoto(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Photo may not exist, ignore error
    }
  }

  // Delete all photos for an attendance record
  Future<void> deleteAttendancePhotos({
    required String userId,
    required String recordId,
  }) async {
    final path = '${AppConstants.attendancePhotosPath}/$userId/$recordId';
    final ref = _storage.ref().child(path);

    try {
      final listResult = await ref.listAll();
      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      // Folder may not exist, ignore error
    }
  }

  // Upload profile photo
  Future<String> uploadProfilePhoto({
    required String userId,
    required File file,
  }) async {
    final fileName = '$userId.jpg';
    final path = 'profile_photos/$fileName';

    final ref = _storage.ref().child(path);

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {
        'userId': userId,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );

    await ref.putFile(file, metadata);

    return await ref.getDownloadURL();
  }

  // Delete profile photo
  Future<void> deleteProfilePhoto(String userId) async {
    final path = 'profile_photos/$userId.jpg';
    final ref = _storage.ref().child(path);

    try {
      await ref.delete();
    } catch (e) {
      // Photo may not exist, ignore error
    }
  }

  // Get download URL
  Future<String?> getDownloadURL(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
