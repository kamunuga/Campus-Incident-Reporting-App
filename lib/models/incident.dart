import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:campusfix/models/app_user.dart';
import 'package:campusfix/models/incident_category.dart';
import 'package:campusfix/models/incident_priority.dart';
import 'package:campusfix/models/incident_status.dart';
import 'package:campusfix/models/status_update.dart';

class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.priority,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.imagePath,
    this.resolvedAt,
    this.supporters = const [],
    this.history = const [],
  });

  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final String location;
  final IncidentPriority priority;
  final IncidentStatus status;
  final String reporterId;
  final String reporterName;
  final bool isAnonymous;
  final String? imageUrl;
  final String? imagePath;
  final List<String> supporters;
  final List<StatusUpdate> history;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  int get supportCount => supporters.length;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  bool isReportedBy(String? uid) => uid != null && uid == reporterId;

  bool isSupportedBy(String? uid) => uid != null && supporters.contains(uid);

  bool canEdit(AppUser? user) =>
      user != null &&
      isReportedBy(user.uid) &&
      status == IncidentStatus.submitted;

  bool canDelete(AppUser? user) =>
      user != null && (user.isStaff || canEdit(user));

  bool canSupport(AppUser? user) =>
      user != null && !user.isStaff && !isReportedBy(user.uid) && status.isOpen;

  String reporterLabelFor(AppUser? viewer) {
    if (isReportedBy(viewer?.uid)) {
      return isAnonymous ? 'You (posted anonymously)' : 'You';
    }
    if (isAnonymous || reporterName.isEmpty) return 'Anonymous';
    return reporterName;
  }

  List<StatusUpdate> get sortedHistory =>
      [...history]..sort((a, b) => a.at.compareTo(b.at));

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Incident.fromMap(doc.id, doc.data() ?? const {});

  factory Incident.fromMap(String id, Map<String, dynamic> map) {
    return Incident(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: IncidentCategory.fromValue(map['category'] as String?),
      location: map['location'] as String? ?? '',
      priority: IncidentPriority.fromValue(map['priority'] as String?),
      status: IncidentStatus.fromValue(map['status'] as String?),
      reporterId: map['reporterId'] as String? ?? '',
      reporterName: map['reporterName'] as String? ?? '',
      isAnonymous: map['isAnonymous'] as bool? ?? false,
      imageUrl: map['imageUrl'] as String?,
      imagePath: map['imagePath'] as String?,
      supporters: List<String>.from(map['supporters'] as List? ?? const []),
      history: (map['history'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => StatusUpdate.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: _toDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: _toDate(map['updatedAt']) ?? DateTime.now(),
      resolvedAt: _toDate(map['resolvedAt']),
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'title': title,
        'description': description,
        'category': category.name,
        'location': location,
        'priority': priority.name,
        'status': status.name,
        'reporterId': reporterId,
        'reporterName': reporterName,
        'isAnonymous': isAnonymous,
        'imageUrl': imageUrl,
        'imagePath': imagePath,
        'supporters': supporters,
        'history': history.map((h) => h.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  static DateTime? _toDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
