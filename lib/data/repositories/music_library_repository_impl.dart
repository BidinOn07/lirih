import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:lirih/core/errors/failures.dart';
import 'package:lirih/core/utils/stable_id.dart';
import 'package:lirih/data/datasources/local/media_store_scanner.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/domain/entities/track_source.dart';
import 'package:lirih/domain/repositories/music_library_repository.dart';
import 'package:lirih/features/track_tags/track_tags_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';

/// Implementasi [MusicLibraryRepository] membaca MediaStore via
/// [MediaStoreScanner] (task 1.12).
///
/// Pemetaan `SongModel` → [Track] menyaring format yang didukung v1
/// (MP3/FLAC/WAV/AAC/M4A) dan menghasilkan id stabil via [stableTrackId].
class MusicLibraryRepositoryImpl implements MusicLibraryRepository {
  /// Membuat repository; scanner dapat disuntik untuk pengujian.
  MusicLibraryRepositoryImpl(this._scanner, this._tags);

  final MediaStoreScanner _scanner;

  /// Override tag pengguna per path sumber (task 3.5).
  final Map<String, Map<String, dynamic>> _tags;

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
              .map(_applyTags)
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
    final data = song.data; // Path asli (bukan content://) untuk folder.
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
      trackNumber: song.track,
      fileExtension: song.fileExtension.trim().isEmpty
          ? null
          : song.fileExtension.trim(),
      sizeBytes: song.size > 0 ? song.size : null,
      folder: data.trim().isEmpty ? null : _folderOf(data),
      fileName: data.trim().isEmpty
          ? null
          : data.split('/').where((part) => part.isNotEmpty).lastOrNull,
      durationMs: song.duration,
      source: TrackSource.local(
        filePath: uri,
        durationMs: song.duration,
        mediaStoreId: song.id,
      ),
    );
  }

  /// Nama folder induk dari [path] berkas (segmen sebelum nama berkas).
  String _folderOf(String path) {
    final parts = path.split('/').where((part) => part.isNotEmpty).toList();
    if (parts.length < 2) return '/';
    return parts[parts.length - 2];
  }

  /// Menerapkan perubahan tag pengguna (task 3.5) — lihat
  /// [TrackTagsController] mengapa disimpan terpisah dari MediaStore.
  Track _applyTags(Track track) {
    final tags = _tags[track.sourcePath];
    if (tags == null) return track;

    final title = tags[kTagTitle] as String?;
    final artist = tags[kTagArtist] as String?;
    final album = tags[kTagAlbum] as String?;
    final trackNumber = tags[kTagTrackNumber] as int?;

    return track.copyWith(
      title: title == null || title.trim().isEmpty ? track.title : title.trim(),
      artist: artist == null || artist.trim().isEmpty
          ? track.artist
          : artist.trim(),
      album: album == null || album.trim().isEmpty ? null : album.trim(),
      trackNumber: trackNumber,
    );
  }
}
