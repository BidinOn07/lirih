import 'package:flutter/material.dart';

import 'package:lirih/core/constants/app_motion.dart';

/// [Icon] yang beranimasi (skala + pudar) setiap [icon] berganti.
///
/// Dipakai untuk tombol putar/jeda dan favorit yang sering bertukar wujud
/// ikon. [AnimatedSwitcher] hanya memulai animasi bila [Widget.canUpdate]
/// gagal, sehingga [key] dibuat dari nilai [icon] sendiri — rebuild biasa
/// (mis. pembaruan posisi pemutar tiap tick) tidak memicu animasi ulang.
class SwitchingIcon extends StatelessWidget {
  /// Membuat ikon [icon] dengan warna [color] dan ukuran opsional [size].
  const SwitchingIcon({required this.icon, this.color, this.size, super.key});

  /// Ikon yang ditampilkan; setiap perubahan nilai memicu animasi.
  final IconData icon;

  /// Warna ikon; `null` memakai warna bawaan dari [IconTheme].
  final Color? color;

  /// Ukuran ikon dalam dp; `null` memakai ukuran bawaan dari [IconTheme].
  final double? size;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.fast,
      switchInCurve: AppMotion.easeOut,
      switchOutCurve: AppMotion.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: Icon(
        icon,
        key: ValueKey<IconData>(icon),
        color: color,
        size: size,
      ),
    );
  }
}
