import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/app_data.dart';
import '../utils/validators.dart';

// ─── Show Helper ─────────────────────────────────────────────────────────────

void showTambahPemasukanSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const TambahPemasukanSheet(),
  );
}

// ─── Widget ──────────────────────────────────────────────────────────────────

class TambahPemasukanSheet extends StatefulWidget {
  const TambahPemasukanSheet({super.key});

  @override
  State<TambahPemasukanSheet> createState() => _TambahPemasukanSheetState();
}

class _TambahPemasukanSheetState extends State<TambahPemasukanSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nominalCtrl = TextEditingController();
  final TextEditingController _keteranganCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();

  String _selectedCategory = 'Donasi';
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Donasi', 'icon': Icons.volunteer_activism},
    {'name': 'Sponsor', 'icon': Icons.business_center},
    {'name': 'Penjualan', 'icon': Icons.shopping_cart},
    {'name': 'Acara', 'icon': Icons.event},
    {'name': 'Lainnya', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = AppData.formatTanggal(_selectedDate);
  }

  @override
  void dispose() {
    _nominalCtrl.dispose();
    _keteranganCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
        _selectedDate = picked;
        _dateCtrl.text = AppData.formatTanggal(picked);
      });
    }
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    // Validasi tanggal
    final dateError = Validators.validateTanggalPembayaran(_selectedDate);
    if (dateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dateError), backgroundColor: Colors.red),
      );
      return;
    }

    final data = AppDataProvider.of(context);
    final nominal =
        int.tryParse(
          _nominalCtrl.text.replaceAll('.', '').replaceAll(',', ''),
        ) ??
        0;

    final keteranganSanitized = Validators.sanitizeInput(
      _keteranganCtrl.text.trim(),
    );

    data.tambahPemasukanLain(
      nominal: nominal,
      kategori: _selectedCategory,
      keterangan: keteranganSanitized,
      tanggal: _selectedDate,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pemasukan ${AppData.formatRupiah(nominal)} berhasil dicatat',
        ),
        backgroundColor: const Color(0xFF0F6E56),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: kToolbarHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(
                top: 16,
                bottom: 8,
                left: 16,
                right: 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(bottom: BorderSide(color: Color(0xFFEFEDED))),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    width: 48,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E2E2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF0F6E56,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFF0F6E56),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Tambah Pemasukan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.24,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5F3F3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFF3F4944),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                  bottom: 32.0 + bottomInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nominal
                    _buildLabel('NOMINAL'),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5F1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF0F6E56)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Rp',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F6E56),
                              letterSpacing: -0.64,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _nominalCtrl,
                              keyboardType: TextInputType.number,
                              validator: Validators.validateNominal,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F6E56),
                                letterSpacing: -0.64,
                              ),
                              decoration: const InputDecoration(
                                hintText: '0',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Kategori
                    _buildLabel('KATEGORI'),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat['name'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: InkWell(
                              onTap: () {
                                setState(
                                  () =>
                                      _selectedCategory = cat['name'] as String,
                                );
                              },
                              borderRadius: BorderRadius.circular(24),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF0F6E56)
                                      : const Color(0xFFEFEDED),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      cat['icon'] as IconData,
                                      size: 18,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF3F4944),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      cat['name'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF3F4944),
                                        letterSpacing: 0.12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Keterangan
                    _buildLabel('KETERANGAN'),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _keteranganCtrl,
                      maxLength: 200,
                      validator: Validators.validateKeterangan,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Donasi dari alumni',
                        prefixIcon: const Icon(
                          Icons.notes,
                          color: Color(0xFF3F4944),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFBF9F8),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFBEC9C3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFBEC9C3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF005440),
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tanggal
                    _buildLabel('TANGGAL'),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _dateCtrl,
                      readOnly: true,
                      onTap: _pilihTanggal,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF3F4944),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFBF9F8),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFBEC9C3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFBEC9C3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF005440),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // CTA Button
                    ElevatedButton.icon(
                      onPressed: _simpan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F6E56),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.check_circle),
                      label: Text(
                        'Simpan Pemasukan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
        color: const Color(0xFF3F4944),
        letterSpacing: 0.5,
      ),
    );
  }
}
