import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/features/player/mini_player.dart';
import 'package:lirih/features/shell/navigation_index_controller.dart';

/// Bar bawah bersama: mini player + navigasi Home/Search/Library (task 2.4).
///
/// Dipakai di `MainShell` **dan** di seluruh layar detail (album, artis,
/// playlist, daftar trek). Sebelumnya layar detail hanya memasang mini
/// player tanpa navigasi bawah, sehingga:
///
/// * pengguna harus menekan back dulu untuk pindah tab;
/// * mini player terlalu mepet ke gesture bar di perangkat tanpa tombol
///   navigasi fisik (tinggi navigation bar memberi jarak).
///
/// Memilih destination mengganti indeks tab via [navigationIndexProvider]
/// lalu kembali ke root — no-op bila sudah berada di root.
class MainBottomBar extends ConsumerWidget {
  /// Membuat bar bawah.
  const MainBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mini player: muncul otomatis saat ada trek aktif (task 2.7).
        // Mengetuknya (di luar tombol aksi) membuka layar Pemutar penuh.
        const MiniPlayerBottomBar(),
        NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            ref.read(navigationIndexProvider.notifier).currentTab = index;
            // Layar detail di-push di atas MainShell — kembalikan ke root
            // agar tab terlihat. No-op bila sudah berada di root.
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
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
              icon: Icon(Icons.search),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.library_music_outlined),
              selectedIcon: Icon(Icons.library_music),
              label: 'Library',
            ),
          ],
        ),
      ],
    );
  }
}
