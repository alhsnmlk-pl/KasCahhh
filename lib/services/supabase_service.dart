import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_data.dart';

/// Service untuk integrasi dengan Supabase
/// Menyediakan sync data ke cloud database
class SupabaseService {
  static SupabaseClient? _client;
  static bool _isInitialized = false;

  /// Initialize Supabase
  /// Harus dipanggil di main() sebelum runApp()
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('✅ Supabase initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Supabase: $e');
      rethrow;
    }
  }

  /// Get Supabase client instance
  static SupabaseClient get client {
    if (_client == null || !_isInitialized) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }

  /// Check if Supabase is initialized
  static bool get isInitialized => _isInitialized;

  // ─── ANGGOTA ─────────────────────────────────────────────────────────────

  /// Sync anggota ke Supabase
  static Future<void> syncAnggota(List<Anggota> anggotaList) async {
    try {
      for (final anggota in anggotaList) {
        await client.from('anggota').upsert({
          'id': anggota.id,
          'nama': anggota.nama,
          'nominal_iuran': anggota.nominalIuran,
          'frekuensi': anggota.frekuensi,
          'hari_tagihan': anggota.hariTagihan.toList(),
          'foto_profil_path': anggota.fotoProfilPath,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      debugPrint('✅ Synced ${anggotaList.length} anggota to Supabase');
    } catch (e) {
      debugPrint('❌ Error syncing anggota: $e');
      rethrow;
    }
  }

  /// Fetch anggota dari Supabase
  static Future<List<Anggota>> fetchAnggota() async {
    try {
      final response = await client.from('anggota').select();

      final anggotaList = (response as List).map((data) {
        return Anggota(
          id: data['id'],
          nama: data['nama'],
          nominalIuran: data['nominal_iuran'],
          frekuensi: data['frekuensi'],
          hariTagihan: Set<String>.from(data['hari_tagihan']),
          fotoProfilPath: data['foto_profil_path'],
        );
      }).toList();

      debugPrint('✅ Fetched ${anggotaList.length} anggota from Supabase');
      return anggotaList;
    } catch (e) {
      debugPrint('❌ Error fetching anggota: $e');
      rethrow;
    }
  }

  /// Delete anggota dari Supabase
  static Future<void> deleteAnggota(String id) async {
    try {
      await client.from('anggota').delete().eq('id', id);
      debugPrint('✅ Deleted anggota $id from Supabase');
    } catch (e) {
      debugPrint('❌ Error deleting anggota: $e');
      rethrow;
    }
  }

  // ─── PEMBAYARAN ──────────────────────────────────────────────────────────

  /// Sync pembayaran ke Supabase
  static Future<void> syncPembayaran(
    String anggotaId,
    List<Pembayaran> pembayaranList,
  ) async {
    try {
      for (final pembayaran in pembayaranList) {
        await client.from('pembayaran').upsert({
          'id': pembayaran.id,
          'anggota_id': pembayaran.anggotaId,
          'jumlah': pembayaran.jumlah,
          'tanggal': pembayaran.tanggal.toIso8601String(),
          'metode': pembayaran.metode,
          'status': pembayaran.status,
          'catatan': pembayaran.catatan,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      debugPrint('✅ Synced ${pembayaranList.length} pembayaran to Supabase');
    } catch (e) {
      debugPrint('❌ Error syncing pembayaran: $e');
      rethrow;
    }
  }

  /// Fetch pembayaran dari Supabase
  static Future<List<Pembayaran>> fetchPembayaran(String anggotaId) async {
    try {
      final response = await client
          .from('pembayaran')
          .select()
          .eq('anggota_id', anggotaId);

      final pembayaranList = (response as List).map((data) {
        return Pembayaran(
          id: data['id'],
          anggotaId: data['anggota_id'],
          jumlah: data['jumlah'],
          tanggal: DateTime.parse(data['tanggal']),
          metode: data['metode'],
          status: data['status'],
          catatan: data['catatan'] ?? '',
        );
      }).toList();

      debugPrint('✅ Fetched ${pembayaranList.length} pembayaran from Supabase');
      return pembayaranList;
    } catch (e) {
      debugPrint('❌ Error fetching pembayaran: $e');
      rethrow;
    }
  }

  /// Delete pembayaran dari Supabase
  static Future<void> deletePembayaran(String id) async {
    try {
      await client.from('pembayaran').delete().eq('id', id);
      debugPrint('✅ Deleted pembayaran $id from Supabase');
    } catch (e) {
      debugPrint('❌ Error deleting pembayaran: $e');
      rethrow;
    }
  }

  // ─── PENGELUARAN ─────────────────────────────────────────────────────────

  /// Sync pengeluaran ke Supabase
  static Future<void> syncPengeluaran(List<Pengeluaran> pengeluaranList) async {
    try {
      for (final pengeluaran in pengeluaranList) {
        await client.from('pengeluaran').upsert({
          'id': pengeluaran.id,
          'nominal': pengeluaran.nominal,
          'kategori': pengeluaran.kategori,
          'keterangan': pengeluaran.keterangan,
          'tanggal': pengeluaran.tanggal.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      debugPrint('✅ Synced ${pengeluaranList.length} pengeluaran to Supabase');
    } catch (e) {
      debugPrint('❌ Error syncing pengeluaran: $e');
      rethrow;
    }
  }

  /// Fetch pengeluaran dari Supabase
  static Future<List<Pengeluaran>> fetchPengeluaran() async {
    try {
      final response = await client.from('pengeluaran').select();

      final pengeluaranList = (response as List).map((data) {
        return Pengeluaran(
          id: data['id'],
          nominal: data['nominal'],
          kategori: data['kategori'],
          keterangan: data['keterangan'],
          tanggal: DateTime.parse(data['tanggal']),
        );
      }).toList();

      debugPrint(
        '✅ Fetched ${pengeluaranList.length} pengeluaran from Supabase',
      );
      return pengeluaranList;
    } catch (e) {
      debugPrint('❌ Error fetching pengeluaran: $e');
      rethrow;
    }
  }

  /// Delete pengeluaran dari Supabase
  static Future<void> deletePengeluaran(String id) async {
    try {
      await client.from('pengeluaran').delete().eq('id', id);
      debugPrint('✅ Deleted pengeluaran $id from Supabase');
    } catch (e) {
      debugPrint('❌ Error deleting pengeluaran: $e');
      rethrow;
    }
  }

  // ─── PEMASUKAN LAIN ──────────────────────────────────────────────────────

  /// Sync pemasukan lain ke Supabase
  static Future<void> syncPemasukanLain(
    List<PemasukanLain> pemasukanLainList,
  ) async {
    try {
      for (final pemasukan in pemasukanLainList) {
        await client.from('pemasukan_lain').upsert({
          'id': pemasukan.id,
          'nominal': pemasukan.nominal,
          'kategori': pemasukan.kategori,
          'keterangan': pemasukan.keterangan,
          'tanggal': pemasukan.tanggal.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      debugPrint(
        '✅ Synced ${pemasukanLainList.length} pemasukan lain to Supabase',
      );
    } catch (e) {
      debugPrint('❌ Error syncing pemasukan lain: $e');
      rethrow;
    }
  }

  /// Fetch pemasukan lain dari Supabase
  static Future<List<PemasukanLain>> fetchPemasukanLain() async {
    try {
      final response = await client.from('pemasukan_lain').select();

      final pemasukanLainList = (response as List).map((data) {
        return PemasukanLain(
          id: data['id'],
          nominal: data['nominal'],
          kategori: data['kategori'],
          keterangan: data['keterangan'],
          tanggal: DateTime.parse(data['tanggal']),
        );
      }).toList();

      debugPrint(
        '✅ Fetched ${pemasukanLainList.length} pemasukan lain from Supabase',
      );
      return pemasukanLainList;
    } catch (e) {
      debugPrint('❌ Error fetching pemasukan lain: $e');
      rethrow;
    }
  }

  /// Delete pemasukan lain dari Supabase
  static Future<void> deletePemasukanLain(String id) async {
    try {
      await client.from('pemasukan_lain').delete().eq('id', id);
      debugPrint('✅ Deleted pemasukan lain $id from Supabase');
    } catch (e) {
      debugPrint('❌ Error deleting pemasukan lain: $e');
      rethrow;
    }
  }

  // ─── SETTINGS ────────────────────────────────────────────────────────────

  /// Sync settings ke Supabase
  static Future<void> syncSettings(AppData data) async {
    try {
      await client.from('settings').upsert({
        'id': 'app_settings', // Single row untuk settings
        'nama_aplikasi': data.namaAplikasi,
        'foto_aplikasi_path': data.fotoAplikasiPath,
        'nominal_iuran_default': data.nominalIuranDefault,
        'frekuensi_default': data.frekuensiDefault,
        'hari_tagihan_default': data.hariTagihanDefault,
        'nama_periode': data.namaPeriode,
        'mulai_periode': data.mulaiPeriode,
        'pengingat_tagihan': data.pengingatTagihan,
        'laporan_bulanan': data.laporanBulanan,
        'updated_at': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Synced settings to Supabase');
    } catch (e) {
      debugPrint('❌ Error syncing settings: $e');
      rethrow;
    }
  }

  /// Fetch settings dari Supabase
  static Future<Map<String, dynamic>?> fetchSettings() async {
    try {
      final response = await client
          .from('settings')
          .select()
          .eq('id', 'app_settings')
          .maybeSingle();

      if (response != null) {
        debugPrint('✅ Fetched settings from Supabase');
      }
      return response;
    } catch (e) {
      debugPrint('❌ Error fetching settings: $e');
      rethrow;
    }
  }

  // ─── SYNC ALL ────────────────────────────────────────────────────────────

  /// Sync semua data ke Supabase
  static Future<void> syncAll(AppData data) async {
    try {
      debugPrint('🔄 Starting full sync to Supabase...');

      // Sync settings
      await syncSettings(data);

      // Sync anggota
      await syncAnggota(data.anggota.toList());

      // Sync pembayaran untuk setiap anggota
      for (final anggota in data.anggota) {
        await syncPembayaran(anggota.id, anggota.riwayatPembayaran);
      }

      // Sync pengeluaran
      await syncPengeluaran(data.pengeluaran.toList());

      // Sync pemasukan lain
      await syncPemasukanLain(data.pemasukanLain.toList());

      debugPrint('✅ Full sync completed successfully');
    } catch (e) {
      debugPrint('❌ Error during full sync: $e');
      rethrow;
    }
  }

  /// Fetch semua data dari Supabase
  static Future<Map<String, dynamic>> fetchAll() async {
    try {
      debugPrint('🔄 Starting full fetch from Supabase...');

      final settings = await fetchSettings();
      final anggotaList = await fetchAnggota();
      final pengeluaranList = await fetchPengeluaran();
      final pemasukanLainList = await fetchPemasukanLain();

      // Fetch pembayaran untuk setiap anggota
      for (final anggota in anggotaList) {
        final pembayaranList = await fetchPembayaran(anggota.id);
        anggota.riwayatPembayaran.addAll(pembayaranList);
      }

      debugPrint('✅ Full fetch completed successfully');

      return {
        'settings': settings,
        'anggota': anggotaList,
        'pengeluaran': pengeluaranList,
        'pemasukanLain': pemasukanLainList,
      };
    } catch (e) {
      debugPrint('❌ Error during full fetch: $e');
      rethrow;
    }
  }
}
