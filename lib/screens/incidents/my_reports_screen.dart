import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campusfix/core/routes/app_router.dart';
import 'package:campusfix/models/incident_status.dart';
import 'package:campusfix/providers/incident_provider.dart';
import 'package:campusfix/widgets/common.dart';
import 'package:campusfix/widgets/incident_card.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final mine = provider.mine;
    final open = mine.where((i) => i.status.isOpen).length;
    final resolved =
        mine.where((i) => i.status == IncidentStatus.resolved).length;

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: provider.isLoading
          ? const CenteredLoader()
          : mine.isEmpty
              ? EmptyState(
                  icon: Icons.assignment_outlined,
                  title: 'You have not reported anything yet',
                  message:
                      'Spotted a broken tap, a power cut or a safety risk? '
                      'Tap "Report issue" to let campus staff know.',
                  actionLabel: 'Report an issue',
                  onAction: () => Navigator.of(context)
                      .pushNamed(AppRoutes.createIncident),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  children: [
                    SizedBox(
                      height: 118,
                      child: Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Submitted',
                              value: mine.length,
                              icon: Icons.outbox_outlined,
                              highlight: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              label: 'Open',
                              value: open,
                              icon: Icons.pending_actions_outlined,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              label: 'Resolved',
                              value: resolved,
                              icon: Icons.check_circle_outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SectionHeader(title: 'Your reports'),
                    for (final incident in mine) ...[
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
