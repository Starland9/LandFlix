import 'package:equatable/equatable.dart';

/// Statut d'un téléchargement
enum DownloadStatus {
  queued,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

/// Extension pour les chaînes de statut
extension DownloadStatusX on DownloadStatus {
  String get displayName {
    switch (this) {
      case DownloadStatus.queued:
        return 'En attente';
      case DownloadStatus.downloading:
        return 'En cours';
      case DownloadStatus.paused:
        return 'En pause';
      case DownloadStatus.completed:
        return 'Terminé';
      case DownloadStatus.failed:
        return 'Échoué';
      case DownloadStatus.cancelled:
        return 'Annulé';
    }
  }

  String get icon {
    switch (this) {
      case DownloadStatus.queued:
        return '⏳';
      case DownloadStatus.downloading:
        return '⬇️';
      case DownloadStatus.paused:
        return '⏸️';
      case DownloadStatus.completed:
        return '✅';
      case DownloadStatus.failed:
        return '❌';
      case DownloadStatus.cancelled:
        return '🚫';
    }
  }
}

/// Élément de téléchargement en arrière-plan
class BackgroundDownloadItem extends Equatable {
  final String id;
  final String url;
  final String title;
  final String fileName;
  final String? outputDir;
  final int notificationId;
  final DownloadStatus status;
  final double progress;
  final String? message;
  final String? filePath;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BackgroundDownloadItem({
    required this.id,
    required this.url,
    required this.title,
    required this.fileName,
    this.outputDir,
    required this.notificationId,
    required this.status,
    this.progress = 0.0,
    this.message,
    this.filePath,
    required this.createdAt,
    this.updatedAt,
  });

  /// Crée une copie avec des modifications
  BackgroundDownloadItem copyWith({
    String? id,
    String? url,
    String? title,
    String? fileName,
    String? outputDir,
    int? notificationId,
    DownloadStatus? status,
    double? progress,
    String? message,
    String? filePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BackgroundDownloadItem(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      outputDir: outputDir ?? this.outputDir,
      notificationId: notificationId ?? this.notificationId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'fileName': fileName,
      'outputDir': outputDir,
      'notificationId': notificationId,
      'status': status.index,
      'progress': progress,
      'message': message,
      'filePath': filePath,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Création depuis JSON
  factory BackgroundDownloadItem.fromJson(Map<String, dynamic> json) {
    return BackgroundDownloadItem(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      fileName: json['fileName'] as String,
      outputDir: json['outputDir'] as String?,
      notificationId: json['notificationId'] as int,
      status: DownloadStatus.values[json['status'] as int],
      progress: (json['progress'] as num).toDouble(),
      message: json['message'] as String?,
      filePath: json['filePath'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
    );
  }

  /// Conversion vers un format compatible avec WorkManager (types primitifs uniquement)
  Map<String, dynamic> toWorkManagerData() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'fileName': fileName,
      'outputDir': outputDir,
      'notificationId': notificationId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Création depuis les données WorkManager avec gestion sécurisée des types
  factory BackgroundDownloadItem.fromWorkManagerData(
    Map<String, dynamic> data,
  ) {
    int parseInt(dynamic value, {int? defaultValue}) {
      if (value == null) {
        return defaultValue ?? 0;
      }

      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? (defaultValue ?? 0);
      }

      return defaultValue ?? 0;
    }

    String? parseString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value.isEmpty ? null : value;
      return value.toString();
    }

    final createdAtMillis = parseInt(
      data['createdAt'],
      defaultValue: DateTime.now().millisecondsSinceEpoch,
    );

    return BackgroundDownloadItem(
      id: parseString(data['id']) ?? 'unknown',
      url: parseString(data['url']) ?? '',
      title: parseString(data['title']) ?? 'Téléchargement',
      fileName: parseString(data['fileName']) ?? 'file.mp4',
      outputDir: parseString(data['outputDir']),
      notificationId: parseInt(data['notificationId']),
      status: DownloadStatus.queued,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
    );
  }

  @override
  List<Object?> get props => [
    id,
    url,
    title,
    fileName,
    outputDir,
    notificationId,
    status,
    progress,
    message,
    filePath,
    createdAt,
    updatedAt,
  ];
}

/// Détails d'un téléchargement préparé
class DownloadDetails extends Equatable {
  final VideoInfo videoInfo;
  final String downloadPath;
  final String fileName;
  final String downloadDir;

  const DownloadDetails({
    required this.videoInfo,
    required this.downloadPath,
    required this.fileName,
    required this.downloadDir,
  });

  @override
  List<Object?> get props => [videoInfo, downloadPath, fileName, downloadDir];
}

/// Informations d'une vidéo
class VideoInfo extends Equatable {
  final String title;
  final String? description;
  final String? duration;
  final String? quality;
  final String? thumbnail;
  final int? size;

  const VideoInfo({
    required this.title,
    this.description,
    this.duration,
    this.quality,
    this.thumbnail,
    this.size,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    duration,
    quality,
    thumbnail,
    size,
  ];
}
