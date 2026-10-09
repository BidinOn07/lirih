// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artwork_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cache sampul album dalam memori (task 3.4).
///
/// Byte sampul diambil dari MediaStore via `queryArtwork` (hanya sekali per
/// MediaStore id) dan disimpan sebagai [Future] agar pemanggilan paralel
/// dari beberapa widget (mis. baris daftar + pemutar) tidak memuat berkas
/// yang sama berkali-kali. Trek tanpa id MediaStore (mis. dipilih via SAF)
/// tidak memiliki sampul.

@ProviderFor(ArtworkCache)
final artworkCacheProvider = ArtworkCacheProvider._();

/// Cache sampul album dalam memori (task 3.4).
///
/// Byte sampul diambil dari MediaStore via `queryArtwork` (hanya sekali per
/// MediaStore id) dan disimpan sebagai [Future] agar pemanggilan paralel
/// dari beberapa widget (mis. baris daftar + pemutar) tidak memuat berkas
/// yang sama berkali-kali. Trek tanpa id MediaStore (mis. dipilih via SAF)
/// tidak memiliki sampul.
final class ArtworkCacheProvider
    extends $NotifierProvider<ArtworkCache, Map<int, Future<Uint8List?>>> {
  /// Cache sampul album dalam memori (task 3.4).
  ///
  /// Byte sampul diambil dari MediaStore via `queryArtwork` (hanya sekali per
  /// MediaStore id) dan disimpan sebagai [Future] agar pemanggilan paralel
  /// dari beberapa widget (mis. baris daftar + pemutar) tidak memuat berkas
  /// yang sama berkali-kali. Trek tanpa id MediaStore (mis. dipilih via SAF)
  /// tidak memiliki sampul.
  ArtworkCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'artworkCacheProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$artworkCacheHash();

  @$internal
  @override
  ArtworkCache create() => ArtworkCache();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, Future<Uint8List?>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, Future<Uint8List?>>>(value),
    );
  }
}

String _$artworkCacheHash() => r'b0cc1cbccaca0f85b3c42adde00eec92ce32c2f1';

/// Cache sampul album dalam memori (task 3.4).
///
/// Byte sampul diambil dari MediaStore via `queryArtwork` (hanya sekali per
/// MediaStore id) dan disimpan sebagai [Future] agar pemanggilan paralel
/// dari beberapa widget (mis. baris daftar + pemutar) tidak memuat berkas
/// yang sama berkali-kali. Trek tanpa id MediaStore (mis. dipilih via SAF)
/// tidak memiliki sampul.

abstract class _$ArtworkCache extends $Notifier<Map<int, Future<Uint8List?>>> {
  Map<int, Future<Uint8List?>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<Map<int, Future<Uint8List?>>, Map<int, Future<Uint8List?>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<int, Future<Uint8List?>>,
                Map<int, Future<Uint8List?>>
              >,
              Map<int, Future<Uint8List?>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
