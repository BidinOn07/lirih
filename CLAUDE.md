# AGENTS.md — Flutter: Rilis Play Store & Keamanan Repositori GitHub

Dokumen ini adalah panduan untuk agent (OpenCode) saat mengerjakan project Flutter ini, khususnya menjelang rilis ke Google Play Store dan saat mengelola repositori GitHub.

Persyaratan Google Play (target API, closed testing, dll.) sering berubah. Jika ragu, minta pengguna memverifikasi di Play Console atau dokumentasi resmi sebelum mengambil keputusan.

---

## 0. Aturan Perilaku Agent (WAJIB)

1. **Jangan pernah** membaca isi, mencetak, atau meng-commit file rahasia: `key.properties`, `*.jks`, `*.keystore`, `.env*`, service account JSON, token, password.
2. **Jangan** menjalankan perintah destruktif tanpa konfirmasi eksplisit pengguna: `git push --force`, `git reset --hard`, `git filter-repo`, `git clean -fd`, menghapus branch/tag, mengubah riwayat Git.
3. **Jangan** melakukan `git push`, membuat tag, atau membuat GitHub Release tanpa diminta.
4. Sebelum setiap commit, jalankan `git status` dan `git diff --staged`, lalu pastikan tidak ada secret yang ikut masuk.
5. Jika menemukan secret yang sudah ter-commit, **hentikan**, laporkan ke pengguna, dan sarankan: cabut/rotasi secret dulu, baru bersihkan riwayat Git.
6. Jangan menaikkan `versionCode`/`versionName`, mengganti `applicationId`, atau mengubah signing config tanpa persetujuan pengguna. `applicationId` tidak bisa diganti setelah publish.
7. Lakukan perubahan kecil dan terfokus. Jelaskan apa yang diubah dan alasannya.
8. Jangan menambahkan dependency baru tanpa alasan jelas dan tanpa memeriksa lisensinya.

---

## 1. Checklist Sebelum Rilis ke Play Store

### 1.1 Persyaratan Play Store
- [ ] `targetSdk` dan `compileSdk` memenuhi syarat terbaru Google Play (per Agustus 2026: app baru dan update harus menargetkan Android 16 / API 36 atau lebih tinggi). Cek `android/app/build.gradle(.kts)` dan konfirmasi di detail bundle Play Console.
- [ ] Build memakai **AAB**, bukan APK: `flutter build appbundle --release`
- [ ] **Play App Signing** aktif. Upload keystore aman dan ter-backup di luar repo.
- [ ] Jika akun developer **personal** dibuat setelah 13 Nov 2023: **closed testing** dengan minimal 12 tester opt-in selama 14 hari berturut-turut sebelum bisa mengajukan akses production (tester internal testing tidak dihitung). Mulai sedini mungkin.

### 1.2 Konfigurasi Release Build
- [ ] `applicationId` sudah final.
- [ ] `version` di `pubspec.yaml` benar (`x.y.z+N`). `versionCode` (`N`) harus naik di setiap upload.
- [ ] Nama app, ikon launcher, dan splash screen sudah benar.
- [ ] Release build memakai **signing config release**, bukan debug key.
- [ ] Jika R8/ProGuard (minify) aktif: test release build menyeluruh dan siapkan keep rules untuk library yang memakai reflection.
- [ ] Permission di `AndroidManifest.xml` hanya yang diperlukan. Periksa permission yang ikut masuk dari plugin (manifest merge).
- [ ] Permission sensitif (lokasi background, SMS, kontak, dll.) punya justifikasi untuk Play Console.
- [ ] URL API mengarah ke **production**. Tidak ada localhost/staging, log debug, atau API key hardcoded.
- [ ] `usesCleartextTraffic` tidak aktif kecuali benar-benar perlu.
- [ ] Jika memakai `--obfuscate --split-debug-info`: simpan symbol file untuk membaca stack trace.

### 1.3 Testing Fungsional
- [ ] `flutter analyze` bersih (tanpa error/warning penting).
- [ ] `flutter test` lulus (unit + widget test).
- [ ] `integration_test` untuk alur kritis: login/register, onboarding, pembayaran (jika ada), logout.
- [ ] Jalankan di **release mode**: `flutter run --release` atau install AAB lewat internal testing.
- [ ] Skenario jaringan: offline, lambat, timeout, putus di tengah request.
- [ ] Lifecycle: rotasi layar, app di-background lalu dibuka, proses dimatikan sistem, permission ditolak user.
- [ ] Deep link, push notification, in-app purchase (jika dipakai) diuji pada build yang diinstal dari Play (internal testing).
- [ ] **Google Sign-In / Firebase**: SHA-1 dan SHA-256 dari **Play App Signing key** (bukan hanya upload key) sudah ditambahkan di Firebase/Google Cloud. Ini penyebab umum login gagal hanya di versi Play Store.

