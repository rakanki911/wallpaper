class Wallpaper {
  final String id;
  final String imageUrl;
  final String thumbUrl;
  final String description;
  final String photographer;

  Wallpaper({
    required this.id,
    required this.imageUrl,
    required this.thumbUrl,
    required this.description,
    required this.photographer,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['id'],
      imageUrl: json['urls']['regular'],
      thumbUrl: json['urls']['small'],
      description: json['description'] ?? json['alt_description'] ?? '',
      photographer: json['user']['name'] ?? '',
    );
  }
}