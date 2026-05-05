import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/app_data.dart';
import '../widgets/anggota_list_card.dart';
import '../widgets/bottom_nav.dart';
import 'detail_anggota_screen.dart';
import 'tambah_anggota_sheet.dart';

class AnggotaScreen extends StatefulWidget {
  const AnggotaScreen({super.key});

  @override
  State<AnggotaScreen> createState() => _AnggotaScreenState();
}

class _AnggotaScreenState extends State<AnggotaScreen> {
  final int _selectedIndex = 1;
  int _selectedTabIndex = 0;
  DateTime _targetDate = DateTime.now();
  String _searchQuery = '';

  final List<String> _tabs = ['Semua', 'Lunas', 'Belum Bayar'];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Anggota> _filteredAnggota(List<Anggota> all, AppData data) {
    List<Anggota> list = all;

    // Filter by tab
    if (_selectedTabIndex == 1) {
      list = list.where((a) => data.isLunas(a, targetDate: _targetDate)).toList();
    } else if (_selectedTabIndex == 2) {
      list = list.where((a) => !data.isLunas(a, targetDate: _targetDate)).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      list = list
          .where(
            (a) => a.nama.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final data = AppDataProvider.of(context);
    final filtered = _filteredAnggota(data.anggota.toList(), data);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F6E56),
        elevation: 0,
        titleSpacing: 16,
        automaticallyImplyLeading: false,
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
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tidak ada notifikasi baru'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Daftar Anggota',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Search + Tambah Button
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Cari nama anggota...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => showTambahAnggotaSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      'Tambah',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Date Picker Selector
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _targetDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF0F6E56),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() => _targetDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEFEDED)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, color: Color(0xFF0F6E56), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Target: ${AppData.formatTanggal(_targetDate)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F6E56),
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF0F6E56)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tab Filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = index == _selectedTabIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_tabs[index]),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedTabIndex = index);
                      },
                      showCheckmark: false,
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF9AEDCF)
                            : colorScheme.onSurfaceVariant,
                      ),
                      backgroundColor: colorScheme.surface,
                      selectedColor: colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.4,
                                ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.group_off_outlined,
                            size: 56,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Anggota "$_searchQuery" tidak ditemukan'
                                : 'Belum ada anggota',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final a = filtered[i];
                        final sudahBayar = data.isLunas(a, targetDate: _targetDate);
                        final selisih = data.hitungSelisihPeriode(a, targetDate: _targetDate);
                        final label = data.labelPeriode(a);
                        String? periodInfo;
                        Color? periodInfoColor;
                        if (selisih < 0) {
                          periodInfo = 'Kurang ${-selisih} $label';
                          periodInfoColor = colorScheme.error;
                        } else if (selisih > 0) {
                          periodInfo = '+$selisih $label ke depan';
                          periodInfoColor = const Color(0xFF0F6E56);
                        }
                        return AnggotaListCard(
                          name: a.nama,
                          fotoProfil: a.fotoProfil,
                          initial: a.inisial,
                          statusText: sudahBayar ? 'Lunas' : 'Belum Bayar',
                          statusColor: sudahBayar
                              ? colorScheme.tertiaryContainer
                              : colorScheme.error,
                          statusBgColor: sudahBayar
                              ? colorScheme.tertiaryContainer.withValues(
                                  alpha: 0.1,
                                )
                              : colorScheme.error.withValues(alpha: 0.1),
                          currentAmount: AppData.formatRupiah(a.totalDibayar),
                          targetAmount: _formatAngka(a.nominalIuran),
                          amountColor: sudahBayar
                              ? colorScheme.tertiaryContainer
                              : colorScheme.onSurface,
                          periodInfo: periodInfo,
                          periodInfoColor: periodInfoColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailAnggotaScreen(anggotaId: a.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNav(context, _selectedIndex),
    );
  }

  String _formatAngka(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join('');
  }
}
