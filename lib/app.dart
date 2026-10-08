import 'package:flutter/material.dart';
import 'package:lirih/features/poc_pitch/poc_pitch_screen.dart';
import 'package:lirih/shared/widgets/lirih_logo.dart';
import 'package:lirih/shared/widgets/lirih_wordmark.dart';

/// Widget root aplikasi **Lirih**.
///
/// Menampung [MaterialApp] beserta konfigurasi tema dan rute. Penambahan
/// `GoRouter` (`lib/core/router/`) serta palet warna final (task **0N.7**)
/// dilakukan di sini ketika fitur di `lib/features/` mulai dibangun.
///
/// Saat ini masih memakai placeholder — belum ada layar yang dirender selain
/// [_HomePlaceholder] yang menampilkan logo + wordmark (task **0N.5**).
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LirihLogo(size: 112),
            const SizedBox(height: 20),
            const LirihWordmark(fontSize: 32),
            const SizedBox(height: 32),
            // SEMENTARA — pintu ke PoC pitch shift (task 0.6/0.8).
            // Dihapus saat navigasi GoRouter task 2.4 dibangun.
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const PoCPitchScreen()),
              ),
              child: const Text('PoC — Pitch Shift'),
            ),
          ],
        ),
      ),
    );
  }
}
