import 'package:dartz/dartz.dart';
import 'package:lirih/core/errors/failures.dart';
import 'package:lirih/core/utils/stable_id.dart';
import 'package:lirih/data/datasources/local/media_store_scanner.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/domain/entities/track_source.dart';
import 'package:lirih/domain/repositories/music_library_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Implementasi [MusicLibraryRepository] membaca MediaStore via
/// [MediaStoreScanner] (task 1.12).
///
/// Pemetaan `SongModel` → [Track] menyaring format yang didukung v1
/// (MP3/FLAC/WAV/AAC/M4A) dan menghasilkan id stabil via [stableTrackId].
class MusicLibraryRepositoryImpl implements MusicLibraryRepository {
  /// Membuat repository; scanner dapat disuntik untuk pengujian.
  MusicLibraryRepositoryImpl(this._scanner);

  final MediaStoreScanner _scanner;

  /// Ekstensi audio yang didukung v1 (task 0.5).
  static const _supportedExtensions = <String>{
    '.mp3',
    '.flac',
    '.wav',
    '.m4a',
    '.aac',
    '.oga',
    '.opus',
  };

  @override
  Future<Either<Failure, List<Track>>> scanLibrary() async {
    if (!await _scanner.hasPermission()) {
      await _scanner.requestPermission();
      // Jangan percayai nilai balik requestPermission(): plugin lawas
      // on_audio_query membalas method channel DUA kali (result.error lalu
      // result.success) bila query dipanggil saat izin belum diberikan —
      // itu meledakkan thread native. Verifikasi status terlebih dulu;
      // hanya lanjut bila plugin sendiri menganggap izin sudah ada.
      if (!await _scanner.hasPermission()) {
        return left(const PermissionDeniedFailure());
      }
    }

    try {
      final songs = await _scanner.querySongs();
      final tracks =
          songs //
              .where(_isSupported)
              .where((song) => song.uri != null)
              .map(_toTrack)
              .toList(growable: false);

      if (tracks.isEmpty) return left(const EmptyLibraryFailure());
      return right(tracks);
    } on Exception {
      return left(const ScanFailure());
    }
  }

  @override
  Future<bool> hasPermission() => _scanner.hasPermission();

  @override
  Future<bool> requestPermission() => _scanner.requestPermission();

  /// Apakah lagu berformat yang didukung v1.
  bool _isSupported(SongModel song) {
    final ext = song.fileExtension.toLowerCase();
    return _supportedExtensions.contains('.$ext');
  }

  /// Mengubah `SongModel` menjadi [Track] domain.
  Track _toTrack(SongModel song) {
    final uri = song.uri!;
    return Track(
      id: stableTrackId(
        filePath: uri,
        title: song.title,
        artist: song.artist ?? '<unknown>',
        durationMs: song.duration,
      ),
      title: song.title.trim().isEmpty ? 'Tanpa judul' : song.title.trim(),
      artist: (song.artist ?? '').trim().isEmpty
          ? '<unknown>'
          : song.artist!.trim(),
      album: (song.album ?? '').trim().isEmpty ? null : song.album!.trim(),
      durationMs: song.duration,
      source: TrackSource.local(
        filePath: uri,
        durationMs: song.duration,
        mediaStoreId: song.id,
      ),
    );
  }
}
