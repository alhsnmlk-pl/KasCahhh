import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Widget untuk menampilkan foto profil dengan loading dari file system
class FotoProfilWidget extends StatefulWidget {
  final String? fotoPath;
  final String inisial;
  final double radius;
  final Color? backgroundColor;

  const FotoProfilWidget({
    super.key,
    required this.fotoPath,
    required this.inisial,
    this.radius = 40,
    this.backgroundColor,
  });

  @override
  State<FotoProfilWidget> createState() => _FotoProfilWidgetState();
}

class _FotoProfilWidgetState extends State<FotoProfilWidget> {
  Uint8List? _fotoBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoto();
  }

  @override
  void didUpdateWidget(FotoProfilWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fotoPath != widget.fotoPath) {
      _loadFoto();
    }
  }

  Future<void> _loadFoto() async {
    if (widget.fotoPath == null) {
      setState(() => _isLoading = false);
      return;
    }

    final bytes = await StorageService.loadFotoProfil(widget.fotoPath);
    if (mounted) {
      setState(() {
        _fotoBytes = bytes;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: widget.backgroundColor ?? const Color(0xFFF5F3F3),
        child: SizedBox(
          width: widget.radius * 0.6,
          height: widget.radius * 0.6,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_fotoBytes != null) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundImage: MemoryImage(_fotoBytes!),
      );
    }

    // Fallback ke inisial
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.backgroundColor ?? const Color(0xFFF5F3F3),
      child: Text(
        widget.inisial,
        style: TextStyle(
          fontSize: widget.radius * 0.5,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F6E56),
        ),
      ),
    );
  }
}
