import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/routing/app_router.gr.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.router.pushAndPopUntil(
          const HomeRoute(),
          predicate: (route) => false,
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(tag: "icon", child: Image.asset("assets/icon/icon.jpeg")),
            Text("LandPix", style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
