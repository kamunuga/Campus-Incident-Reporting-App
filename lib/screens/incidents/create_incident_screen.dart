import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:campusfix/core/constants/app_constants.dart';
import 'package:campusfix/core/theme/app_colors.dart';
import 'package:campusfix/core/theme/incident_visuals.dart';
import 'package:campusfix/core/utils/app_snack.dart';
import 'package:campusfix/core/utils/validators.dart';
import 'package:campusfix/models/incident.dart';
import 'package:campusfix/models/incident_category.dart';
import 'package:campusfix/models/incident_draft.dart';
import 'package:campusfix/models/incident_priority.dart';
import 'package:campusfix/providers/incident_provider.dart';
import 'package:campusfix/widgets/app_button.dart';
import 'package:campusfix/widgets/app_text_field.dart';
import 'package:campusfix/widgets/common.dart';
import 'package:campusfix/widgets/image_picker_field.dart';

class CreateIncidentScreen extends StatefulWidget {
  const CreateIncidentScreen({super.key, this.existing});

  final Incident? existing;

  @override
  State<CreateIncidentScreen> createState() => _CreateIncidentScreenState();
}

class _CreateIncidentScreenState extends State<CreateIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _description;

  IncidentCategory? _category;
  IncidentPriority _priority = IncidentPriority.medium;
  bool _anonymous = false;
  File? _image;
  bool _removeExisting = false;
  bool _categoryMissing = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _title = TextEditingController(text: existing?.title);
    _location = TextEditingController(text: existing?.location);
    _description = TextEditingController(text: existing?.description);
    if (existing != null) {
      _category = existing.category;
      _priority = existing.priority;
      _anonymous = existing.isAnonymous;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _chooseImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined,
                  color: AppColors.matcha),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.matcha),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (picked == null || !mounted) return;
      final file = File(picked.path);
      final size = await file.length();
      if (!mounted) return;
      if (size > AppConstants.maxImageBytes) {
        AppSnack.error(context, 'That photo is larger than 5 MB.');
        return;
      }
      setState(() {
        _image = file;
        _removeExisting = false;
      });
    } catch (_) {
      if (mounted) {
        AppSnack.error(
          context,
          'Could not open the camera or gallery. Check app permissions.',
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      if (_image != null) {
        _image = null;
      } else {
        _removeExisting = true;
      }
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final formValid = _formKey.currentState!.validate();
    setState(() => _categoryMissing = _category == null);
    if (!formValid || _category == null) {
      AppSnack.error(context, 'Please fix the highlighted fields.');
      return;
    }

    final draft = IncidentDraft(
      title: _title.text.trim(),
      description: _description.text.trim(),
      category: _category!,
      location: _location.text.trim(),
      priority: _priority,
      isAnonymous: _anonymous,
      image: _image,
      removeExistingImage: _removeExisting,
    );

    final provider = context.read<IncidentProvider>();
    final navigator = Navigator.of(context);
    final error = _isEditing
        ? await provider.update(widget.existing!, draft)
        : await provider.submit(draft);
    if (!mounted) return;

    if (error != null) {
      AppSnack.error(context, error);
      return;
    }
    AppSnack.success(
      context,
      _isEditing
          ? 'Report updated.'
          : 'Report submitted. Campus staff have been notified.',
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select<IncidentProvider, bool>((p) => p.isSaving);
    final existingUrl = _removeExisting ? null : widget.existing?.imageUrl;

    return PopScope(
      canPop: !saving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit report' : 'Report an issue'),
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: [
                  const Text(
                    'Tell campus staff what is wrong and where. '
                    'Clear details help them fix it faster.',
                    style: TextStyle(color: AppColors.inkMuted, height: 1.4),
                  ),
                  const SectionHeader(title: 'What happened?'),
                  AppTextField(
                    controller: _title,
                    label: 'Short title',
                    hint: 'e.g. No water in Block C bathrooms',
                    icon: Icons.title,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    validator: Validators.text(field: 'Title', min: 5, max: 80),
                  ),
                  const SectionHeader(title: 'Category'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in IncidentCategory.values)
                        ChoiceChip(
                          avatar: Icon(
                            category.icon,
                            size: 18,
                            color: _category == category
                                ? AppColors.matchaDeep
                                : AppColors.inkMuted,
                          ),
                          label: Text(category.label),
                          showCheckmark: false,
                          selected: _category == category,
                          side: BorderSide(
                            color: _category == category
                                ? AppColors.matcha
                                : _categoryMissing
                                    ? AppColors.danger
                                    : AppColors.border,
                          ),
                          onSelected: (_) => setState(() {
                            _category = category;
                            _categoryMissing = false;
                          }),
                        ),
                    ],
                  ),
                  if (_categoryMissing)
                    const Padding(
                      padding: EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        'Choose a category',
                        style: TextStyle(color: AppColors.danger, fontSize: 12),
                      ),
                    ),
                  const SectionHeader(title: 'Location'),
                  AppTextField(
                    controller: _location,
                    label: 'Where is it?',
                    hint: 'e.g. Main building, 2nd floor, Room 204',
                    icon: Icons.place_outlined,
                    maxLength: 100,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    validator:
                        Validators.text(field: 'Location', min: 3, max: 100),
                  ),
                  const SectionHeader(title: 'How urgent is it?'),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<IncidentPriority>(
                      showSelectedIcon: false,
                      segments: [
                        for (final priority in IncidentPriority.values)
                          ButtonSegment(
                            value: priority,
                            label: Text(priority.label),
                            icon: Icon(priority.icon, size: 18),
                          ),
                      ],
                      selected: {_priority},
                      onSelectionChanged: (value) =>
                          setState(() => _priority = value.first),
                    ),
                  ),
                  const SectionHeader(title: 'Description'),
                  AppTextField(
                    controller: _description,
                    label: 'Describe the problem',
                    hint: 'What did you notice, since when, and who is affected?',
                    maxLines: 5,
                    maxLength: 1000,
                    textCapitalization: TextCapitalization.sentences,
                    validator: Validators.text(
                      field: 'Description',
                      min: 15,
                      max: 1000,
                    ),
                  ),
                  const SectionHeader(title: 'Photo (optional)'),
                  ImagePickerField(
                    file: _image,
                    networkUrl: existingUrl,
                    onPick: _chooseImage,
                    onRemove: _removeImage,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SwitchListTile(
                      value: _anonymous,
                      onChanged: (value) => setState(() => _anonymous = value),
                      title: const Text(
                        'Report anonymously',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Your name is hidden from other students. Campus staff '
                        'can still see it to prevent misuse.',
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: _isEditing ? 'Save changes' : 'Submit report',
                    icon: _isEditing ? Icons.save_outlined : Icons.send_outlined,
                    isLoading: saving,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
            if (saving)
              LoadingOverlay(
                message: _isEditing ? 'Saving changes' : 'Submitting report',
              ),
          ],
        ),
      ),
    );
  }
}
