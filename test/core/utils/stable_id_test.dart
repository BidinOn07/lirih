import 'package:flutter_test/flutter_test.dart';

import 'package:lirih/core/utils/stable_id.dart';

void main() {
  group('stableTrackId', () {
    test('deterministik untuk input identik', () {
      const args = (
        filePath: 'content://media/external/audio/media/42',
        title: 'Hingga Ujung Waktu',
        artist: 'Sheila on 7',
        durationMs: 275000,
      );

      final a = stableTrackId(
        filePath: args.filePath,
        title: args.title,
        artist: args.artist,
        durationMs: args.durationMs,
      );
      final b = stableTrackId(
        filePath: args.filePath,
        title: args.title,
        artist: args.artist,
        durationMs: args.durationMs,
      );

      expect(a, b);
    });

    test('berubah bila path berbeda', () {
      final base = stableTrackId(
        filePath: 'content://media/external/audio/media/1',
        title: 'Sampai Jumpa',
        artist: 'BCL',
        durationMs: 1000,
      );
      final other = stableTrackId(
        filePath: 'content://media/external/audio/media/2',
        title: 'Sampai Jumpa',
        artist: 'BCL',
        durationMs: 1000,
      );

      expect(base, isNot(other));
    });

    test('berubah bila judul/artis/durasi berbeda', () {
      final base = stableTrackId(
        filePath: 'p',
        title: 'A',
        artist: 'X',
        durationMs: 1000,
      );

      expect(
        base,
        isNot(
          stableTrackId(
            filePath: 'p',
            title: 'B',
            artist: 'X',
            durationMs: 1000,
          ),
        ),
      );
      expect(
        base,
        isNot(
          stableTrackId(
            filePath: 'p',
            title: 'A',
            artist: 'Y',
            durationMs: 1000,
          ),
        ),
      );
      expect(
        base,
        isNot(
          stableTrackId(filePath: 'p', title: 'A', artist: 'X', durationMs: 2),
        ),
      );
    });

    test('durasi null diperlakukan sama dengan 0', () {
      final withNull = stableTrackId(
        filePath: 'p',
        title: 'A',
        artist: 'X',
        durationMs: null,
      );
      final withZero = stableTrackId(
        filePath: 'p',
        title: 'A',
        artist: 'X',
        durationMs: 0,
      );

      expect(withNull, withZero);
    });

    test('memiliki prefiks local_ (bukan id MediaStore mentah)', () {
      final id = stableTrackId(
        filePath: 'p',
        title: 'A',
        artist: 'X',
        durationMs: 1,
      );

      expect(id, startsWith('local_'));
    });
  });
}
