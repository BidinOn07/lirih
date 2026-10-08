import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/library/artwork_provider.dart';

/// Sampul album [track] — memuat byte dari MediaStore (task 3.4).
///
/// Bila trek tidak memiliki sampul (atau belum selesai dimuat), menampilkan
/// placeholder gradien soga→kunir dengan ikon nada — visual identitas Lirih
/// yang tetap rapi untuk seluruh koleksi, termasuk trek tanpa metadata.
class TrackArtwork extends ConsumerWidget {
  /// Membuat sampul album berukuran [size] × [size] (dp).
  const TrackArtwork({required this.track, this.size = 48, super.key});

  /// Trek yang sampulnya ditampilkan.
  final Track track;

  /// Sisi kotak dalam dp.
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = ref.read(artworkCacheProvider.notifier).artworkFor(track);

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.16),
        child: FutureBuilder<Uint8List?>(
          future: future,
          builder: (context, snapshot) {
            final bytes = snapshot.data;
            if (bytes == null || bytes.isEmpty) return _placeholder;
            return Image.memory(
              bytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => _placeholder,
            );
          },
        ),
      ),
    );
  }

  /// Placeholder gradien dengan ikon nada — dipakai saat dimuat/gagal.
  Widget get _placeholder => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.soga700, AppColors.kunir700],
      ),
    ),
    child: Icon(Icons.music_note, color: AppColors.soga50, size: size * 0.5),
  );
}
