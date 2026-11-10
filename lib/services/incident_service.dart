import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:campusfix/core/constants/app_constants.dart';
import 'package:campusfix/models/incident.dart';
import 'package:campusfix/models/incident_category.dart';
import 'package:campusfix/models/incident_priority.dart';
import 'package:campusfix/models/incident_status.dart';
import 'package:campusfix/models/status_update.dart';

class IncidentService {
  IncidentService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _incidents =>
      _db.collection(AppConstants.incidentsCollection);

  String newId() => _incidents.doc().id;

  Stream<List<Incident>> watchAll() {
    return _incidents
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.maxFeedSize)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Incident.fromDoc).toList());
  }

  Future<void> create(Incident incident) {
    return _incidents.doc(incident.id).set(incident.toCreateMap());
  }

  Future<void> updateDetails({
    required String id,
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    required IncidentPriority priority,
    required bool isAnonymous,
    required String reporterName,
    required String? imageUrl,
    required String? imagePath,
  }) {
    return _incidents.doc(id).update({
      'title': title,
      'description': description,
      'category': category.name,
      'location': location,
      'priority': priority.name,
      'isAnonymous': isAnonymous,
      'reporterName': reporterName,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus({
    required String id,
    required IncidentStatus status,
    required StatusUpdate entry,
  }) {
    return _incidents.doc(id).update({
      'status': status.name,
      'history': FieldValue.arrayUnion([entry.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
      'resolvedAt': status == IncidentStatus.resolved
          ? FieldValue.serverTimestamp()
          : null,
    });
  }

  Future<void> setSupport({
    required String id,
    required String uid,
    required bool supported,
  }) {
    return _incidents.doc(id).update({
      'supporters': supported
          ? FieldValue.arrayUnion([uid])
          : FieldValue.arrayRemove([uid]),
    });
  }

  Future<void> delete(String id) => _incidents.doc(id).delete();
}
