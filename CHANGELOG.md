# Changelog

All notable changes to KasCahh will be documented in this file.

## [1.1.0] - 2026-05-10

### 🔒 Security
- **CRITICAL**: Fixed Row Level Security (RLS) policies in Supabase
- **CRITICAL**: Rotated exposed API keys and removed from repository
- Added comprehensive security documentation
- Implemented proper `.env` file handling with `.gitignore`

### 📚 Documentation
- Added `SECURITY_GUIDE.md` - Complete security setup and best practices
- Added `SUPABASE_ROTATION_STEPS.md` - Step-by-step API key rotation guide
- Added `SECURITY_FIXES_SUMMARY.md` - Summary of all security fixes
- Added `QUICK_START_SECURITY.md` - 5-minute quick setup guide
- Updated `README.md` with security notices and setup instructions
- Updated `supabase_schema.sql` with comprehensive RLS documentation

### 🛡️ Database
- Updated Supabase schema with two RLS policy options:
  - **OPSI 1**: Public Access (Development Mode) - Currently active
  - **OPSI 2**: Authenticated Users (Production Mode) - Ready to deploy
- Added migration guide for production deployment
- Improved database documentation and comments

### ✅ Verified
- Supabase connection working correctly
- Data sync functioning properly
- App tested on Android device (Infinix X6833B)
- All security fixes committed and pushed to GitHub

### 📦 Build
- Updated version from 1.0.0+1 to 1.1.0+2
- Built release APK (53.2MB)
- APK available: `KasCahh-v1.1.0.apk`

---

## [1.0.0] - 2026-01-01

### 🎉 Initial Release
- Basic cash management features
- Member management (anggota)
- Payment tracking (pembayaran)
- Expense tracking (pengeluaran)
- Other income tracking (pemasukan lain)
- Settings and configuration
- Local data storage with SharedPreferences
- Supabase integration for cloud sync
- Export to CSV functionality
- Share reports feature
- Notification system
- Material Design 3 UI

### Features
- ✅ Add/Edit/Delete members
- ✅ Record payments with multiple methods (Cash, Transfer, E-Wallet)
- ✅ Track expenses by category
- ✅ Track other income sources
- ✅ Financial summary dashboard
- ✅ Monthly/Weekly/Daily reports
- ✅ Auto-sync to Supabase
- ✅ Offline-first architecture
- ✅ Profile photos for members
- ✅ Customizable settings
- ✅ Notification reminders

---

## Release Notes

### How to Install
1. Download `KasCahh-v1.1.0.apk`
2. Enable "Install from Unknown Sources" on your Android device
3. Install the APK
4. Follow the security setup guide in `QUICK_START_SECURITY.md`

### Security Setup Required
⚠️ **IMPORTANT**: Before using the app, you must configure your Supabase credentials:
1. Copy `.env.example` to `.env`
2. Add your Supabase URL and Anon Key
3. See `SECURITY_GUIDE.md` for detailed instructions

### System Requirements
- Android 5.0 (API 21) or higher
- ~60MB storage space
- Internet connection for cloud sync (optional)

### Known Issues
- None reported

### Upcoming Features
- [ ] Multi-user authentication
- [ ] Advanced reporting with charts
- [ ] Backup/Restore functionality
- [ ] Dark mode
- [ ] Multiple language support

---

For more information, visit: https://github.com/alasama351/KasCahh
