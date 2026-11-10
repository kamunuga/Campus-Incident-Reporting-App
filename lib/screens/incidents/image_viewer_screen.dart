import 'package:flutter/material.dart';

import 'package:campusfix/core/theme/app_colors.dart';

class ImageViewerArgs {
  const ImageViewerArgs({required this.url, required this.heroTag});

  final String url;
  final String heroTag;
}

class ImageViewerScreen extends StatelessWidget {
  const ImageViewerScreen({super.key, required this.args});

  final ImageViewerArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: Hero(
          tag: args.heroTag,
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Image.network(args.url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
