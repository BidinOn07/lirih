# Third-Party Notices — Lirih

> **Task:** mitigasi **R9** (`MelodicDSP-Compliance-Roadmap-v3.md`) — kewajiban atribusi lisensi.
> **Tanggal verifikasi:** 6 Oktober 2026
> **Metode:** lisensi dibaca langsung dari berkas `LICENSE` di repositori masing-masing, lalu **di-silang cek** dengan tag `license:*` pada API `pub.dev`.
> Nama aplikasi: **Lirih** — task 0N.4 selesai (6 Okt 2026).

Aplikasi ini dibangun dengan perangkat lunak sumber terbuka berikut. Salinan penuh teks lisensi tersedia di tautan masing-masing, dan dapat ditampilkan dari dalam aplikasi melalui layar **Tentang / Lisensi** (lihat bagian 6).

---

## 1. Dependensi runtime — ikut terkompilasi ke dalam aplikasi

| Paket | Lisensi | OSI | Sumber |
|---|---|---|---|
| `lirih_audio` *(plugin buatan sendiri)* | MIT | ✅ | repositori ini — nama dikunci task 0N.4 (6 Okt 2026); kodenya dibuat pada task 0.6/0.8 |
| `flutter_riverpod` 3.4.3 | **MIT** | ✅ | github.com/rrousselGit/riverpod |
| `riverpod_annotation` 4.0.7 | **MIT** | ✅ | github.com/rrousselGit/riverpod |
| `freezed_annotation` 3.1.0 | **MIT** | ✅ | github.com/rrousselGit/freezed |
| `json_annotation` 4.12.0 | **BSD-3-Clause** | ✅ | github.com/google/json_serializable.dart |
| `go_router` 18.0.2 | **BSD-3-Clause** | ✅ | github.com/flutter/packages |
| `hive_ce` 2.20.1 | **BSD-3-Clause** + **Apache-2.0** | ✅ | github.com/IO-Design-Team/hive_ce |
| `hive_ce_flutter` 2.4.0 | **BSD-3-Clause** + **Apache-2.0** | ✅ | github.com/IO-Design-Team/hive_ce |
| `audio_service` 0.18.19 | **MIT** | ✅ | github.com/ryanheise/audio_service |
| `on_audio_query` 2.9.0 | **BSD-3-Clause** | ✅ | github.com/LucJosin/on_audio_query |
| `permission_handler` 13.0.2 | **MIT** | ✅ | github.com/baseflow/flutter-permission-handler |
| `dartz` 0.10.1 | **MIT** | ✅ | github.com/spebbe/dartz |
| `plugin_platform_interface` 2.1.8 | **BSD-3-Clause** | ✅ | github.com/flutter/packages |
| `Plus Jakarta Sans` (4 bobot, **dibundel** di `assets/fonts/`) | **OFL-1.1** | ✅ | github.com/tokotype/PlusJakartaSans |

> **Catatan — `hive_ce`:** berkas `LICENSE` (cabang `main`) berisi **dua lisensi berurutan**, dipisah garis `====`:
> 1. baris 0–11 → **BSD-3-Clause**, *Copyright 2025 Aaron DeLory* (kontribusi fork `hive_ce`)
> 2. baris 14–211 → **Apache License 2.0**, lampiran *Copyright 2019 Simon Leier* (kode asli Hive)
>
> Karena itu keduanya dicantumkan. Tidak ada file `NOTICE` di seluruh repo (`/NOTICE` dan `/hive/NOTICE` → 404), sehingga kewajiban NOTICE pada Apache-2.0 **tidak berlaku**.
> *(Selisih ini sebelumnya tercatat di bagian 5; kini sudah diverifikasi dan diselesaikan — 6 Okt 2026.)*

---

## 2. Dependensi native Android

| Komponen | Lisensi | Catatan |
|---|---|---|
| `androidx.media3:media3-exoplayer` | **Apache-2.0** | Mesin pemutaran + `PitchAudioProcessor` |
| `androidx.media3:media3-common` | **Apache-2.0** | Kelas penunjang Media3 |

---

## 3. Kerangka kerja sistem iOS

| Komponen | Lisensi | Catatan |
|---|---|---|
| `AVAudioEngine` | Lisensi SDK Apple | Kerangka sistem — **tidak didistribusikan** sebagai kode pihak ketiga |
| `AVAudioUnitTimePitch` | Lisensi SDK Apple | Sama — bagian dari `AVFoundation` |

*(Berkas ini dicantumkan untuk kelengkapan; kewajiban atribusi lisensi tidak berlaku karena kodenya tidak ikut dibundel.)*

---

## 4. Perkakas pengembangan — **TIDAK** masuk ke dalam biner

