/// Mode pengurutan daftar lagu di Pustaka (task 2.5).
enum SortMode {
  /// Urutkan berdasarkan judul lagu.
  title,

  /// Urutkan berdasarkan nama artis.
  artist,

  /// Urutkan berdasarkan nama album.
  album,
}

/// Label tiap [SortMode] untuk ditampilkan di UI.
extension SortModeLabel on SortMode {
  /// Label dalam Bahasa Indonesia.
  String get label => switch (this) {
    SortMode.title => 'Judul',
    SortMode.artist => 'Artis',
    SortMode.album => 'Album',
  };
}
