import 'package:flutter/material.dart';

import 'package:campusfix/core/theme/app_colors.dart';
import 'package:campusfix/core/theme/incident_visuals.dart';
import 'package:campusfix/models/incident_category.dart';
import 'package:campusfix/models/incident_priority.dart';
import 'package:campusfix/models/incident_status.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.compact = false});

  final IncidentStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(20),
        border: status == IncidentStatus.submitted
            ? Border.all(color: AppColors.border)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: compact ? 14 : 16, color: status.foreground),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: status.foreground,
              fontSize: compact ? 11.5 : 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryLabel extends StatelessWidget {
  const CategoryLabel({super.key, required this.category});

  final IncidentCategory category;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(category.icon, size: 16, color: AppColors.matcha),
        const SizedBox(width: 6),
        Text(
          category.label,
          style: const TextStyle(
            color: AppColors.matchaDeep,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final IncidentPriority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: priority.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(priority.icon, size: 16, color: priority.color),
          const SizedBox(width: 4),
          Text(
            '${priority.label} priority',
            style: TextStyle(
              color: priority.color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.matchaMist,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.matchaDeep,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
