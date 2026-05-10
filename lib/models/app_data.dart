import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/supabase_service.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class Anggota {
  final String id;
  String nama;
  int nominalIuran;
  String frekuensi; // Harian / Mingguan / Bulanan
  Set<String> hariTagihan;
  List<Pembayaran> riwayatPembayaran;
  String? fotoProfilPath; // Path ke file foto, bukan bytes

  Anggota({
    required this.id,
    required this.nama,
    required this.nominalIuran,
    required this.frekuensi,
    required this.hariTagihan,
    this.fotoProfilPath,
    List<Pembayaran>? riwayatPembayaran,
  }) : riwayatPembayaran = riwayatPembayaran ?? [];

  String get inisial {
    final parts = nama.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nama.isNotEmpty ? nama[0].toUpperCase() : '?';
  }

  int get totalDibayar => riwayatPembayaran.fold(0, (sum, p) => sum + p.jumlah);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'nominalIuran': nominalIuran,
      'frekuensi': frekuensi,
      'hariTagihan': hariTagihan.toList(),
      'riwayatPembayaran': riwayatPembayaran.map((x) => x.toMap()).toList(),
      'fotoProfilPath': fotoProfilPath,
    };
  }

  factory Anggota.fromMap(Map<String, dynamic> map) {
    return Anggota(
      id: map['id'],
      nama: map['nama'],
      nominalIuran: map['nominalIuran'],
      frekuensi: map['frekuensi'],
      hariTagihan: Set<String>.from(map['hariTagihan']),
      riwayatPembayaran: List<Pembayaran>.from(
        map['riwayatPembayaran']?.map((x) => Pembayaran.fromMap(x)),
      ),
      fotoProfilPath: map['fotoProfilPath'],
    );
  }
}

class Pembayaran {
  final String id;
  final String anggotaId;
  int jumlah;
  DateTime tanggal;
  String metode; // Tunai / Transfer
  String status; // Lunas / DP
  String catatan;

  Pembayaran({
    required this.id,
    required this.anggotaId,
    required this.jumlah,
    required this.tanggal,
    required this.metode,
    required this.status,
    this.catatan = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'anggotaId': anggotaId,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
      'metode': metode,
      'status': status,
      'catatan': catatan,
    };
  }

  factory Pembayaran.fromMap(Map<String, dynamic> map) {
    return Pembayaran(
      id: map['id'],
      anggotaId: map['anggotaId'],
      jumlah: map['jumlah'],
      tanggal: DateTime.parse(map['tanggal']),
      metode: map['metode'],
      status: map['status'],
      catatan: map['catatan'] ?? '',
    );
  }
}

class Pengeluaran {
  final String id;
  int nominal;
  String kategori;
  String keterangan;
  DateTime tanggal;

  Pengeluaran({
    required this.id,
    required this.nominal,
    required this.kategori,
    required this.keterangan,
    required this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nominal': nominal,
      'kategori': kategori,
      'keterangan': keterangan,
      'tanggal': tanggal.toIso8601String(),
    };
  }

  factory Pengeluaran.fromMap(Map<String, dynamic> map) {
    return Pengeluaran(
      id: map['id'],
      nominal: map['nominal'],
      kategori: map['kategori'],
      keterangan: map['keterangan'],
      tanggal: DateTime.parse(map['tanggal']),
    );
  }
}

class PemasukanLain {
  final String id;
  int nominal;
  String kategori;
  String keterangan;
  DateTime tanggal;

  PemasukanLain({
    required this.id,
    required this.nominal,
    required this.kategori,
    required this.keterangan,
    required this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nominal': nominal,
      'kategori': kategori,
      'keterangan': keterangan,
      'tanggal': tanggal.toIso8601String(),
    };
  }

  factory PemasukanLain.fromMap(Map<String, dynamic> map) {
    return PemasukanLain(
      id: map['id'],
      nominal: map['nominal'],
      kategori: map['kategori'],
      keterangan: map['keterangan'],
      tanggal: DateTime.parse(map['tanggal']),
    );
  }
}

// ─── Global Store ─────────────────────────────────────────────────────────────

class AppData extends ChangeNotifier {
  // Singleton
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal() {
    _loadFromPrefs();
  }

