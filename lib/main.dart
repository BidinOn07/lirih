import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/app.dart';

/// Titik masuk aplikasi **Lirih**.
///
/// Menjalankan [LirihApp] di dalam [ProviderScope] milik Riverpod agar seluruh
/// provider — pemutar, pustaka lokal, antrean, dan penyetelan frekuensi —
/// sudah tersedia sejak siklus hidup aplikasi dimulai.
///
/// Tugas berat (inisialisasi Hive, permintaan izin baca media) dipindahkan ke
/// task **0.6** dan **3.x**; saat ini hanya memastikan binding Flutter siap.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: LirihApp()));
}
