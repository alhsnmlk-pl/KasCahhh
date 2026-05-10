-- ============================================================================
-- SUPABASE DATABASE SCHEMA FOR KASCAHH
-- ============================================================================
-- Jalankan script ini di Supabase SQL Editor untuk membuat database schema
-- Dashboard Supabase → SQL Editor → New Query → Paste & Run
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLE: anggota
-- ============================================================================
CREATE TABLE IF NOT EXISTS anggota (
    id TEXT PRIMARY KEY,
    nama TEXT NOT NULL,
    nominal_iuran INTEGER NOT NULL DEFAULT 0,
    frekuensi TEXT NOT NULL DEFAULT 'Bulanan',
    hari_tagihan TEXT[] NOT NULL DEFAULT '{}',
    foto_profil_path TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index untuk pencarian
CREATE INDEX IF NOT EXISTS idx_anggota_nama ON anggota(nama);
CREATE INDEX IF NOT EXISTS idx_anggota_updated_at ON anggota(updated_at);

-- ============================================================================
-- TABLE: pembayaran
-- ============================================================================
CREATE TABLE IF NOT EXISTS pembayaran (
    id TEXT PRIMARY KEY,
    anggota_id TEXT NOT NULL REFERENCES anggota(id) ON DELETE CASCADE,
    jumlah INTEGER NOT NULL DEFAULT 0,
    tanggal TIMESTAMP WITH TIME ZONE NOT NULL,
    metode TEXT NOT NULL DEFAULT 'Tunai',
    status TEXT NOT NULL DEFAULT 'Lunas',
    catatan TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index untuk query cepat
CREATE INDEX IF NOT EXISTS idx_pembayaran_anggota_id ON pembayaran(anggota_id);
CREATE INDEX IF NOT EXISTS idx_pembayaran_tanggal ON pembayaran(tanggal);
CREATE INDEX IF NOT EXISTS idx_pembayaran_updated_at ON pembayaran(updated_at);

-- ============================================================================
-- TABLE: pengeluaran
-- ============================================================================
CREATE TABLE IF NOT EXISTS pengeluaran (
    id TEXT PRIMARY KEY,
    nominal INTEGER NOT NULL DEFAULT 0,
    kategori TEXT NOT NULL,
    keterangan TEXT NOT NULL,
    tanggal TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index untuk query cepat
CREATE INDEX IF NOT EXISTS idx_pengeluaran_tanggal ON pengeluaran(tanggal);
CREATE INDEX IF NOT EXISTS idx_pengeluaran_kategori ON pengeluaran(kategori);
CREATE INDEX IF NOT EXISTS idx_pengeluaran_updated_at ON pengeluaran(updated_at);

-- ============================================================================
-- TABLE: pemasukan_lain
-- ============================================================================
CREATE TABLE IF NOT EXISTS pemasukan_lain (
    id TEXT PRIMARY KEY,
    nominal INTEGER NOT NULL DEFAULT 0,
    kategori TEXT NOT NULL,
    keterangan TEXT NOT NULL,
    tanggal TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index untuk query cepat
CREATE INDEX IF NOT EXISTS idx_pemasukan_lain_tanggal ON pemasukan_lain(tanggal);
CREATE INDEX IF NOT EXISTS idx_pemasukan_lain_kategori ON pemasukan_lain(kategori);
CREATE INDEX IF NOT EXISTS idx_pemasukan_lain_updated_at ON pemasukan_lain(updated_at);

-- ============================================================================
-- TABLE: settings
-- ============================================================================
CREATE TABLE IF NOT EXISTS settings (
    id TEXT PRIMARY KEY DEFAULT 'app_settings',
    nama_aplikasi TEXT NOT NULL DEFAULT 'KasCahh',
    foto_aplikasi_path TEXT,
    nominal_iuran_default INTEGER NOT NULL DEFAULT 50000,
    frekuensi_default TEXT NOT NULL DEFAULT 'Bulanan',
    hari_tagihan_default TEXT NOT NULL DEFAULT 'Tanggal 1',
    nama_periode TEXT NOT NULL DEFAULT 'Kas Kelas',
    mulai_periode TEXT NOT NULL DEFAULT '2026-01-01',
    pengingat_tagihan BOOLEAN NOT NULL DEFAULT true,
    laporan_bulanan BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default settings
INSERT INTO settings (id) VALUES ('app_settings')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- FUNCTIONS: Auto update updated_at timestamp
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers untuk auto update updated_at
DROP TRIGGER IF EXISTS update_anggota_updated_at ON anggota;
CREATE TRIGGER update_anggota_updated_at
    BEFORE UPDATE ON anggota
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_pembayaran_updated_at ON pembayaran;
CREATE TRIGGER update_pembayaran_updated_at
    BEFORE UPDATE ON pembayaran
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_pengeluaran_updated_at ON pengeluaran;
CREATE TRIGGER update_pengeluaran_updated_at
    BEFORE UPDATE ON pengeluaran
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_pemasukan_lain_updated_at ON pemasukan_lain;
CREATE TRIGGER update_pemasukan_lain_updated_at
    BEFORE UPDATE ON pemasukan_lain
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_settings_updated_at ON settings;
CREATE TRIGGER update_settings_updated_at
    BEFORE UPDATE ON settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================
-- Enable RLS untuk semua tabel
ALTER TABLE anggota ENABLE ROW LEVEL SECURITY;
ALTER TABLE pembayaran ENABLE ROW LEVEL SECURITY;
ALTER TABLE pengeluaran ENABLE ROW LEVEL SECURITY;
ALTER TABLE pemasukan_lain ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- SECURITY POLICIES
-- ============================================================================
-- IMPORTANT: Untuk production, implementasi authentication terlebih dahulu!
-- 
-- Opsi 1: PUBLIC ACCESS (Development/Single User)
-- Gunakan ini jika aplikasi hanya untuk 1 user/organisasi tanpa auth
-- 
-- Opsi 2: AUTHENTICATED USERS (Production dengan Auth)
-- Uncomment policies di bawah dan setup Supabase Auth
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- OPSI 1: PUBLIC ACCESS (CURRENT - Development Mode)
-- ────────────────────────────────────────────────────────────────────────────
-- ⚠️ WARNING: Policies ini mengizinkan akses penuh tanpa authentication
-- Hanya gunakan untuk development atau single-user deployment
-- Untuk production dengan multiple users, gunakan OPSI 2

-- Anggota policies
DROP POLICY IF EXISTS "Public access for anggota" ON anggota;
CREATE POLICY "Public access for anggota" ON anggota
    FOR ALL 
    USING (true) 
    WITH CHECK (true);

-- Pembayaran policies
DROP POLICY IF EXISTS "Public access for pembayaran" ON pembayaran;
CREATE POLICY "Public access for pembayaran" ON pembayaran
    FOR ALL 
    USING (true) 
    WITH CHECK (true);

-- Pengeluaran policies
DROP POLICY IF EXISTS "Public access for pengeluaran" ON pengeluaran;
CREATE POLICY "Public access for pengeluaran" ON pengeluaran
    FOR ALL 
    USING (true) 
    WITH CHECK (true);

-- Pemasukan lain policies
DROP POLICY IF EXISTS "Public access for pemasukan_lain" ON pemasukan_lain;
CREATE POLICY "Public access for pemasukan_lain" ON pemasukan_lain
    FOR ALL 
    USING (true) 
    WITH CHECK (true);

-- Settings policies
DROP POLICY IF EXISTS "Public access for settings" ON settings;
CREATE POLICY "Public access for settings" ON settings
    FOR ALL 
    USING (true) 
    WITH CHECK (true);

-- ────────────────────────────────────────────────────────────────────────────
-- OPSI 2: AUTHENTICATED USERS (Production dengan Auth)
-- ────────────────────────────────────────────────────────────────────────────
-- Uncomment policies di bawah untuk production dengan authentication
-- Pastikan sudah setup Supabase Auth dan tambahkan user_id column ke tabel

/*
-- Step 1: Tambahkan user_id column ke semua tabel
ALTER TABLE anggota ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
ALTER TABLE pembayaran ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
ALTER TABLE pengeluaran ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
ALTER TABLE pemasukan_lain ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
ALTER TABLE settings ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- Step 2: Create indexes untuk performance
CREATE INDEX IF NOT EXISTS idx_anggota_user_id ON anggota(user_id);
CREATE INDEX IF NOT EXISTS idx_pembayaran_user_id ON pembayaran(user_id);
CREATE INDEX IF NOT EXISTS idx_pengeluaran_user_id ON pengeluaran(user_id);
CREATE INDEX IF NOT EXISTS idx_pemasukan_lain_user_id ON pemasukan_lain(user_id);
CREATE INDEX IF NOT EXISTS idx_settings_user_id ON settings(user_id);

-- Step 3: Drop public policies
DROP POLICY IF EXISTS "Public access for anggota" ON anggota;
DROP POLICY IF EXISTS "Public access for pembayaran" ON pembayaran;
DROP POLICY IF EXISTS "Public access for pengeluaran" ON pengeluaran;
DROP POLICY IF EXISTS "Public access for pemasukan_lain" ON pemasukan_lain;
DROP POLICY IF EXISTS "Public access for settings" ON settings;

-- Step 4: Create authenticated policies

-- Anggota policies (user can only access their own data)
CREATE POLICY "Users can view their own anggota" ON anggota
    FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own anggota" ON anggota
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own anggota" ON anggota
    FOR UPDATE 
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own anggota" ON anggota
    FOR DELETE 
    USING (auth.uid() = user_id);

-- Pembayaran policies
CREATE POLICY "Users can view their own pembayaran" ON pembayaran
    FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own pembayaran" ON pembayaran
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own pembayaran" ON pembayaran
    FOR UPDATE 
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own pembayaran" ON pembayaran
    FOR DELETE 
    USING (auth.uid() = user_id);

-- Pengeluaran policies
CREATE POLICY "Users can view their own pengeluaran" ON pengeluaran
    FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own pengeluaran" ON pengeluaran
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own pengeluaran" ON pengeluaran
    FOR UPDATE 
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own pengeluaran" ON pengeluaran
    FOR DELETE 
    USING (auth.uid() = user_id);

-- Pemasukan lain policies
CREATE POLICY "Users can view their own pemasukan_lain" ON pemasukan_lain
    FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own pemasukan_lain" ON pemasukan_lain
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own pemasukan_lain" ON pemasukan_lain
    FOR UPDATE 
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own pemasukan_lain" ON pemasukan_lain
    FOR DELETE 
    USING (auth.uid() = user_id);

-- Settings policies
CREATE POLICY "Users can view their own settings" ON settings
    FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own settings" ON settings
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own settings" ON settings
    FOR UPDATE 
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own settings" ON settings
    FOR DELETE 
    USING (auth.uid() = user_id);
*/

-- ============================================================================
-- VIEWS: Helpful views untuk analytics
-- ============================================================================

-- View: Total kas per anggota
CREATE OR REPLACE VIEW v_anggota_summary AS
SELECT 
    a.id,
    a.nama,
    a.nominal_iuran,
    a.frekuensi,
    COALESCE(SUM(p.jumlah), 0) as total_dibayar,
    COUNT(p.id) as jumlah_pembayaran
FROM anggota a
LEFT JOIN pembayaran p ON a.id = p.anggota_id
GROUP BY a.id, a.nama, a.nominal_iuran, a.frekuensi;

-- View: Ringkasan keuangan
CREATE OR REPLACE VIEW v_ringkasan_keuangan AS
SELECT 
    (SELECT COALESCE(SUM(jumlah), 0) FROM pembayaran) as total_pemasukan_iuran,
    (SELECT COALESCE(SUM(nominal), 0) FROM pemasukan_lain) as total_pemasukan_lain,
    (SELECT COALESCE(SUM(nominal), 0) FROM pengeluaran) as total_pengeluaran,
    (SELECT COALESCE(SUM(jumlah), 0) FROM pembayaran) + 
    (SELECT COALESCE(SUM(nominal), 0) FROM pemasukan_lain) - 
    (SELECT COALESCE(SUM(nominal), 0) FROM pengeluaran) as saldo_kas;

-- ============================================================================
-- SAMPLE DATA (Optional - untuk testing)
-- ============================================================================
-- Uncomment untuk insert sample data

-- INSERT INTO anggota (id, nama, nominal_iuran, frekuensi, hari_tagihan) VALUES
-- ('1', 'John Doe', 50000, 'Bulanan', ARRAY['Tanggal 1']),
-- ('2', 'Jane Smith', 50000, 'Bulanan', ARRAY['Tanggal 1']),
-- ('3', 'Bob Johnson', 50000, 'Bulanan', ARRAY['Tanggal 1']);

-- INSERT INTO pembayaran (id, anggota_id, jumlah, tanggal, metode, status) VALUES
-- ('1', '1', 50000, NOW(), 'Tunai', 'Lunas'),
-- ('2', '2', 50000, NOW(), 'Transfer', 'Lunas');

-- INSERT INTO pengeluaran (id, nominal, kategori, keterangan, tanggal) VALUES
-- ('1', 25000, 'Konsumsi', 'Snack rapat', NOW());

-- INSERT INTO pemasukan_lain (id, nominal, kategori, keterangan, tanggal) VALUES
-- ('1', 100000, 'Donasi', 'Donasi dari alumni', NOW());

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- Jalankan query ini untuk verifikasi schema sudah benar

-- Check tables
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Check anggota count
SELECT COUNT(*) as total_anggota FROM anggota;

-- Check ringkasan keuangan
SELECT * FROM v_ringkasan_keuangan;

-- ============================================================================
-- DONE! 🎉
-- ============================================================================
-- Schema berhasil dibuat!
-- 
-- Next steps:
-- 1. Copy Supabase URL dan Anon Key dari Project Settings
-- 2. Tambahkan ke .env file atau config
-- 3. Initialize Supabase di main.dart
-- 4. Test sync data
-- ============================================================================
