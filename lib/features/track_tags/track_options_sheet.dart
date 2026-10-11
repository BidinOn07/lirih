import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/favorites/favorites_controller.dart';
import 'package:lirih/features/library/album_detail_screen.dart';
import 'package:lirih/features/library/artist_detail_screen.dart';
import 'package:lirih/features/library/library_scan_controller.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/features/player/track_info_sheet.dart';
import 'package:lirih/features/playlists/add_to_playlist_sheet.dart';
import 'package:lirih/features/track_tags/edit_track_sheet.dart';
import 'package:lirih/shared/widgets/track_artwork.dart';

/// Membuka *bottom sheet* opsi lengkap untuk [track] (task 3.5).
///
/// Dipanggil dari tombol ⋯ pada baris trek di mana pun di aplikasi, serta
/// dari tombol ⋯ di layar Pemutar. Mencakup: favorit, putar berikutnya,
/// tambah ke antrean, tambah ke playlist, buka artis/album/folder, info
/// lagu, dan edit info lagu (termasuk lirik).
Future<void> showTrackOptionsSheet(BuildContext context, Track track) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.soga850,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _TrackOptionsSheet(track: track),
  );
}

class _TrackOptionsSheet extends ConsumerWidget {
  const _TrackOptionsSheet({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref
        .watch(favoritesControllerProvider)
        .any((favorite) => favorite.id == track.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: sampul + judul + artis.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                TrackArtwork(track: track),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.soga50,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.soga300,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.soga700, height: 20),

          // Aksi utama.
          _OptionTile(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            iconColor: isFavorite ? AppColors.kunir500 : AppColors.soga200,
            title: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
            onTap: () async {
              await ref
                  .read(favoritesControllerProvider.notifier)
                  .toggle(track);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          _OptionTile(
            icon: Icons.play_circle_outline,
            title: 'Putar berikutnya',
            onTap: () async {
              await ref.read(playerControllerProvider.notifier).playNext(track);
              if (!context.mounted) return;
              Navigator.of(context).pop();
              _snack(context, '"${track.title}" diputar berikutnya');
            },
          ),
          _OptionTile(
            icon: Icons.queue_music,
            title: 'Tambahkan ke antrean',
            onTap: () async {
              await ref
                  .read(playerControllerProvider.notifier)
                  .addToQueue(track);
              if (!context.mounted) return;
              Navigator.of(context).pop();
              _snack(context, '"${track.title}" ditambahkan ke antrean');
            },
          ),
          _OptionTile(
            icon: Icons.playlist_add,
            title: 'Tambahkan ke playlist',
            onTap: () {
              Navigator.of(context).pop();
              unawaited(showAddToPlaylistSheet(context, track));
            },
          ),
          const Divider(color: AppColors.soga700, height: 12),

          // Navigasi konteks.
          _OptionTile(
            icon: Icons.person_outline,
            title: 'Buka artis',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ArtistDetailScreen(artist: track.artist),
                ),
              );
            },
          ),
          _OptionTile(
            icon: Icons.album_outlined,
            title: 'Buka album',
            onTap: () {
              Navigator.of(context).pop();
              final library = ref
                  .read(libraryScanControllerProvider)
                  .maybeWhen(data: (tracks) => tracks, orElse: () => <Track>[]);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AlbumDetailScreen(
                    album: track.album ?? 'Tanpa album',
                    tracks: library
                        .where((item) => item.album == track.album)
                        .toList(),
                    artist: track.artist,
                  ),
                ),
              );
            },
          ),
          _OptionTile(
            icon: Icons.folder_outlined,
            title: 'Buka folder',
            enabled: track.folder != null,
            onTap: () {
              Navigator.of(context).pop();
              final library = ref
                  .read(libraryScanControllerProvider)
                  .maybeWhen(data: (tracks) => tracks, orElse: () => <Track>[]);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AlbumDetailScreen(
                    album: track.folder ?? 'Folder',
                    tracks: library
                        .where((item) => item.folder == track.folder)
                        .toList(),
                  ),
                ),
              );
            },
          ),
          const Divider(color: AppColors.soga700, height: 12),

          // Info & edit.
          _OptionTile(
            icon: Icons.info_outline,
            title: 'Info lagu',
            onTap: () {
              Navigator.of(context).pop();
              unawaited(showTrackInfoSheet(context, track));
            },
          ),
          _OptionTile(
            icon: Icons.edit_outlined,
            title: 'Edit info lagu',
            onTap: () {
              Navigator.of(context).pop();
              unawaited(showEditTrackSheet(context, track));
            },
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.soga800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Satu baris opsi pada sheet.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.enabled = true,
  });

  final IconData icon;

  final String title;

  final VoidCallback onTap;

  final Color? iconColor;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.soga50 : AppColors.soga500;
    return ListTile(
      enabled: enabled,
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? AppColors.soga200, size: 22),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color, fontSize: 15),
      ),
    );
  }
}
