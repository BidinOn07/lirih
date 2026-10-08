import 'package:dartz/dartz.dart';

import 'package:lirih/core/errors/failures.dart';
import 'package:lirih/domain/entities/track.dart';

/// Kontrak akses ke pustaka musik lokal pengguna (domain layer).
///
/// Implementasi konkret ada di `lib/data/repositories/`
/// (`MusicLibraryRepositoryImpl` memakai `on_audio_query`). Layer domain
/// tidak tahu MediaStore — hanya kontrak ini — sehingga repository dapat
/// diuji dengan mock (lihat TDD §2, clean architecture).
abstract interface class MusicLibraryRepository {
  /// Memindai seluruh audio di perangkat dan mengembalikan daftar [Track].
  ///
  /// Mengembalikan [PermissionDeniedFailure] bila izin belum diberikan,
  /// [EmptyLibraryFailure] bila tidak ada lagu, atau [ScanFailure] bila
  /// MediaStore bermasalah.
  Future<Either<Failure, List<Track>>> scanLibrary();

  /// Memeriksa apakah izin akses media sudah diberikan.
  Future<bool> hasPermission();

  /// Meminta izin akses media. Mengembalikan `true` bila diberikan.
  Future<bool> requestPermission();
}
