class Track {
  final String name;
  final String artist;
  final String imageUrl;

  Track({required this.name, required this.artist, required this.imageUrl});

  factory Track.fromJson(Map<String, dynamic> json) {
    final track = json['track'];
    final artistNames = (track['artists'] as List)
        .map((artist) => artist['name'])
        .join(', ');
    return Track(
      name: track['name'],
      artist: artistNames,
      imageUrl: track['album']['images'][0]['url'],
    );
  }
}