# AGENTS.md — Lirih

Panduan padat untuk sesi OpenCode berikutnya. Hanya berisi hal yang **mudah dilewatkan** atau **tidak terlihat dari nama berkas**.

**Lirih** = pemutar musik **offline** (Flutter, Android-first untuk v1). Penerbit: **Sakadabra**. Fitur inti: preset frekuensi **440 / 432 / 528 Hz** (pitch shift). Cari konteks lengkap di `docs/` (lokal, lihat §Git).

---

## Batasan keras — jangan dilanggar

- **`applicationId` `io.github.bidinon07.lirih` TERKUNCI.** Tidak bisa diubah setelah AAB pertama diunggah ke Google Play. MethodChannel DSP: `io.github.bidinon07.lirih/dsp`. Plugin native rencana: package `lirih_audio`.
- **Tanpa jaringan, tanpa akun, tanpa iklan.** v1 murni offline — **jangan tambahkan permission `INTERNET`** atau dependensi runtime yang butuh koneksi. Privacy policy & form Data Safety Play menyatakan "tidak mengumpulkan data"; manifest wajib diverifikasi bebas `INTERNET` sebelum rilis.
- **432/528 Hz murni pengaturan pemutaran (pitch).** Dilarang menulis klaim kesehatan/medis/terapi di kode, aset, maupun listing Play. Risiko kebijakan Play.
- **Identitas harus orisinal:** BUKAN `#121212`+hijau ala Spotify, BUKAN font Circular, tidak menyebut merek pemutar musik lain di aset/listing/keyword. Pakai palet Gamelan (`AppColors`: soga/kunir/nila) + **Plus Jakarta Sans**.

## Toolchain (terkunci — jangan naikkan sembarangan)

Flutter **3.47.6 stable** / Dart 3.13.5 · AGP **9.1.0** · Kotlin **2.4.0** · Gradle **9.3.1** · Java/JVM target **17** · compileSdk **36** · targetSdk **36** · minSdk **24**.