### 1.4 Kompatibilitas Perangkat
- [ ] Diuji di beberapa ukuran layar dan versi Android (versi minimum yang didukung dan Android terbaru).
- [ ] Diuji di perangkat fisik kelas bawah (RAM kecil).
- [ ] Font size besar, dark mode, dan bahasa lain (jika didukung) tidak merusak layout.
- [ ] Perilaku **predictive back** dan **edge-to-edge** aman pada target API baru, termasuk plugin lama.
- [ ] Pertimbangkan Firebase Test Lab dan Pre-launch report di Play Console.

### 1.5 Performa & Kualitas
- [ ] Profiling di **profile mode** dengan Flutter DevTools: jank, rebuild berlebihan, memory leak.
- [ ] Cek ukuran app: `flutter build appbundle --analyze-size`. Periksa aset gambar yang terlalu besar.
- [ ] Waktu startup, penggunaan baterai, dan data wajar.
- [ ] `flutter pub outdated` diperiksa untuk dependency usang atau rentan.
- [ ] Crash reporting (Crashlytics/Sentry) terpasang dan terbukti menerima laporan dari build release.

### 1.6 Keamanan Aplikasi & Privasi
- [ ] Token/data sensitif disimpan di `flutter_secure_storage`, bukan `SharedPreferences` biasa.
- [ ] Semua komunikasi memakai HTTPS (pertimbangkan certificate pinning untuk app sensitif).
- [ ] Tidak ada secret/API key privat di dalam kode app.
- [ ] Validasi dan otorisasi dilakukan di sisi server, bukan hanya di app.

### 1.7 Kelengkapan Play Console
- [ ] Store listing: deskripsi, screenshot, feature graphic, ikon 512x512.
- [ ] **URL privacy policy** bisa diakses publik.
- [ ] **Data Safety form** sesuai dengan data yang benar-benar dikumpulkan app dan SDK pihak ketiga (Firebase, AdMob, analytics, dll.).
- [ ] Content rating, target audience, deklarasi Ads, App access (sediakan akun demo jika app butuh login).
- [ ] Negara/region distribusi dan deklarasi tambahan (kesehatan, finansial, dll.) jika relevan.

### 1.8 Strategi Rilis
1. Internal testing (tim kecil)
2. Closed testing (wajib bagi akun personal baru)
3. Production dengan **staged rollout** (mis. 10% → 50% → 100%)
4. Pantau Crashlytics dan Android vitals di hari-hari pertama; siapkan rencana rollback.

---

## 2. Checklist Keamanan & Keberlanjutan Repositori GitHub

### 2.1 Jangan Commit Rahasia
`.gitignore` harus mencakup minimal:

```gitignore
# Secrets & signing
android/key.properties
*.jks
*.keystore
.env
.env.*
android/local.properties
*service-account*.json

# Flutter / Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
build/
.packages
```

- [ ] `.gitignore` sudah mencakup semua di atas.
- [ ] `google-services.json` / `GoogleService-Info.plist` dianggap semi-sensitif. Jika repo publik, batasi API key di Google Cloud Console (restrict by package name + SHA-1).
- [ ] Pertimbangkan pre-commit hook dengan **gitleaks** untuk menangkap secret sebelum commit.
- [ ] Verifikasi riwayat tidak berisi secret: `git log --all -p -S "password"` atau scan dengan gitleaks.

### 2.2 Jika Secret Sudah Terlanjur Ter-commit
Menghapus file di commit berikutnya **tidak cukup**, karena riwayat Git masih menyimpannya.

1. Anggap secret sudah bocor: **cabut dan buat yang baru** (API key, token, password DB).
2. Bersihkan riwayat dengan `git filter-repo` atau BFG Repo-Cleaner, lalu force push (**hanya atas konfirmasi pengguna**).
3. Beri tahu kolaborator agar clone ulang.
4. Untuk upload keystore yang bocor: ajukan reset upload key lewat Play Console (karena memakai Play App Signing).

### 2.3 Fitur Keamanan GitHub (Settings → Code security)
- [ ] **Secret scanning + Push protection** aktif.
- [ ] **Dependabot alerts** dan **security updates** aktif.
- [ ] `.github/dependabot.yml` memuat ecosystem `pub` (dan `github-actions`).
- [ ] **CodeQL** aktif jika ada kode native/backend.
- [ ] Catatan: ketersediaan fitur untuk repo private bergantung pada paket akun.

### 2.4 Keamanan Akun & Akses
- [ ] **2FA** aktif (passkey/authenticator, bukan SMS). Recovery codes tersimpan aman.
- [ ] Personal access token memakai **fine-grained**, masa berlaku pendek, izin minimal.
- [ ] Tinjau berkala: SSH keys, authorized OAuth apps, deploy keys. Hapus yang tidak dipakai.
- [ ] Kolaborator diberi akses minimum (Read/Triage/Write), bukan semuanya Admin.

