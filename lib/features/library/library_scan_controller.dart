import 'package:lirih/core/di/injection.dart';
import 'package:lirih/core/extensions/either_x.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_scan_controller.g.dart';

/// Status pemindaian pustaka (task 1.12) — sumber kebenaran daftar lagu
/// untuk tab Tracks/Home.
///
/// Memuat otomatis saat pertama dibaca (`build`), dan dapat dimuat ulang
/// lewat [rescan] (pull-to-refresh di Tracks). Mengembalikan daftar [Track]
/// atau galat dari MusicLibraryRepository — UI memetakan galat ke
/// *empty state* yang sesuai (task 3.6).
@riverpod
class LibraryScanController extends _$LibraryScanController {
  @override
  FutureOr<List<Track>> build() async {
    final repo = ref.watch(musicLibraryRepositoryProvider);
    final result = await repo.scanLibrary();
    return result.getOrThrow();
  }

  /// Memindai ulang pustaka dari awal (mis. setelah memberikan izin).
  Future<void> rescan() async {
    state = const AsyncLoading();
    final repo = ref.read(musicLibraryRepositoryProvider);
    final result = await repo.scanLibrary();
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      AsyncData<List<Track>>.new,
    );
  }
}
