import 'package:package_info_plus/package_info_plus.dart';

class AppInfosService {
  static final AppInfosService _instance = AppInfosService._internal();
  factory AppInfosService() => _instance;
  AppInfosService._internal();

  PackageInfo? _packageInfo;

  Future<PackageInfo> get packageInfo async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    return _packageInfo!;
  }

  String? get appName => _packageInfo?.appName;
  String? get packageName => _packageInfo?.packageName;
  String? get version => _packageInfo?.version;
  String? get buildNumber => _packageInfo?.buildNumber;
}