### 2.5 Proteksi Branch `main`
- [ ] Wajib Pull Request (meski dikerjakan sendiri).
- [ ] Wajib status check lulus (`flutter analyze`, `flutter test`) sebelum merge.
- [ ] Larang force push dan penghapusan branch.
- [ ] Jika tim: minimal 1 review, `CODEOWNERS` untuk `android/` dan `.github/workflows/`.
- [ ] Opsional: signed commits.

### 2.6 GitHub Actions (jika dipakai)
- [ ] Secret disimpan di Settings → Secrets and variables → Actions, bukan di file workflow. Keystore sebagai secret base64 yang di-decode saat build.
- [ ] `permissions:` di workflow seminimal mungkin (mis. `contents: read`).
- [ ] Action pihak ketiga di-pin ke versi/commit SHA, bukan `@main`.
- [ ] Waspada `pull_request_target` dan PR dari fork (risiko kebocoran secret).
- [ ] Deploy production memakai **Environments** dengan approval manual.

### 2.7 Visibilitas Repo
- [ ] Project komersial/berisi logika bisnis: pertimbangkan repo **private**.
- [ ] Jika publik: tidak ada URL internal, data pengguna, atau komentar sensitif di riwayat commit.

---

## 3. Keberlanjutan & Pengembangan Versi Baru

### 3.1 Versioning
- Gunakan **Semantic Versioning**: `MAJOR.MINOR.PATCH`.
- `pubspec.yaml`: `version: 1.2.0+15` (angka setelah `+` = `versionCode`, harus naik setiap upload).
- Setiap rilis ditandai **Git tag** (`v1.2.0`) dan **GitHub Release**.

### 3.2 Branching
| Branch | Fungsi |
|---|---|
| `main` | Selalu stabil dan siap rilis |
| `feature/<nama>` | Fitur baru |
| `fix/<nama>` / `hotfix/<nama>` | Perbaikan bug / perbaikan cepat |
| `release/x.y.z` (opsional) | Menstabilkan rilis sambil pengembangan lain berjalan |

Hotfix dibuat dari tag rilis terakhir bila perlu.

### 3.3 Dokumentasi
- [ ] `README.md`: setup, build, cara menjalankan.
- [ ] `CHANGELOG.md` (format Keep a Changelog). Bisa jadi bahan "What's new" di Play Store.
- [ ] `CONTRIBUTING.md` dan `SECURITY.md` jika repo publik atau ada kontributor.
- [ ] Dokumentasikan konfigurasi environment, lokasi penyimpanan rahasia, dan prosedur rilis.

### 3.4 Lisensi
- [ ] Repo publik punya file lisensi (MIT/Apache-2.0, atau tetap proprietary / all rights reserved).
- [ ] Lisensi dependency kompatibel dengan tujuan komersial.

### 3.5 Dependency & Toolchain
- [ ] `pubspec.lock` **di-commit** (untuk aplikasi) agar build reprodusibel.
- [ ] Versi Flutter dikunci (mis. **FVM** dengan `.fvmrc`, atau dicatat di README).
- [ ] Update dependency berkala dalam PR kecil, termasuk persiapan kenaikan target API tahunan Play Store.

### 3.6 CI Minimal (setiap PR)
```
flutter pub get
flutter analyze
flutter test
flutter build appbundle   # opsional
```

### 3.7 Backup & Risiko "Bus Factor"
- [ ] Upload keystore + password di-backup di tempat terpisah dan aman (password manager/brankas terenkripsi), **bukan di repo**.
- [ ] Akses Play Console, Firebase, domain, dan GitHub tidak bergantung pada satu orang/email. Pertimbangkan GitHub Organization.
- [ ] Ada mirror/clone cadangan di luar GitHub.

---

## 4. Contoh Workflow GitHub Actions (CI Dasar)

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

Sesuaikan versi action dan pin ke versi/SHA yang sudah diverifikasi sebelum dipakai.

---

## 5. Prioritas Jika Waktu Terbatas

1. `.gitignore` benar dan tidak ada secret di riwayat commit
2. 2FA aktif + secret scanning/push protection
3. Branch protection di `main`
4. Tag + SemVer + CHANGELOG
5. Backup keystore di luar repo
6. Dependabot dan CI dasar

---

## 6. Perintah Berguna

```bash
# Build rilis
flutter build appbundle --release
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols

# Kualitas
flutter analyze
flutter test
flutter pub outdated
flutter build appbundle --analyze-size

# Cek sebelum commit
git status
git diff --staged

# Rilis (hanya atas permintaan pengguna)
git tag -a v1.2.0 -m "Release 1.2.0"
git push origin v1.2.0
```
