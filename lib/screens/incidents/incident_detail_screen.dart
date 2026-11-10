import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campusfix/core/routes/app_router.dart';
import 'package:campusfix/core/theme/app_colors.dart';
import 'package:campusfix/core/theme/incident_visuals.dart';
import 'package:campusfix/core/utils/app_snack.dart';
import 'package:campusfix/core/utils/dialogs.dart';
import 'package:campusfix/core/utils/formatters.dart';
import 'package:campusfix/models/app_user.dart';
import 'package:campusfix/models/incident.dart';
import 'package:campusfix/models/incident_status.dart';
import 'package:campusfix/providers/incident_provider.dart';
import 'package:campusfix/providers/session_provider.dart';
import 'package:campusfix/screens/incidents/image_viewer_screen.dart';
import 'package:campusfix/screens/staff/status_update_sheet.dart';
import 'package:campusfix/services/auth_service.dart';
import 'package:campusfix/widgets/app_button.dart';
import 'package:campusfix/widgets/badges.dart';
import 'package:campusfix/widgets/common.dart';
import 'package:campusfix/widgets/status_timeline.dart';

class IncidentDetailScreen extends StatelessWidget {
  const IncidentDetailScreen({super.key, required this.incidentId});

  final String incidentId;

  @override
  Widget build(BuildContext context) {
    final incident =
        context.select<IncidentProvider, Incident?>((p) => p.byId(incidentId));
    final viewer = context.watch<SessionProvider>().user;

    if (incident == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report details')),
        body: EmptyState(
          icon: Icons.search_off_outlined,
          title: 'Report not available',
          message: 'This report may have been removed.',
          actionLabel: 'Go back',
          onAction: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report details'),
        actions: [
          if (incident.canEdit(viewer))
            IconButton(
              tooltip: 'Edit report',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.editIncident,
                arguments: incident,
              ),
            ),
          if (incident.canDelete(viewer))
            IconButton(
              tooltip: 'Delete report',
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () => _delete(context, incident),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          if (incident.hasImage) ...[
            _HeroImage(incident: incident),
            const SizedBox(height: 18),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusChip(status: incident.status),
              PriorityBadge(priority: incident.priority),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            incident.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Column(
                children: [
                  InfoRow(
                    icon: incident.category.icon,
                    label: 'Category',
                    value: Text(incident.category.label),
                  ),
                  InfoRow(
                    icon: Icons.place_outlined,
                    label: 'Location',
                    value: Text(incident.location),
                  ),
                  InfoRow(
                    icon: Icons.person_outline,
                    label: 'Reported by',
                    value: _ReporterName(incident: incident, viewer: viewer),
                  ),
                  InfoRow(
                    icon: Icons.schedule_outlined,
                    label: 'Reported on',
                    value: Text(Formatters.dateTime(incident.createdAt)),
                  ),
                  if (incident.supportCount > 0)
                    InfoRow(
                      icon: Icons.people_alt_outlined,
                      label: 'Also affected',
                      value: Text(
                        '${incident.supportCount} '
                        '${incident.supportCount == 1 ? 'person' : 'people'}',
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Description'),
          Text(
            incident.description,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          const SectionHeader(title: 'Progress'),
          StatusTimeline(history: incident.sortedHistory),
          if (incident.isReportedBy(viewer?.uid) &&
              incident.status == IncidentStatus.submitted) ...[
            const SizedBox(height: 20),
            const _Notice(
              text: 'You can edit or delete this report until campus staff '
                  'start reviewing it.',
            ),
          ],
        ],
      ),
      bottomNavigationBar: _BottomAction(incident: incident, viewer: viewer),
    );
  }

  Future<void> _delete(BuildContext context, Incident incident) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete report?',
      message: 'This permanently removes "${incident.title}" and its photo.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final navigator = Navigator.of(context);
    final error = await context.read<IncidentProvider>().delete(incident);
    if (!context.mounted) return;
    if (error != null) {
      AppSnack.error(context, error);
    } else {
      AppSnack.success(context, 'Report deleted.');
      navigator.pop();
    }
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final tag = 'incident-image-${incident.id}';
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.imageViewer,
        arguments: ImageViewerArgs(url: incident.imageUrl!, heroTag: tag),
      ),
      child: Hero(
        tag: tag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Image.network(
              incident.imageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const ColoredBox(
                      color: AppColors.matchaMist,
                      child: CenteredLoader(),
                    ),
              errorBuilder: (context, error, stack) => const ColoredBox(
                color: AppColors.matchaMist,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.matcha,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReporterName extends StatefulWidget {
  const _ReporterName({required this.incident, required this.viewer});

  final Incident incident;
  final AppUser? viewer;

  @override
  State<_ReporterName> createState() => _ReporterNameState();
}

class _ReporterNameState extends State<_ReporterName> {
  Future<AppUser?>? _reporter;

  bool get _staffViewingAnonymous =>
      (widget.viewer?.isStaff ?? false) &&
      widget.incident.isAnonymous &&
      !widget.incident.isReportedBy(widget.viewer?.uid);

  @override
  void initState() {
    super.initState();
    if (_staffViewingAnonymous) {
      _reporter =
          context.read<AuthService>().fetchProfile(widget.incident.reporterId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_staffViewingAnonymous || _reporter == null) {
      return Text(widget.incident.reporterLabelFor(widget.viewer));
    }

    return FutureBuilder<AppUser?>(
      future: _reporter,
      builder: (context, snapshot) {
        final name = snapshot.data?.name;
        return Text(
          name == null ? 'Anonymous' : 'Anonymous to students ($name)',
        );
      },
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.matchaMist,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.matcha),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.matchaDeep, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.incident, required this.viewer});

  final Incident incident;
  final AppUser? viewer;

  @override
  Widget build(BuildContext context) {
    final user = viewer;
    if (user == null) return const SizedBox.shrink();

    Widget? action;
    if (user.isStaff) {
      action = AppButton(
        label: 'Update status',
        icon: Icons.published_with_changes,
        onPressed: () => showStatusUpdateSheet(context, incident),
      );
    } else if (incident.canSupport(user)) {
      final supported = incident.isSupportedBy(user.uid);
      final pending = context.select<IncidentProvider, bool>(
        (p) => p.isSupportPending(incident.id),
      );
      action = AppButton(
        label: supported
            ? 'You are affected too (${incident.supportCount})'
            : 'This affects me too',
        icon: supported ? Icons.check : Icons.people_alt_outlined,
        variant:
            supported ? AppButtonVariant.outlined : AppButtonVariant.filled,
        isLoading: pending,
        onPressed: () async {
          final error =
              await context.read<IncidentProvider>().toggleSupport(incident);
          if (error != null && context.mounted) AppSnack.error(context, error);
        },
      );
    }

    if (action == null) return const SizedBox.shrink();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: action,
      ),
    );
  }
}
