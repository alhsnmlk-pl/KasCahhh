import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class Anggota {
  final String id;
  String nama;
  int nominalIuran;
  String frekuensi; // Harian / Mingguan / Bulanan
  Set<String> hariTagihan;
  List<Pembayaran> riwayatPembayaran;
  Uint8List? fotoProfil;

  Anggota({
    required this.id,
    required this.nama,
    required this.nominalIuran,
    required this.frekuensi,
    required this.hariTagihan,
    this.fotoProfil,
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
      'fotoProfil': fotoProfil != null ? base64Encode(fotoProfil!) : null,
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
      fotoProfil: map['fotoProfil'] != null
          ? base64Decode(map['fotoProfil'])
          : null,
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
  Uint8List? fotoAplikasi;

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

  List<Anggota> get anggota => List.unmodifiable(_anggota);
  List<Pengeluaran> get pengeluaran => List.unmodifiable(_pengeluaran);

  // Persistence Logic
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'namaAplikasi': namaAplikasi,
        'fotoAplikasi': fotoAplikasi != null
            ? base64Encode(fotoAplikasi!)
            : null,
        'nominalIuranDefault': nominalIuranDefault,
        'frekuensiDefault': frekuensiDefault,
        'hariTagihanDefault': hariTagihanDefault,
        'namaPeriode': namaPeriode,
        'mulaiPeriode': mulaiPeriode,
        'pengingatTagihan': pengingatTagihan,
        'laporanBulanan': laporanBulanan,
        'anggota': _anggota.map((e) => e.toMap()).toList(),
        'pengeluaran': _pengeluaran.map((e) => e.toMap()).toList(),
      };
      await prefs.setString('kascahh_data', jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('kascahh_data');
      if (jsonStr != null) {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        namaAplikasi = data['namaAplikasi'] ?? 'KasCahh';
        fotoAplikasi = data['fotoAplikasi'] != null
            ? base64Decode(data['fotoAplikasi'])
            : null;
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
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  @override
  void notifyListeners() {
    _saveToPrefs();
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
    final pemasukan = _anggota.fold<int>(0, (sum, a) => sum + a.totalDibayar);
    final keluar = totalPengeluaran;
    return pemasukan - keluar;
  }

  int get pemasukanBulanIni {
    final now = DateTime.now();
    int total = 0;
    for (final a in _anggota) {
      for (final p in a.riwayatPembayaran) {
        if (p.tanggal.month == now.month && p.tanggal.year == now.year) {
          total += p.jumlah;
        }
      }
    }
    return total;
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
  void tambahAnggota({required String nama, Uint8List? fotoProfil}) {
    _anggota.add(
      Anggota(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: nama,
        nominalIuran: nominalIuranDefault,
        frekuensi: frekuensiDefault,
        hariTagihan: {hariTagihanDefault},
        fotoProfil: fotoProfil,
      ),
    );
    notifyListeners();
  }

  void editAnggota(String id, {required String nama, Uint8List? fotoProfil}) {
    final idx = _anggota.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _anggota[idx].nama = nama;
      if (fotoProfil != null) {
        _anggota[idx].fotoProfil = fotoProfil;
      }
      // Note: We don't overwrite the member's specific settings on edit
      notifyListeners();
    }
  }

  void hapusAnggota(String id) {
    _anggota.removeWhere((a) => a.id == id);
    notifyListeners();
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
  }

  // ─── Settings ────────────────────────────────────────────────────────────
  void updateSettings({
    String? namaAplikasi,
    Uint8List? fotoAplikasi,
    int? nominalIuranDefault,
    String? frekuensiDefault,
    String? hariTagihanDefault,
    String? namaPeriode,
    String? mulaiPeriode,
    bool? pengingatTagihan,
    bool? laporanBulanan,
  }) {
    if (namaAplikasi != null) this.namaAplikasi = namaAplikasi;
    if (fotoAplikasi != null) this.fotoAplikasi = fotoAplikasi;
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
    notifyListeners();
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
