import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
      ),
    );
  }
}
