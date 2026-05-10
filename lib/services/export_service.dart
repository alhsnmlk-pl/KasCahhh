import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_data.dart';

class ExportService {
  /// Export rekap anggota & pembayaran sebagai CSV, lalu share.
  static Future<void> exportRekap(AppData data) async {
    try {
      // ── Build CSV rows ────────────────────────────────────────────────────
      final List<List<dynamic>> rows = [];

      // Header info
      rows.add(['Nama Kas', data.namaAplikasi]);
      rows.add(['Periode Mulai', data.mulaiPeriode]);
      rows.add(['Diekspor pada', AppData.formatTanggal(DateTime.now())]);
      rows.add([]);

      // ── Sheet 1: Rekap Anggota ────────────────────────────────────────────
      rows.add([
        'No',
        'Nama Anggota',
        'Frekuensi',
        'Nominal Iuran',
        'Total Dibayar',
        'Total Tagihan',
        'Kekurangan',
        'Kelebihan',
        'Periode Terbayar',
        'Periode Seharusnya',
        'Status',
      ]);

      int no = 1;
      for (final a in data.anggota) {
        final tagihan = data.hitungTotalTagihan(a);
        final kekurangan = data.hitungKekurangan(a);
        final kelebihan = data.hitungKelebihan(a);
        final periodeTerbayar = data.hitungPeriodeTerbayar(a);
        final periodeSeharusnya = data.hitungJumlahPeriode(a);
        final status = data.isLunas(a) ? 'Lunas' : 'Belum Lunas';

        rows.add([
          no++,
          a.nama,
          a.frekuensi,
          a.nominalIuran,
          a.totalDibayar,
          tagihan,
          kekurangan,
          kelebihan,
          periodeTerbayar,
          periodeSeharusnya,
          status,
        ]);
      }

      rows.add([]);

      // ── Sheet 2: Riwayat Pembayaran ───────────────────────────────────────
      rows.add(['=== RIWAYAT PEMBAYARAN ===']);
      rows.add([
        'No',
        'Nama Anggota',
        'Tanggal',
        'Jumlah',
        'Metode',
        'Status',
        'Catatan',
      ]);

      int noPbyr = 1;
      for (final a in data.anggota) {
        final sorted = [...a.riwayatPembayaran]
          ..sort((x, y) => y.tanggal.compareTo(x.tanggal));
        for (final p in sorted) {
          rows.add([
            noPbyr++,
            a.nama,
            AppData.formatTanggal(p.tanggal),
            p.jumlah,
            p.metode,
            p.status,
            p.catatan,
          ]);
        }
      }

      rows.add([]);

      // ── Sheet 3: Pengeluaran ──────────────────────────────────────────────
      rows.add(['=== PENGELUARAN ===']);
      rows.add(['No', 'Tanggal', 'Kategori', 'Keterangan', 'Nominal']);

      int noPeng = 1;
      final sortedPeng = [...data.pengeluaran]
        ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
      for (final p in sortedPeng) {
        rows.add([
          noPeng++,
          AppData.formatTanggal(p.tanggal),
          p.kategori,
          p.keterangan,
          p.nominal,
        ]);
      }

      rows.add([]);

      // ── Summary ────────────────────────────────────────────────────────
      rows.add(['=== RINGKASAN ===']);
      rows.add(['Total Anggota', data.totalAnggota]);
      rows.add(['Sudah Lunas', data.anggotaSudahBayar]);
      rows.add(['Belum Lunas', data.anggotaBelumBayar]);
      rows.add([
        'Total Pemasukan',
        data.anggota.fold<int>(0, (s, a) => s + a.totalDibayar),
      ]);
      rows.add(['Total Pengeluaran', data.totalPengeluaran]);
      rows.add(['Saldo Kas', data.totalKas]);

      // ── Convert to CSV string ─────────────────────────────────────────────
      final csv = Csv().encoder.convert(rows);

      // ── Save & Share ──────────────────────────────────────────────────────
      final fileName =
          'KasCahh_${data.namaAplikasi}_${DateTime.now().millisecondsSinceEpoch}.csv';

      if (kIsWeb) {
        // Web: tidak bisa share file, tapi bisa copy text
        throw UnsupportedError(
          'Export ke file tidak didukung di web. Gunakan versi mobile.',
        );
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csv);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv')],
          subject: 'Rekap Kas ${data.namaAplikasi}',
          text:
              'Rekap kas ${data.namaAplikasi} - ${AppData.formatTanggal(DateTime.now())}',
        ),
      );
    } catch (e) {
      throw Exception('Gagal mengekspor rekap: $e');
    }
  }

  /// Export hanya pengeluaran bulan ini
  static Future<void> exportPengeluaranBulanIni(AppData data) async {
    try {
      final now = DateTime.now();
      final List<List<dynamic>> rows = [];

      final bulanNama = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];

      rows.add(['Laporan Pengeluaran', '${bulanNama[now.month]} ${now.year}']);
      rows.add(['Nama Kas', data.namaAplikasi]);
      rows.add([]);
      rows.add(['No', 'Tanggal', 'Kategori', 'Keterangan', 'Nominal']);

      final pengeluaranBulanIni =
          data.pengeluaran
              .where(
                (p) =>
                    p.tanggal.month == now.month && p.tanggal.year == now.year,
              )
              .toList()
            ..sort((a, b) => b.tanggal.compareTo(a.tanggal));

      int no = 1;
      for (final p in pengeluaranBulanIni) {
        rows.add([
          no++,
          AppData.formatTanggal(p.tanggal),
          p.kategori,
          p.keterangan,
          p.nominal,
        ]);
      }

      rows.add([]);
      rows.add(['TOTAL', '', '', '', data.pengeluaranBulanIni]);

      final csv = Csv().encoder.convert(rows);
      final fileName = 'Pengeluaran_${bulanNama[now.month]}_${now.year}.csv';

      if (kIsWeb) {
        throw UnsupportedError('Export tidak didukung di web.');
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csv);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv')],
          subject: 'Pengeluaran ${bulanNama[now.month]} ${now.year}',
        ),
      );
    } catch (e) {
      throw Exception('Gagal mengekspor pengeluaran: $e');
    }
  }
}
