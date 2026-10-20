import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indeks tab yang sedang aktif di MainShell (Home/Search/Library).
///
/// State ini dipindah dari `StatefulWidget` ke provider agar bar navigasi
/// bawah — yang kini dipakai bersama oleh seluruh layar detail (lihat
/// `MainBottomBar`) — dapat mengganti tab dari mana pun, lalu kembali ke
/// root. Tanpa ini, NavigationBar di layar detail tidak punya cara untuk
/// mengubah tab yang ditampilkan shell.
final navigationIndexProvider =
    NotifierProvider<NavigationIndexController, int>(
      NavigationIndexController.new,
    );

/// Pengendali indeks tab navigasi utama.
class NavigationIndexController extends Notifier<int> {
  /// Tab pertama (Home) aktif saat aplikasi dibuka.
  @override
  int build() => 0;

  /// Tab yang sedang aktif.
  int get currentTab => state;

  /// Mengganti tab aktif ke [index].
  set currentTab(int index) => state = index;
}