  // ─── Settings ───────────────────────────────────────────────────────────
  String namaAplikasi = 'KasCahh';
  String? fotoAplikasiPath; // Path ke file foto, bukan bytes

  String get initialAplikasi {
    if (namaAplikasi.isEmpty) return 'KC';
    final parts = namaAplikasi.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return namaAplikasi
        .trim()
        .substring(0, namaAplikasi.trim().length >= 2 ? 2 : 1)
        .toUpperCase();
  }

  int nominalIuranDefault = 5000;
  String frekuensiDefault = 'Bulanan';
  String hariTagihanDefault = 'Tanggal 1';
  String namaPeriode = 'Kas Kelas';
  String mulaiPeriode = '2026-05-05';
  bool laporanBulanan = false;
  bool pengingatTagihan = true;

  // ─── Data ───────────────────────────────────────────────────────────────
  List<Anggota> _anggota = [];
  List<Pengeluaran> _pengeluaran = [];
  List<PemasukanLain> _pemasukanLain = [];

  List<Anggota> get anggota => List.unmodifiable(_anggota);
  List<Pengeluaran> get pengeluaran => List.unmodifiable(_pengeluaran);
  List<PemasukanLain> get pemasukanLain => List.unmodifiable(_pemasukanLain);

  // Persistence Logic with debounce
  bool _isSaving = false;
  bool _isSyncing = false;

