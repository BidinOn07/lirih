import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/audio/dsp_channel.dart';
import 'package:lirih/core/constants/app_motion.dart';
import 'package:lirih/features/home/home_screen.dart';
import 'package:lirih/features/library/library_screen.dart';
import 'package:lirih/features/search/search_screen.dart';
import 'package:lirih/features/shell/main_bottom_bar.dart';
import 'package:lirih/features/shell/navigation_index_controller.dart';

/// Shell navigasi utama (task 2.4) — tiga tab dengan silang-pudar.
///
/// Layar Pemutar **bukan tab** — diakses dengan mengetuk mini player yang
/// muncul di atas navigasi bawah saat ada trek aktif. Saat tidak ada trek
/// diputar, mini player hilang, sehingga tidak ada entry point yang menuju
/// layar kosong.
///
/// Indeks tab disimpan di [navigationIndexProvider] agar NavigationBar di
/// bar bawah ([MainBottomBar]) — yang juga dipasang di layar detail — dapat
/// mengganti tab dari mana pun.
///
/// Tab non-aktif tetap hidup di pohon widget (posisi gulir dan isian
/// pencarian terjaga persis seperti [IndexedStack]) namun dipudarkan lewat
/// [AnimatedOpacity] supaya pergantian tab terasa halus, bukan pindah
/// mendadak. Saat [AnimatedOpacity] mencapai 0, cat tinta child dihentikan
/// sepenuhnya, jadi tidak ada biaya gambar untuk tab tersembunyi.
class MainShell extends ConsumerWidget {
  /// Membuat shell navigasi.
  const MainShell({super.key});

  /// Tab-tab yang ditampilkan shell, urut sesuai [navigationIndexProvider].
  static const List<Widget> _tabs = [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navigationIndexProvider);

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
        body: Stack(
          children: [
            for (var i = 0; i < _tabs.length; i++)
              Positioned.fill(
                child: _TabPane(selected: i == index, child: _tabs[i]),
              ),
          ],
        ),
        bottomNavigationBar: const MainBottomBar(),
      ),
    );
  }
}

/// Satu tab dari [MainShell] — memudar masuk/keluar saat tab berganti.
///
/// Child selalu di-build agar state-nya tidak hilang, tapi tab yang tidak
/// dipilih dibungkus [IgnorePointer] (tak menerima sentuhan) dan
/// [ExcludeSemantics] (diamkan dari pembaca layar).
///
/// Urutan penting: [TickerMode] harus berada **di bawah** [AnimatedOpacity],
/// bukan membungkusnya. [TickerMode] mematikan (mute) seluruh ticker di
/// bawahnya, dan ticker yang dimatikan tidak pernah berdetak — bila
/// [AnimatedOpacity] ikut dimatikan, pudar keluar tidak akan jalan dan tab
/// lama tertinggal tampil penuh di belakang tab baru.
class _TabPane extends StatelessWidget {
  /// Membuat panel tab dengan status [selected].
  const _TabPane({required this.selected, required this.child});

  /// Apakah tab ini sedang aktif ditampilkan.
  final bool selected;

  /// Isi tab.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !selected,
      child: ExcludeSemantics(
        excluding: !selected,
        child: AnimatedOpacity(
          opacity: selected ? 1 : 0,
          duration: AppMotion.medium,
          curve: AppMotion.easeOut,
          // Di dalam AnimatedOpacity: menghentikan animasi bawaan tab
          // tersembunyi tanpa membekukan transisi pudarnya sendiri.
          child: TickerMode(enabled: selected, child: child),
        ),
      ),
    );
  }
}
