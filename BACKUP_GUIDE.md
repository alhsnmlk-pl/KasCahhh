# 💾 Panduan Backup & Restore Data KasCahh

## 📋 Daftar Isi
- [Tentang Backup](#-tentang-backup)
- [Cara Membuat Backup](#-cara-membuat-backup)
- [Cara Restore Data](#-cara-restore-data)
- [Manajemen File Backup](#-manajemen-file-backup)
- [Tips & Best Practices](#-tips--best-practices)
- [Troubleshooting](#-troubleshooting)

---

## 📖 Tentang Backup

### Apa itu Backup?
Backup adalah salinan lengkap dari semua data aplikasi KasCahh Anda yang disimpan dalam format JSON. File backup ini dapat digunakan untuk:
- 🔄 Memulihkan data jika terjadi kehilangan data
- 📱 Memindahkan data ke device lain
- 💾 Menyimpan snapshot data pada waktu tertentu
- 🔐 Mengamankan data sebelum melakukan perubahan besar

### Apa yang Di-backup?
File backup mencakup **semua data** aplikasi:
- ✅ Data anggota (nama, iuran, frekuensi, dll)
- ✅ Riwayat pembayaran semua anggota
- ✅ Data pengeluaran
- ✅ Data pemasukan lain
- ✅ Pengaturan aplikasi (nama, periode, dll)
- ⚠️ **Tidak termasuk**: Foto profil (disimpan terpisah di file system)

### Format File Backup
- **Format**: JSON (JavaScript Object Notation)
- **Nama File**: `kascahh_backup_[timestamp].json`
- **Contoh**: `kascahh_backup_1715356800000.json`
- **Lokasi**: Folder Documents aplikasi

---

## 📤 Cara Membuat Backup

### Langkah-langkah:

1. **Buka Aplikasi KasCahh**
   - Jalankan aplikasi di device Anda

2. **Masuk ke Menu Pengaturan**
   - Tap icon ⚙️ (Pengaturan) di bottom navigation bar

3. **Scroll ke Section "Data Kas"**
   - Cari section dengan icon 💾 Storage

4. **Tap "Buat Backup Data"**
   - Button berwarna hijau muda dengan icon 💾 Backup

5. **Tunggu Proses Backup**
   - Aplikasi akan menampilkan loading indicator
   - Proses biasanya memakan waktu < 1 detik

6. **Share atau Simpan File**
   - Setelah backup selesai, dialog share akan muncul
   - Pilih aplikasi untuk menyimpan file:
     - 📧 Email
     - 💬 WhatsApp
     - ☁️ Google Drive
     - 📁 File Manager
     - Atau aplikasi lainnya

7. **Konfirmasi Backup Berhasil**
   - Notifikasi hijau akan muncul: "✅ Backup berhasil dibuat dan siap dibagikan"

### Tips Membuat Backup:
- 🕐 Buat backup secara rutin (mingguan/bulanan)
- 📅 Buat backup sebelum update aplikasi
- 🔄 Buat backup sebelum reset data
- ☁️ Simpan backup di cloud storage (Google Drive, Dropbox, dll)
- 📧 Kirim backup ke email Anda sebagai backup tambahan

---

## 📥 Cara Restore Data

### Langkah-langkah:

1. **Buka Aplikasi KasCahh**
   - Jalankan aplikasi di device Anda

2. **Masuk ke Menu Pengaturan**
   - Tap icon ⚙️ (Pengaturan) di bottom navigation bar

3. **Scroll ke Section "Data Kas"**
   - Cari section dengan icon 💾 Storage

4. **Tap "Pulihkan dari Backup"**
   - Button berwarna hijau terang dengan icon 🔄 Restore

5. **Pilih File Backup**
   - Dialog akan menampilkan daftar file backup yang tersedia
   - Setiap file menampilkan:
     - 📅 Tanggal backup
     - 🕐 Waktu backup
     - 💾 Ukuran file
   - Tap file backup yang ingin dipulihkan

6. **Konfirmasi Restore**
   - Dialog konfirmasi akan muncul
   - **PERINGATAN**: Data saat ini akan diganti dengan data dari backup
   - Tap "Restore" untuk melanjutkan
   - Tap "Batal" untuk membatalkan

7. **Tunggu Proses Restore**
   - Aplikasi akan menampilkan loading indicator
   - Proses biasanya memakan waktu < 2 detik

8. **Restart Aplikasi**
   - Notifikasi akan muncul: "✅ Data berhasil dipulihkan. Silakan restart aplikasi untuk melihat perubahan."
   - **Tutup aplikasi** (swipe dari recent apps)
   - **Buka kembali aplikasi**
   - Data dari backup sudah dipulihkan! 🎉

### ⚠️ Peringatan Penting:
- ❗ Restore akan **menimpa semua data saat ini**
- 💾 Buat backup data saat ini sebelum restore (jika diperlukan)
- 🔄 Restart aplikasi diperlukan untuk melihat perubahan
- 📸 Foto profil tidak ikut di-restore (harus diupload ulang)

---

## 🗂️ Manajemen File Backup

### Melihat Daftar Backup
1. Tap "Pulihkan dari Backup" di menu Pengaturan
2. Dialog akan menampilkan semua file backup yang tersedia
3. File diurutkan dari yang terbaru ke terlama

### Menghapus File Backup
1. Tap "Pulihkan dari Backup"
2. Pada daftar backup, tap icon 🗑️ (Delete) di sebelah kanan file
3. File backup akan dihapus

### Auto Cleanup
- 🧹 Aplikasi otomatis menghapus backup yang lebih dari **30 hari**
- 🔄 Cleanup dilakukan saat aplikasi dibuka
- 💾 Simpan backup penting di cloud storage untuk jangka panjang

### Lokasi File Backup
- **Android**: `/data/data/id.kascahh.app/app_flutter/`
- **iOS**: `Library/Application Support/`
- **Akses Manual**: Gunakan file manager dengan akses root (Android) atau iTunes File Sharing (iOS)

---

## 💡 Tips & Best Practices

### Jadwal Backup Rutin
```
📅 Backup Harian   → Jika ada transaksi setiap hari
📅 Backup Mingguan → Untuk kas dengan aktivitas sedang
📅 Backup Bulanan  → Untuk kas dengan aktivitas rendah
```

### Strategi Backup 3-2-1
Ikuti aturan backup profesional:
- **3** salinan data (1 original + 2 backup)
- **2** media penyimpanan berbeda (device + cloud)
- **1** backup off-site (cloud storage)

### Contoh Implementasi:
1. 💾 **Backup Lokal**: File di device (otomatis)
2. ☁️ **Backup Cloud**: Upload ke Google Drive setiap minggu
3. 📧 **Backup Email**: Kirim ke email setiap bulan

### Naming Convention
Jika menyimpan manual, gunakan nama yang jelas:
```
kascahh_backup_2026-05-10_kas-rt04.json
kascahh_backup_2026-04-30_sebelum-reset.json
kascahh_backup_2026-03-31_akhir-bulan.json
```

### Keamanan Backup
- 🔐 File backup berisi data sensitif (nama, jumlah uang)
- 🚫 Jangan share backup di grup publik
- ✅ Simpan di cloud storage pribadi (Google Drive, iCloud)
- ✅ Gunakan password untuk file backup (zip dengan password)

---

## 🔧 Troubleshooting

### ❌ "Tidak ada file backup ditemukan"
**Penyebab**: Belum pernah membuat backup atau file terhapus

**Solusi**:
1. Buat backup baru dengan tap "Buat Backup Data"
2. Jika pernah membuat backup, cek apakah file masih ada di device
3. Restore dari backup yang disimpan di cloud/email

---

### ❌ "Gagal membuat backup"
**Penyebab**: Tidak ada izin akses storage atau storage penuh

**Solusi**:
1. Cek izin aplikasi di Settings → Apps → KasCahh → Permissions
2. Pastikan storage device tidak penuh
3. Restart aplikasi dan coba lagi

---

### ❌ "Gagal restore backup"
**Penyebab**: File backup corrupt atau format tidak valid

**Solusi**:
1. Pastikan file backup adalah file JSON yang valid
2. Coba restore dari backup lain
3. Jika semua backup gagal, mulai dari awal dan buat data baru

---

### ❌ "Data tidak berubah setelah restore"
**Penyebab**: Aplikasi belum di-restart

**Solusi**:
1. **Tutup aplikasi sepenuhnya** (swipe dari recent apps)
2. **Buka kembali aplikasi**
3. Data seharusnya sudah berubah

---

### ❌ "Foto profil hilang setelah restore"
**Penyebab**: Foto profil tidak disimpan dalam file backup

**Solusi**:
1. Foto profil harus diupload ulang secara manual
2. Untuk backup foto, gunakan fitur backup device (Google Photos, iCloud)
3. Atau copy folder foto manual dari file manager

---

### ❌ "Backup hanya tersedia di versi mobile"
**Penyebab**: Fitur backup/restore tidak didukung di web

**Solusi**:
1. Gunakan aplikasi di Android atau iOS
2. Untuk web, gunakan export CSV sebagai alternatif

---

## 📞 Butuh Bantuan?

Jika mengalami masalah yang tidak tercantum di sini:

1. 📧 **Email**: alasama351@gmail.com
2. 🐛 **Report Bug**: Buat issue di GitHub repository
3. 💬 **Diskusi**: Hubungi developer

---

## 🔄 Update Log

### v1.0.0 (2026-05-10)
- ✨ Fitur backup/restore pertama kali ditambahkan
- 💾 Format backup: JSON
- 🔄 Auto cleanup backup lama (30+ hari)
- 📤 Share backup via aplikasi lain
- 🗂️ Manajemen file backup (view, delete)

---

<div align="center">

**💾 Backup data Anda secara rutin!**

Made with Flutter 💙 | KasCahh v1.0

</div>
