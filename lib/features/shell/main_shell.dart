import 'package:flutter/material.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/features/home/home_screen.dart';
import 'package:lirih/features/library/library_screen.dart';
import 'package:lirih/features/player/mini_player.dart';
import 'package:lirih/features/player/player_screen.dart';
import 'package:lirih/features/poc_pitch/poc_pitch_screen.dart';
import 'package:lirih/features/search/search_screen.dart';

/// Shell navigasi utama (task 2.4) — empat tab dengan [IndexedStack].
///
/// Layar Pemutar **bukan tab** — diakses dengan mengetuk [MiniPlayerBar]
/// yang muncul di atas navigasi bawah saat ada trek aktif. Saat tidak
/// ada trek diputar, mini player hilang, sehingga tidak ada entry point
/// yang menuju layar kosong.
///
/// Tab "PoC" **sementara** (alat uji task 0.6/0.8); dihapus saat seluruh
/// validasi perangkat selesai dan mesin dipindah ke plugin `lirih_audio`.
class MainShell extends StatefulWidget {
  /// Membuat shell navigasi.
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          LibraryScreen(),
          SearchScreen(),
          PoCPitchScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini player: muncul otomatis saat ada trek aktif (task 2.7).
          // Mengetuknya (di luar tombol aksi) membuka layar Pemutar penuh.
          MiniPlayerBar(
            onOpenPlayer: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PlayerScreen()),
            ),
          ),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (index) => setState(() => _index = index),
            backgroundColor: AppColors.soga800,
            indicatorColor: AppColors.kunir600,
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined),
                selectedIcon: Icon(Icons.library_music),
                label: 'Pustaka',
              ),
              NavigationDestination(
                icon: Icon(Icons.search),
                selectedIcon: Icon(Icons.search),
                label: 'Cari',
              ),
              NavigationDestination(
                icon: Icon(Icons.science_outlined),
                selectedIcon: Icon(Icons.science),
                label: 'PoC',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
