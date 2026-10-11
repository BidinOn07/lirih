// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_tags_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Perubahan tag yang ditulis pengguna via sheet "Edit info lagu"
/// (task 3.5).
///
/// **Mengapa disimpan terpisah, bukan ditulis ulang ke MediaStore?**
/// Menulis ulang tag ke MediaStore butuh izin tulis media (rumit di
/// Android 13+) dan memaksa rescan penuh. Sebagai gantinya, perubahan
/// disimpan di `trackTagsBox` dengan **key = path sumber trek** — path
/// ini stabil dan tidak berubah saat judul/artis diedit (beda dengan
/// `stableTrackId` yang memuat judul+artis di hash-nya, sehingga id
/// akan berubah dan memutus referensi Hive lain). Saat pemindaian,
/// repository menggabungkan nilai asli dengan override ini.
///
/// Karena box bisa jadi belum terbuka saat provider pertama dibaca,
/// controller bersifat *inert*: operasi menjadi no-op alih-alih
/// menghempaskan galat.

@ProviderFor(TrackTagsController)
final trackTagsControllerProvider = TrackTagsControllerProvider._();

/// Perubahan tag yang ditulis pengguna via sheet "Edit info lagu"
/// (task 3.5).
///
/// **Mengapa disimpan terpisah, bukan ditulis ulang ke MediaStore?**
/// Menulis ulang tag ke MediaStore butuh izin tulis media (rumit di
/// Android 13+) dan memaksa rescan penuh. Sebagai gantinya, perubahan
/// disimpan di `trackTagsBox` dengan **key = path sumber trek** — path
/// ini stabil dan tidak berubah saat judul/artis diedit (beda dengan
/// `stableTrackId` yang memuat judul+artis di hash-nya, sehingga id
/// akan berubah dan memutus referensi Hive lain). Saat pemindaian,
/// repository menggabungkan nilai asli dengan override ini.
///
/// Karena box bisa jadi belum terbuka saat provider pertama dibaca,
/// controller bersifat *inert*: operasi menjadi no-op alih-alih
/// menghempaskan galat.
final class TrackTagsControllerProvider
    extends
        $NotifierProvider<
          TrackTagsController,
          Map<String, Map<String, dynamic>>
        > {
  /// Perubahan tag yang ditulis pengguna via sheet "Edit info lagu"
  /// (task 3.5).
  ///
  /// **Mengapa disimpan terpisah, bukan ditulis ulang ke MediaStore?**
  /// Menulis ulang tag ke MediaStore butuh izin tulis media (rumit di
  /// Android 13+) dan memaksa rescan penuh. Sebagai gantinya, perubahan
  /// disimpan di `trackTagsBox` dengan **key = path sumber trek** — path
  /// ini stabil dan tidak berubah saat judul/artis diedit (beda dengan
  /// `stableTrackId` yang memuat judul+artis di hash-nya, sehingga id
  /// akan berubah dan memutus referensi Hive lain). Saat pemindaian,
  /// repository menggabungkan nilai asli dengan override ini.
  ///
  /// Karena box bisa jadi belum terbuka saat provider pertama dibaca,
  /// controller bersifat *inert*: operasi menjadi no-op alih-alih
  /// menghempaskan galat.
  TrackTagsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackTagsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackTagsControllerHash();

  @$internal
  @override
  TrackTagsController create() => TrackTagsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Map<String, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Map<String, dynamic>>>(
        value,
      ),
    );
  }
}

String _$trackTagsControllerHash() =>
    r'39e464d308b9d15043c38c5ae18d6a387b520f59';

/// Perubahan tag yang ditulis pengguna via sheet "Edit info lagu"
/// (task 3.5).
///
/// **Mengapa disimpan terpisah, bukan ditulis ulang ke MediaStore?**
/// Menulis ulang tag ke MediaStore butuh izin tulis media (rumit di
/// Android 13+) dan memaksa rescan penuh. Sebagai gantinya, perubahan
/// disimpan di `trackTagsBox` dengan **key = path sumber trek** — path
/// ini stabil dan tidak berubah saat judul/artis diedit (beda dengan
/// `stableTrackId` yang memuat judul+artis di hash-nya, sehingga id
/// akan berubah dan memutus referensi Hive lain). Saat pemindaian,
/// repository menggabungkan nilai asli dengan override ini.
///
/// Karena box bisa jadi belum terbuka saat provider pertama dibaca,
/// controller bersifat *inert*: operasi menjadi no-op alih-alih
/// menghempaskan galat.

abstract class _$TrackTagsController
    extends $Notifier<Map<String, Map<String, dynamic>>> {
  Map<String, Map<String, dynamic>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, Map<String, dynamic>>,
              Map<String, Map<String, dynamic>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, Map<String, dynamic>>,
                Map<String, Map<String, dynamic>>
              >,
              Map<String, Map<String, dynamic>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
