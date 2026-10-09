import 'package:flutter/material.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/core/utils/duration_format.dart';
import 'package:lirih/domain/entities/track.dart';

/// Membuka *bottom sheet* berisi info trek yang sedang diputar: judul,
/// artis, album, nomor trek, format (codec), dan durasi (task 3.1).
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
class _TrackInfoSheet extends StatelessWidget {
  /// Membuat sheet info untuk [track].
  const _TrackInfoSheet({required this.track});

  /// Trek yang infonya ditampilkan.
  final Track track;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Info lagu',
            style: TextStyle(
              color: AppColors.soga50,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
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
          _InfoRow(label: 'Format', value: track.formatLabel),
          _InfoRow(
            label: 'Durasi',
            value: formatTrackDuration(track.durationMs),
          ),
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
