// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyrics_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Lirik trek yang sedang aktif (task 3.2) — diambil dari frame lirik
/// tertanam (`USLT` di tag ID3v2) lewat parser native (best effort:
/// `null` bila tak ada).
///
/// Status berupa [AsyncValue] `String?`: `loading` saat mengambil,
/// `data(null)` bila trek tak punya lirik. Hasil di-<b>cache</b> per id
/// trek dalam memori. Provider hanya dibangun ulang saat trek aktif
/// berubah (bukan tiap pembaruan posisi).

@ProviderFor(LyricsController)
final lyricsControllerProvider = LyricsControllerProvider._();

/// Lirik trek yang sedang aktif (task 3.2) — diambil dari frame lirik
/// tertanam (`USLT` di tag ID3v2) lewat parser native (best effort:
/// `null` bila tak ada).
///
/// Status berupa [AsyncValue] `String?`: `loading` saat mengambil,
/// `data(null)` bila trek tak punya lirik. Hasil di-<b>cache</b> per id
/// trek dalam memori. Provider hanya dibangun ulang saat trek aktif
/// berubah (bukan tiap pembaruan posisi).
final class LyricsControllerProvider
    extends $AsyncNotifierProvider<LyricsController, String?> {
  /// Lirik trek yang sedang aktif (task 3.2) — diambil dari frame lirik
  /// tertanam (`USLT` di tag ID3v2) lewat parser native (best effort:
  /// `null` bila tak ada).
  ///
  /// Status berupa [AsyncValue] `String?`: `loading` saat mengambil,
  /// `data(null)` bila trek tak punya lirik. Hasil di-<b>cache</b> per id
  /// trek dalam memori. Provider hanya dibangun ulang saat trek aktif
  /// berubah (bukan tiap pembaruan posisi).
  LyricsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lyricsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lyricsControllerHash();

  @$internal
  @override
  LyricsController create() => LyricsController();
}

String _$lyricsControllerHash() => r'17df391f16009ec587752895822e90af40d3c029';

/// Lirik trek yang sedang aktif (task 3.2) — diambil dari frame lirik
/// tertanam (`USLT` di tag ID3v2) lewat parser native (best effort:
/// `null` bila tak ada).
///
/// Status berupa [AsyncValue] `String?`: `loading` saat mengambil,
/// `data(null)` bila trek tak punya lirik. Hasil di-<b>cache</b> per id
/// trek dalam memori. Provider hanya dibangun ulang saat trek aktif
/// berubah (bukan tiap pembaruan posisi).

abstract class _$LyricsController extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
