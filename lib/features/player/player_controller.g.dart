// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Kendali pemutar Lirih (task 2.7) — jembatan antara antrean trek dan
/// mesin DSP native.
///
/// Memegang [PlayerState] sebagai sumber kebenaran tunggal: antrean, trek
/// aktif, status pemutaran, posisi, dan **frekuensi penalaan**. Posisi
/// dijaga tetap mutakhir dengan *polling* periodik (mesin native tidak
/// memancarkan posisi — hanya `completed`/`error`).
///
/// Sementara memakai [DspChannel] (PoC); akan digantikan oleh plugin
/// `lirih_audio` (task 1.x) tanpa mengubah UI.

@ProviderFor(PlayerController)
final playerControllerProvider = PlayerControllerProvider._();

/// Kendali pemutar Lirih (task 2.7) — jembatan antara antrean trek dan
/// mesin DSP native.
///
/// Memegang [PlayerState] sebagai sumber kebenaran tunggal: antrean, trek
/// aktif, status pemutaran, posisi, dan **frekuensi penalaan**. Posisi
/// dijaga tetap mutakhir dengan *polling* periodik (mesin native tidak
/// memancarkan posisi — hanya `completed`/`error`).
///
/// Sementara memakai [DspChannel] (PoC); akan digantikan oleh plugin
/// `lirih_audio` (task 1.x) tanpa mengubah UI.
final class PlayerControllerProvider
    extends $NotifierProvider<PlayerController, PlayerState> {
  /// Kendali pemutar Lirih (task 2.7) — jembatan antara antrean trek dan
  /// mesin DSP native.
  ///
  /// Memegang [PlayerState] sebagai sumber kebenaran tunggal: antrean, trek
  /// aktif, status pemutaran, posisi, dan **frekuensi penalaan**. Posisi
  /// dijaga tetap mutakhir dengan *polling* periodik (mesin native tidak
  /// memancarkan posisi — hanya `completed`/`error`).
  ///
  /// Sementara memakai [DspChannel] (PoC); akan digantikan oleh plugin
  /// `lirih_audio` (task 1.x) tanpa mengubah UI.
  PlayerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerControllerHash();

  @$internal
  @override
  PlayerController create() => PlayerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerState>(value),
    );
  }
}

String _$playerControllerHash() => r'148ea8fec6e6451e2148c64fa97ee46ab7a1be96';

/// Kendali pemutar Lirih (task 2.7) — jembatan antara antrean trek dan
/// mesin DSP native.
///
/// Memegang [PlayerState] sebagai sumber kebenaran tunggal: antrean, trek
/// aktif, status pemutaran, posisi, dan **frekuensi penalaan**. Posisi
/// dijaga tetap mutakhir dengan *polling* periodik (mesin native tidak
/// memancarkan posisi — hanya `completed`/`error`).
///
/// Sementara memakai [DspChannel] (PoC); akan digantikan oleh plugin
/// `lirih_audio` (task 1.x) tanpa mengubah UI.

abstract class _$PlayerController extends $Notifier<PlayerState> {
  PlayerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PlayerState, PlayerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlayerState, PlayerState>,
              PlayerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