- **`kotlin.incremental=false`** di `android/gradle.properties` **sengaja** — cache incremental Kotlin 2.4 gagal lintas-drive di Windows (pub cache di `C:\`, build dir di `E:\`). Jangan "perbaiki".
- **Blok patch AGP 9 di `android/build.gradle.kts`** (`subprojects { afterEvaluate ... }`) menambal plugin lawas `on_audio_query_android` (namespace dari `group`, Java 17, compileSdk 36). Hapus = build gagal.
- **`permission_handler` dipin `^12.0.3`** dengan sengaja — 13.0.x menarik `compileSdk 37` yang tidak didukung AGP 9.1.0 (maks 36). Lihat catatan di `pubspec.yaml`. Naikkan hanya setelah Flutter pakai AGP ≥ 9.2.
- **`on_audio_query_android` tak terawat** (per 2023, masih KGP lama). Harus diganti saat Flutter mencabut dukungan KGP.

## Perintah utama

```bash
flutter pub get

# Gate CI — urutan ini wajib: format → analyze → test
dart format .                                          # perbaiki format
dart format --output=none --set-exit-if-changed .     # cek (ini yang jalan di CI)
flutter analyze                      # WAJIB 0 issue. Sengaja TANPA --fatal-infos.
flutter test                         # atau: flutter test --coverage
flutter test test/widget_test.dart   # satu berkas tes

flutter build appbundle --release    # Play HANYA menerima .aab (bukan .apk)

# Codegen (freezed / riverpod_annotation / hive_ce_generator) — belum ada outputnya;
# jalankan setelah model pertama dibuat:
dart run build_runner build --delete-conflicting-outputs

# Regenerasi ikon launcher + aset branding (Windows/PowerShell):
pwsh ./ignore/tools/generate_lirih_branding.ps1
```

## Struktur & arsitektur

Clean architecture di `lib/`: `core/` · `data/` · `domain/` · `features/` · `shared/`. `app.dart` sengaja dipisah dari `main.dart`.

- Entrypoint: `lib/main.dart` → `ProviderScope` → `LirihApp` (`lib/app.dart`).
- Kini hanya ada: placeholder home (logo + wordmark), token desain (`lib/core/constants/app_colors.dart`, `app_typography.dart`), dan widget brand (`lib/shared/widgets/`).
- Model domain rencana (TDD §3): `TrackSource` (sealed), `Track`, `FrequencyPreset`. Matematika pitch: `ratio = target / 440`.
- Box Hive rencana (TDD §7): `queueBox`, `recentsBox`, `searchHistoryBox`, `playlistsBox`, `lyricsBox`.
- Tidak ada layer network — sengaja dihapus dari rancangan karena v1 offline (TDD §6 adalah konten Versi B yang **tidak akan pernah dibangun** di repo ini).

## Konvensi kode (berbeda dari default)

Linter: `very_good_analysis` 11.0.0 (sangat ketat) + tambahan proyek di `analysis_options.yaml`.

- **`sort_pub_dependencies`** — dependensi di `pubspec.yaml` **wajib urut alfabet**.
- `prefer_single_quotes`, `directives_ordering` aktif.
- **Maksimum 80 karakter per baris** (`lines_longer_than_80`).
- **Semua member publik di `lib/` wajib berdokumentasi** (`public_member_api_docs`) — tulis doc comment `[...]`.
- `unnecessary_type_name_in_constructor` **sengaja dimatikan** (template Flutter 3.47 masih pakai konstruktor berNama). Aktifkan kembali hanya setelah Flutter mengadopsi sintaks `new`.
- `avoid_print` — jangan pakai `print`.
- **Bahasa dokumen/doc comment memakai Bahasa Indonesia** — ikuti gaya berkas di sekitar.
- File generated (`*.g.dart`, `*.freezed.dart`, `*.mocks.dart`) dikecualikan dari analyzer.

## Sinkronisasi lintas-berkas (mudah pecah)

- **Geometri logo ada di dua tempat** — konstanta di `lib/shared/widgets/lirih_logo.dart` **harus identik** dengan `ignore/tools/generate_lirih_branding.ps1` (yang menghasilkan ikon launcher). Ubah satu tanpa yang lain → logo dalam app ≠ ikon launcher.
- **Token warna juga duplikat** — hex di `app_colors.dart` vs di script branding tersebut. Jaga sinkron.
- **Wordmark = widget `LirihWordmark`** ("LIRIH" kapital, Plus Jakarta Sans Bold, `letterSpacing = 0.22 × fontSize`) — **bukan** `AppTypography.display`.

## Git & rahasia

- Branch `main`; remote bernama `lirih`.
- **`docs/` dan `ignore/` di-gitignore** — dokumentasi perencanaan internal, **sengaja tidak diterbitkan** (README menyatakannya). Jangan pernah commit. Ini tetap sumber kebenaran lokal untuk roadmap & desain.
- **Material tanda tangan tidak boleh masuk repo:** `key.properties`, `*.jks`, `*.keystore`, `*.p12`, `*.pem`, `service-account*.json`. Job CI `signing-guard` akan **gagalkan build** jika ter-track.
- AAB untuk Play dibuat **lokal** dengan keystore di luar repo; artefak job CI `build` **unsigned** dan hanya untuk verifikasi.

## Rujukan

- `docs/MelodicDSP-v1-Checklist.md` — checklist harian; centang `[x]` setiap task selesai. Nomor task menyilang ke roadmap.
- `docs/MelodicDSP-Roadmap-v1-Offline.md` — sumber kebenaran *apa & mengapa*.
- `docs/MelodicDSP-Technical-Design-Doc.md` — desain arsitektur. ⚠️ Bagian §6 (backend API) adalah Versi B yang tidak dibangun di repo ini, dan nama plugin masih ditulis `melodic_audio` (kini `lirih_audio`) — **percayai checklist/README** bila berbenturan.
- Root: `README.md`, `PRIVACY-POLICY.md`, `THIRD_PARTY_NOTICES.md` (semua diterbitkan).
- CI: `.github/workflows/ci.yml` — 3 job: `quality` (format+analyze+test, tiap push/PR ke main), `signing-guard`, `build` appbundle (hanya `workflow_dispatch` manual).
