import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uqload_downloader_dart/uqload_downloader_dart.dart';

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
      id: _generateId(originalUrl),
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
  static String _generateId(String url) {
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

/// États possibles des téléchargements
enum DownloadStatus {
  completed,
  failed,
  deleted, // Fichier supprimé mais garde l'historique
}

/// Service de gestion des téléchargements
class DownloadManager {
  static const String _downloadsKey = 'landflix_downloads';
  static const String _downloadedIdsKey = 'landflix_downloaded_ids';

  static DownloadManager? _instance;
  static DownloadManager get instance => _instance ??= DownloadManager._();

  DownloadManager._();

  List<DownloadItem> _downloads = [];
  Set<String> _downloadedIds = {};

  /// Initialise le gestionnaire en chargeant les données
  Future<void> initialize() async {
    await _loadDownloads();
    await _loadDownloadedIds();
  }

  /// Ajoute un téléchargement terminé
  Future<void> addDownload(DownloadItem download) async {
    // Éviter les doublons
    _downloads.removeWhere((item) => item.id == download.id);
    _downloads.insert(0, download); // Ajouter en premier (plus récent)
    _downloadedIds.add(download.id);

    await _saveDownloads();
    await _saveDownloadedIds();
  }

  /// Enregistre un téléchargement terminé depuis les infos UQLoad
  Future<void> recordDownload({
    required VideoInfo videoInfo,
    required String filePath,
    required String originalUrl,
  }) async {
    final download = DownloadItem.fromVideoInfo(
      videoInfo: videoInfo,
      filePath: filePath,
      originalUrl: originalUrl,
    );
    await addDownload(download);
  }

  /// Vérifie si un média est déjà téléchargé
  bool isDownloaded(String url) {
    final id = DownloadItem._generateId(url);
    return _downloadedIds.contains(id);
  }

  /// Récupère les informations d'un téléchargement par URL
  DownloadItem? getDownloadByUrl(String url) {
    final id = DownloadItem._generateId(url);
    try {
      return _downloads.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Liste de tous les téléchargements
  List<DownloadItem> get downloads => List.unmodifiable(_downloads);

  /// Nombre total de téléchargements
  int get totalDownloads => _downloads.length;

  /// Taille totale des téléchargements
  int get totalSize => _downloads.fold(0, (sum, item) => sum + item.fileSize);

  /// Supprime un téléchargement (marque comme supprimé)
  Future<void> removeDownload(String id) async {
    final index = _downloads.indexWhere((item) => item.id == id);
    if (index != -1) {
      final download = _downloads[index];

      // Supprimer le fichier physique si il existe
      final file = File(download.filePath);
      if (file.existsSync()) {
        try {
          await file.delete();
        } catch (e) {
          print("Erreur lors de la suppression du fichier: $e");
        }
      }

      // Marquer comme supprimé au lieu de supprimer complètement
      _downloads[index] = DownloadItem(
        id: download.id,
        title: download.title,
        originalUrl: download.originalUrl,
        filePath: download.filePath,
        fileSize: download.fileSize,
        downloadDate: download.downloadDate,
        thumbnailUrl: download.thumbnailUrl,
        resolution: download.resolution,
        duration: download.duration,
        status: DownloadStatus.deleted,
      );

      // Retirer de la liste des IDs téléchargés
      _downloadedIds.remove(id);

      await _saveDownloads();
      await _saveDownloadedIds();
    }
  }

  /// Nettoie les téléchargements supprimés
  Future<void> cleanupDeletedDownloads() async {
    _downloads.removeWhere((item) => item.status == DownloadStatus.deleted);
    await _saveDownloads();
  }

  /// Vérifie et met à jour le statut des fichiers
  Future<void> refreshFileStatus() async {
    bool hasChanges = false;

    for (int i = 0; i < _downloads.length; i++) {
      final download = _downloads[i];
      if (download.status == DownloadStatus.completed && !download.fileExists) {
        // Fichier supprimé externalement
        _downloads[i] = DownloadItem(
          id: download.id,
          title: download.title,
          originalUrl: download.originalUrl,
          filePath: download.filePath,
          fileSize: download.fileSize,
          downloadDate: download.downloadDate,
          thumbnailUrl: download.thumbnailUrl,
          resolution: download.resolution,
          duration: download.duration,
          status: DownloadStatus.deleted,
        );
        _downloadedIds.remove(download.id);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await _saveDownloads();
      await _saveDownloadedIds();
    }
  }

  /// Charge les téléchargements depuis SharedPreferences
  Future<void> _loadDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloadsJson = prefs.getString(_downloadsKey);

      if (downloadsJson != null) {
        final List<dynamic> downloadsList = jsonDecode(downloadsJson);
        _downloads = downloadsList
            .map((json) => DownloadItem.fromJson(json))
            .toList();
      }
    } catch (e) {
      print("Erreur lors du chargement des téléchargements: $e");
      _downloads = [];
    }
  }

  /// Sauvegarde les téléchargements
  Future<void> _saveDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloadsJson = jsonEncode(
        _downloads.map((d) => d.toJson()).toList(),
      );
      await prefs.setString(_downloadsKey, downloadsJson);
    } catch (e) {
      print("Erreur lors de la sauvegarde des téléchargements: $e");
    }
  }

  /// Charge la liste des IDs téléchargés
  Future<void> _loadDownloadedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_downloadedIdsKey);
      _downloadedIds = ids?.toSet() ?? {};
    } catch (e) {
      print("Erreur lors du chargement des IDs téléchargés: $e");
      _downloadedIds = {};
    }
  }

  /// Sauvegarde les IDs téléchargés
  Future<void> _saveDownloadedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_downloadedIdsKey, _downloadedIds.toList());
    } catch (e) {
      print("Erreur lors de la sauvegarde des IDs téléchargés: $e");
    }
  }
}
