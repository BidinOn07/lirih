import 'package:flutter/animation.dart';

/// Token durasi dan kurva animasi **Lirih**.
///
/// Seluruh gerak antarmuka mengambil nilai dari sini agar iramanya
/// konsisten: micro-interaction paling singkat, silang-pudar sedang, dan
/// transisi antar layar paling lama. Angka sengaja di bawah ±400 ms agar
/// terasa responsif di perangkat kelas menengah.
abstract final class AppMotion {
  /// Micro-interaction: ganti ikon putar/jeda, pop favorit, pudar sampul.
  static const Duration fast = Duration(milliseconds: 150);

  /// Silang-pudar sedang: ganti tab, tampil/sembunyi mini player, ganti
  /// panel lirik.
  static const Duration medium = Duration(milliseconds: 250);

  /// Transisi antar layar: layar Pemutar naik dari bawah.
  static const Duration route = Duration(milliseconds: 350);

  /// Kurva masuk — melambat di akhir agar "mendarat" lembut.
  static const Curve easeOut = Curves.easeOutCubic;

  /// Kurva keluar — mulai cepat agar tidak terasa menunda.
  static const Curve easeIn = Curves.easeInCubic;
}
