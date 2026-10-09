/// Utilitas impor playlist dari berkas `.m3u`/`.m3u8` (task 3.1).
///
/// Berkas M3U adalah daftar baris: setiap baris adalah path/URI berkas
/// audio, baris kosong dan baris yang diawali `#` (metadata seperti
/// `#EXTM3U`, `#EXTINF`) diabaikan. Karena trek Lirih disimpan dengan
/// path MediaStore (`content://`), pencocokan dilakukan berdasarkan
/// **nama berkas** (basename) — bukan path lengkap yang bisa berbeda.
abstract final class M3uParser {
  /// Memecah [content] menjadi daftar entri (path/URI) non-komentar.
  static List<String> entries(String content) {
    return content
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toList(growable: false);
  }

  /// Nama berkas (basename) dari [pathOrUri], di-decode dan dibuat
  /// *case-insensitive* untuk pencocokan. Aman untuk path biasa maupun
  /// `content://` URI.
  static String basenameOf(String pathOrUri) {
    String decoded;
    try {
      decoded = Uri.decodeComponent(pathOrUri);
    } on Object {
      // Sequence '%' tidak valid — pakai string mentah.
      decoded = pathOrUri;
    }
    final slash = decoded.lastIndexOf('/');
    final name = slash >= 0 ? decoded.substring(slash + 1) : decoded;
    return name.toLowerCase();
  }

  /// Nama playlist dari nama berkas — ekstensi dibuang; fallback bila
  /// nama kosong.
  static String playlistNameFromFileName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    final base = dot >= 0 ? fileName.substring(0, dot) : fileName;
    return base.trim().isEmpty ? 'Playlist diimpor' : base.trim();
  }
}
