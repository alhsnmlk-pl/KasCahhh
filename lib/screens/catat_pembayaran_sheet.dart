import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/app_data.dart';
import '../utils/validators.dart';

// ─── Show Helper ─────────────────────────────────────────────────────────────

void showCatatPembayaranSheet(
  BuildContext context, {
  required Anggota anggota,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CatatPembayaranSheet(anggota: anggota),
  );
}

// ─── Widget ──────────────────────────────────────────────────────────────────

class CatatPembayaranSheet extends StatefulWidget {
  final Anggota anggota;
  const CatatPembayaranSheet({super.key, required this.anggota});

  @override
  State<CatatPembayaranSheet> createState() => _CatatPembayaranSheetState();
}

class _CatatPembayaranSheetState extends State<CatatPembayaranSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jumlahCtrl = TextEditingController();
  final TextEditingController _catatanCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();

  String _selectedMethod = 'Tunai';
  String _selectedStatus = 'Lunas';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _jumlahCtrl.text = widget.anggota.nominalIuran.toString();
    _dateCtrl.text = AppData.formatTanggal(_selectedDate);
  }

  @override
  void dispose() {
    _jumlahCtrl.dispose();
    _catatanCtrl.dispose();
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
    final jumlah =
        int.tryParse(
          _jumlahCtrl.text.replaceAll('.', '').replaceAll(',', ''),
        ) ??
        0;

    final catatanSanitized = Validators.sanitizeInput(_catatanCtrl.text.trim());

    data.catatPembayaran(
      anggotaId: widget.anggota.id,
      jumlah: jumlah,
      tanggal: _selectedDate,
      metode: _selectedMethod,
      status: _selectedStatus,
      catatan: catatanSanitized,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pembayaran ${AppData.formatRupiah(jumlah)} berhasil dicatat',
        ),
        backgroundColor: const Color(0xFF0F6E56),
      ),
    );
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    'Catat Pembayaran',
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
                      color: const Color(0xFFF5F3F3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person,
                          size: 14,
                          color: Color(0xFF50625D),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.anggota.nama,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF50625D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF5F3F3)),
            const SizedBox(height: 16),

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
                    // Jumlah Bayar
                    _buildLabel('Jumlah Bayar'),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _jumlahCtrl,
                      keyboardType: TextInputType.number,
                      validator: Validators.validateNominal,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 8.0,
                          ),
                          child: Text(
                            'Rp',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD3E7E0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD3E7E0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0F6E56),
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
                    _buildLabel('Tanggal'),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _dateCtrl,
                      readOnly: true,
                      onTap: _pilihTanggal,
                      decoration: InputDecoration(
                        suffixIcon: const Icon(
                          Icons.calendar_month,
                          color: Color(0xFF3F4944),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD3E7E0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD3E7E0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0F6E56),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Metode & Status
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Metode'),
                              const SizedBox(height: 4),
                              _buildSegmentedControl(
                                options: ['Tunai', 'Transfer'],
                                selectedValue: _selectedMethod,
                                onChanged: (val) =>
                                    setState(() => _selectedMethod = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Status'),
                              const SizedBox(height: 4),
                              _buildSegmentedControl(
                                options: ['Lunas', 'DP'],
                                selectedValue: _selectedStatus,
                                onChanged: (val) =>
                                    setState(() => _selectedStatus = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Catatan
                    _buildLabel('Catatan (Opsional)'),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _catatanCtrl,
                      maxLines: 2,
                      maxLength: 200,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan keterangan...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF6F7A74),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD3E7E0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD3E7E0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0F6E56),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Sticky CTA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF5F3F3))),
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
                  elevation: 0,
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  'Simpan Pembayaran',
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
        color: const Color(0xFF3F4944),
      ),
    );
  }

  Widget _buildSegmentedControl({
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEDED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = selectedValue == option;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 40,
                decoration: isSelected
                    ? BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      )
                    : const BoxDecoration(),
                alignment: Alignment.center,
                child: Text(
                  option,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF0F6E56)
                        : const Color(0xFF3F4944),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
