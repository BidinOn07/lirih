// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_timer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sleep timer (task 2.9) —menjeda playback otomatis setelah selang waktu.
///
/// Status berupa sisa durasi; `null` berarti timer tidak aktif. Saat habis,
/// playback dijeda lewat [PlayerController.pauseIfPlaying] (frekuensi penalaan
/// tidak direset, sehingga melanjutkan tetap pada 432/528 Hz).

@ProviderFor(SleepTimerController)
final sleepTimerControllerProvider = SleepTimerControllerProvider._();

/// Sleep timer (task 2.9) —menjeda playback otomatis setelah selang waktu.
///
/// Status berupa sisa durasi; `null` berarti timer tidak aktif. Saat habis,
/// playback dijeda lewat [PlayerController.pauseIfPlaying] (frekuensi penalaan
/// tidak direset, sehingga melanjutkan tetap pada 432/528 Hz).
final class SleepTimerControllerProvider
    extends $NotifierProvider<SleepTimerController, Duration?> {
  /// Sleep timer (task 2.9) —menjeda playback otomatis setelah selang waktu.
  ///
  /// Status berupa sisa durasi; `null` berarti timer tidak aktif. Saat habis,
  /// playback dijeda lewat [PlayerController.pauseIfPlaying] (frekuensi penalaan
  /// tidak direset, sehingga melanjutkan tetap pada 432/528 Hz).
  SleepTimerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sleepTimerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sleepTimerControllerHash();

  @$internal
  @override
  SleepTimerController create() => SleepTimerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration?>(value),
    );
  }
}

String _$sleepTimerControllerHash() =>
    r'b082045f9f16c3d19199e4570e2fde6f3eca5144';

/// Sleep timer (task 2.9) —menjeda playback otomatis setelah selang waktu.
///
/// Status berupa sisa durasi; `null` berarti timer tidak aktif. Saat habis,
/// playback dijeda lewat [PlayerController.pauseIfPlaying] (frekuensi penalaan
/// tidak direset, sehingga melanjutkan tetap pada 432/528 Hz).

abstract class _$SleepTimerController extends $Notifier<Duration?> {
  Duration? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Duration?, Duration?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Duration?, Duration?>,
              Duration?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
