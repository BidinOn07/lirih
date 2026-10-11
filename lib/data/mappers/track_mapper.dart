import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/domain/entities/track_source.dart';

/// Pemetaan [Track] ke/dari `Map<String, dynamic>` untuk penyimpanan lokal
/// (Hive, task 2.6) —di luar entitas agar domain tetap murni.
///
/// Format datang dari `on_audio_query` saat pemindaian, tetapi disimpan
/// ulang saat pemutaran, sehingga rekaman terkini tetap tersedia walau
/// metadata MediaStore berubah. Kunci [Track.id] (stabil) dipakai untuk
/// identitas, bukan `mediaStoreId`.
abstract final class TrackMapper {
  /// Mengubah [track] menjadi map yang dapat disimpan.
  static Map<String, dynamic> toJson(Track track) => <String, dynamic>{
    'id': track.id,
    'title': track.title,
    'artist': track.artist,
    'album': track.album,
    'trackNumber': track.trackNumber,
    'fileExtension': track.fileExtension,
    'sizeBytes': track.sizeBytes,
    'folder': track.folder,
    'fileName': track.fileName,
    'filePath': track.sourcePath,
    'mediaStoreId': track.mediaStoreId,
    'durationMs': track.durationMs,
  };

  /// Membangun [Track] dari map [json].
  ///
  /// Bila [json] tidak lengkap (format lama/rusak), mengembalikan `null`.
  static Track? fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final title = json['title'] as String?;
    final artist = json['artist'] as String?;
    final filePath = json['filePath'] as String?;
    if (id == null || title == null || artist == null || filePath == null) {
      return null;
    }

    return Track(
      id: id,
      title: title,
      artist: artist,
      album: json['album'] as String?,
      trackNumber: json['trackNumber'] as int?,
      fileExtension: (json['fileExtension'] as String?)?.trim(),
      sizeBytes: json['sizeBytes'] as int?,
      folder: json['folder'] as String?,
      fileName: json['fileName'] as String?,
      durationMs: json['durationMs'] as int?,
      source: TrackSource.local(
        filePath: filePath,
        durationMs: json['durationMs'] as int?,
        mediaStoreId: json['mediaStoreId'] as int?,
      ),
    );
  }
}
