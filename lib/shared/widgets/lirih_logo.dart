import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lirih/core/constants/app_colors.dart';

/// Logo **Lirih** — keluaran task **0N.5**.
///
/// Mark **"Gelombang Lirih"**: monogram huruf **L** yang sayap horizontalnya
/// bergetar menjadi gelombang audio beramplitudo mengecil ke kanan —
/// visualisasi makna *lirih* (suara yang makin halus). Bergradasi
/// [AppColors.kunir500] → [AppColors.nila500], tanda tangan penyetel
/// frekuensi 432 / 528 Hz.
///
/// **100% original** — tidak meniru logo aplikasi musik mana pun.
///
/// Sumber kebenaran geometri: `ignore/tools/generate_lirih_branding.ps1`
/// (yang menghasilkan ikon launcher Android). Konstanta di bawah harus selalu
/// sama dengan script tersebut agar logo dalam aplikasi dan ikon identik.
class LirihLogo extends StatelessWidget {
  /// Membuat logo ukuran [size] × [size].
  const LirihLogo({super.key, this.size = 64});

  /// Sisi logo dalam piksel logis.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GelombangLirihPainter()),
    );
  }
}

/// Melukis mark "Gelombang Lirih" di kanvas kuadrat.
class _GelombangLirihPainter extends CustomPainter {
  // ── Geometri (fraksi canvas) — identik dengan script branding ─────────
  static const double _vx1 = 0.28;
  static const double _vx2 = 0.36;
  static const double _vy1 = 0.28;
  static const double _vy2 = 0.72;
  static const double _wx1 = 0.28;
  static const double _wx2 = 0.72;
  static const double _wymid = 0.72;
  static const double _amp0 = 0.080;
  static const double _amp1 = 0.020;
  static const double _halfThick = 0.040;
  static const double _cycles = 2;

  /// Membentuk path gelombang tertutup (kontur atas → cap kanan membulat →
  /// kontur bawah mundur).
  Path _bangunGelombang(double s) {
    const n = 80;
    final path = Path();
    for (var i = 0; i <= n; i++) {
      final t = i / n;
      final x = (_wx1 + t * (_wx2 - _wx1)) * s;
      // Amplitudo mengecil linier dari [_amp0] ke [_amp1].
      final amp = _amp0 + (_amp1 - _amp0) * t;
      final y = (_wymid - amp * _sin(t)) * s;
      final p = Offset(x, y - _halfThick * s);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    // Ujung kanan membulat (setengah lingkaran).
    path.arcToPoint(
      Offset(_wx2 * s, _wymid * s + _halfThick * s),
      radius: Radius.circular(_halfThick * s),
    );
    // Kontur bawah, ditarik mundur ke kiri.
    for (var i = n; i >= 0; i--) {
      final t = i / n;
      final x = (_wx1 + t * (_wx2 - _wx1)) * s;
      final amp = _amp0 + (_amp1 - _amp0) * t;
      final y = (_wymid - amp * _sin(t)) * s;
      path.lineTo(x, y + _halfThick * s);
    }
    path.close();
    return path;
  }

  /// Satu siklus gelombang: `sin(2π · _cycles · t)`.
  double _sin(double t) => math.sin(2 * math.pi * _cycles * t);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width; // kanvas kuadrat
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(_vx1 * s, 0),
        Offset(_wx2 * s, 0),
        <Color>[AppColors.kunir500, AppColors.nila500],
      )
      ..style = PaintingStyle.fill;

    // Batang vertikal "L" — digambar terpisah lalu digam ulangi dengan
    // kuas gradient yang sama; tidak transparan sehingga hasil visual
    // identik dengan union kedua path.
    canvas
      ..drawRect(Rect.fromLTRB(_vx1 * s, _vy1 * s, _vx2 * s, _vy2 * s), paint)
      ..drawPath(_bangunGelombang(s), paint);
  }

  @override
  bool shouldRepaint(covariant _GelombangLirihPainter oldDelegate) => false;
}
