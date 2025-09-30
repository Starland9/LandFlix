import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/routing/app_router.dart';
import 'package:french_stream_downloader/src/core/themes/app_theme.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _appRouter = AppRouter();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LandFlix',
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter.config(),
      theme: AppTheme.darkTheme,
    );
  }
}
