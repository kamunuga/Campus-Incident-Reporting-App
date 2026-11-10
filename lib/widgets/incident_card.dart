import 'package:flutter/material.dart';

import 'package:campusfix/core/theme/app_colors.dart';
import 'package:campusfix/core/theme/incident_visuals.dart';
import 'package:campusfix/core/utils/formatters.dart';
import 'package:campusfix/models/incident.dart';
import 'package:campusfix/models/incident_priority.dart';
import 'package:campusfix/widgets/badges.dart';
import 'package:campusfix/widgets/incident_thumbnail.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
    this.isMine = false,
  });

  final Incident incident;
  final VoidCallback onTap;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IncidentThumbnail(incident: incident, size: 68),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            incident.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (incident.priority == IncidentPriority.high)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(
                              incident.priority.icon,
                              size: 18,
                              color: incident.priority.color,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          incident.category.icon,
                          size: 14,
                          color: AppColors.matcha,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${incident.category.label}  |  ${incident.location}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.inkMuted,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        StatusChip(status: incident.status, compact: true),
                        if (isMine) ...[
                          const SizedBox(width: 6),
                          const _MineTag(),
                        ],
                        const Spacer(),
                        if (incident.supportCount > 0) ...[
                          const Icon(
                            Icons.people_alt_outlined,
                            size: 15,
                            color: AppColors.inkMuted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${incident.supportCount}',
                            style: const TextStyle(
                              color: AppColors.inkMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          Formatters.timeAgo(incident.createdAt),
                          style: const TextStyle(
                            color: AppColors.inkMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MineTag extends StatelessWidget {
  const _MineTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.matchaSoft),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Yours',
        style: TextStyle(
          color: AppColors.matchaDeep,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
