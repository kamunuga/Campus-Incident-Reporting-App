import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campusfix/core/constants/app_constants.dart';
import 'package:campusfix/core/theme/app_colors.dart';
import 'package:campusfix/core/utils/dialogs.dart';
import 'package:campusfix/core/utils/formatters.dart';
import 'package:campusfix/models/incident_status.dart';
import 'package:campusfix/providers/incident_provider.dart';
import 'package:campusfix/providers/session_provider.dart';
import 'package:campusfix/widgets/app_button.dart';
import 'package:campusfix/widgets/badges.dart';
import 'package:campusfix/widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sign out?',
      message: 'You will need to sign in again to report or track issues.',
      confirmLabel: 'Sign out',
    );
    if (confirmed && context.mounted) {
      await context.read<SessionProvider>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionProvider>().user;
    final incidents = context.watch<IncidentProvider>();
    if (user == null) return const SizedBox.shrink();

    final int first;
    final int second;
    final int third;
    final List<String> labels;

    if (user.isStaff) {
      final updates = incidents.all
          .expand((i) => i.history)
          .where((h) => h.byId == user.uid)
          .toList();
      first = updates.length;
      second = updates.where((h) => h.status == IncidentStatus.resolved).length;
      third = updates.where((h) => h.status == IncidentStatus.rejected).length;
      labels = ['Updates made', 'Resolved', 'Rejected'];
    } else {
      final mine = incidents.mine;
      first = mine.length;
      second = mine.where((i) => i.status.isOpen).length;
      third = mine.where((i) => i.status == IncidentStatus.resolved).length;
      labels = ['Reports', 'Open', 'Resolved'];
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.matcha,
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(color: AppColors.inkMuted),
                ),
                const SizedBox(height: 10),
                RoleBadge(label: user.role.label),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 112,
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: labels[0],
                    value: first,
                    icon: Icons.insights_outlined,
                    highlight: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: labels[1],
                    value: second,
                    icon: user.isStaff
                        ? Icons.check_circle_outline
                        : Icons.pending_actions_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: labels[2],
                    value: third,
                    icon: user.isStaff
                        ? Icons.block_outlined
                        : Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Account'),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.verified_user_outlined,
                    label: 'Email status',
                    value: const Text('Verified ALU account'),
                  ),
                  InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Role',
                    value: Text(user.role.label),
                  ),
                  if (user.createdAt != null)
                    InfoRow(
                      icon: Icons.event_outlined,
                      label: 'Member since',
                      value: Text(Formatters.dateTime(user.createdAt!)),
                    ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'About'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                user.isStaff
                    ? '${AppConstants.appName} staff accounts can review every '
                        'report, move it through the resolution workflow and '
                        'leave notes that reporters can see.'
                    : '${AppConstants.appName} connects students with campus '
                        'administration. Report problems, mark issues that '
                        'affect you too and follow each fix from submission to '
                        'resolution.',
                style: const TextStyle(color: AppColors.inkMuted, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'Sign out',
            icon: Icons.logout,
            variant: AppButtonVariant.outlined,
            onPressed: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
