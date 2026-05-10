/// Utility class untuk validasi input
class Validators {
  /// Validasi nama tidak boleh kosong dan minimal 2 karakter
  static String? validateNama(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    if (value.trim().length > 50) {
      return 'Nama maksimal 50 karakter';
    }
    return null;
  }

  /// Validasi nominal harus positif dan tidak boleh 0
  static String? validateNominal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nominal tidak boleh kosong';
    }

    final nominal = int.tryParse(value.replaceAll('.', '').replaceAll(',', ''));
    if (nominal == null) {
      return 'Nominal harus berupa angka';
    }

    if (nominal <= 0) {
      return 'Nominal harus lebih dari 0';
    }

    if (nominal > 999999999) {
      return 'Nominal terlalu besar (maks 999.999.999)';
    }

    return null;
  }

  /// Validasi keterangan tidak boleh kosong
  static String? validateKeterangan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Keterangan tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Keterangan minimal 3 karakter';
    }
    if (value.trim().length > 200) {
      return 'Keterangan maksimal 200 karakter';
    }
    return null;
  }

  /// Validasi kategori tidak boleh kosong
  static String? validateKategori(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kategori tidak boleh kosong';
    }
    return null;
  }

  /// Validasi tanggal tidak boleh di masa depan (untuk pembayaran)
  static String? validateTanggalPembayaran(DateTime? value) {
    if (value == null) {
      return 'Tanggal tidak boleh kosong';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(value.year, value.month, value.day);

    if (selected.isAfter(today)) {
      return 'Tanggal tidak boleh di masa depan';
    }

    // Validasi tidak boleh lebih dari 5 tahun ke belakang
    final fiveYearsAgo = today.subtract(const Duration(days: 365 * 5));
    if (selected.isBefore(fiveYearsAgo)) {
      return 'Tanggal terlalu lama (maks 5 tahun ke belakang)';
    }

    return null;
  }

  /// Validasi nama aplikasi
  static String? validateNamaAplikasi(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama aplikasi tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama aplikasi minimal 3 karakter';
    }
    if (value.trim().length > 30) {
      return 'Nama aplikasi maksimal 30 karakter';
    }
    return null;
  }

  /// Validasi nama periode
  static String? validateNamaPeriode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama periode tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama periode minimal 3 karakter';
    }
    if (value.trim().length > 50) {
      return 'Nama periode maksimal 50 karakter';
    }
    return null;
  }

  /// Sanitize input untuk mencegah injection
  static String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>]'), '') // Remove HTML tags
        .replaceAll(
          RegExp(r'[\x00-\x1F\x7F]'),
          '',
        ); // Remove control characters
  }

  /// Validasi ukuran file foto (maks 5MB)
  static String? validateFileSize(int bytes) {
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (bytes > maxSize) {
      return 'Ukuran foto terlalu besar (maks 5MB)';
    }
    return null;
  }
}
