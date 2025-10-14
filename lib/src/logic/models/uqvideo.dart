class Uqvideo {
  final String? duration;
  final String? imageUrl;
  final String? resolution;
  final String title;
  final String url;
  final String type;
  final String htmlUrl;
  final int sizeInBytes;

  Uqvideo({
    required this.duration,
    required this.imageUrl,
    required this.resolution,
    required this.title,
    required this.url,
    required this.type,
    required this.htmlUrl,
    required this.sizeInBytes,
  });

  factory Uqvideo.fromJson(Map<String, dynamic> json) {
    return Uqvideo(
      duration: json['duration'],
      imageUrl: json['image_url'],
      resolution: json['resolution'],
      title: json['title'],
      url: json['url'],
      type: json['type'],
      htmlUrl: json['html_url'],
      sizeInBytes: json['size_in_bytes'],
    );
  }
}
