import 'dart:async';

import 'package:hive_ce/hive.dart';
import 'package:lirih/core/services/hive_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'track_tags_controller.g.dart';

/// Field tag yang bisa disimpan per trek (task 3.5).
///
/// Kunci ini dipakai di dalam map nilai `trackTagsBox` (lihat
/// [TrackTagsController]).
const String kTagTitle = 'title';

/// Kunci map untuk artis.
const String kTagArtist = 'artist';

/// Kunci map untuk album.
const String kTagAlbum = 'album';

/// Kunci map untuk nomor trek.
const String kTagTrackNumber = 'trackNumber';

/// Kunci map untuk lirik hasil edit pengguna.
const String kTagLyrics = 'lyrics';

/// Perubahan tag yang ditulis pengguna via sheet "Edit info lagu"
/// (task 3.5).
///
/// **Mengapa disimpan terpisah, bukan ditulis ulang ke MediaStore?**
/// Menulis ulang tag ke MediaStore butuh izin tulis media (rumit di
/// Android 13+) dan memaksa rescan penuh. Sebagai gantinya, perubahan
/// disimpan di `trackTagsBox` dengan **key = path sumber trek** — path
/// ini stabil dan tidak berubah saat judul/artis diedit (beda dengan
/// `stableTrackId` yang memuat judul+artis di hash-nya, sehingga id
/// akan berubah dan memutus referensi Hive lain). Saat pemindaian,
/// repository menggabungkan nilai asli dengan override ini.
///
/// Karena box bisa jadi belum terbuka saat provider pertama dibaca,
/// controller bersifat *inert*: operasi menjadi no-op alih-alih
/// menghempaskan galat.
@riverpod
class TrackTagsController extends _$TrackTagsController {
  Box<dynamic>? _box;

  @override
  Map<String, Map<String, dynamic>> build() {
    if (!Hive.isBoxOpen(HiveBoxes.trackTags)) {
      return const <String, Map<String, dynamic>>{};
    }
    _box = Hive.box<dynamic>(HiveBoxes.trackTags);
    return _readAll();
  }

  /// Membaca seluruh override: key path → map field.
  Map<String, Map<String, dynamic>> _readAll() {
    final box = _box;
    if (box == null) return const <String, Map<String, dynamic>>{};

    final overrides = <String, Map<String, dynamic>>{};
    for (final key in box.keys) {
      if (key is! String) continue;
      final value = box.get(key);
      if (value is! Map) continue;
      overrides[key] = Map<String, dynamic>.from(value);
    }
    return Map<String, Map<String, dynamic>>.unmodifiable(overrides);
  }

  /// Menyimpan perubahan tag untuk trek pada [sourcePath].
  ///
  /// Hanya field yang diberikan (non-null) yang ditulis; field lain
  /// tetap memakai nilai dari MediaStore. [trackNumber] `null` berarti
  /// "kosongkan". Bila [removeLyrics] `true`, override lirik dihapus
  /// (kembali ke lirik tertanam).
  Future<void> saveTags(
    String sourcePath, {
    String? title,
    String? artist,
    String? album,
    int? trackNumber,
    String? lyrics,
    bool removeLyrics = false,
  }) async {
    final box = _box;
    if (box == null) return;

    final existing = Map<String, dynamic>.from(
      (box.get(sourcePath) as Map?) ?? {},
    );
    if (title != null) existing[kTagTitle] = title.trim();
    if (artist != null) existing[kTagArtist] = artist.trim();
    if (album != null) existing[kTagAlbum] = album.trim();
    if (trackNumber != null) existing[kTagTrackNumber] = trackNumber;
    if (removeLyrics) {
      existing.remove(kTagLyrics);
    } else if (lyrics != null) {
      existing[kTagLyrics] = lyrics;
    }

    if (existing.isEmpty) {
      await box.delete(sourcePath);
    } else {
      await box.put(sourcePath, existing);
    }
    state = _readAll();
  }
}
