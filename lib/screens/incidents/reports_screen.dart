import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campusfix/core/routes/app_router.dart';
import 'package:campusfix/providers/incident_provider.dart';
import 'package:campusfix/widgets/common.dart';
import 'package:campusfix/widgets/filter_bar.dart';
import 'package:campusfix/widgets/incident_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [SortMenuButton(), SizedBox(width: 4)],
      ),
      body: const Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: IncidentSearchField(),
          ),
          IncidentFilterBar(),
          SizedBox(height: 4),
          Expanded(child: _ReportsList()),
        ],
      ),
    );
  }
}

class _ReportsList extends StatelessWidget {
  const _ReportsList();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final uid = provider.user?.uid;

    if (provider.isLoading) return const CenteredLoader();

    if (provider.error != null) {
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load reports',
        message: provider.error!,
        actionLabel: 'Try again',
        onAction: provider.retry,
      );
    }

    final items = provider.filtered;
    if (items.isEmpty) {
      final filtering = provider.filter.isActive;
      return EmptyState(
        icon: filtering ? Icons.filter_alt_off_outlined : Icons.inbox_outlined,
        title: filtering ? 'No matching reports' : 'No reports yet',
        message: filtering
            ? 'Try a different search or clear the category and status filters.'
            : 'When someone reports a campus issue it will appear here.',
        actionLabel: filtering ? 'Clear filters' : null,
        onAction: filtering ? provider.clearFilters : null,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: items.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            '${items.length} ${items.length == 1 ? 'report' : 'reports'}',
            style: Theme.of(context).textTheme.labelLarge,
          );
        }
        final incident = items[index - 1];
        return IncidentCard(
          incident: incident,
          isMine: incident.isReportedBy(uid),
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.incidentDetail,
            arguments: incident.id,
          ),
        );
      },
    );
  }
}
