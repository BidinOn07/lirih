import 'package:flutter/material.dart';
import 'package:lirih/core/constants/app_typography.dart';

/// Wordmark **Lirih** — keluaran task **0N.5**.
///
/// Nama aplikasi ditampilkan sebagai teks "LIRIH" dalam Plus Jakarta Sans
/// Bold dengan *letter-spacing* lebar yang proporsional terhadap ukuran —
/// membangun kesan tenang sesuai makna "lirih" (suara yang halus).
///
/// **100% original** — tidak meniru wordmark aplikasi musik mana pun.
/// Jarak antar huruf otomatis mengikuti [fontSize] (0,22 × ukuran).
class LirihWordmark extends StatelessWidget {
  /// Membuat wordmark dengan ukuran dan warna opsional.
  const LirihWordmark({super.key, this.fontSize = 24, this.color});

  /// Ukuran huruf wordmark.
  final double fontSize;

  /// Warna teks. `null` mengikuti [DefaultTextStyle] di sekitarnya.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'LIRIH',
      style: TextStyle(
        fontFamily: AppTypography.keluarga,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        height: 1,
        letterSpacing: fontSize * 0.22,
        color: color,
      ),
    );
  }
}
