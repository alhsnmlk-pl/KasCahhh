import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/app_data.dart';
import '../services/notification_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/summary_row.dart';
import '../widgets/member_card.dart';
import '../widgets/bottom_nav.dart';
import 'anggota_screen.dart';
import 'catat_pembayaran_sheet.dart';
import 'detail_anggota_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final data = AppDataProvider.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F6E56),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            if (data.fotoAplikasi != null)
              CircleAvatar(
                radius: 16,
                backgroundImage: MemoryImage(data.fotoAplikasi!),
              )
            else
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 20,
                ),
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
                          ? 'Notifikasi terkirim untuk ${data.anggotaBelumBayar} anggota belum bayar'
                          : 'Semua anggota sudah lunas!',
                    ),
                    backgroundColor: const Color(0xFF0F6E56),
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Izin notifikasi ditolak. Aktifkan di pengaturan HP.',
                    ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Section ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 48,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF0F6E56),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang!',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFCCFBF1),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Kas Terkumpul',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp ',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatAngka(data.totalKas),
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Bento Stats ───────────────────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        value: '${data.totalAnggota}',
                        label: 'Total\nAnggota',
                        valueColor: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        value: '${data.anggotaSudahBayar}',
                        label: 'Sudah\nBayar',
                        valueColor: colorScheme.tertiaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        value: '${data.anggotaBelumBayar}',
                        label: 'Belum\nBayar',
                        valueColor: colorScheme.error,
                        isError: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Ringkasan Bulan Ini ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Bulan Ini',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      children: [
                        SummaryRow(
                          icon: Icons.arrow_downward,
                          iconColor: colorScheme.tertiaryContainer,
                          iconBgColor: colorScheme.tertiaryContainer.withValues(
                            alpha: 0.1,
                          ),
                          label: 'Pemasukan',
                          amount:
                              '+${AppData.formatRupiah(data.pemasukanBulanIni)}',
                          amountColor: colorScheme.tertiaryContainer,
                        ),
                        const Divider(height: 32, color: Color(0xFFE4E2E2)),
                        SummaryRow(
                          icon: Icons.arrow_upward,
                          iconColor: colorScheme.error,
                          iconBgColor: colorScheme.error.withValues(alpha: 0.1),
                          label: 'Pengeluaran',
                          amount:
                              '-${AppData.formatRupiah(data.pengeluaranBulanIni)}',
                          amountColor: colorScheme.onSurface,
                        ),
                        const Divider(height: 32, color: Color(0xFFE4E2E2)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Saldo Bersih',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              AppData.formatRupiah(data.saldoBersihBulanIni),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Anggota Belum Bayar ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Belum Bayar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  const AnggotaScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        child: Text(
                          'Lihat Semua',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (data.anggotaBelumBayarList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '🎉 Semua anggota sudah bayar!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    ...data.anggotaBelumBayarList.map((a) {
                      final kekurangan = data.hitungKekurangan(a);
                      final selisih = data.hitungSelisihPeriode(a);
                      final label = data.labelPeriode(a);
                      String statusText;
                      if (kekurangan > 0 && selisih < 0) {
                        statusText =
                            'Kurang ${AppData.formatRupiah(kekurangan)} (${-selisih} $label)';
                      } else {
                        statusText = 'Periode ini';
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MemberCard(
                          initials: a.inisial,
                          name: a.nama,
                          status: statusText,
                          anggotaId: a.id,
                          fotoProfil: a.fotoProfil,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailAnggotaScreen(anggotaId: a.id),
                              ),
                            );
                          },
                          onTagih: () =>
                              showCatatPembayaranSheet(context, anggota: a),
                        ),
                      );
                    }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNav(context, _selectedIndex),
    );
  }

  String _formatAngka(int amount) {
    final str = amount.abs().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    final reversed = buffer.toString().split('').reversed.join('');
    return amount < 0 ? '-$reversed' : reversed;
  }
}
