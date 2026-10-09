import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:lirih/domain/entities/track_source.dart';

part 'track.freezed.dart';

/// Sebuah trek musik di pustaka pengguna (TDD §3.2).
///
/// Entri domain utama yang mengalir melalui seluruh layer: pemindai pustaka,
/// antrean, pemutar, dan riwayat. Identitasnya [id] — dibuat deterministik
/// dari konten trek (lihat `stableTrackId`), bukan id MediaStore — agar
/// stabil lintas pemindaian.
@freezed
abstract class Track with _$Track {
  /// Membuat entri trek.
  const factory Track({
    /// Identifier unik aplikasi (UUID v4).
    required String id,

    /// Judul trek.
    required String title,

    /// Nama artis; `'<unknown>'` bila tak diketahui.
    required String artist,

    /// Sumber berkas audio.
    required TrackSource source,

    /// Nama album, `null` bila tak diketahui.
    String? album,

    /// Nomor trek dalam album (tag `TRK`), `null` bila tak diketahui.
    /// Dipakai mengurutkan lagu dalam tampilan album (task 3.1).
    int? trackNumber,

    /// Ekstensi berkas audio tanpa titik — mis. `mp3`, `flac`, `opus`.
    /// Dipakai menampilkan codec pada info lagu (task 3.1). Nilai ini
    /// diambil dari MediaStore, bukan nama berkas.
    String? fileExtension,

    /// URI sampul album (content:// dari MediaStore). `null` bila tak ada.
    String? artUri,

    /// Durasi dalam milidetik.
    int? durationMs,

    /// Terakhir diputar — dipakai tab "Putar terakhir" (task 2.6).
    DateTime? lastPlayedAt,
  }) = _Track;

  const Track._();

  /// Nama tampilan singkat: "Artis − Judul".
  String get displayLabel => '$artist − $title';

  /// Nama format untuk tampilan (besar): `MP3`, `FLAC`, dst. `—` bila tak
  /// diketahui.
  String get formatLabel {
    final ext = fileExtension;
    if (ext == null || ext.isEmpty) return '—';
    return ext.toUpperCase();
  }

  /// Absolute path atau `content://` URI berkas audio (v1 selalu lokal).
  String get sourcePath => switch (source) {
    LocalSource(:final filePath) => filePath,
  };

  /// ID MediaStore lagu — dipakai mengambil sampul album lewat
  /// `queryArtwork` (task 3.4). `null` bila trek bukan dari MediaStore
  /// (mis. dipilih via pemilih berkas SAF).
  int? get mediaStoreId => switch (source) {
    LocalSource(:final mediaStoreId) => mediaStoreId,
  };
}
