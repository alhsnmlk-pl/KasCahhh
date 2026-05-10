import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/foto_profil_widget.dart';

class MemberCard extends StatelessWidget {
  final String initials;
  final String name;
  final String status;
  final String anggotaId;
  final String? fotoProfilPath;
  final VoidCallback? onTap;
  final VoidCallback? onTagih;

  const MemberCard({
    super.key,
    required this.initials,
    required this.name,
    required this.status,
    required this.anggotaId,
    this.fotoProfilPath,
    this.onTap,
    this.onTagih,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
            children: [
              Row(
                children: [
                  FotoProfilWidget(
                    fotoPath: fotoProfilPath,
                    inisial: initials,
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        status,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF50625D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  // Tagih button
                  ElevatedButton(
                    onPressed: onTagih,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD3E7E0),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      minimumSize: const Size(64, 36),
                    ),
                    child: Text(
                      'Tagih',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
