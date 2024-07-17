class Song {
  final int? id;
  final String? trackName;
  final String? artistName;
  final String? albumName;
  final double? duration;
  final bool? instrumental;
  final String? plainLyrics;
  final String? syncedLyrics;

  const Song({
    this.id,
    this.trackName,
    this.artistName,
    this.albumName,
    this.duration,
    this.instrumental,
    this.plainLyrics,
    this.syncedLyrics,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'trackName': String trackName,
        'artistName': String artistName,
        'albumName': String albumName,
        'duration': double duration,
        'instrumental': bool instrumental,
        'plainLyrics': String plainLyrics,
        'syncedLyrics': String syncedLyrics,
      } =>
        Song(
          id: id,
          trackName: trackName,
          artistName: artistName,
          albumName: albumName,
          duration: duration,
          instrumental: instrumental,
          plainLyrics: plainLyrics,
          syncedLyrics: syncedLyrics,
        ),
      _ => throw const FormatException('Failed to construct song.'),
    };
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'trackName': trackName,
        'artistName': artistName,
        'albumName': albumName,
        'duration': duration,
        'instrumental': instrumental,
        'plainLyrics': plainLyrics,
        'syncedLyrics': syncedLyrics,
      };
}