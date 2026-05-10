# 🚀 Panduan Setup Supabase untuk KasCahh

## 📋 Daftar Isi
- [Apa itu Supabase?](#-apa-itu-supabase)
- [Kenapa Menggunakan Supabase?](#-kenapa-menggunakan-supabase)
- [Setup Supabase Project](#-setup-supabase-project)
- [Konfigurasi Database](#-konfigurasi-database)
- [Integrasi dengan Flutter](#-integrasi-dengan-flutter)
- [Testing](#-testing)
- [Troubleshooting](#-troubleshooting)

---

## 🌟 Apa itu Supabase?

**Supabase** adalah platform Backend-as-a-Service (BaaS) open-source yang menyediakan:
- 🗄️ **PostgreSQL Database** - Database relational yang powerful
- 🔐 **Authentication** - User management & auth
- 📦 **Storage** - File storage untuk foto/dokumen
- 🔄 **Realtime** - Sync data real-time antar device
- 🚀 **API Auto-generated** - REST & GraphQL API otomatis

**Alternatif open-source untuk Firebase!**

---

## 💡 Kenapa Menggunakan Supabase?

### Keuntungan untuk KasCahh:

✅ **Sync Antar Device**
- Data tersimpan di cloud
- Akses dari HP/tablet manapun
- Tidak hilang saat ganti device

✅ **Backup Otomatis**
- Data aman di cloud
- Tidak perlu backup manual
- Restore kapan saja

✅ **Multi-User (Future)**
- Bisa diakses banyak orang
- Kolaborasi real-time
- Role & permission management

✅ **Gratis untuk Mulai**
- Free tier: 500MB database
- 1GB file storage
- 2GB bandwidth/bulan
- Cukup untuk ratusan anggota!

✅ **Scalable**
- Bisa upgrade kapan saja
- Handle ribuan transaksi
- Performance tinggi

---

## 🛠️ Setup Supabase Project

### Step 1: Buat Akun Supabase

1. **Buka** [https://supabase.com](https://supabase.com)
2. **Klik** "Start your project"
3. **Sign up** dengan:
   - GitHub account (recommended)
   - Google account
   - Email & password

### Step 2: Buat Project Baru

1. **Klik** "New Project"
2. **Isi form**:
   ```
   Name: KasCahh
   Database Password: [buat password kuat, simpan di tempat aman]
   Region: Southeast Asia (Singapore) - untuk Indonesia
   Pricing Plan: Free
   ```
3. **Klik** "Create new project"
4. **Tunggu** ~2 menit sampai project ready

### Step 3: Dapatkan API Credentials

1. **Buka** Project Settings (icon ⚙️ di sidebar)
2. **Klik** "API" di menu
3. **Copy** credentials berikut:
   ```
   Project URL: https://xxxxxxxxxxxxx.supabase.co
   anon public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```
4. **Simpan** di tempat aman (akan digunakan di Flutter)

---

## 🗄️ Konfigurasi Database

### Step 1: Buka SQL Editor

1. **Klik** icon 🔧 "SQL Editor" di sidebar
2. **Klik** "New Query"

### Step 2: Jalankan Schema SQL

1. **Buka file** `supabase_schema.sql` di project KasCahh
2. **Copy semua isi** file tersebut
3. **Paste** di SQL Editor Supabase
4. **Klik** "Run" atau tekan `Ctrl+Enter`
5. **Tunggu** sampai muncul "Success. No rows returned"

### Step 3: Verifikasi Tables

1. **Klik** icon 🗄️ "Table Editor" di sidebar
2. **Pastikan** tables berikut sudah ada:
   - ✅ `anggota`
   - ✅ `pembayaran`
   - ✅ `pengeluaran`
   - ✅ `pemasukan_lain`
   - ✅ `settings`

### Step 4: Check Row Level Security (RLS)

1. **Klik** salah satu table (misal: `anggota`)
2. **Scroll** ke bawah, cari section "Policies"
3. **Pastikan** ada policy "Allow all for anggota"
4. **Status** harus "Enabled"

---

## 📱 Integrasi dengan Flutter

### Step 1: Buat Config File

Buat file `.env` di root project (sejajar dengan `pubspec.yaml`):

```env
# Supabase Configuration
SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**⚠️ PENTING**: Tambahkan `.env` ke `.gitignore` agar tidak ter-commit!

```gitignore
# .gitignore
.env
*.env
```

### Step 2: Update main.dart

Tambahkan initialization Supabase di `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize(
    supabaseUrl: 'https://xxxxxxxxxxxxx.supabase.co',
    supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  );

  runApp(const MyApp());
}
```

**💡 Tips**: Untuk production, gunakan environment variables atau secure storage untuk menyimpan credentials.

### Step 3: Test Connection

Tambahkan test di `main.dart` setelah initialization:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize(
    supabaseUrl: 'YOUR_SUPABASE_URL',
    supabaseAnonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Test connection
  try {
    final count = await SupabaseService.client
        .from('anggota')
        .select()
        .count();
    print('✅ Supabase connected! Anggota count: $count');
  } catch (e) {
    print('❌ Supabase connection failed: $e');
  }

  runApp(const MyApp());
}
```

### Step 4: Jalankan Aplikasi

```bash
flutter run
```

**Check console output**:
- ✅ Jika muncul "Supabase connected!" → Berhasil!
- ❌ Jika error → Lihat troubleshooting di bawah

---

## 🧪 Testing

### Test 1: Sync Data ke Supabase

Tambahkan button test di Pengaturan screen:

```dart
ElevatedButton(
  onPressed: () async {
    try {
      final data = AppDataProvider.of(context);
      await SupabaseService.syncAll(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Sync berhasil!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Sync gagal: $e')),
      );
    }
  },
  child: Text('Test Sync to Supabase'),
)
```

### Test 2: Fetch Data dari Supabase

```dart
ElevatedButton(
  onPressed: () async {
    try {
      final result = await SupabaseService.fetchAll();
      print('Anggota: ${result['anggota'].length}');
      print('Pengeluaran: ${result['pengeluaran'].length}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Fetch berhasil!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Fetch gagal: $e')),
      );
    }
  },
  child: Text('Test Fetch from Supabase'),
)
```

### Test 3: Check Data di Supabase Dashboard

1. **Buka** Supabase Dashboard
2. **Klik** Table Editor
3. **Pilih** table `anggota`
4. **Pastikan** data sudah muncul

---

## 🔧 Troubleshooting

### ❌ Error: "Invalid API key"

**Penyebab**: API key salah atau expired

**Solusi**:
1. Buka Supabase Dashboard → Settings → API
2. Copy ulang `anon public` key
3. Paste ke `main.dart`
4. Restart aplikasi

---

### ❌ Error: "Row Level Security policy violation"

**Penyebab**: RLS policy belum di-setup dengan benar

**Solusi**:
1. Buka Supabase Dashboard → Table Editor
2. Pilih table yang error
3. Klik "Policies" tab
4. Pastikan ada policy "Allow all"
5. Atau jalankan ulang `supabase_schema.sql`

---

### ❌ Error: "Connection timeout"

**Penyebab**: Network issue atau Supabase URL salah

**Solusi**:
1. Check internet connection
2. Verify Supabase URL di Settings → API
3. Pastikan URL format: `https://xxxxx.supabase.co`
4. Coba ping URL di browser

---

### ❌ Error: "Table does not exist"

**Penyebab**: Schema SQL belum dijalankan

**Solusi**:
1. Buka SQL Editor di Supabase
2. Jalankan `supabase_schema.sql`
3. Verify tables di Table Editor
4. Restart aplikasi

---

### ❌ Data tidak sync

**Penyebab**: Error saat sync atau network issue

**Solusi**:
1. Check console log untuk error message
2. Verify internet connection
3. Check Supabase Dashboard → Logs untuk error
4. Coba sync manual dengan button test

---

## 📊 Monitoring & Analytics

### Dashboard Supabase

**Table Editor**:
- Lihat semua data real-time
- Edit data manual
- Export data ke CSV

**SQL Editor**:
- Jalankan custom query
- Analytics & reporting
- Data migration

**Logs**:
- Monitor API calls
- Debug errors
- Performance metrics

**Database**:
- Storage usage
- Connection pool
- Query performance

---

## 🔐 Security Best Practices

### 1. Jangan Commit Credentials

```gitignore
# .gitignore
.env
*.env
supabase_config.dart
```

### 2. Gunakan Environment Variables

```dart
// Untuk production
final supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
final supabaseKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
```

### 3. Setup Row Level Security (RLS)

Untuk production, customize RLS policies:

```sql
-- Example: Only allow users to see their own data
CREATE POLICY "Users can only see their own data" ON anggota
    FOR SELECT USING (auth.uid() = user_id);
```

### 4. Rotate API Keys

- Rotate keys setiap 6 bulan
- Gunakan service role key hanya di backend
- Never expose service role key di client

---

## 💰 Pricing & Limits

### Free Tier (Cukup untuk KasCahh!)

| Resource | Limit |
|----------|-------|
| Database | 500 MB |
| Storage | 1 GB |
| Bandwidth | 2 GB/month |
| API Requests | Unlimited |
| Realtime | 200 concurrent connections |

### Estimasi Usage KasCahh:

- **100 anggota** = ~50 KB
- **1000 transaksi** = ~200 KB
- **Total** = ~250 KB database
- **Foto** = Gunakan storage service (optional)

**Kesimpulan**: Free tier cukup untuk ratusan anggota! 🎉

---

## 🚀 Next Steps

Setelah setup Supabase berhasil:

1. ✅ **Implement Auto Sync**
   - Sync otomatis setiap perubahan data
   - Background sync setiap 5 menit
   - Sync on app resume

2. ✅ **Offline Mode**
   - Cache data di local (SharedPreferences)
   - Queue changes saat offline
   - Sync saat online kembali

3. ✅ **Conflict Resolution**
   - Handle data conflicts
   - Last-write-wins strategy
   - Atau manual conflict resolution

4. ✅ **Multi-User Support**
   - Authentication dengan Supabase Auth
   - User roles (Admin, Member)
   - Permission management

5. ✅ **Realtime Sync**
   - Listen to database changes
   - Update UI real-time
   - Collaborative editing

---

## 📚 Resources

- 📖 [Supabase Documentation](https://supabase.com/docs)
- 🎓 [Flutter Supabase Tutorial](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- 💬 [Supabase Discord Community](https://discord.supabase.com)
- 🐛 [Report Issues](https://github.com/supabase/supabase/issues)

---

## 🎉 Selesai!

Supabase sudah siap digunakan untuk KasCahh! 🚀

**Happy coding!** 💙

---

<div align="center">

Made with Flutter 💙 | Powered by Supabase 🚀

</div>
