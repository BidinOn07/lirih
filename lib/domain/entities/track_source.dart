import 'package:freezed_annotation/freezed_annotation.dart';

part 'track_source.freezed.dart';

/// Sumber sebuah trek — kunci abstraksi domain (TDD §3.1).
///
/// Sebuah trek selalu berasal dari satu sumber. v1 **murni offline** sehingga
/// hanya ada `LocalSource`; tipe *sealed* menjaga agar penambahan sumber
/// baru di masa depan dipaksa eksplisit (compiler memeriksa `switch`
/// lengkap).
@freezed
sealed class TrackSource with _$TrackSource {
  /// Sumber lokal: berkas audio di perangkat pengguna.
  const factory TrackSource.local({
    /// Absolute path atau `content://` URI berkas audio.
    required String filePath,

    /// Durasi dalam milidetik jika diketahui saat pemindaian.
    int? durationMs,

    /// ID MediaStore lagu — dipakai mengambil sampul album via
    /// `on_audio_query.queryArtwork` (task 3.4). `null` bila trek tidak
    /// berasal dari MediaStore (mis. dipilih via SAF).
    int? mediaStoreId,
  }) = LocalSource;
}
