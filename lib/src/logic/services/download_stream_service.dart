import 'package:background_downloader/background_downloader.dart' as bd;

/// Service singleton pour gérer le stream des téléchargements
/// Évite le problème "Stream has already been listened to"
class DownloadStreamService {
  static DownloadStreamService? _instance;
  static DownloadStreamService get instance =>
      _instance ??= DownloadStreamService._();

  DownloadStreamService._();

  /// Stream broadcast partagé pour tous les listeners
  late final Stream<bd.TaskUpdate> updates = bd.FileDownloader().updates
      .asBroadcastStream();
}
