import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/errors/failures.dart';
import 'package:lirih/core/utils/duration_format.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/library/library_scan_controller.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/shared/widgets/track_artwork.dart';
import 'package:permission_handler/permission_handler.dart';

/// Layar Pustaka — daftar lagu di perangkat pengguna (task 2.5).
///
/// Memuat [LibraryScanController] secara otomatis; memetakan tiap galat ke
/// *empty state* yang sesuai (task 3.6): izin ditolak → tombol buka
/// pengaturan; pustaka kosong → ajakan menyalin musik; galat teknis → coba
/// lagi. Tarik ke bawah untuk memindai ulang.
class LibraryScreen extends ConsumerWidget {
  /// Membuat layar Pustaka.
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scan = ref.watch(libraryScanControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.soga900,
      appBar: AppBar(
        backgroundColor: AppColors.soga800,
        foregroundColor: AppColors.soga50,
        title: const Text('Pustaka'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(libraryScanControllerProvider.notifier).rescan(),
        child: scan.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.kunir500),
          ),
          error: (error, _) => _ErrorState(failure: _asFailure(error)),
          data: (tracks) => _TrackList(tracks: tracks),
        ),
      ),
    );
  }

  /// Mengubah galat AsyncValue menjadi [Failure] (dilempar oleh controller).
  Failure _asFailure(Object error) =>
      error is Failure ? error : const ScanFailure();
}

/// Daftar trek yang dapat diputar.
class _TrackList extends ConsumerWidget {
  const _TrackList({required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tracks.length,
      separatorBuilder: (_, _) =>
          const Divider(color: AppColors.soga700, height: 1),
      itemBuilder: (context, index) {
        final track = tracks[index];
        return _TrackRow(
          track: track,
          onTap: () => ref
              .read(playerControllerProvider.notifier)
              .playTrack(track, queue: tracks),
        );
      },
    );
  }
}

/// Satu baris trek: judul, artis, durasi.
class _TrackRow extends StatelessWidget {
  const _TrackRow({required this.track, required this.onTap});

  final Track track;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: TrackArtwork(track: track),
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.soga50,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        track.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.soga300, fontSize: 13),
      ),
      trailing: Text(
        formatTrackDuration(track.durationMs),
        style: const TextStyle(color: AppColors.soga400, fontSize: 13),
      ),
    );
  }
}

/// Empty/error state sesuai jenis [Failure].
class _ErrorState extends ConsumerWidget {
  const _ErrorState({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPermission = failure is PermissionDeniedFailure;
    final isEmpty = failure is EmptyLibraryFailure;

    return ListView(
      children: [
        const SizedBox(height: 96),
        Icon(
          isPermission
              ? Icons.lock_outline
              : isEmpty
              ? Icons.library_music_outlined
              : Icons.error_outline,
          size: 64,
          color: AppColors.soga400,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            failure.message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.soga200, fontSize: 15),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: FilledButton.icon(
            onPressed: () async {
              if (isPermission) {
                await openAppSettings();
              } else {
                await ref.read(libraryScanControllerProvider.notifier).rescan();
              }
            },
            icon: Icon(isPermission ? Icons.settings : Icons.refresh),
            label: Text(isPermission ? 'Buka pengaturan' : 'Coba lagi'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.kunir600,
              foregroundColor: AppColors.soga50,
            ),
          ),
        ),
      ],
    );
  }
}
