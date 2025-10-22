import 'dart:developer' as developper;

import 'package:dio/dio.dart';
import 'package:french_stream_downloader/src/core/env/env.dart';
import 'package:french_stream_downloader/src/logic/services/app_infos_service.dart';

class VersionCheckService {
  static final VersionCheckService _instance = VersionCheckService._internal();
  factory VersionCheckService() => _instance;
  VersionCheckService._internal();

  final Dio _dio = Dio(BaseOptions(baseUrl: Env.apiUrl));

  /// Vérifie si une mise à jour est disponible
  /// Retourne true si une mise à jour est nécessaire
  Future<bool> isUpdateAvailable() async {
    try {
      // Récupérer la version actuelle de l'app
      final appInfos = await AppInfosService().packageInfo;
      final currentVersion = appInfos.version;

      // Appeler l'API pour obtenir la dernière version
      final response = await _dio.get("/latest-release");

      if (response.statusCode == 200) {
        final latestVersion =
            response.data['latest_release_version'] as String?;

        if (latestVersion == null) {
          return false;
        }

        // Comparer les versions
        return _compareVersions(currentVersion, latestVersion) < 0;
      }

      return false;
    } catch (e) {
      // En cas d'erreur (pas de connexion, API down, etc.), ne pas bloquer l'utilisateur
      developper.log(
        'Erreur lors de la vérification de version: $e',
        name: runtimeType.toString(),
      );
      return false;
    }
  }

  /// Récupère la dernière version disponible
  Future<String?> getLatestVersion() async {
    try {
      final response = await _dio.get("/latest-release");

      if (response.statusCode == 200) {
        return response.data['latest_release_version'] as String?;
      }

      return null;
    } catch (e) {
      developper.log(
        'Erreur lors de la récupération de la dernière version: $e',
        name: runtimeType.toString(),
      );
      return null;
    }
  }

  /// Compare deux versions (format: x.y.z)
  /// Retourne -1 si v1 < v2, 0 si v1 == v2, 1 si v1 > v2
  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();

    // S'assurer que les deux versions ont le même nombre de parties
    while (parts1.length < parts2.length) {
      parts1.add(0);
    }
    while (parts2.length < parts1.length) {
      parts2.add(0);
    }

    // Comparer chaque partie
    for (int i = 0; i < parts1.length; i++) {
      if (parts1[i] < parts2[i]) {
        return -1;
      } else if (parts1[i] > parts2[i]) {
        return 1;
      }
    }

    return 0;
  }
}
