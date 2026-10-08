import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:lirih/domain/entities/track.dart';

part 'playlist.freezed.dart';

/// Daftar putar buatan pengguna (task 3.1).
///
/// Berisi trek secara *inline* (disimpan utuh di Hive via `TrackMapper`)
/// sehingga playlist tetap dapat diputar walau pemindaian MediaStore belum
/// selesai — berbeda dengan penyimpanan referensi id yang memaksa resolusi
/// ulang tiap scan. Identitasnya [id] yang dibuat aplikasi.
@freezed
abstract class Playlist with _$Playlist {
  /// Membuat daftar putar.
  const factory Playlist({
    /// Identifier unik aplikasi (`pl_<microsecondsSinceEpoch>`).
    required String id,

    /// Nama yang ditampilkan; bisa diubah (task 3.1).
    required String name,

    /// Trek anggota, terurut; urutan ini dipertahankan saat diputar.
    @Default(<Track>[]) List<Track> tracks,
  }) = _Playlist;

  const Playlist._();

  /// Jumlah trek anggota.
  int get length => tracks.length;

  /// Apakah playlist kosong.
  bool get isEmpty => tracks.isEmpty;
}
