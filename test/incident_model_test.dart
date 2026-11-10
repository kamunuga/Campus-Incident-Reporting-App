import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campusfix/models/app_user.dart';
import 'package:campusfix/models/incident.dart';
import 'package:campusfix/models/incident_category.dart';
import 'package:campusfix/models/incident_filter.dart';
import 'package:campusfix/models/incident_priority.dart';
import 'package:campusfix/models/incident_status.dart';

Incident buildIncident({
  String id = 'a',
  String title = 'No water in Block C',
  IncidentCategory category = IncidentCategory.water,
  IncidentStatus status = IncidentStatus.submitted,
  IncidentPriority priority = IncidentPriority.medium,
  String reporterId = 'student-1',
  bool anonymous = false,
  List<String> supporters = const [],
  DateTime? createdAt,
}) {
  final created = createdAt ?? DateTime(2026, 11, 1);
  return Incident(
    id: id,
    title: title,
    description: 'Taps have been dry since this morning.',
    category: category,
    location: 'Block C',
    priority: priority,
    status: status,
    reporterId: reporterId,
    reporterName: anonymous ? '' : 'Jane Doe',
    isAnonymous: anonymous,
    supporters: supporters,
    createdAt: created,
    updatedAt: created,
  );
}

const student = AppUser(
  uid: 'student-1',
  name: 'Jane Doe',
  email: 'jane@alustudent.com',
  role: UserRole.student,
);
const otherStudent = AppUser(
  uid: 'student-2',
  name: 'John Roe',
  email: 'john@alustudent.com',
  role: UserRole.student,
);
const staff = AppUser(
  uid: 'staff-1',
  name: 'Facilities Team',
  email: 'facilities@alueducation.com',
  role: UserRole.staff,
);

void main() {
  group('Incident permissions', () {
    test('reporter can edit and delete only while submitted', () {
      final submitted = buildIncident();
      final reviewing = buildIncident(status: IncidentStatus.underReview);

      expect(submitted.canEdit(student), isTrue);
      expect(submitted.canDelete(student), isTrue);
      expect(reviewing.canEdit(student), isFalse);
      expect(reviewing.canDelete(student), isFalse);
    });

    test('other students cannot edit, staff can delete', () {
      final incident = buildIncident();
      expect(incident.canEdit(otherStudent), isFalse);
      expect(incident.canDelete(otherStudent), isFalse);
      expect(incident.canEdit(staff), isFalse);
      expect(incident.canDelete(staff), isTrue);
    });

    test('only other students can mark an open report as affecting them', () {
      final incident = buildIncident();
      expect(incident.canSupport(otherStudent), isTrue);
      expect(incident.canSupport(student), isFalse);
      expect(incident.canSupport(staff), isFalse);
      expect(
        buildIncident(status: IncidentStatus.resolved).canSupport(otherStudent),
        isFalse,
      );
    });

    test('anonymous reporter name is hidden from other users', () {
      final incident = buildIncident(anonymous: true);
      expect(incident.reporterLabelFor(otherStudent), 'Anonymous');
      expect(incident.reporterLabelFor(student), 'You (posted anonymously)');
    });
  });

  group('IncidentStatus workflow', () {
    test('allows only defined transitions', () {
      expect(
        IncidentStatus.submitted.canMoveTo(IncidentStatus.underReview),
        isTrue,
      );
      expect(
        IncidentStatus.inProgress.canMoveTo(IncidentStatus.resolved),
        isTrue,
      );
      expect(
        IncidentStatus.resolved.canMoveTo(IncidentStatus.submitted),
        isFalse,
      );
      expect(IncidentStatus.rejected.requiresNote, isTrue);
    });

    test('unknown values fall back safely', () {
      expect(IncidentStatus.fromValue('bogus'), IncidentStatus.submitted);
      expect(IncidentCategory.fromValue(null), IncidentCategory.other);
      expect(IncidentPriority.fromValue('x'), IncidentPriority.medium);
    });
  });

  group('Incident.fromMap', () {
    test('parses Firestore data including history', () {
      final incident = Incident.fromMap('id-1', {
        'title': 'Broken chair',
        'description': 'Leg snapped in the library.',
        'category': 'furniture',
        'location': 'Library',
        'priority': 'high',
        'status': 'inProgress',
        'reporterId': 'student-1',
        'reporterName': 'Jane Doe',
        'isAnonymous': false,
        'supporters': ['student-2'],
        'history': [
          {
            'status': 'submitted',
            'note': 'Report submitted',
            'byId': 'student-1',
            'byName': 'Jane Doe',
            'at': Timestamp.fromDate(DateTime(2026, 11, 1)),
          },
        ],
        'createdAt': Timestamp.fromDate(DateTime(2026, 11, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2026, 11, 2)),
      });

      expect(incident.category, IncidentCategory.furniture);
      expect(incident.priority, IncidentPriority.high);
      expect(incident.status, IncidentStatus.inProgress);
      expect(incident.supportCount, 1);
      expect(incident.history.single.byName, 'Jane Doe');
      expect(incident.hasImage, isFalse);
    });
  });

  group('IncidentFilter', () {
    final items = [
      buildIncident(
        id: '1',
        title: 'Power cut in hostel',
        category: IncidentCategory.electricity,
        createdAt: DateTime(2026, 11, 1),
      ),
      buildIncident(
        id: '2',
        title: 'Dry taps',
        category: IncidentCategory.water,
        status: IncidentStatus.resolved,
        priority: IncidentPriority.high,
        createdAt: DateTime(2026, 11, 3),
      ),
      buildIncident(
        id: '3',
        title: 'Broken desk',
        category: IncidentCategory.furniture,
        supporters: ['x', 'y'],
        createdAt: DateTime(2026, 11, 2),
      ),
    ];

    test('filters by category, status and search text', () {
      expect(
        const IncidentFilter(category: IncidentCategory.water)
            .apply(items)
            .map((i) => i.id),
        ['2'],
      );
      expect(
        const IncidentFilter(status: IncidentStatus.submitted)
            .apply(items)
            .length,
        2,
      );
      expect(
        const IncidentFilter(query: 'HOSTEL').apply(items).single.id,
        '1',
      );
    });

    test('sorts by newest, support and priority', () {
      expect(
        const IncidentFilter().apply(items).map((i) => i.id),
        ['2', '3', '1'],
      );
      expect(
        const IncidentFilter(sort: IncidentSort.mostSupported)
            .apply(items)
            .first
            .id,
        '3',
      );
      expect(
        const IncidentFilter(sort: IncidentSort.priority).apply(items).first.id,
        '2',
      );
    });

    test('copyWith can clear nullable fields', () {
      const filter = IncidentFilter(category: IncidentCategory.water);
      expect(filter.copyWith(category: () => null).category, isNull);
      expect(filter.isActive, isTrue);
    });
  });
}
