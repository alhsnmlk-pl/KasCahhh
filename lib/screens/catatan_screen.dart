import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/app_data.dart';
import '../services/export_service.dart';
import '../services/notification_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/foto_profil_widget.dart';
import 'tambah_pengeluaran_sheet.dart';

class CatatanScreen extends StatefulWidget {
  const CatatanScreen({super.key});

  @override
  State<CatatanScreen> createState() => _CatatanScreenState();
}

class _CatatanScreenState extends State<CatatanScreen> {
  final int _selectedIndex = 2;

  // Map kategori ke icon
  IconData _iconForKategori(String kategori) {
    switch (kategori) {
      case 'Konsumsi':
        return Icons.restaurant;
      case 'Perlengkapan':
        return Icons.shopping_bag;
      case 'Transportasi':
        return Icons.local_taxi;
      case 'Tagihan':
        return Icons.receipt_long;
      default:
        return Icons.monetization_on_outlined;
    }
  }

  Color _colorForKategori(String kategori, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (kategori) {
      case 'Konsumsi':
        return cs.error;
      case 'Perlengkapan':
        return const Color(0xFF275300);
      case 'Transportasi':
        return const Color(0xFF566863);
      default:
        return cs.primary;
    }
  }

  Color _bgColorForKategori(String kategori, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (kategori) {
      case 'Konsumsi':
        return cs.error.withValues(alpha: 0.1);
      case 'Perlengkapan':
        return const Color(0xFF3B6D11).withValues(alpha: 0.2);
      case 'Transportasi':
        return const Color(0xFFD3E7E0).withValues(alpha: 0.3);
      default:
        return cs.primary.withValues(alpha: 0.1);
    }
  }

  // Kelompokkan pengeluaran berdasarkan tanggal
  Map<String, List<Pengeluaran>> _groupByDate(List<Pengeluaran> list) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final Map<String, List<Pengeluaran>> groups = {};

    for (final p in list) {
      String key;
      if (p.tanggal.year == now.year &&
          p.tanggal.month == now.month &&
          p.tanggal.day == now.day) {
        key = 'Hari Ini, ${AppData.formatTanggal(p.tanggal)}';
      } else if (p.tanggal.year == yesterday.year &&
          p.tanggal.month == yesterday.month &&
          p.tanggal.day == yesterday.day) {
        key = 'Kemarin, ${AppData.formatTanggal(p.tanggal)}';
      } else {
        key = AppData.formatTanggal(p.tanggal);
      }
      groups.putIfAbsent(key, () => []).add(p);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final data = AppDataProvider.of(context);

    // Sort pengeluaran by date descending
    final sortedPengeluaran = [...data.pengeluaran]
      ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
    final grouped = _groupByDate(sortedPengeluaran);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F6E56),
        elevation: 0,
        titleSpacing: 16,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            FotoProfilWidget(
              fotoPath: data.fotoAplikasiPath,
              inisial: data.initialAplikasi,
              radius: 16,
            ),
            const SizedBox(width: 12),
            Text(
              data.namaAplikasi,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none, color: Colors.white),
                if (data.anggotaBelumBayar > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () async {
              final granted = await NotificationService.requestPermission();
              if (!context.mounted) return;

              if (granted) {
                await NotificationService.kirimReminderBelumBayar(data);
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      data.anggotaBelumBayar > 0
                          ? 'Notifikasi dikirim: ${data.anggotaBelumBayar} belum bayar'
                          : 'Semua anggota sudah lunas!',
                    ),
                    backgroundColor: const Color(0xFF0F6E56),
                  ),
                );
              } else {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Izin notifikasi ditolak'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catatan Pengeluaran',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Summary Card
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL BULAN INI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6F7A74),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppData.formatRupiah(data.pengeluaranBulanIni),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF005440),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  // Mini Bar Chart (dinamis berdasarkan data)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _buildMiniChart(data.pengeluaran.toList()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Primary Action Button
            ElevatedButton.icon(
              onPressed: () => showTambahPengeluaranSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005440),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                'Tambah Pengeluaran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Export Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: kIsWeb
                        ? null
                        : () async {
                            try {
                              await ExportService.exportPengeluaranBulanIni(
                                data,
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal export: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF005440),
                      side: const BorderSide(color: Color(0xFF005440)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    label: Text(
                      kIsWeb ? 'Export (Mobile only)' : 'Export Bulan Ini',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: kIsWeb
                        ? null
                        : () async {
                            try {
                              await ExportService.exportRekap(data);
                            } catch (e) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal export: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF005440),
                      side: const BorderSide(color: Color(0xFF005440)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: Text(
                      kIsWeb ? 'Export (Mobile only)' : 'Export Rekap Kas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Expense List
            if (sortedPengeluaran.isEmpty)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 56,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada catatan pengeluaran',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateHeader(entry.key),
                    const SizedBox(height: 8),
                    ...entry.value.map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildExpenseItem(
                          context: context,
                          pengeluaran: p,
                          icon: _iconForKategori(p.kategori),
                          iconColor: _colorForKategori(p.kategori, context),
                          iconBgColor: _bgColorForKategori(p.kategori, context),
                          onDelete: () => _hapusPengeluaran(context, p),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              }),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNav(context, _selectedIndex),
    );
  }

  void _hapusPengeluaran(BuildContext context, Pengeluaran p) {
    final data = AppDataProvider.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Pengeluaran?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Catatan "${p.keterangan}" akan dihapus.',
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
              data.hapusPengeluaran(p.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengeluaran dihapus'),
                  backgroundColor: Colors.red,
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

  List<Widget> _buildMiniChart(List<Pengeluaran> all) {
    if (all.isEmpty) {
      return [
        _buildBar(12, const Color(0xFFE4E2E2)),
        const SizedBox(width: 4),
        _buildBar(12, const Color(0xFFE4E2E2)),
        const SizedBox(width: 4),
        _buildBar(12, const Color(0xFFE4E2E2)),
        const SizedBox(width: 4),
        _buildBar(12, const Color(0xFF005440)),
        const SizedBox(width: 4),
        _buildBar(12, const Color(0xFFE4E2E2)),
      ];
    }

    // Kelompokkan per hari 5 hari terakhir
    final now = DateTime.now();
    final List<Widget> bars = [];
    for (int i = 4; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final total = all
          .where(
            (p) =>
                p.tanggal.year == day.year &&
                p.tanggal.month == day.month &&
                p.tanggal.day == day.day,
          )
          .fold(0, (sum, p) => sum + p.nominal);

      final maxHeight = 36.0;
      final maxTotal = all.fold(0, (s, p) => s + p.nominal);
      final height = maxTotal > 0 ? (total / maxTotal * maxHeight) + 4 : 6.0;

      bars.add(
        _buildBar(
          height,
          i == 0 ? const Color(0xFF005440) : const Color(0xFFE4E2E2),
        ),
      );
      if (i > 0) bars.add(const SizedBox(width: 4));
    }
    return bars;
  }

  Widget _buildBar(double height, Color color) {
    return Container(
      width: 8,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
      ),
    );
  }

  Widget _buildDateHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6F7A74),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildExpenseItem({
    required BuildContext context,
    required Pengeluaran pengeluaran,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onDelete,
  }) {
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pengeluaran.kategori,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  pengeluaran.keterangan,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6F7A74),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${AppData.formatRupiah(pengeluaran.nominal)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              Text(
                '${pengeluaran.tanggal.hour.toString().padLeft(2, '0')}:${pengeluaran.tanggal.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFBEC9C3),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.delete_outline,
                size: 18,
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
