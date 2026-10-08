// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pengaturan aplikasi yang disimpan permanen (task 5.x).
///
/// Saat ini hanya menyimpan **frekuensi default** — frekuensi penalaan
/// terakhir yang dipakai pemutar, dipulihkan saat aplikasi dibuka kembali.
/// Sama seperti controller Hive lainnya, bersifat *inert* (mengembalikan
/// nilai bawaan [kReferenceFrequencyHz]) bila box belum terbuka.

@ProviderFor(SettingsController)
final settingsControllerProvider = SettingsControllerProvider._();

/// Pengaturan aplikasi yang disimpan permanen (task 5.x).
///
/// Saat ini hanya menyimpan **frekuensi default** — frekuensi penalaan
/// terakhir yang dipakai pemutar, dipulihkan saat aplikasi dibuka kembali.
/// Sama seperti controller Hive lainnya, bersifat *inert* (mengembalikan
/// nilai bawaan [kReferenceFrequencyHz]) bila box belum terbuka.
final class SettingsControllerProvider
    extends $NotifierProvider<SettingsController, double> {
  /// Pengaturan aplikasi yang disimpan permanen (task 5.x).
  ///
  /// Saat ini hanya menyimpan **frekuensi default** — frekuensi penalaan
  /// terakhir yang dipakai pemutar, dipulihkan saat aplikasi dibuka kembali.
  /// Sama seperti controller Hive lainnya, bersifat *inert* (mengembalikan
  /// nilai bawaan [kReferenceFrequencyHz]) bila box belum terbuka.
  SettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsControllerHash();

  @$internal
  @override
  SettingsController create() => SettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$settingsControllerHash() =>
    r'9addd65a9f8d4dfe2881c8a164a613d7b2669478';

/// Pengaturan aplikasi yang disimpan permanen (task 5.x).
///
/// Saat ini hanya menyimpan **frekuensi default** — frekuensi penalaan
/// terakhir yang dipakai pemutar, dipulihkan saat aplikasi dibuka kembali.
/// Sama seperti controller Hive lainnya, bersifat *inert* (mengembalikan
/// nilai bawaan [kReferenceFrequencyHz]) bila box belum terbuka.

abstract class _$SettingsController extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
