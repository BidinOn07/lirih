// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyrics_panel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Apakah panel lirik sedang ditampilkan di Pemutar (task 3.3).

@ProviderFor(LyricsVisibility)
final lyricsVisibilityProvider = LyricsVisibilityProvider._();

/// Apakah panel lirik sedang ditampilkan di Pemutar (task 3.3).
final class LyricsVisibilityProvider
    extends $NotifierProvider<LyricsVisibility, bool> {
  /// Apakah panel lirik sedang ditampilkan di Pemutar (task 3.3).
  LyricsVisibilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lyricsVisibilityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lyricsVisibilityHash();

  @$internal
  @override
  LyricsVisibility create() => LyricsVisibility();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$lyricsVisibilityHash() => r'daf514eaebd7411b858eaf9c786379caed4e48cc';

/// Apakah panel lirik sedang ditampilkan di Pemutar (task 3.3).

abstract class _$LyricsVisibility extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
