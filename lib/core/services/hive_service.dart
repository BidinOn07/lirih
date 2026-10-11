import 'package:flutter/foundation.dart';

import 'package:hive_ce_flutter/hive_flutter.dart';

/// Nama-nama box Hive (TDD §7).
abstract final class HiveBoxes {
  /// Antrean diputar (task 1.10).
  static const String queue = 'queueBox';

  /// Trek yang pernah diputar untuk tab "Putar terakhir" (task 2.6).
  static const String recents = 'recentsBox';

  /// Riwayat pencarian (task 3.5).
  static const String searchHistory = 'searchHistoryBox';

  /// Daftar putar pengguna (task 3.1).
  static const String playlists = 'playlistsBox';

  /// Trek yang ditandai favorit pengguna (task 3.1).
  static const String favorites = 'favoritesBox';

  /// Perubahan tag (judul/artis/album/nomor trek/lirik) yang ditulis
  /// pengguna via sheet "Edit info lagu" (task 3.5). Key = path sumber
  /// trek (stabil — tidak berubah saat tag diedit, beda dengan
  /// `stableTrackId`), value = map field yang diubah.
  static const String trackTags = 'trackTagsBox';

  /// Lirik tersimpan per trek (task 3.2).
  static const String lyrics = 'lyricsBox';

  /// Pengaturan aplikasi (frekuensi default, dll. — task 5.x).
  static const String settings = 'settingsBox';
}

/// Layanan inisialisasi penyimpanan lokal Hive (task 1.10, TDD §7).
///
/// Semua box direncanakan dibuka di sini sekali saja sebelum `runApp`,
/// sehingga controller cukup membaca/menulis tanpa menunggu box terbuka.
/// v1 menyimpan data sederhana (String, Map) — tanpa adapter kustom.
@immutable
class HiveService {
  const HiveService._();

  /// Menyiapkan Hive dan membuka seluruh box yang direncanakan.
  ///
  /// Wajib dipanggil setelah `WidgetsFlutterBinding.ensureInitialized()`.
  static Future<void> initialize() async {
    await Hive.initFlutter();

    await Future.wait([
      _openSafe(HiveBoxes.queue),
      _openSafe(HiveBoxes.recents),
      _openSafe(HiveBoxes.searchHistory),
      _openSafe(HiveBoxes.playlists),
      _openSafe(HiveBoxes.favorites),
      _openSafe(HiveBoxes.trackTags),
      _openSafe(HiveBoxes.lyrics),
      _openSafe(HiveBoxes.settings),
    ]);
  }

  /// Membuka box [name]; membuat bila belum ada.
  static Future<void> _openSafe(String name) async {
    if (Hive.isBoxOpen(name)) return;
    await Hive.openBox<dynamic>(name);
  }
}
