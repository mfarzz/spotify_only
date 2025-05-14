class Playlist {
  final String id;
  final String name;
  final String imageUrl;

  Playlist({required this.id, required this.name, required this.imageUrl});

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List;
    return Playlist(
      id: json['id'],
      name: json['name'],
      imageUrl: images.isNotEmpty ? images[0]['url'] : '',
    );
  }
}