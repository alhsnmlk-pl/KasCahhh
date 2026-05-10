import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '../models/app_data.dart';
import '../services/storage_service.dart';
import '../utils/validators.dart';

// ─── Show Helper ─────────────────────────────────────────────────────────────

void showTambahAnggotaSheet(
  BuildContext context, {
  Anggota? anggota, // jika diisi => mode edit
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TambahAnggotaSheet(anggota: anggota),
  );
}

// ─── Widget ──────────────────────────────────────────────────────────────────

class TambahAnggotaSheet extends StatefulWidget {
  final Anggota? anggota;
  const TambahAnggotaSheet({super.key, this.anggota});

  @override
  State<TambahAnggotaSheet> createState() => _TambahAnggotaSheetState();
}

class _TambahAnggotaSheetState extends State<TambahAnggotaSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  Uint8List? _fotoProfil;
  String? _fotoPath;

  bool get _isEdit => widget.anggota != null;

  @override
  void initState() {
    super.initState();
    final a = widget.anggota;
    _namaCtrl = TextEditingController(text: a?.nama ?? '');
    _fotoPath = a?.fotoProfilPath;
    _loadFoto();
  }

  Future<void> _loadFoto() async {
    if (_fotoPath != null) {
      final bytes = await StorageService.loadFotoProfil(_fotoPath);
      if (mounted) {
        setState(() => _fotoProfil = bytes);
      }
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final data = AppDataProvider.of(context);
    final namaSanitized = Validators.sanitizeInput(_namaCtrl.text.trim());

    if (_isEdit) {
      data.editAnggota(
        widget.anggota!.id,
        nama: namaSanitized,
        fotoProfilPath: _fotoPath,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data anggota berhasil diperbarui'),
          backgroundColor: Color(0xFF0F6E56),
        ),
      );
    } else {
      data.tambahAnggota(nama: namaSanitized, fotoProfilPath: _fotoPath);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anggota berhasil ditambahkan'),
          backgroundColor: Color(0xFF0F6E56),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.only(top: kToolbarHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            const SizedBox(height: 16),
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFE4E2E2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEdit ? 'Edit Anggota' : 'Tambah Anggota',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Profil Photo Picker
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: Stack(
                  children: [
                    _fotoProfil != null
                        ? CircleAvatar(
                            radius: 40,
                            backgroundImage: MemoryImage(_fotoProfil!),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF5F3F3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
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

                            // Validasi ukuran file
                            final sizeError = Validators.validateFileSize(
                              bytes.length,
                            );

                            if (sizeError != null) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(sizeError),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Simpan foto ke file system
                            try {
                              final anggotaId =
                                  widget.anggota?.id ??
                                  DateTime.now().millisecondsSinceEpoch
                                      .toString();
                              final path = await StorageService.saveFotoProfil(
                                anggotaId,
                                bytes,
                              );

                              if (mounted) {
                                setState(() {
                                  _fotoProfil = bytes;
                                  _fotoPath = path;
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
              ),
            ),
            const SizedBox(height: 24),

            // Scrollable Form
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0 + bottomInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama
                    _buildLabel('Nama Lengkap'),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _namaCtrl,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 50,
                      validator: Validators.validateNama,
                      decoration: _inputDecoration(
                        hint: 'Masukkan nama anggota',
                        prefixIcon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Sticky Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE4E2E2))),
              ),
              child: ElevatedButton.icon(
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F6E56),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.save),
                label: Text(
                  _isEdit ? 'Simpan Perubahan' : 'Simpan Anggota',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF50625D),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF6F7A74)),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF6F7A74)),
      filled: true,
      fillColor: const Color(0xFFFBF9F8),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
