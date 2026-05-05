import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/beranda_screen.dart';
import '../screens/anggota_screen.dart';
import '../screens/catatan_screen.dart';
import '../screens/pengaturan_screen.dart';

Widget buildBottomNav(BuildContext context, int selectedIndex) {
  void onTap(int index) {
    if (index == selectedIndex) return;
    Widget destination;
    switch (index) {
      case 0:
        destination = const BerandaScreen();
        break;
      case 1:
        destination = const AnggotaScreen();
        break;
      case 2:
        destination = const CatatanScreen();
        break;
      case 3:
        destination = const PengaturanScreen();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, a1, a2) => destination,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  return Container(
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: Colors.grey.shade200)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF0F6E56),
      unselectedItemColor: Colors.grey.shade500,
      selectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_filled),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined),
          activeIcon: Icon(Icons.group),
          label: 'Anggota',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description_outlined),
          activeIcon: Icon(Icons.description),
          label: 'Catatan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Pengaturan',
        ),
      ],
    ),
  );
}