  Future<void> _saveToPrefs() async {
    if (_isSaving) return; // Prevent concurrent saves

    _isSaving = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'namaAplikasi': namaAplikasi,
        'fotoAplikasiPath': fotoAplikasiPath,
        'nominalIuranDefault': nominalIuranDefault,
        'frekuensiDefault': frekuensiDefault,
        'hariTagihanDefault': hariTagihanDefault,
        'namaPeriode': namaPeriode,
        'mulaiPeriode': mulaiPeriode,
        'pengingatTagihan': pengingatTagihan,
        'laporanBulanan': laporanBulanan,
        'anggota': _anggota.map((e) => e.toMap()).toList(),
        'pengeluaran': _pengeluaran.map((e) => e.toMap()).toList(),
        'pemasukanLain': _pemasukanLain.map((e) => e.toMap()).toList(),
      };
      await prefs.setString('kascahh_data', jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving data: $e');
    } finally {
      _isSaving = false;
    }
  }

  /// Auto-sync ke Supabase setiap kali ada perubahan
  Future<void> _autoSyncToSupabase() async {
    // Skip jika Supabase tidak initialized atau sedang sync
    if (!SupabaseService.isInitialized || _isSyncing) return;

    _isSyncing = true;
    try {
      await SupabaseService.syncAll(this);
      debugPrint('✅ Auto-sync to Supabase completed');
    } catch (e) {
      debugPrint('❌ Auto-sync failed: $e');
      // Tidak throw error, biarkan app tetap jalan
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('kascahh_data');
      if (jsonStr != null) {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        namaAplikasi = data['namaAplikasi'] ?? 'KasCahh';
        fotoAplikasiPath = data['fotoAplikasiPath'];
        nominalIuranDefault = data['nominalIuranDefault'] ?? 50000;
        frekuensiDefault = data['frekuensiDefault'] ?? 'Bulanan';
        hariTagihanDefault = data['hariTagihanDefault'] ?? 'Tanggal 1';
        namaPeriode = data['namaPeriode'] ?? 'kas apa gitu';
        mulaiPeriode = data['mulaiPeriode'] ?? '2024-01-01';
        pengingatTagihan = data['pengingatTagihan'] ?? true;
        laporanBulanan = data['laporanBulanan'] ?? false;

        if (data['anggota'] != null) {
          _anggota = List<Anggota>.from(
            (data['anggota'] as List).map((e) => Anggota.fromMap(e)),
          );
        }
        if (data['pengeluaran'] != null) {
          _pengeluaran = List<Pengeluaran>.from(
            (data['pengeluaran'] as List).map((e) => Pengeluaran.fromMap(e)),
          );
        }
        if (data['pemasukanLain'] != null) {
          _pemasukanLain = List<PemasukanLain>.from(
            (data['pemasukanLain'] as List).map(
              (e) => PemasukanLain.fromMap(e),
            ),
          );
        }
        notifyListeners();
      }

      // Setelah load dari local, coba sync dari Supabase
      await _loadFromSupabase();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  /// Load data dari Supabase saat app start
  Future<void> _loadFromSupabase() async {
    if (!SupabaseService.isInitialized) return;

    try {
      debugPrint('🔄 Loading data from Supabase...');
      final result = await SupabaseService.fetchAll();

      // Update data dari Supabase
      if (result['settings'] != null) {
        final settings = result['settings'] as Map<String, dynamic>;
        namaAplikasi = settings['nama_aplikasi'] ?? namaAplikasi;
        fotoAplikasiPath = settings['foto_aplikasi_path'] ?? fotoAplikasiPath;
        nominalIuranDefault =
            settings['nominal_iuran_default'] ?? nominalIuranDefault;
        frekuensiDefault = settings['frekuensi_default'] ?? frekuensiDefault;
        hariTagihanDefault =
            settings['hari_tagihan_default'] ?? hariTagihanDefault;
        namaPeriode = settings['nama_periode'] ?? namaPeriode;
        mulaiPeriode = settings['mulai_periode'] ?? mulaiPeriode;
        pengingatTagihan = settings['pengingat_tagihan'] ?? pengingatTagihan;
        laporanBulanan = settings['laporan_bulanan'] ?? laporanBulanan;
      }

      if (result['anggota'] != null) {
        _anggota = result['anggota'] as List<Anggota>;
      }

      if (result['pengeluaran'] != null) {
        _pengeluaran = result['pengeluaran'] as List<Pengeluaran>;
      }

      if (result['pemasukanLain'] != null) {
        _pemasukanLain = result['pemasukanLain'] as List<PemasukanLain>;
      }

      // Save ke local setelah load dari Supabase
      await _saveToPrefs();
      notifyListeners();

      debugPrint('✅ Data loaded from Supabase successfully');
    } catch (e) {
      debugPrint('❌ Error loading from Supabase: $e');
      // Tidak throw error, gunakan data local
    }
  }

  @override
  void notifyListeners() {
    _saveToPrefs();
    _autoSyncToSupabase(); // Auto-sync ke Supabase
    super.notifyListeners();
  }

  // ─── Computed ───────────────────────────────────────────────────────────
  int get totalAnggota => _anggota.length;

  // Logika Akumulasi Tagihan
  int hitungTotalTagihan(Anggota a, {DateTime? targetDate}) {
    final mulai = DateTime.tryParse(mulaiPeriode) ?? DateTime.now();
    final target = targetDate ?? DateTime.now();

    int count = 0;
    if (a.frekuensi == 'Harian') {
      final days = target.difference(mulai).inDays;
      count = days >= 0 ? days + 1 : 1;
    } else if (a.frekuensi == 'Mingguan') {
      final days = target.difference(mulai).inDays;
      count = days >= 0 ? (days / 7).floor() + 1 : 1;
    } else {
      // Bulanan
      int months = (target.year - mulai.year) * 12 + target.month - mulai.month;
      count = months >= 0 ? months + 1 : 1;
    }

    if (count < 0) count = 0;

    return count * a.nominalIuran;
  }

  bool isLunas(Anggota a, {DateTime? targetDate}) =>
      a.totalDibayar >= hitungTotalTagihan(a, targetDate: targetDate);

  int get anggotaSudahBayar => _anggota.where((a) => isLunas(a)).length;

  int get anggotaBelumBayar => _anggota.where((a) => !isLunas(a)).length;

  List<Anggota> get anggotaBelumBayarList =>
      _anggota.where((a) => !isLunas(a)).toList();

  // ─── Period Analysis ──────────────────────────────────────────────────
  int hitungJumlahPeriode(Anggota a, {DateTime? targetDate}) {
    if (a.nominalIuran <= 0) return 0;
    return hitungTotalTagihan(a, targetDate: targetDate) ~/ a.nominalIuran;
  }

  int hitungPeriodeTerbayar(Anggota a) {
    if (a.nominalIuran <= 0) return 0;
    return a.totalDibayar ~/ a.nominalIuran;
  }

  int hitungKekurangan(Anggota a, {DateTime? targetDate}) {
    final tagihan = hitungTotalTagihan(a, targetDate: targetDate);
    final selisih = tagihan - a.totalDibayar;
    return selisih > 0 ? selisih : 0;
  }

  int hitungKelebihan(Anggota a, {DateTime? targetDate}) {
    final tagihan = hitungTotalTagihan(a, targetDate: targetDate);
    final selisih = a.totalDibayar - tagihan;
    return selisih > 0 ? selisih : 0;
  }

  /// Negative = behind, positive = ahead, 0 = exact
  int hitungSelisihPeriode(Anggota a, {DateTime? targetDate}) {
    return hitungPeriodeTerbayar(a) -
        hitungJumlahPeriode(a, targetDate: targetDate);
  }

  String labelPeriode(Anggota a) {
    if (a.frekuensi == 'Harian') return 'hari';
    if (a.frekuensi == 'Mingguan') return 'minggu';
    return 'bulan';
  }

  int get totalKas {
    final pemasukanIuran = _anggota.fold<int>(
      0,
      (sum, a) => sum + a.totalDibayar,
    );
    final pemasukanLainTotal = _pemasukanLain.fold<int>(
      0,
      (sum, p) => sum + p.nominal,
    );
    final keluar = totalPengeluaran;
    return pemasukanIuran + pemasukanLainTotal - keluar;
  }

  int get pemasukanBulanIni {
    final now = DateTime.now();
    int totalIuran = 0;
    for (final a in _anggota) {
      for (final p in a.riwayatPembayaran) {
        if (p.tanggal.month == now.month && p.tanggal.year == now.year) {
          totalIuran += p.jumlah;
        }
      }
    }

    final totalPemasukanLain = _pemasukanLain
        .where(
          (p) => p.tanggal.month == now.month && p.tanggal.year == now.year,
        )
        .fold<int>(0, (sum, p) => sum + p.nominal);

    return totalIuran + totalPemasukanLain;
  }

  int get totalPemasukanLain =>
      _pemasukanLain.fold(0, (sum, p) => sum + p.nominal);

  int get pemasukanLainBulanIni {
    final now = DateTime.now();
    return _pemasukanLain
        .where(
          (p) => p.tanggal.month == now.month && p.tanggal.year == now.year,
        )
        .fold(0, (sum, p) => sum + p.nominal);
  }

  int get totalPengeluaran => _pengeluaran.fold(0, (sum, p) => sum + p.nominal);

  int get pengeluaranBulanIni {
    final now = DateTime.now();
    return _pengeluaran
        .where(
          (p) => p.tanggal.month == now.month && p.tanggal.year == now.year,
        )
        .fold(0, (sum, p) => sum + p.nominal);
  }

  int get saldoBersihBulanIni => pemasukanBulanIni - pengeluaranBulanIni;

  // ─── CRUD Anggota ────────────────────────────────────────────────────────
  void tambahAnggota({required String nama, String? fotoProfilPath}) {
    _anggota.add(
      Anggota(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: nama,
        nominalIuran: nominalIuranDefault,
        frekuensi: frekuensiDefault,
        hariTagihan: {hariTagihanDefault},
        fotoProfilPath: fotoProfilPath,
      ),
    );
    notifyListeners();
  }

  void editAnggota(String id, {required String nama, String? fotoProfilPath}) {
    final idx = _anggota.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _anggota[idx].nama = nama;
      if (fotoProfilPath != null) {
        _anggota[idx].fotoProfilPath = fotoProfilPath;
      }
      // Note: We don't overwrite the member's specific settings on edit
      notifyListeners();
    }
  }

  void hapusAnggota(String id) {
    _anggota.removeWhere((a) => a.id == id);
    notifyListeners();

    // Delete dari Supabase
    if (SupabaseService.isInitialized) {
      SupabaseService.deleteAnggota(id).catchError((e) {
        debugPrint('❌ Error deleting anggota from Supabase: $e');
      });
    }
  }

  Anggota? getAnggota(String id) {
    try {
      return _anggota.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── CRUD Pembayaran ─────────────────────────────────────────────────────
  void catatPembayaran({
    required String anggotaId,
    required int jumlah,
    required DateTime tanggal,
    required String metode,
    required String status,
    String catatan = '',
  }) {
    final anggota = getAnggota(anggotaId);
    if (anggota != null) {
      anggota.riwayatPembayaran.add(
        Pembayaran(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          anggotaId: anggotaId,
          jumlah: jumlah,
          tanggal: tanggal,
          metode: metode,
          status: status,
          catatan: catatan,
        ),
      );
      notifyListeners();
    }
  }

  // ─── CRUD Pengeluaran ────────────────────────────────────────────────────
  void tambahPengeluaran({
    required int nominal,
    required String kategori,
    required String keterangan,
    required DateTime tanggal,
  }) {
    _pengeluaran.add(
      Pengeluaran(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nominal: nominal,
        kategori: kategori,
        keterangan: keterangan,
        tanggal: tanggal,
      ),
    );
    notifyListeners();
  }

  void hapusPengeluaran(String id) {
    _pengeluaran.removeWhere((p) => p.id == id);
    notifyListeners();

    // Delete dari Supabase
    if (SupabaseService.isInitialized) {
      SupabaseService.deletePengeluaran(id).catchError((e) {
        debugPrint('❌ Error deleting pengeluaran from Supabase: $e');
      });
    }
  }

  // ─── CRUD Pemasukan Lain ─────────────────────────────────────────────────
  void tambahPemasukanLain({
    required int nominal,
    required String kategori,
    required String keterangan,
    required DateTime tanggal,
  }) {
    _pemasukanLain.add(
      PemasukanLain(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nominal: nominal,
        kategori: kategori,
        keterangan: keterangan,
        tanggal: tanggal,
      ),
    );
    notifyListeners();
  }

  void hapusPemasukanLain(String id) {
    _pemasukanLain.removeWhere((p) => p.id == id);
    notifyListeners();

    // Delete dari Supabase
    if (SupabaseService.isInitialized) {
      SupabaseService.deletePemasukanLain(id).catchError((e) {
        debugPrint('❌ Error deleting pemasukan lain from Supabase: $e');
      });
    }
  }

  // ─── Settings ────────────────────────────────────────────────────────────
  void updateSettings({
    String? namaAplikasi,
    String? fotoAplikasiPath,
    int? nominalIuranDefault,
    String? frekuensiDefault,
    String? hariTagihanDefault,
    String? namaPeriode,
    String? mulaiPeriode,
    bool? pengingatTagihan,
    bool? laporanBulanan,
  }) {
    if (namaAplikasi != null) this.namaAplikasi = namaAplikasi;
    if (fotoAplikasiPath != null) this.fotoAplikasiPath = fotoAplikasiPath;
    if (nominalIuranDefault != null) {
      this.nominalIuranDefault = nominalIuranDefault;
    }
    if (frekuensiDefault != null) this.frekuensiDefault = frekuensiDefault;
    if (hariTagihanDefault != null) {
      this.hariTagihanDefault = hariTagihanDefault;
    }
    if (namaPeriode != null) this.namaPeriode = namaPeriode;
    if (mulaiPeriode != null) this.mulaiPeriode = mulaiPeriode;
    if (pengingatTagihan != null) this.pengingatTagihan = pengingatTagihan;
    if (laporanBulanan != null) this.laporanBulanan = laporanBulanan;
    notifyListeners();
  }

  void resetData() {
    _anggota.clear();
    _pengeluaran.clear();
    _pemasukanLain.clear();
    notifyListeners();

    // Delete semua data dari Supabase
    if (SupabaseService.isInitialized) {
      _resetSupabaseData().catchError((e) {
        debugPrint('❌ Error resetting Supabase data: $e');
      });
    }
  }

  /// Reset semua data di Supabase
  Future<void> _resetSupabaseData() async {
    try {
      // Delete semua anggota (cascade akan delete pembayaran juga)
      await SupabaseService.client.from('anggota').delete().neq('id', '');

      // Delete semua pengeluaran
      await SupabaseService.client.from('pengeluaran').delete().neq('id', '');

      // Delete semua pemasukan lain
      await SupabaseService.client
          .from('pemasukan_lain')
          .delete()
          .neq('id', '');

      debugPrint('✅ All data deleted from Supabase');
    } catch (e) {
      debugPrint('❌ Error resetting Supabase data: $e');
      rethrow;
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
  static String formatRupiah(int amount) {
    final str = amount.abs().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    final reversed = buffer.toString().split('').reversed.join('');
    return amount < 0 ? '-Rp $reversed' : 'Rp $reversed';
  }

  static String formatTanggal(DateTime dt) {
    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${bulan[dt.month]} ${dt.year}';
  }
}
