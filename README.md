# Lirih

> Pemutar musik **offline** untuk koleksi lokal Anda — dengan **preset frekuensi 440 / 432 / 528 Hz** dan **pengaturan tinggi nada (pitch shift)** yang berlaku langsung saat musik mengalir.

**Status:** dalam pengembangan · **Target rilis perdana:** Google Play Store · **Versi:** v1 (offline)

---

## ✨ Fitur (v1 — offline)

| Kategori | Fitur |
|---|---|
| **Pemutaran** | MP3, FLAC, WAV, AAC, M4A · antrean, putar ulang, acak · timer tidur |
| ⭐ **Frequency tuner** | Preset **440 / 432 / 528 Hz** + slider kontinu **400–600 Hz** dengan tampilan **offset cents** |
| ⭐ **DSP** | Tinggi nada (**pitch shift**) tanpa mengubah tempo · tempo tanpa mengubah tinggi nada · rentang aman 0,5×–2,0× |
| **Pustaka** | Pemindaian otomatis · tab Tracks / Artists / Albums · pencarian lokal + riwayat |
| **Playlist** | Buat, ubah nama, susun ulang (*drag*), hapus |
| **Lirik** | Tersinkronisasi dari tag **USLT/SYLT** dan berkas `.lrc` · sorotan baris aktif · ketuk untuk melompat |
| **Antarmuka** | Gelap-first · sampul album dari file · bilah mini persisten · kendali layar kunci & notifikasi |
| **Privasi** | **Tanpa akun · tanpa iklan · tanpa pembelian · tanpa koneksi internet** |

**Belum ada di v1** (dijadwalkan kemudian): pemutaran media daring / YouTube, akun, sinkronisasi.

---

## 🛠️ Teknologi

- **Flutter** (Dart) — Android, `minSdk 24`, `targetSdk 36`
- **Media3 / ExoPlayer** — mesin pemutaran + `PitchAudioProcessor` (audio sink kustom)
- **AVAudioEngine + AVAudioUnitTimePitch** — jalur iOS (dijadwalkan setelah Android)
- **Riverpod** — state management · **GoRouter** — navigasi · **Hive** — penyimpanan lokal
- **audio_service** — notifikasi media & layar kunci

`applicationId`: **`io.github.bidinon07.lirih`**

---

## 🚀 Memulai

```bash
# 1. Salin repositori
git clone <repo-url>
cd music-player

# 2. Ambil dependensi
flutter pub get

# 3. Jalankan
flutter run
```

### Membangun untuk Play Store

```bash
flutter build appbundle --release   # → build/app/outputs/bundle/release/app-release.aab
```

> Google Play **hanya menerima `.aab`**, bukan `.apk`.
> **Keystore & `key.properties` TIDAK BOLEH di-commit** — lihat task 0.10. CI menjaga hal ini (`.github/workflows/ci.yml`, job `signing-guard`).

---

## 📚 Dokumen

| Berkas | Isi |
|---|---|
| [`PRIVACY-POLICY.md`](PRIVACY-POLICY.md) | Kebijakan privasi — **wajib untuk Google Play** |
| [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) | Atribusi lisensi dependensi (task R9) |

> Dokumen perencanaan internal (roadmap, checklist, **desain teknis**, clearance, listing, guide) sengaja **tidak diterbitkan** di repo ini.

---

## ⚖️ Disclaimer & Ketentuan Hukum

### Tentang preset frekuensi 432 Hz dan 528 Hz

> Preset **432 Hz** dan **528 Hz** dalam aplikasi ini **murni merupakan pengaturan pemutaran** *(playback setting)*. Preset tersebut bekerja dengan **mengubah tinggi nada (pitch)** audio yang sedang diputar, dan **berlaku untuk seluruh lagu** yang sedang dimainkan.
>
> Aplikasi ini **TIDAK** memberikan klaim kesehatan, medis, terapi, penyembuhan, maupun pengobatan apa pun. **Tidak ada** pernyataan bahwa penggunaan preset tertentu dapat menyembuhkan, menurunkan stres, menyeimbangkan tubuh, atau menghasilkan efek medis.
>
> Gunakan sesuai selera mendengarkan Anda. Konsultasikan tenaga kesehatan bila Anda memiliki kondisi medis.

*(Mitigasi risiko **R10** — dokumen compliance internal)*

### Privasi
Aplikasi ini **tidak mengumpulkan data pengguna**, tidak memiliki server, dan tidak meminta izin `INTERNET`. Seluruh file musik tetap berada di perangkat Anda.
Rincian: [`PRIVACY-POLICY.md`](PRIVACY-POLICY.md)

### Merek pihak ketiga
Nama-nama merek lain (mis. pemutar musik komersial) **tidak** berafiliasi, tidak disponsori, dan tidak didukung oleh proyek ini. Seluruh aset visual dan teks pemasaran dibuat original.

---

## 📄 Lisensi

Kode sumber proyek ini dilisensikan di bawah **MIT** — lihat [`LICENSE`](LICENSE).

Dependensi pihak ketiga memiliki lisensi masing-masing — daftar lengkap di [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

---

## 🔗 Tautan

- Rilis / unduhan: _belum tersedia_
- Kebijakan privasi: _[URL GitHub Pages — isi setelah 5.12]_
- Masalah & laporan: _[URL issues]_
