import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:french_stream_downloader/src/app.dart';
import 'package:french_stream_downloader/src/logic/repos/uq_repo.dart';
import 'package:french_stream_downloader/src/logic/services/dio_service.dart';

void main() async {
  final dio = await DioService().init();

  runApp(RepositoryProvider(create: (context) => UqRepo(dio), child: MyApp()));
}
