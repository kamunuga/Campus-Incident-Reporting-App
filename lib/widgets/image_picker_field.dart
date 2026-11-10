import 'dart:io';

import 'package:flutter/material.dart';

import 'package:campusfix/core/theme/app_colors.dart';

class ImagePickerField extends StatelessWidget {
  const ImagePickerField({
    super.key,
    required this.onPick,
    required this.onRemove,
    this.file,
    this.networkUrl,
  });

  final File? file;
  final String? networkUrl;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  bool get _hasImage =>
      file != null || (networkUrl != null && networkUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    if (!_hasImage) {
      return InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 130,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceTint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.matchaSoft, width: 1.5),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.matcha,
                size: 32,
              ),
              SizedBox(height: 8),
              Text(
                'Add a photo',
                style: TextStyle(
                  color: AppColors.matchaDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Camera or gallery, up to 5 MB',
                style: TextStyle(color: AppColors.inkMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final image = file != null
        ? Image.file(file!, fit: BoxFit.cover)
        : Image.network(networkUrl!, fit: BoxFit.cover);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            Positioned(
              right: 10,
              top: 10,
              child: Row(
                children: [
                  _OverlayButton(
                    icon: Icons.swap_horiz,
                    tooltip: 'Replace photo',
                    onTap: onPick,
                  ),
                  const SizedBox(width: 8),
                  _OverlayButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Remove photo',
                    onTap: onRemove,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      elevation: 1,
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: AppColors.matchaDeep, size: 20),
        onPressed: onTap,
      ),
    );
  }
}
