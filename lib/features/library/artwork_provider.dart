import 'dart:typed_data';

import 'package:lirih/core/di/injection.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'artwork_provider.g.dart';

/// Cache sampul album dalam memori (task 3.4).
///
/// Byte sampul diambil dari MediaStore via `queryArtwork` (hanya sekali per
/// MediaStore id) dan disimpan sebagai [Future] agar pemanggilan paralel
/// dari beberapa widget (mis. baris daftar + pemutar) tidak memuat berkas
/// yang sama berkali-kali. Trek tanpa id MediaStore (mis. dipilih via SAF)
/// tidak memiliki sampul.
@riverpod
class ArtworkCache extends _$ArtworkCache {
  @override
  Map<int, Future<Uint8List?>> build() => <int, Future<Uint8List?>>{};

  /// Byte sampul album [track]; `null` bila tidak tersedia.
  Future<Uint8List?> artworkFor(Track track) {
    final id = track.mediaStoreId;
    if (id == null) return Future<Uint8List?>.value();
    return state.putIfAbsent(id, () {
      final scanner = ref.read(mediaStoreScannerProvider);
      return scanner.artworkFor(id);
    });
  }
}
