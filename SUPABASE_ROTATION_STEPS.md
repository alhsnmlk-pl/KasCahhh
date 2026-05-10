# 🔄 Supabase API Keys Rotation - Step by Step

## ⚠️ URGENT: API Keys Exposed - Rotation Required

API keys Supabase ter-commit ke repository dan perlu di-rotate **SEGERA**.

---

## 📋 Rotation Checklist

### ✅ Step 1: Rotate API Keys di Supabase Dashboard

1. **Login ke Supabase**
   - Buka: https://app.supabase.com
   - Login dengan akun Anda

2. **Pilih Project**
   - Klik project "KasCahh" atau project yang digunakan

3. **Navigate to API Settings**
   - Sidebar → **Settings** (⚙️)
   - Pilih **API**

4. **Reset API Keys**
   
   **Option A: Reset Anon Key (Recommended)**
   - Scroll ke section "Project API keys"
   - Cari "anon public" key
   - Klik **"Reset"** atau **"Regenerate"**
   - Confirm action
   - **Copy new key** (akan hilang setelah page refresh!)
   
   **Option B: Create New Project (Nuclear Option)**
   - Jika khawatir data sudah diakses
   - Create new Supabase project
   - Migrate data dari project lama
   - Delete project lama

5. **Save New Credentials**
   ```
   New Project URL: https://xxxxx.supabase.co
   New Anon Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

---

### ✅ Step 2: Update Local Environment

1. **Update .env file**
   ```bash
   # Edit file .env
   nano .env  # atau gunakan text editor favorit
   ```

2. **Paste new credentials**
   ```env
   SUPABASE_URL=https://your-new-project.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your-new-key...
   ```

3. **Verify file tidak ter-commit**
   ```bash
   git status
   # .env TIDAK boleh muncul di list
   ```

---

### ✅ Step 3: Test New Configuration

1. **Clean build**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Run app**
   ```bash
   flutter run
   ```

3. **Check console output**
   - ✅ `Supabase initialized successfully` → Berhasil!
   - ❌ `Error initializing Supabase` → Periksa credentials

4. **Test sync functionality**
   - Tambah anggota baru
   - Cek di Supabase Dashboard → Table Editor
   - Data harus muncul di database

---

### ✅ Step 4: Revoke Old Keys (Important!)

1. **Kembali ke Supabase Dashboard**
   - Settings → API

2. **Verify old keys tidak bisa digunakan**
   - Old keys otomatis invalid setelah reset
   - Jika masih bisa, ulangi Step 1

3. **Check API logs**
   - Dashboard → Logs → API Logs
   - Cari suspicious activity dengan old keys
   - Note: IP addresses, timestamps, endpoints accessed

---

### ✅ Step 5: Update Team Members

Jika ada team members lain:

1. **Notify via secure channel** (bukan public chat!)
   ```
   Subject: [URGENT] Supabase API Keys Rotated
   
   Hi team,
   
   API keys telah di-rotate karena security issue.
   Silakan update .env file dengan credentials baru:
   
   1. Pull latest code
   2. Copy .env.example ke .env
   3. Minta credentials baru ke [your-name]
   4. Test aplikasi
   
   Jangan share credentials via email/chat!
   ```

2. **Share new credentials securely**
   - Gunakan password manager (1Password, LastPass)
   - Atau share via encrypted message
   - JANGAN via email/Slack/WhatsApp plain text!

---

### ✅ Step 6: Update CI/CD (If Applicable)

Jika menggunakan CI/CD (GitHub Actions, etc):

1. **Update secrets**
   - GitHub: Settings → Secrets → Actions
   - Update `SUPABASE_URL` dan `SUPABASE_ANON_KEY`

2. **Re-run failed builds**
   - Builds yang gagal karena old keys
   - Trigger manual re-run

---

### ✅ Step 7: Security Audit

1. **Check Supabase logs**
   - Dashboard → Logs
   - Filter by date range (saat keys exposed)
   - Look for:
     - Unusual IP addresses
     - High request volume
     - Unauthorized data access
     - Failed authentication attempts

2. **Check data integrity**
   - Table Editor → Review all tables
   - Look for:
     - Unexpected data modifications
     - Deleted records
     - New unauthorized records

3. **Document findings**
   ```
   Date: [date]
   Exposed duration: [start] to [end]
   Suspicious activity: [yes/no]
   Data breach: [yes/no]
   Actions taken: [list]
   ```

---

### ✅ Step 8: Prevent Future Exposure

1. **Verify .gitignore**
   ```bash
   cat .gitignore | grep .env
   # Should show: .env
   ```

2. **Remove .env from Git history** (if committed)
   ```bash
   # WARNING: This rewrites Git history!
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch .env" \
     --prune-empty --tag-name-filter cat -- --all
   
   # Force push (coordinate with team!)
   git push origin --force --all
   ```

3. **Setup pre-commit hooks**
   ```bash
   # Install pre-commit
   pip install pre-commit
   
   # Create .pre-commit-config.yaml
   cat > .pre-commit-config.yaml << EOF
   repos:
     - repo: https://github.com/pre-commit/pre-commit-hooks
       rev: v4.4.0
       hooks:
         - id: check-added-large-files
         - id: detect-private-key
         - id: check-yaml
         - id: end-of-file-fixer
         - id: trailing-whitespace
   EOF
   
   # Install hooks
   pre-commit install
   ```

4. **Enable GitHub secret scanning**
   - Repository → Settings → Security
   - Enable "Secret scanning"
   - Enable "Push protection"

---

## 🚨 Emergency Contacts

Jika menemukan data breach atau suspicious activity:

1. **Immediately**:
   - Disable Supabase project (Settings → General → Pause project)
   - Notify team lead
   - Document everything

2. **Contact**:
   - Email: alasama351@gmail.com
   - Subject: [SECURITY] Data Breach - KasCahh

3. **Include**:
   - Timeline of exposure
   - Suspicious activity logs
   - Data affected
   - Actions taken

---

## ✅ Verification Checklist

Before marking as complete:

- [ ] New API keys generated di Supabase
- [ ] `.env` file updated dengan new keys
- [ ] App tested dan bisa connect ke Supabase
- [ ] Old keys confirmed invalid
- [ ] Team members notified (if applicable)
- [ ] CI/CD secrets updated (if applicable)
- [ ] Supabase logs checked untuk suspicious activity
- [ ] Data integrity verified
- [ ] `.env` confirmed in `.gitignore`
- [ ] Git history cleaned (if .env was committed)
- [ ] Pre-commit hooks installed
- [ ] GitHub secret scanning enabled
- [ ] Documentation updated

---

## 📚 References

- [Supabase Security Best Practices](https://supabase.com/docs/guides/platform/going-into-prod)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)
- [OWASP API Security](https://owasp.org/www-project-api-security/)

---

**Status**: 🔴 **PENDING ROTATION**  
**Priority**: 🚨 **CRITICAL**  
**Deadline**: **ASAP**

---

**Last Updated**: 2026-05-10  
**Created By**: Kiro AI Assistant  
**Version**: 1.0.0
