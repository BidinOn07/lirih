import 'package:flutter/material.dart';

/// Token warna **Lirih** — keluaran task **0N.7**.
///
/// Palet disusun dari pewarna alam batik Jawa sebagai benang merek Lirih
/// (penerbit **Sakadabra**):
///
/// | Kelompok | Pewarna alam | Peran |
/// |---|---|---|
/// | `soga` | kayu jati / soga | netral gelap (permukaan) |
/// | `paper` | kertas mori | netral terang (permukaan) |
/// | `kunir` | kunyit / kuningan gamelan | **warna primer** |
/// | `nila` | nila (indigo) | **warna tersier** — penyetel frekuensi |
///
/// ✅ Larangan task 0N.7 terpenuhi: bukan `#121212` + hijau ala Spotify,
/// tidak memakai warna merek pemutar musik mana pun.
abstract final class AppColors {
  // ── Netral gelap: Soga / kayu jati ─────────────────────────────
  // Skala hangat bernuansa cokelat — sengaja BUKAN hitam netral `#121212`.

  /// Lapisan paling dalam: scrim, dialog, dan modal gelap.
  static const Color soga950 = Color(0xFF14100C);

  /// Latar utama aplikasi pada tema gelap.
  static const Color soga900 = Color(0xFF1C1712);

  /// Latar bersarang: bottom sheet dan panel terbenam.
  static const Color soga850 = Color(0xFF241D17);

  /// Permukaan kartu, baris daftar, dan pencari.
  static const Color soga800 = Color(0xFF2A2119);

  /// Permukaan terangkat: app bar, chip terpilih, tombol sekunder.
  static const Color soga700 = Color(0xFF382D23);

  /// Garis pemisah dan batas luar komponen.
  static const Color soga600 = Color(0xFF4A3C30);

  /// Elemen nonaktif (disabled) pada latar gelap.
  static const Color soga500 = Color(0xFF5E4E3F);

  /// Teks petunjuk (hint) pada latar gelap.
  static const Color soga400 = Color(0xFF8A7767);

  /// Teks sekunder dan ikon nonaktif pada latar gelap.
  static const Color soga300 = Color(0xFFA89684);

  /// Teks sekunder terang dan pembatas lembut.
  static const Color soga200 = Color(0xFFC9BAA8);

  /// Teks sekunder paling terang.
  static const Color soga100 = Color(0xFFE4D8C8);

  /// Teks utama pada latar gelap.
  static const Color soga50 = Color(0xFFF5EDE0);

  // ── Netral terang: kertas mori ─────────────────────────────────

  /// Latar utama aplikasi pada tema terang.
  static const Color paper50 = Color(0xFFFAF6F0);

  /// Permukaan kartu dan daftar pada tema terang.
  static const Color paper100 = Color(0xFFF5EDE0);

  /// Permukaan terangkat pada tema terang.
  static const Color paper200 = Color(0xFFEDE3D4);

  /// Garis pemisah dan batas luar pada tema terang.
  static const Color paper300 = Color(0xFFE0D4C2);

  /// Teks utama pada latar terang.
  static const Color ink900 = Color(0xFF1C1712);

  /// Teks sekunder pada latar terang.
  static const Color ink700 = Color(0xFF5E4E3F);

  /// Teks petunjuk (hint) pada latar terang.
  static const Color ink500 = Color(0xFF8A7767);

  // ── Primer: Kunir / kuningan gamelan ───────────────────────────

  /// Warna primer — aksen kuningan, dipakai tombol utama & progres.
  static const Color kunir500 = Color(0xFFD9A441);

  /// Primer lebih terang (hover, fokus, sorotan teks).
  static const Color kunir400 = Color(0xFFE8BC63);

  /// Primer lebih pekat (tertekan, label pada latar terang).
  static const Color kunir600 = Color(0xFFB9862E);

  /// Primer paling pekat (teks aksen di atas latar sangat terang).
  static const Color kunir700 = Color(0xFF966A22);

  /// Kunir sangat redup — latar chip dan badge.
  static const Color kunir100 = Color(0xFFF3DCA8);

  // ── Tersier: Nila / indigo ─────────────────────────────────────
  // Dipakai khusus untuk area penyetelan frekuensi (432 / 528 Hz) agar
  // terlihat berbeda dari aksen primer tanpa memakai warna hijau.

  /// Tersier — indigo nila, penanda preset frekuensi aktif.
  static const Color nila500 = Color(0xFF4A5FA8);

  /// Tersier lebih terang (highlight penyetel, jejak gelombang).
  static const Color nila400 = Color(0xFF6B81C7);

  /// Tersier lebih pekat (teks aksen di atas latar terang).
  static const Color nila600 = Color(0xFF3A4B87);

  // ── Sekunder ───────────────────────────────────────────────────

  /// Sekunder — kuningan meredup, untuk kontrol sekunder dan ikon.
  static const Color sekunder500 = Color(0xFFA98D6B);

  /// Sekunder terang, dipakai sebagai teks di atas primer.
  static const Color sekunder100 = Color(0xFFF0E4D2);

  // ── Status ─────────────────────────────────────────────────────

  /// Galat: penghapusan, kegagalan pemutaran, izin ditolak.
  static const Color error500 = Color(0xFFE5534B);

  /// Teks/galat di atas latar gelap.
  static const Color error300 = Color(0xFFF79C96);

  /// Berhasil: sinkronisasi selesai, berkas ditemukan.
  static const Color success500 = Color(0xFF5B9A5E);

  // ── Utilitas ───────────────────────────────────────────────────

  /// Hitam translusen untuk scrim di atas gambar sampul.
  static const Color scrim = Color(0x66000000);

  /// Putih translusen untuk ikon di atas sampul album.
  static const Color iconAtasSampul = Color(0xB3FFFFFF);
}
