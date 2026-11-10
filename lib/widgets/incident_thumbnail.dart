import 'package:flutter/material.dart';

import 'package:campusfix/core/theme/app_colors.dart';
import 'package:campusfix/core/theme/incident_visuals.dart';
import 'package:campusfix/models/incident.dart';

class IncidentThumbnail extends StatelessWidget {
  const IncidentThumbnail({super.key, required this.incident, this.size = 64});

  final Incident incident;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: AppColors.matchaMist,
      child: Icon(
        incident.category.icon,
        color: AppColors.matcha,
        size: size * 0.42,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: incident.hasImage
          ? Image.network(
              incident.imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => placeholder,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : placeholder,
            )
          : placeholder,
    );
  }
}
