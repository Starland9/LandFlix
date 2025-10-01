import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:french_stream_downloader/src/app.dart';
import 'package:french_stream_downloader/src/logic/services/download_manager.dart';
import 'package:french_stream_downloader/src/logic/repos/uq_repo.dart';
import 'package:french_stream_downloader/src/logic/services/dio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dio = await DioService().init();
  
  // Initialiser le gestionnaire de téléchargements
  await DownloadManager.instance.initialize();

  runApp(RepositoryProvider(create: (context) => UqRepo(dio), child: MyApp()));
}
