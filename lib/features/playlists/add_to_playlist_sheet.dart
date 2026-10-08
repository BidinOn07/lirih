import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/domain/entities/playlist.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/playlists/playlist_form_sheet.dart';
import 'package:lirih/features/playlists/playlists_controller.dart';

/// Membuka *bottom sheet* untuk memilih playlist tujuan [track] (task 3.1).
///
/// Menampilkan playlist yang ada (tap = tambah trek) serta opsi membuat
/// playlist baru. Trek duplikat diabaikan controller.
Future<void> showAddToPlaylistSheet(BuildContext context, Track track) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.soga850,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AddToPlaylistSheet(track: track),
  );
}

class _AddToPlaylistSheet extends ConsumerWidget {
  const _AddToPlaylistSheet({required this.track});

  final Track track;

  Future<void> _addTo(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) async {
    await ref
        .read(playlistsControllerProvider.notifier)
        .addTrack(playlist.id, track);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ditambahkan ke "${playlist.name}"'),
          backgroundColor: AppColors.soga800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tambahkan ke playlist',
                style: TextStyle(
                  color: AppColors.soga50,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add, color: AppColors.kunir500),
            title: const Text(
              'Playlist baru',
              style: TextStyle(
                color: AppColors.kunir500,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              final created = await showPlaylistFormSheet(context);
              if (created != null && context.mounted) {
                await _addTo(context, ref, created);
              }
            },
          ),
          const Divider(color: AppColors.soga700, height: 1),
          if (playlists.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Belum ada playlist. Buat satu untuk mulai mengumpulkan '
                'lagu favoritmu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.soga300, fontSize: 14),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.queue_music,
                      color: AppColors.soga200,
                    ),
                    title: Text(
                      playlist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.soga50),
                    ),
                    subtitle: Text(
                      '${playlist.length} trek',
                      style: const TextStyle(
                        color: AppColors.soga400,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () => _addTo(context, ref, playlist),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
