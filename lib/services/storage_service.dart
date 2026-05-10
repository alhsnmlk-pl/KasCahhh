import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Service untuk mengelola penyimpanan file (foto profil)
/// Menggunakan file system untuk efisiensi, bukan base64 di SharedPreferences
class StorageService {
  static const String _photoDirectory = 'profile_photos';

  /// Get direktori untuk menyimpan foto profil
  static Future<Directory> _getPhotoDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('File storage tidak didukung di web');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${appDir.path}/$_photoDirectory');

    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }

    return photoDir;
  }

  /// Simpan foto profil dan return path-nya
  /// @param id - ID unik untuk foto (biasanya anggota ID atau app ID)
  /// @param imageBytes - Data foto dalam bytes
  /// @return Path file yang disimpan
  static Future<String> saveFotoProfil(String id, Uint8List imageBytes) async {
    try {
      final photoDir = await _getPhotoDirectory();
      final fileName = 'photo_$id.jpg';
      final file = File('${photoDir.path}/$fileName');

      await file.writeAsBytes(imageBytes);
      return file.path;
    } catch (e) {
      debugPrint('Error saving photo: $e');
      rethrow;
    }
  }

  /// Load foto profil dari path
  /// @param path - Path file foto
  /// @return Bytes foto atau null jika tidak ditemukan
  static Future<Uint8List?> loadFotoProfil(String? path) async {
    if (path == null || path.isEmpty) return null;

    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('Error loading photo: $e');
      return null;
    }
  }

  /// Hapus foto profil
  /// @param path - Path file foto yang akan dihapus
  static Future<void> deleteFotoProfil(String? path) async {
    if (path == null || path.isEmpty) return;

    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting photo: $e');
    }
  }

  /// Hapus semua foto profil (untuk reset data)
  static Future<void> deleteAllPhotos() async {
    try {
      final photoDir = await _getPhotoDirectory();
      if (await photoDir.exists()) {
        await photoDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error deleting all photos: $e');
    }
  }

  /// Get ukuran total semua foto (untuk monitoring storage)
  /// @return Ukuran dalam bytes
  static Future<int> getTotalPhotoSize() async {
    try {
      final photoDir = await _getPhotoDirectory();
      if (!await photoDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in photoDir.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('Error calculating photo size: $e');
      return 0;
    }
  }

  /// Format ukuran file ke string yang readable
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
