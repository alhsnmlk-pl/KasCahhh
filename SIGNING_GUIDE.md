# 🔐 Panduan Signing APK untuk Production

## Mengapa Perlu Signing?

Untuk publish ke Google Play Store atau distribusi production, APK harus di-sign dengan keystore yang valid. Saat ini aplikasi masih menggunakan debug signing yang tidak aman untuk production.

## Langkah-langkah Setup Signing

### 1. Generate Keystore

Buka terminal dan jalankan perintah berikut:

```bash
keytool -genkey -v -keystore ~/kascahh-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias kascahh
```

**Penjelasan:**
- `-keystore ~/kascahh-release-key.jks` → Lokasi file keystore
- `-keyalg RSA -keysize 2048` → Algoritma enkripsi
- `-validity 10000` → Valid selama ~27 tahun
- `-alias kascahh` → Nama alias untuk key

**Anda akan diminta mengisi:**
- Password keystore (minimal 6 karakter)
- Password key (bisa sama dengan password keystore)
- Nama, organisasi, kota, negara, dll.

**⚠️ PENTING:** Simpan password dan file `.jks` dengan aman! Jika hilang, Anda tidak bisa update aplikasi di Play Store.

### 2. Buat File keystore.properties

Copy file `keystore.properties.example` menjadi `keystore.properties`:

```bash
cp android/keystore.properties.example android/keystore.properties
```

Edit file `android/keystore.properties` dan isi dengan data Anda:

```properties
storePassword=password_keystore_anda
keyPassword=password_key_anda
keyAlias=kascahh
storeFile=C:/Users/YourName/kascahh-release-key.jks
```

**⚠️ PENTING:** Jangan commit file `keystore.properties` ke Git! File ini sudah ada di `.gitignore`.

### 3. Update build.gradle.kts

Edit file `android/app/build.gradle.kts` dan tambahkan konfigurasi signing:

```kotlin
// Di bagian atas file, setelah plugins
def keystorePropertiesFile = rootProject.file("keystore.properties")
def keystoreProperties = new Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... konfigurasi lainnya ...

    // Tambahkan signingConfigs sebelum buildTypes
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            // Ganti baris ini:
            // signingConfig = signingConfigs.getByName("debug")
            
            // Dengan:
            signingConfig = signingConfigs.getByName("release")
            
            // Optional: Enable minification & obfuscation
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 4. Build Signed APK

Setelah setup selesai, build APK production:

```bash
# Build APK
flutter build apk --release

# Atau build App Bundle (untuk Play Store)
flutter build appbundle --release
```

File output:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### 5. Verifikasi Signing

Cek apakah APK sudah ter-sign dengan benar:

```bash
# Windows (dengan Java JDK installed)
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# Atau gunakan apksigner (Android SDK)
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

Output harus menunjukkan:
- ✅ `jar verified.`
- ✅ Certificate fingerprint (SHA-256)

## 📦 Upload ke Play Store

1. Buat akun Google Play Console
2. Bayar one-time fee $25
3. Buat aplikasi baru
4. Upload file `.aab` (App Bundle)
5. Isi store listing, screenshots, dll.
6. Submit untuk review

## 🔒 Keamanan Keystore

**DO:**
- ✅ Simpan file `.jks` di tempat aman (cloud backup)
- ✅ Gunakan password yang kuat
- ✅ Backup keystore di multiple locations
- ✅ Tambahkan `keystore.properties` ke `.gitignore`

**DON'T:**
- ❌ Commit keystore ke Git/GitHub
- ❌ Share keystore dengan orang lain
- ❌ Gunakan password yang mudah ditebak
- ❌ Simpan password di plain text di repository

## 🆘 Troubleshooting

### Error: "keystore.properties not found"
- Pastikan file `keystore.properties` ada di folder `android/`
- Cek path file keystore sudah benar

### Error: "Keystore was tampered with, or password was incorrect"
- Password salah, coba lagi
- File keystore corrupt, restore dari backup

### Error: "Failed to read key from keystore"
- Key alias salah
- Password key salah

## 📚 Referensi

- [Flutter: Build and release Android app](https://docs.flutter.dev/deployment/android)
- [Android: Sign your app](https://developer.android.com/studio/publish/app-signing)
- [Google Play Console](https://play.google.com/console)

---

**Catatan:** Panduan ini untuk production release. Untuk development, tetap gunakan debug signing yang sudah otomatis.
