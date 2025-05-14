class Album {
  final String id;
  final String name;
  final String imageUrl;
  final String artist;

  Album({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.artist,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      name: json['name'],
      imageUrl: json['images']?.isNotEmpty == true ? json['images'][0]['url'] : '',
      artist: json['artists']?.isNotEmpty == true ? json['artists'][0]['name'] : 'Unknown Artist',
    );
  }
}