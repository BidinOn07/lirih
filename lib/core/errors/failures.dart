/// Tipe kegagalan domain yang mengalir sebagai `Either<Failure, T>`
/// (dartz) dari layer repository ke presentation — lihat TDD §8.
///
/// Mengimplementasikan [Exception] agar dapat dilempar (`throw failure`) di
/// AsyncNotifier Riverpod tanpa melanggar lint `only_throw_errors`.
sealed class Failure implements Exception {
  /// Membuat kegagalan dengan [message] yang ditampilkan ke pengguna.
  const Failure(this.message);

  /// Pesan galat siap tampil (bahasa pengguna).
  final String message;
}

/// Izin akses media belum diberikan atau dicabut.
class PermissionDeniedFailure extends Failure {
  /// Membuat kegagalan izin.
  const PermissionDeniedFailure([
    super.message = 'Akses ke file audio belum diizinkan.',
  ]);
}

/// Izin diberikan tetapi tidak ada lagu yang ditemukan di perangkat.
class EmptyLibraryFailure extends Failure {
  /// Membuat kegagalan pustaka kosong.
  const EmptyLibraryFailure([
    super.message = 'Tidak ada lagu yang ditemukan di perangkat Anda.',
  ]);
}

/// Kegagalan teknis saat memindai MediaStore (mis. MediaStore bermasalah).
class ScanFailure extends Failure {
  /// Membuat kegagalan pemindaian.
  const ScanFailure([
    super.message = 'Gagal memindai pustaka musik. Coba lagi nanti.',
  ]);
}

/// Berkas yang diputar rusak atau dilindungi DRM.
class UnsupportedMediaFailure extends Failure {
  /// Membuat kegagalan media tidak didukung.
  const UnsupportedMediaFailure([
    super.message = 'Berkas ini tidak dapat diputar.',
  ]);
}
