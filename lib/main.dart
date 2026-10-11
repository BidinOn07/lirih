import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/app.dart';
import 'package:lirih/core/services/hive_service.dart';

/// Titik masuk aplikasi **Lirih**.
///
/// Menjalankan [LirihApp] di dalam [ProviderScope] milik Riverpod agar seluruh
/// provider — pemutar, pustaka lokal, antrean, dan penyetelan frekuensi —
/// sudah tersedia sejak siklus hidup aplikasi dimulai.
///
/// Penyimpanan lokal (Hive) disiapkan di sini sekali saja (task 1.10)
/// sehingga controller cukup membaca/menulis box yang sudah terbuka.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kunci orientasi ke portrait — pemutar musik tidak perlu rotasi
  // otomatis (task 5.x).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await HiveService.initialize();

  runApp(const ProviderScope(child: LirihApp()));
}
