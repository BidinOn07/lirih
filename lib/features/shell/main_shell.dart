import 'package:flutter/material.dart';

import 'package:lirih/core/audio/dsp_channel.dart';
import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/features/home/home_screen.dart';
import 'package:lirih/features/library/library_screen.dart';
import 'package:lirih/features/player/mini_player.dart';
import 'package:lirih/features/search/search_screen.dart';

/// Shell navigasi utama (task 2.4) — empat tab dengan [IndexedStack].
///
/// Layar Pemutar **bukan tab** — diakses dengan mengetuk [MiniPlayerBar]
/// yang muncul di atas navigasi bawah saat ada trek aktif. Saat tidak
/// ada trek diputar, mini player hilang, sehingga tidak ada entry point
/// yang menuju layar kosong.
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
    return PopScope(
      // Back di root TIDAK boleh keluar dari app — pindahkan ke background
      // saja (seperti tombol Home) agar pemutar tetap berjalan. Layar
      // yang di-push (mis. Pemutar) tetap bisa pop seperti biasa karena
      // PopScope ini hanya menangani rute paling bawah.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await const DspChannel().moveToBackground();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [HomeScreen(), LibraryScreen(), SearchScreen()],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini player: muncul otomatis saat ada trek aktif (task 2.7).
            // Mengetuknya (di luar tombol aksi) membuka layar Pemutar penuh.
            const MiniPlayerBottomBar(),
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
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.library_music_outlined),
                  selectedIcon: Icon(Icons.library_music),
                  label: 'Library',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search),
                  selectedIcon: Icon(Icons.search),
                  label: 'Search',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
