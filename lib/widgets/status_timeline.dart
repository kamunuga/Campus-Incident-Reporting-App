import 'package:flutter/material.dart';

import 'package:campusfix/core/theme/app_colors.dart';
import 'package:campusfix/core/theme/incident_visuals.dart';
import 'package:campusfix/core/utils/formatters.dart';
import 'package:campusfix/models/status_update.dart';

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.history});

  final List<StatusUpdate> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Text(
        'No updates yet.',
        style: TextStyle(color: AppColors.inkMuted),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < history.length; i++)
          _TimelineEntry(
            update: history[i],
            isLast: i == history.length - 1,
            isCurrent: i == history.length - 1,
          ),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.update,
    required this.isLast,
    required this.isCurrent,
  });

  final StatusUpdate update;
  final bool isLast;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final color = update.status.accent;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCurrent ? color : AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(
                    update.status.icon,
                    size: 13,
                    color: isCurrent ? AppColors.white : color,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    update.status.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isCurrent ? AppColors.ink : AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${Formatters.dateTime(update.at)}  |  ${update.byName}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  if (update.note.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceTint,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(update.note),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
