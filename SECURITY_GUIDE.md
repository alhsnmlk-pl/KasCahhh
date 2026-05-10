# 🔒 Security Guide - KasCahh

## ⚠️ IMPORTANT: API Keys Rotation Required

**Status**: ✅ API keys telah di-rotate dan dihapus dari repository

### What Happened?
API keys Supabase sebelumnya ter-commit ke repository dan exposed secara public. Keys tersebut sudah **TIDAK VALID** dan telah di-rotate.

---

## 🔐 Setup Supabase Credentials (Required)

### Step 1: Get New API Keys

1. Buka [Supabase Dashboard](https://app.supabase.com)
2. Login dan pilih project Anda
3. Navigasi ke: **Settings → API**
4. Copy credentials berikut:
   - **Project URL** (contoh: `https://xxxxx.supabase.co`)
   - **anon public** key (JWT token panjang)

### Step 2: Configure Local Environment

1. Copy file `.env.example` menjadi `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit file `.env` dan isi dengan credentials Anda:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

3. **JANGAN commit file `.env` ke Git!** (sudah ada di `.gitignore`)

### Step 3: Verify Configuration

Jalankan aplikasi dan pastikan tidak ada error:
```bash
flutter run
```

Cek console untuk pesan:
- ✅ `Supabase initialized successfully` → Berhasil
- ❌ `Error initializing Supabase` → Periksa credentials

---

## 🛡️ Row Level Security (RLS) Policies

### Current Setup: Public Access (Development Mode)

**Status**: ⚠️ **Development Mode** - Semua user bisa akses semua data

File `supabase_schema.sql` saat ini menggunakan **OPSI 1: Public Access** yang mengizinkan akses penuh tanpa authentication.

```sql
-- Current policy (Development)
CREATE POLICY "Public access for anggota" ON anggota
    FOR ALL USING (true) WITH CHECK (true);
```

**Gunakan ini jika:**
- ✅ Aplikasi hanya untuk 1 user/organisasi
- ✅ Development/testing
- ✅ Single-user deployment

**JANGAN gunakan untuk:**
- ❌ Production dengan multiple users
- ❌ Public-facing application
- ❌ Aplikasi yang memerlukan data isolation

---

## 🔒 Production Setup: Authenticated Users

Untuk production dengan multiple users, ikuti langkah berikut:

### Step 1: Enable Supabase Authentication

1. Buka Supabase Dashboard → **Authentication**
2. Enable authentication providers (Email, Google, dll)
3. Configure email templates dan redirect URLs

### Step 2: Update Database Schema

Jalankan SQL berikut di Supabase SQL Editor:

```sql
-- Tambahkan user_id column ke semua tabel
ALTER TABLE anggota ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
ALTER TABLE pembayaran ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
ALTER TABLE pengeluaran ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
ALTER TABLE pemasukan_lain ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
ALTER TABLE settings ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- Create indexes untuk performance
CREATE INDEX IF NOT EXISTS idx_anggota_user_id ON anggota(user_id);
CREATE INDEX IF NOT EXISTS idx_pembayaran_user_id ON pembayaran(user_id);
CREATE INDEX IF NOT EXISTS idx_pengeluaran_user_id ON pengeluaran(user_id);
CREATE INDEX IF NOT EXISTS idx_pemasukan_lain_user_id ON pemasukan_lain(user_id);
CREATE INDEX IF NOT EXISTS idx_settings_user_id ON settings(user_id);
```

### Step 3: Update RLS Policies

Uncomment **OPSI 2** di file `supabase_schema.sql` dan jalankan di SQL Editor:

```sql
-- Drop public policies
DROP POLICY IF EXISTS "Public access for anggota" ON anggota;
-- ... (drop semua public policies)

-- Create authenticated policies
CREATE POLICY "Users can view their own anggota" ON anggota
    FOR SELECT USING (auth.uid() = user_id);
-- ... (lihat file supabase_schema.sql untuk lengkapnya)
```

### Step 4: Update Flutter App

Tambahkan authentication di aplikasi:

```dart
// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _client = Supabase.instance.client;
  
  // Sign up
  static Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }
  
  // Sign in
  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }
  
  // Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  // Get current user
  static User? get currentUser => _client.auth.currentUser;
  
  // Check if authenticated
  static bool get isAuthenticated => currentUser != null;
}
```

Update `SupabaseService` untuk include `user_id`:

```dart
// lib/services/supabase_service.dart
static Future<void> syncAnggota(List<Anggota> anggotaList) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) throw Exception('User not authenticated');
  
  for (final anggota in anggotaList) {
    await client.from('anggota').upsert({
      'id': anggota.id,
      'user_id': userId,  // ← Tambahkan ini
      'nama': anggota.nama,
      // ... field lainnya
    });
  }
}
```

---

## 🔑 Best Practices

### ✅ DO's

1. **Always use environment variables** untuk credentials
2. **Never commit** `.env` files ke Git
3. **Rotate API keys** jika ter-expose
4. **Use RLS policies** untuk data isolation
5. **Enable authentication** untuk production
6. **Use HTTPS** untuk semua API calls
7. **Validate input** di client dan server
8. **Log security events** untuk monitoring

### ❌ DON'Ts

1. **Never hardcode** API keys di source code
2. **Never commit** credentials ke Git
3. **Never use public policies** di production
4. **Never trust client-side** validation saja
5. **Never expose** service role keys
6. **Never share** API keys via email/chat
7. **Never use same keys** untuk dev dan production

---

## 🚨 Security Checklist

### Before Production Deployment

- [ ] API keys sudah di-rotate
- [ ] `.env` file tidak ter-commit ke Git
- [ ] RLS policies sudah diupdate (OPSI 2)
- [ ] Authentication sudah diimplementasi
- [ ] User data isolation sudah ditest
- [ ] Input validation sudah comprehensive
- [ ] Error messages tidak expose sensitive info
- [ ] HTTPS enforced untuk semua connections
- [ ] Rate limiting configured di Supabase
- [ ] Backup strategy sudah ada
- [ ] Monitoring & alerting sudah setup

---

## 📞 Emergency Response

### If API Keys Are Exposed

1. **Immediately rotate keys** di Supabase Dashboard:
   - Settings → API → Reset API keys
   
2. **Update `.env` file** dengan keys baru

3. **Revoke old keys** di Supabase

4. **Check logs** untuk suspicious activity:
   - Supabase Dashboard → Logs
   
5. **Notify team** jika ada data breach

6. **Update documentation** dengan keys baru

---

## 📚 Additional Resources

- [Supabase Security Best Practices](https://supabase.com/docs/guides/auth/row-level-security)
- [Flutter Security Guidelines](https://flutter.dev/docs/deployment/security)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)

---

## 🆘 Support

Jika ada pertanyaan atau menemukan security issue:

1. **JANGAN** buat public issue di GitHub
2. Email ke: alasama351@gmail.com
3. Include: deskripsi issue, steps to reproduce, impact assessment

---

**Last Updated**: 2026-05-10  
**Version**: 1.0.0  
**Status**: ✅ Keys Rotated, RLS Documented
