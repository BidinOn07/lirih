// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_plays_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riwayat trek yang pernah diputar (task 2.6) — disimpan di `recentsBox`.
///
/// Trek terbaru ada di depan, unik per id trek, dibatasi
/// [kMaxRecentPlays] entri. Dipakai tab Home ("Putar terakhir") dan
/// quick-access. Sama seperti SearchHistoryController, controller ini
/// bersifat *inert* bila box belum terbuka (tidak menghemparkan galat).

@ProviderFor(RecentPlaysController)
final recentPlaysControllerProvider = RecentPlaysControllerProvider._();

/// Riwayat trek yang pernah diputar (task 2.6) — disimpan di `recentsBox`.
///
/// Trek terbaru ada di depan, unik per id trek, dibatasi
/// [kMaxRecentPlays] entri. Dipakai tab Home ("Putar terakhir") dan
/// quick-access. Sama seperti SearchHistoryController, controller ini
/// bersifat *inert* bila box belum terbuka (tidak menghemparkan galat).
final class RecentPlaysControllerProvider
    extends $NotifierProvider<RecentPlaysController, List<Track>> {
  /// Riwayat trek yang pernah diputar (task 2.6) — disimpan di `recentsBox`.
  ///
  /// Trek terbaru ada di depan, unik per id trek, dibatasi
  /// [kMaxRecentPlays] entri. Dipakai tab Home ("Putar terakhir") dan
  /// quick-access. Sama seperti SearchHistoryController, controller ini
  /// bersifat *inert* bila box belum terbuka (tidak menghemparkan galat).
  RecentPlaysControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentPlaysControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentPlaysControllerHash();

  @$internal
  @override
  RecentPlaysController create() => RecentPlaysController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Track> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Track>>(value),
    );
  }
}

String _$recentPlaysControllerHash() =>
    r'9f7b17af9770272ea8925ea371f4eb28ac6f3dfd';

/// Riwayat trek yang pernah diputar (task 2.6) — disimpan di `recentsBox`.
///
/// Trek terbaru ada di depan, unik per id trek, dibatasi
/// [kMaxRecentPlays] entri. Dipakai tab Home ("Putar terakhir") dan
/// quick-access. Sama seperti SearchHistoryController, controller ini
/// bersifat *inert* bila box belum terbuka (tidak menghemparkan galat).

abstract class _$RecentPlaysController extends $Notifier<List<Track>> {
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
