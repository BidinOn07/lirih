import 'package:flutter/material.dart';

import 'package:lirih/core/constants/app_colors.dart';
import 'package:lirih/domain/entities/track.dart';
import 'package:lirih/shared/widgets/track_artwork.dart';

/// Kartu grid untuk sebuah kelompok (artis/album) — sampul wakili trek
/// pertama, nama kelompok, dan jumlah trek (task 2.5).
///
/// Dipakai oleh grid Pustaka (Artis/Album) maupun grid album di dalam
/// detail artis. Ukuran sampul mengikuti lebar kartu (kotak).
class GroupCard extends StatelessWidget {
  /// Membuat kartu kelompok.
  const GroupCard({
    required this.title,
    required this.subtitle,
    required this.representative,
    required this.onTap,
    super.key,
  });

  /// Nama kelompok (artis/album).
  final String title;

  /// Keterangan di bawah nama (biasanya jumlah trek).
  final String subtitle;

  /// Trek wakil untuk mengambil sampul album.
  final Track representative;

  /// Aksi saat kartu ditekan.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, constraints) => TrackArtwork(
                track: representative,
                size: constraints.maxWidth,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.soga50,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.soga400, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
