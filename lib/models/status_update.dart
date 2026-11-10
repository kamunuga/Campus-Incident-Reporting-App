import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:campusfix/models/incident_status.dart';

class StatusUpdate {
  const StatusUpdate({
    required this.status,
    required this.note,
    required this.byId,
    required this.byName,
    required this.at,
  });

  final IncidentStatus status;
  final String note;
  final String byId;
  final String byName;
  final DateTime at;

  factory StatusUpdate.fromMap(Map<String, dynamic> map) {
    final at = map['at'];
    return StatusUpdate(
      status: IncidentStatus.fromValue(map['status'] as String?),
      note: map['note'] as String? ?? '',
      byId: map['byId'] as String? ?? '',
      byName: map['byName'] as String? ?? '',
      at: at is Timestamp ? at.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'status': status.name,
        'note': note,
        'byId': byId,
        'byName': byName,
        'at': Timestamp.fromDate(at),
      };
}
