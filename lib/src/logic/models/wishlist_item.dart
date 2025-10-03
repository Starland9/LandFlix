import 'package:french_stream_downloader/src/logic/models/uqvideo.dart';

/// Modèle représentant un contenu favori enregistré par l’utilisateur.
class WishlistItem {
  final String id;
  final String title;
  final String htmlUrl;
  final String videoUrl;
  final String type;
  final String? imageUrl;
  final String? resolution;
  final String? duration;
  final int sizeInBytes;
  final DateTime addedAt;

  const WishlistItem({
    required this.id,
    required this.title,
    required this.htmlUrl,
    required this.videoUrl,
    required this.type,
    required this.imageUrl,
    required this.resolution,
    required this.duration,
    required this.sizeInBytes,
    required this.addedAt,
  });

  factory WishlistItem.fromUqvideo(Uqvideo video, {DateTime? addedAt}) {
    return WishlistItem(
      id: idFromUrl(video.htmlUrl),
      title: video.title,
      htmlUrl: video.htmlUrl,
      videoUrl: video.url,
      type: video.type,
      imageUrl: video.imageUrl,
      resolution: video.resolution,
      duration: video.duration,
      sizeInBytes: video.sizeInBytes,
      addedAt: addedAt ?? DateTime.now(),
    );
  }

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as String,
      title: json['title'] as String,
      htmlUrl: json['htmlUrl'] as String,
      videoUrl: json['videoUrl'] as String,
      type: json['type'] as String,
      imageUrl: json['imageUrl'] as String?,
      resolution: json['resolution'] as String?,
      duration: json['duration'] as String?,
      sizeInBytes: json['sizeInBytes'] as int,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'htmlUrl': htmlUrl,
      'videoUrl': videoUrl,
      'type': type,
      'imageUrl': imageUrl,
      'resolution': resolution,
      'duration': duration,
      'sizeInBytes': sizeInBytes,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  static String idFromUrl(String url) => url.hashCode.abs().toString();

  WishlistItem copyWith({DateTime? addedAt}) {
    return WishlistItem(
      id: id,
      title: title,
      htmlUrl: htmlUrl,
      videoUrl: videoUrl,
      type: type,
      imageUrl: imageUrl,
      resolution: resolution,
      duration: duration,
      sizeInBytes: sizeInBytes,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
