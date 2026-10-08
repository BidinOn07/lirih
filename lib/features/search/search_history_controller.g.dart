// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riwayat pencarian pengguna (task 3.5) — disimpan di `searchHistoryBox`.
///
/// Entri terbaru ada di depan, unik, dibatasi [kMaxSearchHistory] entri.
/// Karena hanya menyimpan String, tidak butuh adapter Hive kustom.
///
/// Bila box belum terbuka (mis. inisialisasi Hive gagal atau lingkungan
/// test), controller bersifat *inert*: riwayat tetap tampil kosong tanpa
/// menghempaskan galat ke UI — fitur ini bersifat pelengkap, bukan inti.

@ProviderFor(SearchHistoryController)
final searchHistoryControllerProvider = SearchHistoryControllerProvider._();

/// Riwayat pencarian pengguna (task 3.5) — disimpan di `searchHistoryBox`.
///
/// Entri terbaru ada di depan, unik, dibatasi [kMaxSearchHistory] entri.
/// Karena hanya menyimpan String, tidak butuh adapter Hive kustom.
///
/// Bila box belum terbuka (mis. inisialisasi Hive gagal atau lingkungan
/// test), controller bersifat *inert*: riwayat tetap tampil kosong tanpa
/// menghempaskan galat ke UI — fitur ini bersifat pelengkap, bukan inti.
final class SearchHistoryControllerProvider
    extends $NotifierProvider<SearchHistoryController, List<String>> {
  /// Riwayat pencarian pengguna (task 3.5) — disimpan di `searchHistoryBox`.
  ///
  /// Entri terbaru ada di depan, unik, dibatasi [kMaxSearchHistory] entri.
  /// Karena hanya menyimpan String, tidak butuh adapter Hive kustom.
  ///
  /// Bila box belum terbuka (mis. inisialisasi Hive gagal atau lingkungan
  /// test), controller bersifat *inert*: riwayat tetap tampil kosong tanpa
  /// menghempaskan galat ke UI — fitur ini bersifat pelengkap, bukan inti.
  SearchHistoryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchHistoryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHistoryControllerHash();

  @$internal
  @override
  SearchHistoryController create() => SearchHistoryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$searchHistoryControllerHash() =>
    r'c32636d3ebb3d0fc2698a0d2574c5074fafd93d1';

/// Riwayat pencarian pengguna (task 3.5) — disimpan di `searchHistoryBox`.
///
/// Entri terbaru ada di depan, unik, dibatasi [kMaxSearchHistory] entri.
/// Karena hanya menyimpan String, tidak butuh adapter Hive kustom.
///
/// Bila box belum terbuka (mis. inisialisasi Hive gagal atau lingkungan
/// test), controller bersifat *inert*: riwayat tetap tampil kosong tanpa
/// menghempaskan galat ke UI — fitur ini bersifat pelengkap, bukan inti.

abstract class _$SearchHistoryController extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
