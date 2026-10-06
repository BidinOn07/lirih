import 'package:flutter/material.dart';

/// Skala tipografi **Lirih** — keluaran task **0N.7**.
///
/// Font: **Plus Jakarta Sans** (OFL-1.1, dirancang *Tokotype* — foundry
/// Indonesia), dibundel di `assets/fonts/` karena aplikasi berjalan
/// **tanpa permission INTERNET**. Empat bobot dipakai:
///
/// | Bobot | `FontWeight` | Peran |
/// |---|---|---|
/// | Regular | [FontWeight.w400] | teks isi |
/// | Medium | [FontWeight.w500] | angka & metadata |
/// | SemiBold | [FontWeight.w600] | judul & label |
/// | Bold | [FontWeight.w700] | judul besar |
///
/// ✅ Bukan **Circular** (larangan task 0N.7).
///
/// Warna sengaja **tidak** ditentukan di sini — warna dipasang oleh
/// `ThemeData` dari `AppColors` agar skala ini berlaku di tema gelap
/// maupun terang.
abstract final class AppTypography {
  /// Nama keluarga font yang terdaftar di `pubspec.yaml`.
  static const String keluarga = 'Plus Jakarta Sans';

  // ── Judul ─────────────────────────────────────────────────────

  /// Judul layar pemutar dan wordmark di dalam aplikasi.
  static const TextStyle display = TextStyle(
    fontFamily: keluarga,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.5,
  );

  /// Judul halaman (Pustaka, Pengaturan, Hasil pencarian).
  static const TextStyle judul1 = TextStyle(
    fontFamily: keluarga,
    fontSize: 23,
    fontWeight: FontWeight.w700,
    height: 1.20,
    letterSpacing: -0.25,
  );

  /// Judul bagian dan judul lagu pada daftar.
  static const TextStyle judul2 = TextStyle(
    fontFamily: keluarga,
    fontSize: 19,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.1,
  );

  /// Judul kartu dan label tombol utama.
  static const TextStyle judul3 = TextStyle(
    fontFamily: keluarga,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.30,
  );

  // ── Isi ───────────────────────────────────────────────────────

  /// Teks isi besar — deskripsi, pesan kosong.
  static const TextStyle isiBesar = TextStyle(
    fontFamily: keluarga,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.50,
  );

  /// Teks isi standar — daftar, paragraf.
  static const TextStyle isi = TextStyle(
    fontFamily: keluarga,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  /// Teks isi kecil — baris metadata album/artis.
  static const TextStyle isiKecil = TextStyle(
    fontFamily: keluarga,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.40,
  );

  // ── Label & angka ─────────────────────────────────────────────

  /// Label tombol, chip, dan tab (rata huruf lebar).
  static const TextStyle label = TextStyle(
    fontFamily: keluarga,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.30,
    letterSpacing: 0.4,
  );

  /// Keterangan sekunder dan teks bantuan.
  static const TextStyle caption = TextStyle(
    fontFamily: keluarga,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 0.2,
  );

  /// Angka posisi durasi (`1:23`) dan nilai frekuensi (432 / 528 Hz).
  /// Sengaja `FontFeature.tabularFigures` supaya angka tidak bergetar
  /// saat bertambah.
  static const TextStyle angka = TextStyle(
    fontFamily: keluarga,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.20,
    letterSpacing: 0.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
