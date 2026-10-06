import 'package:flutter/material.dart';

/// Widget root aplikasi **Lirih**.
///
/// Menampung [MaterialApp] beserta konfigurasi tema dan rute. Penambahan
/// `GoRouter` (`lib/core/router/`) serta palet warna final (task **0N.7**)
/// dilakukan di sini ketika fitur di `lib/features/` mulai dibangun.
///
/// Saat ini masih memakai placeholder — belum ada layar yang dirender selain
/// [_HomePlaceholder].
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
      theme: ThemeData(useMaterial3: true),
      home: const _HomePlaceholder(),
    );
  }
}

/// Layar sementara yang menggantikan demo bawaan `flutter create`.
///
/// Akan diganti oleh rute pertama task **0.3–1.x** (Home / Pustaka).
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text(LirihApp.title)));
  }
}
