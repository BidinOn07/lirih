import 'package:dartz/dartz.dart';

import 'package:lirih/core/errors/failures.dart';

/// Ekstensi utilitas untuk `Either<Failure, R>` dartz (TDD §8).
///
/// Spesifik pada [Failure] (bukan generik `L`) agar nilai kiri yang dilempar
/// selalu bertipe [Exception] — memenuhi lint `only_throw_errors`.
extension EitherX<R> on Either<Failure, R> {
  /// Mengembalikan nilai kanan atau melempar nilai kiri sebagai galat.
  ///
  /// Dipakai di AsyncNotifier Riverpod: `build`/`state` butuh nilai murni,
  /// sedangkan galat harus dilempar agar tertangkap sebagai `AsyncError`
  /// (yang ditampilkan sebagai *error state* di UI).
  R getOrThrow() => fold((l) => throw l, (r) => r);
}
