import 'package:flutter/material.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/features/library/library_screen.dart';
import 'package:lirih/features/player/player_screen.dart';
import 'package:lirih/features/poc_pitch/poc_pitch_screen.dart';

/// Shell navigasi utama (task 2.4) — tiga tab dengan [IndexedStack].
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
        children: const [LibraryScreen(), PlayerScreen(), PoCPitchScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        backgroundColor: AppColors.soga800,
        indicatorColor: AppColors.kunir600,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music),
            label: 'Pustaka',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle),
            label: 'Pemutar',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science),
            label: 'PoC',
          ),
        ],
      ),
    );
  }
}
