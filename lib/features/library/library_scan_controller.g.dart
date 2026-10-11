// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_scan_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Status pemindaian pustaka (task 1.12) — sumber kebenaran daftar lagu
/// untuk tab Tracks/Home.
///
/// Memuat otomatis saat pertama dibaca (`build`), dan dapat dimuat ulang
/// lewat [rescan] (pull-to-refresh di Tracks). Mengembalikan daftar [Track]
/// atau galat dari MusicLibraryRepository — UI memetakan galat ke
/// *empty state* yang sesuai (task 3.6).

@ProviderFor(LibraryScanController)
final libraryScanControllerProvider = LibraryScanControllerProvider._();

/// Status pemindaian pustaka (task 1.12) — sumber kebenaran daftar lagu
/// untuk tab Tracks/Home.
///
/// Memuat otomatis saat pertama dibaca (`build`), dan dapat dimuat ulang
/// lewat [rescan] (pull-to-refresh di Tracks). Mengembalikan daftar [Track]
/// atau galat dari MusicLibraryRepository — UI memetakan galat ke
/// *empty state* yang sesuai (task 3.6).
final class LibraryScanControllerProvider
    extends $AsyncNotifierProvider<LibraryScanController, List<Track>> {
  /// Status pemindaian pustaka (task 1.12) — sumber kebenaran daftar lagu
  /// untuk tab Tracks/Home.
  ///
  /// Memuat otomatis saat pertama dibaca (`build`), dan dapat dimuat ulang
  /// lewat [rescan] (pull-to-refresh di Tracks). Mengembalikan daftar [Track]
  /// atau galat dari MusicLibraryRepository — UI memetakan galat ke
  /// *empty state* yang sesuai (task 3.6).
  LibraryScanControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryScanControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryScanControllerHash();

  @$internal
  @override
  LibraryScanController create() => LibraryScanController();
}

String _$libraryScanControllerHash() =>
    r'79146035b80c9539e86aa25eda91df1861e69672';

/// Status pemindaian pustaka (task 1.12) — sumber kebenaran daftar lagu
/// untuk tab Tracks/Home.
///
/// Memuat otomatis saat pertama dibaca (`build`), dan dapat dimuat ulang
/// lewat [rescan] (pull-to-refresh di Tracks). Mengembalikan daftar [Track]
/// atau galat dari MusicLibraryRepository — UI memetakan galat ke
/// *empty state* yang sesuai (task 3.6).

abstract class _$LibraryScanController extends $AsyncNotifier<List<Track>> {
  FutureOr<List<Track>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Track>>, List<Track>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Track>>, List<Track>>,
              AsyncValue<List<Track>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
