import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:french_stream_downloader/src/core/routing/app_router.dart';
import 'package:french_stream_downloader/src/core/themes/app_theme.dart';
import 'package:french_stream_downloader/src/logic/cubits/background_download/background_download_cubit.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _appRouter = AppRouter();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BackgroundDownloadCubit()..initialize(),
      child: MaterialApp.router(
        title: 'LandFlix',
        debugShowCheckedModeBanner: false,
        routerConfig: _appRouter.config(),
        theme: AppTheme.darkTheme,
      ),
    );
  }
}
