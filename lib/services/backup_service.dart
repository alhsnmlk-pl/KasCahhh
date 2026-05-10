import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk backup dan restore data aplikasi
class BackupService {
  /// Backup semua data ke file JSON
  /// @return Path file backup yang dibuat
  static Future<String> createBackup() async {
    try {
      if (kIsWeb) {
        throw UnsupportedError('Backup tidak didukung di web');
      }

      // Get data dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final dataJson = prefs.getString('kascahh_data');

      if (dataJson == null || dataJson.isEmpty) {
        throw Exception('Tidak ada data untuk di-backup');
      }

      // Buat file backup
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'kascahh_backup_$timestamp.json';
      final dir = await getApplicationDocumentsDirectory();
      final backupFile = File('${dir.path}/$fileName');

      await backupFile.writeAsString(dataJson);

      return backupFile.path;
    } catch (e) {
      debugPrint('Error creating backup: $e');
      rethrow;
    }
  }

  /// Share backup file
  static Future<void> shareBackup() async {
    try {
      final backupPath = await createBackup();
      final file = File(backupPath);

      if (!await file.exists()) {
        throw Exception('File backup tidak ditemukan');
      }

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(backupPath, mimeType: 'application/json')],
          subject: 'Backup KasCahh',
          text: 'Backup data KasCahh - ${DateTime.now().toString()}',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing backup: $e');
      rethrow;
    }
  }

  /// Restore data dari file backup
  /// @param backupPath - Path ke file backup
  /// @return true jika berhasil
  static Future<bool> restoreFromBackup(String backupPath) async {
    try {
      if (kIsWeb) {
        throw UnsupportedError('Restore tidak didukung di web');
      }

      final file = File(backupPath);
      if (!await file.exists()) {
        throw Exception('File backup tidak ditemukan');
      }

      // Baca data dari file
      final dataJson = await file.readAsString();

      if (dataJson.isEmpty) {
        throw Exception('File backup kosong');
      }

      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('kascahh_data', dataJson);

      return true;
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      rethrow;
    }
  }

  /// Get list semua file backup
  static Future<List<FileSystemEntity>> getBackupFiles() async {
    try {
      if (kIsWeb) return [];

      final dir = await getApplicationDocumentsDirectory();
      final files = dir
          .listSync()
          .where((f) => f.path.contains('kascahh_backup_'))
          .toList();

      // Sort by modified date (newest first)
      files.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      });

      return files;
    } catch (e) {
      debugPrint('Error getting backup files: $e');
      return [];
    }
  }

  /// Hapus file backup
  static Future<void> deleteBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting backup: $e');
      rethrow;
    }
  }

  /// Hapus semua file backup lama (lebih dari 30 hari)
  static Future<void> cleanOldBackups({int daysToKeep = 30}) async {
    try {
      final backups = await getBackupFiles();
      final now = DateTime.now();

      for (final backup in backups) {
        final stat = backup.statSync();
        final age = now.difference(stat.modified).inDays;

        if (age > daysToKeep) {
          await backup.delete();
          debugPrint('Deleted old backup: ${backup.path}');
        }
      }
    } catch (e) {
      debugPrint('Error cleaning old backups: $e');
    }
  }

  /// Format ukuran file
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Format tanggal dari timestamp di nama file
  static DateTime? getBackupDate(String fileName) {
    try {
      final regex = RegExp(r'kascahh_backup_(\d+)\.json');
      final match = regex.firstMatch(fileName);
      if (match != null) {
        final timestamp = int.parse(match.group(1)!);
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
