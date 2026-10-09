import 'package:flutter_test/flutter_test.dart';
import 'package:lirih/core/utils/m3u_parser.dart';

void main() {
  group('M3uParser.entries', () {
    test('mengabaikan baris kosong dan komentar (#)', () {
      const content =
          '#EXTM3U\n'
          '#EXTINF:200,Artis - Judul\n'
          '/music/satu.mp3\n'
          '\n'
          '   \n'
          '# comment\n'
          '/music/dua.flac\n';
      expect(M3uParser.entries(content), [
        '/music/satu.mp3',
        '/music/dua.flac',
      ]);
    });

    test('menangani CRLF', () {
      const content = '#EXTM3U\r\n/music/a.mp3\r\n/music/b.mp3\r\n';
      expect(M3uParser.entries(content).length, 2);
    });

    test('string kosong → list kosong', () {
      expect(M3uParser.entries(''), isEmpty);
    });
  });

  group('M3uParser.basenameOf', () {
    test('mengambil nama berkas dari path biasa (lowercase)', () {
      expect(
        M3uParser.basenameOf('/storage/emulated/0/Music/Lagu.mp3'),
        'lagu.mp3',
      );
    });

    test('memecah encoded content:// URI', () {
      expect(
        M3uParser.basenameOf(
          'content://media/external/audio/media/1/album%20art/Satu%20.mp3',
        ),
        'satu .mp3',
      );
    });

    test('aman untuk sequence % tidak valid', () {
      expect(M3uParser.basenameOf('/music/100% lagu.mp3'), '100% lagu.mp3');
    });

    test('tanpa slash → nama itu sendiri', () {
      expect(M3uParser.basenameOf('lagu.mp3'), 'lagu.mp3');
    });
  });

  group('M3uParser.playlistNameFromFileName', () {
    test('membuang ekstensi', () {
      expect(M3uParser.playlistNameFromFileName('favorit.m3u8'), 'favorit');
    });

    test('nama kosong → fallback', () {
      expect(M3uParser.playlistNameFromFileName('.m3u'), 'Playlist diimpor');
    });
  });
}
