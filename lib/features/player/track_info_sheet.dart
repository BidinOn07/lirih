import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/utils/duration_format.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/features/player/player_controller.dart';
import 'package:lirih/features/track_tags/edit_track_sheet.dart';

/// Membuka *bottom sheet* berisi info trek yang sedang diputar: judul,
/// artis, album, nomor trek, format (codec), durasi, frekuensi penalaan
/// aktif, ukuran berkas, nama berkas, dan folder asal (task 3.1 & 3.5).
Future<void> showTrackInfoSheet(BuildContext context, Track track) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.soga850,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _TrackInfoSheet(track: track),
  );
}

/// Isi *bottom sheet* info trek — daftar pasangan label/nilai.
class _TrackInfoSheet extends ConsumerWidget {
  /// Membuat sheet info untuk [track].
  const _TrackInfoSheet({required this.track});

  /// Trek yang infonya ditampilkan.
  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hz = ref.watch(
      playerControllerProvider.select((state) => state.frequencyHz),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Info lagu',
                style: TextStyle(
                  color: AppColors.soga50,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => showEditTrackSheet(context, track),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.kunir500,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.soga700, height: 24),
          _InfoRow(label: 'Judul', value: track.title),
          _InfoRow(label: 'Artis', value: track.artist),
          _InfoRow(label: 'Album', value: track.album ?? '—'),
          _InfoRow(
            label: 'Trek ke-',
            value: track.trackNumber != null
                ? '${track.trackNumber}'
                : 'Tidak diketahui',
          ),
          _InfoRow(
            label: 'Durasi',
            value: formatTrackDuration(track.durationMs),
          ),
          _InfoRow(label: 'Format', value: track.formatLabel),
          _InfoRow(
            label: 'Frekuensi',
            value: '${hz.toStringAsFixed(hz == hz.roundToDouble() ? 0 : 1)} Hz',
          ),
          _InfoRow(label: 'Ukuran', value: track.sizeLabel),
          _InfoRow(label: 'Berkas', value: track.fileName ?? '—'),
          _InfoRow(label: 'Folder', value: track.folder ?? '—'),
        ],
      ),
    );
  }
}

/// Satu baris label/nilai pada sheet info.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  /// Nama field (kiri).
  final String label;

  /// Isi field (kanan).
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.soga300, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.soga50,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
