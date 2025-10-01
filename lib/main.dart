import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:french_stream_downloader/src/app.dart';
import 'package:french_stream_downloader/src/core/services/background_download_service.dart';
import 'package:french_stream_downloader/src/logic/repos/uq_repo.dart';
import 'package:french_stream_downloader/src/logic/services/dio_service.dart';
import 'package:french_stream_downloader/src/logic/services/download_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dio = await DioService().init();

  // Initialiser les services
  await DownloadManager.instance.initialize();
  await BackgroundDownloadService().initialize(requestPermissions: false);

  runApp(RepositoryProvider(create: (context) => UqRepo(dio), child: MyApp()));
}
