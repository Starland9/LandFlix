import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/routing/app_router.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';
import 'package:google_fonts/google_fonts.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          primary: Colors.blueAccent,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.aBeeZeeTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
    );
  }
}
