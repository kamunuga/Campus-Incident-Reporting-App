import 'package:flutter/material.dart';

import 'package:campusfix/core/theme/app_colors.dart';
import 'package:campusfix/models/incident_category.dart';
import 'package:campusfix/models/incident_priority.dart';
import 'package:campusfix/models/incident_status.dart';

extension IncidentCategoryVisuals on IncidentCategory {
  IconData get icon => switch (this) {
        IncidentCategory.facilities => Icons.handyman_outlined,
        IncidentCategory.water => Icons.water_drop_outlined,
        IncidentCategory.electricity => Icons.bolt_outlined,
        IncidentCategory.furniture => Icons.chair_outlined,
        IncidentCategory.sanitation => Icons.cleaning_services_outlined,
        IncidentCategory.safety => Icons.shield_outlined,
        IncidentCategory.internet => Icons.wifi_off_outlined,
        IncidentCategory.other => Icons.more_horiz,
      };
}

extension IncidentStatusVisuals on IncidentStatus {
  IconData get icon => switch (this) {
        IncidentStatus.submitted => Icons.outbox_outlined,
        IncidentStatus.underReview => Icons.manage_search_outlined,
        IncidentStatus.inProgress => Icons.construction_outlined,
        IncidentStatus.resolved => Icons.check_circle_outline,
        IncidentStatus.rejected => Icons.block_outlined,
      };

  Color get foreground => switch (this) {
        IncidentStatus.submitted => AppColors.inkMuted,
        IncidentStatus.underReview => AppColors.matcha,
        IncidentStatus.inProgress => AppColors.matchaDeep,
        IncidentStatus.resolved => AppColors.white,
        IncidentStatus.rejected => AppColors.danger,
      };

  Color get background => switch (this) {
        IncidentStatus.submitted => AppColors.surfaceTint,
        IncidentStatus.underReview => AppColors.matchaMist,
        IncidentStatus.inProgress => AppColors.matchaSoft,
        IncidentStatus.resolved => AppColors.matcha,
        IncidentStatus.rejected => AppColors.dangerMist,
      };

  Color get accent => switch (this) {
        IncidentStatus.submitted => AppColors.inkMuted,
        IncidentStatus.underReview => AppColors.matchaBright,
        IncidentStatus.inProgress => AppColors.matcha,
        IncidentStatus.resolved => AppColors.matchaDeep,
        IncidentStatus.rejected => AppColors.danger,
      };
}

extension IncidentPriorityVisuals on IncidentPriority {
  Color get color => switch (this) {
        IncidentPriority.low => AppColors.matchaBright,
        IncidentPriority.medium => AppColors.matchaDeep,
        IncidentPriority.high => AppColors.danger,
      };

  IconData get icon => switch (this) {
        IncidentPriority.low => Icons.keyboard_arrow_down,
        IncidentPriority.medium => Icons.drag_handle,
        IncidentPriority.high => Icons.keyboard_double_arrow_up,
      };
}
