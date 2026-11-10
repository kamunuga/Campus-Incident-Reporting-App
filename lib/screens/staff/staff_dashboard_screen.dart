import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campusfix/core/routes/app_router.dart';
import 'package:campusfix/core/theme/app_colors.dart';
import 'package:campusfix/core/theme/incident_visuals.dart';
import 'package:campusfix/models/incident_category.dart';
import 'package:campusfix/models/incident_status.dart';
import 'package:campusfix/providers/incident_provider.dart';
import 'package:campusfix/providers/session_provider.dart';
import 'package:campusfix/widgets/common.dart';
import 'package:campusfix/widgets/incident_card.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key, required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionProvider>().user;
    final provider = context.watch<IncidentProvider>();
    final counts = provider.statusCounts;
    final open = counts[IncidentStatus.submitted]! +
        counts[IncidentStatus.underReview]! +
        counts[IncidentStatus.inProgress]!;
    final attention = provider.needsAttention.take(8).toList();
    final categories = provider.openCategoryCounts;

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Dashboard')),
      body: provider.isLoading
          ? const CenteredLoader()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                Text(
                  'Hello ${user?.firstName ?? ''}, here is what needs '
                  'attention on campus today.',
                  style: const TextStyle(
                    color: AppColors.inkMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.45,
                  children: [
                    StatCard(
                      label: 'Open reports',
                      value: open,
                      icon: Icons.pending_actions_outlined,
                      highlight: true,
                    ),
                    StatCard(
                      label: 'New, not reviewed',
                      value: counts[IncidentStatus.submitted]!,
                      icon: IncidentStatus.submitted.icon,
                    ),
                    StatCard(
                      label: 'In progress',
                      value: counts[IncidentStatus.inProgress]!,
                      icon: IncidentStatus.inProgress.icon,
                    ),
                    StatCard(
                      label: 'Resolved',
                      value: counts[IncidentStatus.resolved]!,
                      icon: IncidentStatus.resolved.icon,
                    ),
                  ],
                ),
                if (categories.isNotEmpty) ...[
                  const SectionHeader(title: 'Open issues by category'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          for (final entry in categories.entries)
                            _CategoryBar(
                              category: entry.key,
                              count: entry.value,
                              total: open,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                SectionHeader(
                  title: 'Needs attention',
                  trailing: TextButton(
                    onPressed: onViewAll,
                    child: const Text('View all'),
                  ),
                ),
                if (attention.isEmpty)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.task_alt, color: AppColors.matcha),
                      title: Text(
                        'All caught up',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text('There are no open reports right now.'),
                    ),
                  )
                else
                  for (final incident in attention) ...[
                    IncidentCard(
                      incident: incident,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.incidentDetail,
                        arguments: incident.id,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.category,
    required this.count,
    required this.total,
  });

  final IncidentCategory category;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(category.icon, size: 18, color: AppColors.matcha),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              category.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: ratio, minHeight: 8),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
