// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'injection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sumber data MediaStore (task 1.12). Singleton implisit via Riverpod.

@ProviderFor(mediaStoreScanner)
final mediaStoreScannerProvider = MediaStoreScannerProvider._();

/// Sumber data MediaStore (task 1.12). Singleton implisit via Riverpod.

final class MediaStoreScannerProvider
    extends
        $FunctionalProvider<
          MediaStoreScanner,
          MediaStoreScanner,
          MediaStoreScanner
        >
    with $Provider<MediaStoreScanner> {
  /// Sumber data MediaStore (task 1.12). Singleton implisit via Riverpod.
  MediaStoreScannerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaStoreScannerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaStoreScannerHash();

  @$internal
  @override
  $ProviderElement<MediaStoreScanner> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MediaStoreScanner create(Ref ref) {
    return mediaStoreScanner(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaStoreScanner value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaStoreScanner>(value),
    );
  }
}

String _$mediaStoreScannerHash() => r'1af7a9944c39d813fec6e8b4ead8612de5347e96';

/// Kontrak domain [MusicLibraryRepository] — selalu akses lewat provider ini
/// agar layer presentation tidak bergantung pada implementasi `on_audio_query`.

@ProviderFor(musicLibraryRepository)
final musicLibraryRepositoryProvider = MusicLibraryRepositoryProvider._();

/// Kontrak domain [MusicLibraryRepository] — selalu akses lewat provider ini
/// agar layer presentation tidak bergantung pada implementasi `on_audio_query`.

final class MusicLibraryRepositoryProvider
    extends
        $FunctionalProvider<
          MusicLibraryRepository,
          MusicLibraryRepository,
          MusicLibraryRepository
        >
    with $Provider<MusicLibraryRepository> {
  /// Kontrak domain [MusicLibraryRepository] — selalu akses lewat provider ini
  /// agar layer presentation tidak bergantung pada implementasi `on_audio_query`.
  MusicLibraryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musicLibraryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musicLibraryRepositoryHash();

  @$internal
  @override
  $ProviderElement<MusicLibraryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MusicLibraryRepository create(Ref ref) {
    return musicLibraryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MusicLibraryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MusicLibraryRepository>(value),
    );
  }
}

String _$musicLibraryRepositoryHash() =>
    r'09a20a53972a36721ea331df8564009c7f16daa9';
