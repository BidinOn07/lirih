import 'dart:async';
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
///
/// **Penting — mengapa setiap akses plugin diserialkan:** `on_audio_query`
/// (plugin tak terawat) menyimpan hasil method channel di sebuah *singleton*
/// global yang **ditimpa setiap kali sebuah method dipanggil**. Bila dua
/// method dipanggil bersamaan — mis. pemindaian pustaka sedang menunggu
/// dialog izin sementara Beranda memuat sampul album trek terakhir — hasil
/// permintaan izin tertimpa oleh hasil kueri sampul. Balasan dialog izin
/// lalu nyasar ke objek hasil yang sudah pernah dibalas:
/// `IllegalStateException: Reply already submitted` → aplikasi lumpuh.
///
/// Karena itu method plugin hanya boleh berjalan satu per satu di sini.
class OnAudioQueryMediaStoreScanner implements MediaStoreScanner {
  /// Membuat scanner; [query] dapat disuntikkan untuk pengujian.
  OnAudioQueryMediaStoreScanner([OnAudioQuery? query])
    : _query = query ?? OnAudioQuery();

  final OnAudioQuery _query;

  /// Antrean operasi: method berikutnya menunggu operasi sebelumnya selesai.
  Future<void>? _pending;

  /// Menjalankan [action] satu per satu (lihat catatan kelas).
  Future<T> _serialize<T>(Future<T> Function() action) async {
    final previous = _pending;
    final done = Completer<void>();
    _pending = done.future;
    try {
      await previous;
      return await action();
    } finally {
      done.complete();
    }
  }

  @override
  Future<bool> hasPermission() => _serialize(_query.permissionsStatus);

  @override
  Future<bool> requestPermission() => _serialize(_query.permissionsRequest);

  @override
  Future<List<SongModel>> querySongs() => _serialize(
    () => _query.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    ),
  );

  @override
  Future<Uint8List?> artworkFor(int songId) => _serialize(() async {
    // Plugin membalas method channel DUA kali (result.error lalu
    // result.success) bila sebuah query dipanggil saat izin belum
    // diberikan → crash. Jangan panggil `queryArtwork` sebelum izin ada.
    final granted = await _query.permissionsStatus();
    if (!granted) return null;
    // HD: ukuran 600 dp memastikan sampul tajam di grid besar maupun
    // layar pemutar (yang butuh ~300 dp). Plugin memakai
    // `loadThumbnail(size, size)` — 200 (default) terlihat buram saat
    // diperbesar.
    return await _query.queryArtwork(songId, ArtworkType.AUDIO, size: 600);
  });
}
