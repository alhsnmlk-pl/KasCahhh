# 🚀 Quick Start - Security Setup

## ⚡ 5-Minute Setup Guide

### Step 1: Get Supabase Credentials (2 min)

1. Go to: https://app.supabase.com
2. Login → Select your project
3. Settings → API
4. Copy:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGci...`

### Step 2: Configure Local Environment (1 min)

```bash
# Copy template
cp .env.example .env

# Edit .env (use your favorite editor)
nano .env
```

Paste your credentials:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Step 3: Run the App (2 min)

```bash
# Install dependencies
flutter pub get

# Run app
flutter run
```

### Step 4: Verify (30 sec)

Check console for:
- ✅ `Supabase initialized successfully` → You're good!
- ❌ `Error initializing Supabase` → Check credentials

---

## 🔒 Security Checklist

- [ ] `.env` file created with your credentials
- [ ] App runs without Supabase errors
- [ ] `.env` is NOT in `git status` (should be ignored)
- [ ] Never commit `.env` to Git
- [ ] Read `SECURITY_GUIDE.md` when you have time

---

## 🆘 Troubleshooting

### Error: "Supabase not initialized"
→ Check `.env` file exists and has correct credentials

### Error: "Invalid API key"
→ Copy fresh keys from Supabase Dashboard

### `.env` appears in git status
→ Run: `git rm --cached .env` then commit

---

## 📚 Full Documentation

- 📖 **Complete Guide**: `SECURITY_GUIDE.md`
- 🔄 **Rotation Steps**: `SUPABASE_ROTATION_STEPS.md`
- 📋 **Summary**: `SECURITY_FIXES_SUMMARY.md`

---

**Need Help?** Email: alasama351@gmail.com
