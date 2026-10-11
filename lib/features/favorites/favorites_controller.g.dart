// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Trek yang ditandai favorit pengguna (task 3.1) — disimpan di
/// `favoritesBox`.
///
/// Tiap trek disimpan utuh (key = [Track.id], value = map `TrackMapper`)
/// sehingga favorit tetap bisa diputar walau pemindaian MediaStore belum
/// selesai. Sama seperti controller Hive lainnya, controller ini bersifat
/// *inert* bila box belum terbuka — operasi menjadi no-op alih-alih
/// menghempaskan galat.

@ProviderFor(FavoritesController)
final favoritesControllerProvider = FavoritesControllerProvider._();

/// Trek yang ditandai favorit pengguna (task 3.1) — disimpan di
/// `favoritesBox`.
///
/// Tiap trek disimpan utuh (key = [Track.id], value = map `TrackMapper`)
/// sehingga favorit tetap bisa diputar walau pemindaian MediaStore belum
/// selesai. Sama seperti controller Hive lainnya, controller ini bersifat
/// *inert* bila box belum terbuka — operasi menjadi no-op alih-alih
/// menghempaskan galat.
final class FavoritesControllerProvider
    extends $NotifierProvider<FavoritesController, List<Track>> {
  /// Trek yang ditandai favorit pengguna (task 3.1) — disimpan di
  /// `favoritesBox`.
  ///
  /// Tiap trek disimpan utuh (key = [Track.id], value = map `TrackMapper`)
  /// sehingga favorit tetap bisa diputar walau pemindaian MediaStore belum
  /// selesai. Sama seperti controller Hive lainnya, controller ini bersifat
  /// *inert* bila box belum terbuka — operasi menjadi no-op alih-alih
  /// menghempaskan galat.
  FavoritesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesControllerHash();

  @$internal
  @override
  FavoritesController create() => FavoritesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Track> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Track>>(value),
    );
  }
}

String _$favoritesControllerHash() =>
    r'a2412986f6bf3916df7418d2d5a24d42c36b26a9';

/// Trek yang ditandai favorit pengguna (task 3.1) — disimpan di
/// `favoritesBox`.
///
/// Tiap trek disimpan utuh (key = [Track.id], value = map `TrackMapper`)
/// sehingga favorit tetap bisa diputar walau pemindaian MediaStore belum
/// selesai. Sama seperti controller Hive lainnya, controller ini bersifat
/// *inert* bila box belum terbuka — operasi menjadi no-op alih-alih
/// menghempaskan galat.

abstract class _$FavoritesController extends $Notifier<List<Track>> {
  List<Track> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Track>, List<Track>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Track>, List<Track>>,
              List<Track>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
