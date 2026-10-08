import 'package:flutter/material.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/features/shell/main_shell.dart';

/// Widget root aplikasi **Lirih**.
///
/// Menampung [MaterialApp] beserta konfigurasi tema. Navigasi utama
/// (task 2.4) ada di [MainShell] (bottom navigation). Tema gelap memakai
/// palet Gamelan (`AppColors`) — lihat `lib/core/constants/app_colors.dart`.
class LirihApp extends StatelessWidget {
  /// Membuat widget root [LirihApp].
  const LirihApp({super.key});

  /// Nama aplikasi yang ditampilkan sistem operasi dan dipakai pada tes.
  static const String title = 'Lirih';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.soga900,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.soga800,
          foregroundColor: AppColors.soga50,
        ),
      ),
      home: const MainShell(),
    );
  }
}