| Paket | Lisensi |
|---|---|
| `build_runner` 2.16.1 | BSD-3-Clause |
| `freezed` 4.0.2 | MIT |
| `json_serializable` 6.14.1 | BSD-3-Clause |
| `riverpod_generator` 4.0.9 | MIT |
| `hive_ce_generator` 1.11.3 | BSD-3-Clause + Apache-2.0 |
| `very_good_analysis` 11.0.0 | MIT |
| `mocktail` 1.0.5 | MIT |
| **Flutter / Dart SDK** | BSD-3-Clause |

---

## 5. Dependensi yang direncanakan di TDD §11 tetapi **TIDAK dipakai di v1**

Dicatat agar jelas mengapa tidak muncul di daftar di atas:

| Paket | Lisensi | Alasan tidak dipakai di v1 |
|---|---|---|
| `sentry_flutter` 9.30.1 | MIT | **v1 tanpa Sentry** — memakai **Google Play Vitals** (gratis) |
| `dio` 5.11.1 | MIT | **v1 sepenuhnya offline** — tidak ada panggilan jaringan |
| `cached_network_image` 4.0.4 | MIT | Sampul album diambil dari **file lokal**, bukan URL |

> Bila salah satunya diaktifkan untuk versi mendatang, **tambahkan kembali ke bagian 1** dan perbarui Privacy Policy.

### Penyimpanan lokal: `hive` → `hive_ce` (selesai, 6 Okt 2026)
`hive_generator` 2.0.1 mengunci `analyzer <7.0.0` sedangkan `riverpod_generator` 4.x menuntut `analyzer ≥7.3.0` — keduanya tidak bisa terpasang bersama. Selain itu `hive` 2.2.3 masih menyatakan `sdk >=2.12.0 <3.0.0`, padahal proyek ini memakai **Dart 3.13**. Karena itu `hive` diganti **`hive_ce` 2.20.1** (`sdk ^3.4.0`) beserta `hive_ce_flutter` 2.4.0 dan `hive_ce_generator` 1.11.3 (`analyzer ^14.0.0`). Lisensinya sudah diverifikasi di bagian 1.

---

## 6. Cara menampilkan atribusi di dalam aplikasi

Flutter sudah menyediakan pengumpul lisensi otomatis. Cukup tampilkan halaman lisensi:

```dart
showAboutDialog(
  context: context,
  applicationName: 'Lirih',
  applicationVersion: kAppVersion,
  applicationLegalese: '© 2026 Sakadabra',
  // Daftar dependensi terisi otomatis dari LicenseRegistry
);
```

**Checklist:**
- [ ] Tombol **"Tentang & Lisensi"** tersedia di dalam aplikasi (mis. di pengaturan)
- [ ] `showAboutDialog` / `LicensePage` menampilkan daftar paket di atas
- [ ] Nama & versi aplikasi benar
- [ ] Tautan ke repositori & kebijakan privasi aktif

---

## 7. Kewajiban per lisensi

| Lisensi | Yang wajib dilakukan |
|---|---|
| **MIT** | Sertakan **pemberitahuan hak cipta** (copyright notice) asli |
| **BSD-3-Clause** | Sertakan **copyright notice** + **daftar syarat** (3 klausul) apa adanya |
| **Apache-2.0** | Sertakan **NOTICE** bila ada, cantumkan **perubahan yang dilakukan**, dan lisensikan ulang dengan lisensi yang sama |
| **OFL-1.1** | Sertakan **copyright notice** + **salinan lisensi penuh** bersama berkas font. Font boleh didistribusikan bersama perangkat lunak, tetapi **tidak boleh dijual sendirian** |

> ⚠️ Bila ada modifikasi pada kode pihak ketiga (mis. pada `PitchAudioProcessor` yang diturunkan dari Media3), **wajib ditandai di sini** sebagai modifikasi.

---

## 8. Cara memperbarui berkas ini

```bash
dart pub deps --style=compact          # daftar dependensi aktual
dart pub outdated --mode=null-safety   # cek versi
```

Lalu untuk tiap paket baru:
1. Buka `https://pub.dev/api/packages/<nama>/score` → baca tag `license:*`
2. Buka `https://pub.dev/packages/<nama>` → salin tautan repositori
3. Baca berkas `LICENSE` di repositori → pastikan cocok
4. Tambahkan baris ke **bagian 1**

---

## 🔗 Referensi

- `MelodicDSP-Compliance-Roadmap-v3.md` → **R9** (atribusi lisensi)
- `MelodicDSP-Technical-Design-Doc.md` → §11 Dependensi yang direncanakan
- `README.md` → ikhtisar proyek
- `MelodicDSP-v1-Checklist.md` → Blok A & Fase 5
