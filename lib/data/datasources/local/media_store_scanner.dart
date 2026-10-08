import 'dart:typed_data';

import 'package:on_audio_query/on_audio_query.dart';

/// Sumber data audio lokal (MediaStore via `on_audio_query`).
///
/// Interface terpisah dari `MusicLibraryRepositoryImpl` agar permintaan izin
/// dan kueri MediaStore dapat di-mock pada unit test (task 1.13).
abstract interface class MediaStoreScanner {
  /// Apakah izin akses media sudah diberikan.
  Future<bool> hasPermission();

  /// Meminta izin akses media (menangani Android 13+ `READ_MEDIA_AUDIO`
  /// dan ≤12 `READ_EXTERNAL_STORAGE` secara internal).
  Future<bool> requestPermission();

  /// Mengembalikan seluruh lagu di penyimpanan eksternal, terurut judul.
  Future<List<SongModel>> querySongs();

  /// Mengambil sampul album lagu [songId] sebagai byte, `null` bila tak ada.
  Future<Uint8List?> artworkFor(int songId);
}

/// Implementasi [MediaStoreScanner] memakai `on_audio_query` 2.9.0.
class OnAudioQueryMediaStoreScanner implements MediaStoreScanner {
  /// Membuat scanner; [query] dapat disuntik untuk pengujian.
  OnAudioQueryMediaStoreScanner([OnAudioQuery? query])
    : _query = query ?? OnAudioQuery();

  final OnAudioQuery _query;

  @override
  Future<bool> hasPermission() => _query.permissionsStatus();

  @override
  Future<bool> requestPermission() => _query.permissionsRequest();

  @override
  Future<List<SongModel>> querySongs() => _query.querySongs(
    sortType: SongSortType.TITLE,
    orderType: OrderType.ASC_OR_SMALLER,
    uriType: UriType.EXTERNAL,
  );

  @override
  Future<Uint8List?> artworkFor(int songId) =>
      _query.queryArtwork(songId, ArtworkType.AUDIO, size: 200);
}
