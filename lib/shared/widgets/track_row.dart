import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/utils/duration_format.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/favorites/favorites_controller.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/features/track_tags/track_options_sheet.dart';
import 'package:lirih/shared/widgets/track_artwork.dart';

/// Baris trek standar — dipakai di Beranda, Pustaka, Cari, dan sheet
/// (task 3.5).
///
/// Menampilkan sampul, judul, artis, dan durasi; mengetuk memutar trek
/// dalam konteks [queue]. Tombol hati menandai/menghapus favorit, dan
/// tombol ⋯ membuka [showTrackOptionsSheet] (putar berikutnya, antrean,
/// playlist, buka artis/album/folder, info, edit).
class TrackRow extends ConsumerWidget {
  /// Membuat baris untuk [track].
  const TrackRow({
    required this.track,
    required this.queue,
    this.onTap,
    super.key,
  });

  /// Trek yang direpresentasikan baris ini.
  final Track track;

  /// Antrean konteks bila trek ini diputar (default: trek tunggal).
  final List<Track> queue;

  /// Override handler ketuk; bila `null`, memutar trek pada [queue].
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref
        .watch(favoritesControllerProvider)
        .any((favorite) => favorite.id == track.id);
    final isCurrent = ref.watch(
      playerControllerProvider.select(
        (state) => state.currentTrack?.id == track.id,
      ),
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      onTap:
          onTap ??
          () => ref
              .read(playerControllerProvider.notifier)
              .playTrack(track, queue: queue),
      leading: TrackArtwork(track: track, size: 44),
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isCurrent ? AppColors.kunir500 : AppColors.soga50,
          fontSize: 15,
          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        track.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.soga300, fontSize: 13),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatTrackDuration(track.durationMs),
            style: const TextStyle(color: AppColors.soga400, fontSize: 13),
          ),
          IconButton(
            tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
            onPressed: () =>
                ref.read(favoritesControllerProvider.notifier).toggle(track),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.kunir500 : AppColors.soga200,
              size: 20,
            ),
          ),
          IconButton(
            tooltip: 'Opsi',
            onPressed: () => showTrackOptionsSheet(context, track),
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.soga200,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
