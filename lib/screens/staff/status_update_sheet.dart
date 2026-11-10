import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campusfix/core/theme/app_colors.dart';
import 'package:campusfix/core/theme/incident_visuals.dart';
import 'package:campusfix/core/utils/app_snack.dart';
import 'package:campusfix/models/incident.dart';
import 'package:campusfix/models/incident_status.dart';
import 'package:campusfix/providers/incident_provider.dart';
import 'package:campusfix/providers/session_provider.dart';
import 'package:campusfix/widgets/app_button.dart';
import 'package:campusfix/widgets/app_text_field.dart';
import 'package:campusfix/widgets/badges.dart';

Future<void> showStatusUpdateSheet(BuildContext context, Incident incident) {
  final isStaff = context.read<SessionProvider>().isStaff;
  if (!isStaff) {
    AppSnack.error(context, 'Only authorised campus staff can update status.');
    return Future.value();
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => StatusUpdateSheet(incident: incident),
  );
}

class StatusUpdateSheet extends StatefulWidget {
  const StatusUpdateSheet({super.key, required this.incident});

  final Incident incident;

  @override
  State<StatusUpdateSheet> createState() => _StatusUpdateSheetState();
}

class _StatusUpdateSheetState extends State<StatusUpdateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _note = TextEditingController();
  late IncidentStatus _selected = widget.incident.status.nextStatuses.first;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String? _validateNote(String? value) {
    final text = value?.trim() ?? '';
    if (_selected.requiresNote && text.length < 5) {
      return 'Explain why the report is being rejected';
    }
    if (text.length > 300) return 'Keep the note under 300 characters';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<IncidentProvider>();
    final navigator = Navigator.of(context);
    final error =
        await provider.changeStatus(widget.incident, _selected, _note.text);
    if (!mounted) return;
    if (error != null) {
      AppSnack.error(context, error);
      return;
    }
    navigator.pop();
    AppSnack.success(context, 'Status updated to ${_selected.label}.');
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select<IncidentProvider, bool>((p) => p.isSaving);
    final options = widget.incident.status.nextStatuses;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text(
                  'Current: ',
                  style: TextStyle(color: AppColors.inkMuted),
                ),
                StatusChip(status: widget.incident.status, compact: true),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Move to',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final status in options)
                  ChoiceChip(
                    avatar: Icon(
                      status.icon,
                      size: 18,
                      color: _selected == status
                          ? AppColors.matchaDeep
                          : AppColors.inkMuted,
                    ),
                    label: Text(status.label),
                    showCheckmark: false,
                    selected: _selected == status,
                    side: BorderSide(
                      color: _selected == status
                          ? AppColors.matcha
                          : AppColors.border,
                    ),
                    onSelected: (_) => setState(() => _selected = status),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            AppTextField(
              controller: _note,
              label: _selected.requiresNote
                  ? 'Reason (required)'
                  : 'Note to reporter (optional)',
              hint: 'e.g. Maintenance team assigned, expected fix by Friday',
              icon: Icons.notes_outlined,
              maxLines: 3,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              validator: _validateNote,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Save update',
              icon: Icons.check,
              isLoading: saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
