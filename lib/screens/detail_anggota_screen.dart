import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/app_data.dart';
import 'catat_pembayaran_sheet.dart';
import 'tambah_anggota_sheet.dart';

class DetailAnggotaScreen extends StatelessWidget {
  final String anggotaId;
  const DetailAnggotaScreen({super.key, required this.anggotaId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final data = AppDataProvider.of(context);
    final anggota = data.getAnggota(anggotaId);

    if (anggota == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F6E56),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Detail Anggota',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: const Center(child: Text('Anggota tidak ditemukan')),
      );
    }

    final sudahBayar = data.isLunas(anggota);
    final riwayat = anggota.riwayatPembayaran.reversed.toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F6E56),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Anggota',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // More Options Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'edit') {
                showTambahAnggotaSheet(context, anggota: anggota);
              } else if (value == 'hapus') {
                _konfirmasiHapus(context, data, anggota);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Data',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'hapus',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hapus Anggota',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          children: [
            // ── Profile Card ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (anggota.fotoProfil != null)
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: MemoryImage(anggota.fotoProfil!),
                    )
                  else
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F6E56),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        anggota.inisial,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF9AEDCF),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    anggota.nama,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: sudahBayar
                          ? colorScheme.tertiaryContainer.withValues(alpha: 0.1)
                          : colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          sudahBayar
                              ? Icons.check_circle
                              : Icons.cancel_outlined,
                          size: 14,
                          color: sudahBayar
                              ? colorScheme.tertiaryContainer
                              : colorScheme.error,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          sudahBayar ? 'Lunas' : 'Belum Bayar',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: sudahBayar
                                ? colorScheme.tertiaryContainer
                                : colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Status Pembayaran Periode ─────────────────────────────────
            Builder(builder: (context) {
              final totalTagihan = data.hitungTotalTagihan(anggota);
              final periodeSeharusnya = data.hitungJumlahPeriode(anggota);
              final periodeTerbayar = data.hitungPeriodeTerbayar(anggota);
              final kekurangan = data.hitungKekurangan(anggota);
              final kelebihan = data.hitungKelebihan(anggota);
              final selisihPeriode = data.hitungSelisihPeriode(anggota);
              final label = data.labelPeriode(anggota);
              final progress = totalTagihan > 0
                  ? (anggota.totalDibayar / totalTagihan).clamp(0.0, 1.5)
                  : 0.0;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Pembayaran Periode',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Period count badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$periodeTerbayar dari $periodeSeharusnya $label terbayar',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (selisihPeriode > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F6E56).withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+$selisihPeriode $label ke depan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F6E56),
                              ),
                            ),
                          )
                        else if (selisihPeriode < 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Kurang ${-selisihPeriode} $label',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0).toDouble(),
                        backgroundColor: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          selisihPeriode >= 0
                              ? const Color(0xFF0F6E56)
                              : colorScheme.error,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Detail rows
                    _buildInfoRow(
                      context,
                      'Total Tagihan ($periodeSeharusnya $label)',
                      AppData.formatRupiah(totalTagihan),
                      true,
                    ),
                    _buildInfoRow(
                      context,
                      'Total Dibayar',
                      AppData.formatRupiah(anggota.totalDibayar),
                      true,
                    ),
                    if (kekurangan > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kekurangan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.error,
                              ),
                            ),
                            Text(
                              '-${AppData.formatRupiah(kekurangan)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (kelebihan > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Bayar di Muka ($selisihPeriode $label)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F6E56),
                                ),
                              ),
                            ),
                            Text(
                              '+${AppData.formatRupiah(kelebihan)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F6E56),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF0F6E56),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lunas untuk periode ini',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F6E56),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // ── Info Iuran ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Iuran',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(context, 'Nama Lengkap', anggota.nama, true),
                  _buildInfoRow(
                    context,
                    'Nominal Iuran',
                    AppData.formatRupiah(anggota.nominalIuran),
                    true,
                  ),
                  _buildInfoRow(context, 'Frekuensi', anggota.frekuensi, true),
                  _buildInfoRow(
                    context,
                    'Hari Tagihan',
                    anggota.hariTagihan.join(', '),
                    false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Riwayat Pembayaran ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat Pembayaran',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (riwayat.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Belum ada riwayat pembayaran',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    ...riwayat.take(5).toList().asMap().entries.map((e) {
                      final idx = e.key;
                      final p = e.value;
                      return _buildHistoryRow(
                        context,
                        AppData.formatTanggal(p.tanggal),
                        '+${AppData.formatRupiah(p.jumlah)}',
                        p.metode,
                        p.status,
                        idx < riwayat.take(5).length - 1,
                      );
                    }),
                  if (riwayat.length > 5) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '... dan ${riwayat.length - 5} pembayaran lainnya',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Action Buttons ────────────────────────────────────────────
            ElevatedButton.icon(
              onPressed: () =>
                  showCatatPembayaranSheet(context, anggota: anggota),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F6E56),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: Text(
                'Catat Pembayaran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () =>
                  showTambahAnggotaSheet(context, anggota: anggota),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE1F5EE),
                foregroundColor: const Color(0xFF0F6E56),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(
                'Edit Data',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _konfirmasiHapus(context, data, anggota),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(
                  color: colorScheme.error.withValues(alpha: 0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(
                'Hapus Anggota',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _konfirmasiHapus(BuildContext context, AppData data, Anggota anggota) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Anggota?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Anggota "${anggota.nama}" dan seluruh riwayat pembayarannya akan dihapus secara permanen.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              data.hapusAnggota(anggota.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${anggota.nama} telah dihapus'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    bool withBorder,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: withBorder
            ? Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                ),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF50625D),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(
    BuildContext context,
    String date,
    String amount,
    String metode,
    String status,
    bool withBorder,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: withBorder
            ? Border(
                bottom: BorderSide(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE9E8E7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: Color(0xFF0F6E56),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Iuran · $metode',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF50625D),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.tertiaryContainer,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: status == 'Lunas'
                      ? colorScheme.tertiaryContainer.withValues(alpha: 0.1)
                      : colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: status == 'Lunas'
                        ? colorScheme.tertiaryContainer
                        : colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
