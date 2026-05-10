import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '../models/app_data.dart';
import '../services/backup_service.dart';
import '../services/export_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/foto_profil_widget.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  final int _selectedIndex = 3;

  // Controller untuk field yang perlu disimpan
  late TextEditingController _nominalCtrl;
  late TextEditingController _namaPeriodeCtrl;
  late TextEditingController _mulaiPeriodeCtrl;
  late TextEditingController _namaAplikasiCtrl;

  late String _selectedFrekuensi;
  late String _selectedHariTagihan;
  late bool _pengingatTagihan;
  late bool _laporanBulanan;
  Uint8List? _fotoAplikasi;
  String? _fotoAplikasiPath;

  final List<String> _frekuensiOptions = ['Bulanan', 'Mingguan', 'Harian'];

  List<String> get _hariTagihanOptions {
    if (_selectedFrekuensi == 'Bulanan') {
      return [
        'Tanggal 1',
        'Tanggal 5',
        'Tanggal 10',
        'Tanggal 15',
        'Tanggal 20',
        'Tanggal 25',
        'Akhir Bulan',
      ];
    } else if (_selectedFrekuensi == 'Mingguan') {
      return ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    } else {
      return ['Setiap Hari'];
    }
  }

  @override
  void initState() {
    super.initState();
    final data = AppData();
    _nominalCtrl = TextEditingController(
      text: data.nominalIuranDefault.toString(),
    );
    _namaPeriodeCtrl = TextEditingController(text: data.namaPeriode);
    _mulaiPeriodeCtrl = TextEditingController(text: data.mulaiPeriode);
    _namaAplikasiCtrl = TextEditingController(text: data.namaAplikasi);
    _selectedFrekuensi = data.frekuensiDefault;
    _selectedHariTagihan = data.hariTagihanDefault;
    _pengingatTagihan = data.pengingatTagihan;
    _laporanBulanan = data.laporanBulanan;
    _fotoAplikasiPath = data.fotoAplikasiPath;
    _loadFoto();
  }

  Future<void> _loadFoto() async {
    if (_fotoAplikasiPath != null) {
      final bytes = await StorageService.loadFotoProfil(_fotoAplikasiPath);
      if (mounted) {
        setState(() => _fotoAplikasi = bytes);
      }
    }
  }

  @override
  void dispose() {
    _nominalCtrl.dispose();
    _namaPeriodeCtrl.dispose();
    _mulaiPeriodeCtrl.dispose();
    _namaAplikasiCtrl.dispose();
    super.dispose();
  }

  void _simpanPengaturan() {
    final data = AppDataProvider.of(context);
    final nominal =
        int.tryParse(
          _nominalCtrl.text.replaceAll('.', '').replaceAll(',', ''),
        ) ??
        0;

    data.updateSettings(
      namaAplikasi: _namaAplikasiCtrl.text.trim(),
      fotoAplikasiPath: _fotoAplikasiPath,
      nominalIuranDefault: nominal,
      frekuensiDefault: _selectedFrekuensi,
      hariTagihanDefault: _selectedHariTagihan,
      namaPeriode: _namaPeriodeCtrl.text.trim(),
      mulaiPeriode: _mulaiPeriodeCtrl.text.trim(),
      pengingatTagihan: _pengingatTagihan,
      laporanBulanan: _laporanBulanan,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan berhasil disimpan'),
        backgroundColor: Color(0xFF0F6E56),
      ),
    );
  }

  Future<void> _pilihMulaiPeriode() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_mulaiPeriodeCtrl.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFF0F6E56)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _mulaiPeriodeCtrl.text =
            '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _exportCSV() async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Export hanya tersedia di versi mobile (Android/iOS)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final data = AppDataProvider.of(context);
    try {
      await ExportService.exportRekap(data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal export: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ─── Backup/Restore ────────────────────────────────────────────────────────

  Future<void> _buatBackup() async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup hanya tersedia di versi mobile (Android/iOS)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Show loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Membuat backup...'),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF0F6E56),
        ),
      );

      await BackupService.shareBackup();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Backup berhasil dibuat dan siap dibagikan'),
          backgroundColor: Color(0xFF0F6E56),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat backup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _restoreBackup() async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restore hanya tersedia di versi mobile (Android/iOS)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final backups = await BackupService.getBackupFiles();

      if (!mounted) return;

      if (backups.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada file backup ditemukan'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show dialog untuk pilih backup
      final selectedBackup = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Pilih Backup',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: backups.length,
              itemBuilder: (context, index) {
                final backup = backups[index];
                final fileName = backup.path.split('\\').last;
                final date = BackupService.getBackupDate(fileName);
                final stat = backup.statSync();
                final size = BackupService.formatFileSize(stat.size);

                return ListTile(
                  leading: const Icon(Icons.backup, color: Color(0xFF0F6E56)),
                  title: Text(
                    date != null ? AppData.formatTanggal(date) : fileName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '$size • ${date?.hour.toString().padLeft(2, '0')}:${date?.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12),
                  ),
                  onTap: () => Navigator.pop(ctx, backup.path),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await BackupService.deleteBackup(backup.path);
                      if (!context.mounted) return;
                      Navigator.pop(ctx);
                      _restoreBackup(); // Refresh list
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.plusJakartaSans()),
            ),
          ],
        ),
      );

      if (selectedBackup == null || !mounted) return;

      // Konfirmasi restore
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Restore Data?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Data saat ini akan diganti dengan data dari backup. Pastikan Anda sudah membuat backup data saat ini jika diperlukan.',
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Batal', style: GoogleFonts.plusJakartaSans()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F6E56),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Restore',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );

      if (confirm != true || !mounted) return;

      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Memulihkan data...'),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF0F6E56),
        ),
      );

      final success = await BackupService.restoreFromBackup(selectedBackup);

      if (!mounted) return;

      if (success) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Data berhasil dipulihkan. Silakan restart aplikasi untuk melihat perubahan.',
            ),
            backgroundColor: Color(0xFF0F6E56),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal restore backup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _konfirmasiReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reset Semua Data?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Semua data anggota, pembayaran, dan pengeluaran akan dihapus. Tindakan ini tidak bisa dibatalkan.',
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
              AppDataProvider.of(context).resetData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua data telah direset'),
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
              'Reset',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

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
          // Simpan button di AppBar
          TextButton(
            onPressed: _simpanPengaturan,
            child: Text(
              'Simpan',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profil Aplikasi
            Container(
              padding: const EdgeInsets.all(24),
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
                  Stack(
                    children: [
                      _fotoAplikasi != null
                          ? CircleAvatar(
                              radius: 40,
                              backgroundImage: MemoryImage(_fotoAplikasi!),
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE4E2E2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.business,
                                size: 40,
                                color: colorScheme.primary,
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () async {
                            if (!mounted) return;

                            final messenger = ScaffoldMessenger.of(context);
                            final picker = ImagePicker();
                            final file = await picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 800,
                              maxHeight: 800,
                              imageQuality: 85,
                            );

                            if (!mounted) return;

                            if (file != null) {
                              final bytes = await file.readAsBytes();

                              try {
                                final path =
                                    await StorageService.saveFotoProfil(
                                      'app_logo',
                                      bytes,
                                    );

                                if (mounted) {
                                  setState(() {
                                    _fotoAplikasi = bytes;
                                    _fotoAplikasiPath = path;
                                  });
                                }
                              } catch (e) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal menyimpan foto: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F6E56),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _namaAplikasiCtrl,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Nama Aplikasi',
                      border: InputBorder.none,
                    ),
                  ),
                  Text(
                    'Ubah profil dan nama organisasi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Iuran Default ──────────────────────────────────────────────
            _buildSection(
              icon: Icons.payments,
              title: 'Iuran Default',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Nominal Iuran (Rp)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nominalCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(
                          'Rp',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: const Color(0xFF3F4944),
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      hintText: '50.000',
                      filled: true,
                      fillColor: const Color(0xFFFBF9F8),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD3E7E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD3E7E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF0F6E56)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Frekuensi'),
                            const SizedBox(height: 8),
                            _buildDropdown(
                              options: _frekuensiOptions,
                              value: _selectedFrekuensi,
                              onChanged: (v) {
                                setState(() {
                                  _selectedFrekuensi = v!;
                                  if (!_hariTagihanOptions.contains(
                                    _selectedHariTagihan,
                                  )) {
                                    _selectedHariTagihan =
                                        _hariTagihanOptions.first;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Hari Tagihan'),
                            const SizedBox(height: 8),
                            _buildDropdown(
                              options: _hariTagihanOptions,
                              value: _selectedHariTagihan,
                              onChanged: (v) =>
                                  setState(() => _selectedHariTagihan = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Periode Kas ────────────────────────────────────────────────
            _buildSection(
              icon: Icons.calendar_month,
              title: 'Periode Kas',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Nama Periode'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _namaPeriodeCtrl,
                    decoration: _inputDeco(hint: 'Kas RT 04 Tahun 2024'),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Mulai Periode'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _mulaiPeriodeCtrl,
                    readOnly: true,
                    onTap: _pilihMulaiPeriode,
                    decoration: _inputDeco(
                      hint: '2024-01-01',
                      icon: Icons.calendar_today,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Notifikasi ─────────────────────────────────────────────────
            _buildSection(
              icon: Icons.notifications_active,
              title: 'Notifikasi',
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: 'Pengingat Tagihan',
                    subtitle:
                        'Kirim notifikasi harian pukul 08:00 untuk tagihan belum bayar',
                    value: _pengingatTagihan,
                    onChanged: (val) async {
                      setState(() => _pengingatTagihan = val);
                      final d = AppDataProvider.of(context);
                      if (val) {
                        final granted =
                            await NotificationService.requestPermission();
                        if (!context.mounted) return;

                        if (granted) {
                          d.updateSettings(pengingatTagihan: true);
                          await NotificationService.aturReminderOtomatis(d);
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pengingat harian aktif (08:00)'),
                              backgroundColor: Color(0xFF0F6E56),
                            ),
                          );
                        } else {
                          setState(() => _pengingatTagihan = false);
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Izin notifikasi ditolak'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      } else {
                        d.updateSettings(pengingatTagihan: false);
                        await NotificationService.cancelAll();
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pengingat dimatikan')),
                        );
                      }
                    },
                    showBorder: true,
                  ),
                  _buildSwitchTile(
                    title: 'Laporan Bulanan',
                    subtitle: 'Terima ringkasan kas setiap akhir bulan',
                    value: _laporanBulanan,
                    onChanged: (val) => setState(() => _laporanBulanan = val),
                    showBorder: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Supabase Cloud Sync Status ────────────────────────────────
            if (SupabaseService.isInitialized)
              _buildSection(
                icon: Icons.cloud_done,
                title: 'Cloud Sync',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5F1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0F6E56).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F6E56),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_done,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto-Sync Aktif',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F6E56),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Data otomatis tersinkronisasi ke cloud setiap kali ada perubahan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF0F6E56),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (SupabaseService.isInitialized) const SizedBox(height: 24),

            // ── Data Kas ───────────────────────────────────────────────────
            _buildSection(
              icon: Icons.storage,
              title: 'Data Kas',
              child: Column(
                children: [
                  // Backup
                  ElevatedButton.icon(
                    onPressed: _buatBackup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD3E7E0),
                      foregroundColor: const Color(0xFF0F6E56),
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.backup, size: 20),
                    label: Text(
                      'Buat Backup Data',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Restore
                  ElevatedButton.icon(
                    onPressed: _restoreBackup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F5F1),
                      foregroundColor: const Color(0xFF0F6E56),
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.restore, size: 20),
                    label: Text(
                      'Pulihkan dari Backup',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Export CSV
                  ElevatedButton.icon(
                    onPressed: _exportCSV,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF8E1),
                      foregroundColor: const Color(0xFFF57C00),
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.download, size: 20),
                    label: Text(
                      'Export Data ke CSV',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Reset
                  ElevatedButton.icon(
                    onPressed: _konfirmasiReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFDAD6),
                      foregroundColor: const Color(0xFF93000A),
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_forever, size: 20),
                    label: Text(
                      'Reset Semua Data Kas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Simpan Semua Button (bawah)
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _simpanPengaturan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F6E56),
                foregroundColor: Colors.white,
                elevation: 4,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.save),
              label: Text(
                'Simpan Pengaturan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Footer
            const SizedBox(height: 32),
            Center(
              child: Text(
                'KasCahh v1.0',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6F7A74),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNav(context, _selectedIndex),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0F6E56), size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B1C1C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF3F4944),
      ),
    );
  }

  InputDecoration _inputDeco({required String hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: icon != null ? Icon(icon, size: 18) : null,
      filled: true,
      fillColor: const Color(0xFFFBF9F8),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD3E7E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD3E7E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0F6E56)),
      ),
    );
  }

  Widget _buildDropdown({
    required List<String> options,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD3E7E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: Color(0xFF3F4944)),
          items: options.map((String v) {
            return DropdownMenuItem<String>(
              value: v,
              child: Text(
                v,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF1B1C1C),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool showBorder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(bottom: BorderSide(color: Color(0xFFE9E8E7)))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF3F4944),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF0F6E56),
          ),
        ],
      ),
    );
  }
}
