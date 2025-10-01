import 'dart:io';

import 'package:uqload_downloader_dart/uqload_downloader_dart.dart';

/// États possibles des téléchargements
enum DownloadStatus {
  completed,
  failed,
  deleted, // Fichier supprimé mais garde l'historique
}

/// Modèle pour représenter un téléchargement
class DownloadItem {
  final String id; // ID unique basé sur l'URL
  final String title;
  final String originalUrl; // URL UQLoad originale
  final String filePath; // Chemin du fichier téléchargé
  final int fileSize; // Taille en bytes
  final DateTime downloadDate;
  final String thumbnailUrl; // URL de l'image de prévisualisation
  final String resolution;
  final String duration;
  final DownloadStatus status;

  DownloadItem({
    required this.id,
    required this.title,
    required this.originalUrl,
    required this.filePath,
    required this.fileSize,
    required this.downloadDate,
    required this.thumbnailUrl,
    required this.resolution,
    required this.duration,
    required this.status,
  });

  /// Crée un DownloadItem à partir des infos vidéo UQLoad
  factory DownloadItem.fromVideoInfo({
    required VideoInfo videoInfo,
    required String filePath,
    required String originalUrl,
  }) {
    return DownloadItem(
      id: generateId(originalUrl),
      title: videoInfo.title,
      originalUrl: originalUrl,
      filePath: filePath,
      fileSize: videoInfo.size,
      downloadDate: DateTime.now(),
      thumbnailUrl: videoInfo.imageUrl,
      resolution: videoInfo.resolution ?? "Unknown",
      duration: videoInfo.duration ?? "Unknown",
      status: DownloadStatus.completed,
    );
  }

  /// Génère un ID unique basé sur l'URL
  static String generateId(String url) {
    return url.hashCode.abs().toString();
  }

  /// Conversion vers JSON pour la persistance
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'originalUrl': originalUrl,
      'filePath': filePath,
      'fileSize': fileSize,
      'downloadDate': downloadDate.toIso8601String(),
      'thumbnailUrl': thumbnailUrl,
      'resolution': resolution,
      'duration': duration,
      'status': status.index,
    };
  }

  /// Création depuis JSON
  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      id: json['id'],
      title: json['title'],
      originalUrl: json['originalUrl'],
      filePath: json['filePath'],
      fileSize: json['fileSize'],
      downloadDate: DateTime.parse(json['downloadDate']),
      thumbnailUrl: json['thumbnailUrl'],
      resolution: json['resolution'],
      duration: json['duration'],
      status: DownloadStatus.values[json['status']],
    );
  }

  /// Vérifie si le fichier existe encore
  bool get fileExists => File(filePath).existsSync();

  /// Taille formatée
  String get formattedSize {
    if (fileSize >= 1024 * 1024 * 1024) {
      return "${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
    } else if (fileSize >= 1024 * 1024) {
      return "${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB";
    } else if (fileSize >= 1024) {
      return "${(fileSize / 1024).toStringAsFixed(1)} KB";
    }
    return "$fileSize B";
  }

  /// Date formatée
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(downloadDate);

    if (difference.inDays > 0) {
      return "${difference.inDays}j";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}min";
    }
    return "Maintenant";
  }
}
