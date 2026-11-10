import 'dart:io';

import 'package:campusfix/models/incident_category.dart';
import 'package:campusfix/models/incident_priority.dart';

class IncidentDraft {
  const IncidentDraft({
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.priority,
    required this.isAnonymous,
    this.image,
    this.removeExistingImage = false,
  });

  final String title;
  final String description;
  final IncidentCategory category;
  final String location;
  final IncidentPriority priority;
  final bool isAnonymous;
  final File? image;
  final bool removeExistingImage;
}
