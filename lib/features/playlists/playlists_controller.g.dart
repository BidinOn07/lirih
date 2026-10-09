// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlists_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Daftar putar pengguna (task 3.1) — disimpan di `playlistsBox`.
///
/// Tiap playlist disimpan sebagai satu entri: key = [Playlist.id],
/// value = `{'name': String, 'tracks': List<Map>}` (track di-serialisasi
/// via [TrackMapper]). Controller ini bersifat *inert* bila box belum
/// terbuka — operasi menjadi no-op alih-alih menghempaskan galat.

@ProviderFor(PlaylistsController)
final playlistsControllerProvider = PlaylistsControllerProvider._();

/// Daftar putar pengguna (task 3.1) — disimpan di `playlistsBox`.
///
/// Tiap playlist disimpan sebagai satu entri: key = [Playlist.id],
/// value = `{'name': String, 'tracks': List<Map>}` (track di-serialisasi
/// via [TrackMapper]). Controller ini bersifat *inert* bila box belum
/// terbuka — operasi menjadi no-op alih-alih menghempaskan galat.
final class PlaylistsControllerProvider
    extends $NotifierProvider<PlaylistsController, List<Playlist>> {
  /// Daftar putar pengguna (task 3.1) — disimpan di `playlistsBox`.
  ///
  /// Tiap playlist disimpan sebagai satu entri: key = [Playlist.id],
  /// value = `{'name': String, 'tracks': List<Map>}` (track di-serialisasi
  /// via [TrackMapper]). Controller ini bersifat *inert* bila box belum
  /// terbuka — operasi menjadi no-op alih-alih menghempaskan galat.
  PlaylistsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playlistsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playlistsControllerHash();

  @$internal
  @override
  PlaylistsController create() => PlaylistsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Playlist> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Playlist>>(value),
    );
  }
}

String _$playlistsControllerHash() =>
    r'255c6484cdee2ac23057d3c949c6bd5cff0d4f12';

/// Daftar putar pengguna (task 3.1) — disimpan di `playlistsBox`.
///
/// Tiap playlist disimpan sebagai satu entri: key = [Playlist.id],
/// value = `{'name': String, 'tracks': List<Map>}` (track di-serialisasi
/// via [TrackMapper]). Controller ini bersifat *inert* bila box belum
/// terbuka — operasi menjadi no-op alih-alih menghempaskan galat.

abstract class _$PlaylistsController extends $Notifier<List<Playlist>> {
  List<Playlist> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Playlist>, List<Playlist>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Playlist>, List<Playlist>>,
              List<Playlist>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
