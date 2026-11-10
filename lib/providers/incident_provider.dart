import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:campusfix/models/app_user.dart';
import 'package:campusfix/models/incident.dart';
import 'package:campusfix/models/incident_category.dart';
import 'package:campusfix/models/incident_draft.dart';
import 'package:campusfix/models/incident_filter.dart';
import 'package:campusfix/models/incident_status.dart';
import 'package:campusfix/models/status_update.dart';
import 'package:campusfix/services/incident_service.dart';
import 'package:campusfix/services/storage_service.dart';

class IncidentProvider extends ChangeNotifier {
  IncidentProvider(this._service, this._storage);

  final IncidentService _service;
  final StorageService _storage;

  StreamSubscription<List<Incident>>? _subscription;
  AppUser? _user;
  List<Incident> _all = const [];
  IncidentFilter _filter = const IncidentFilter();
  bool _loading = false;
  bool _saving = false;
  String? _error;
  final Set<String> _pendingSupport = {};

  List<Incident> get all => _all;
  IncidentFilter get filter => _filter;
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get error => _error;
  AppUser? get user => _user;

  List<Incident> get filtered => _filter.apply(_all);

  List<Incident> get mine {
    final uid = _user?.uid;
    if (uid == null) return const [];
    return _all.where((i) => i.reporterId == uid).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Incident> get needsAttention {
    final open = _all.where((i) => i.status.isOpen).toList();
    open.sort((a, b) {
      final byStatus = a.status.index.compareTo(b.status.index);
      if (byStatus != 0) return byStatus;
      final byPriority = b.priority.index.compareTo(a.priority.index);
      if (byPriority != 0) return byPriority;
      return a.createdAt.compareTo(b.createdAt);
    });
    return open;
  }

  Map<IncidentStatus, int> get statusCounts {
    final counts = {for (final s in IncidentStatus.values) s: 0};
    for (final incident in _all) {
      counts[incident.status] = counts[incident.status]! + 1;
    }
    return counts;
  }

  Map<IncidentCategory, int> get openCategoryCounts {
    final counts = <IncidentCategory, int>{};
    for (final incident in _all.where((i) => i.status.isOpen)) {
      counts[incident.category] = (counts[incident.category] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  bool isSupportPending(String id) => _pendingSupport.contains(id);

  Incident? byId(String id) {
    for (final incident in _all) {
      if (incident.id == id) return incident;
    }
    return null;
  }

  void updateUser(AppUser? user) {
    final sameSession = user?.uid == _user?.uid && user?.role == _user?.role;
    _user = user;
    if (sameSession && (_subscription != null || user == null)) return;

    _subscription?.cancel();
    _subscription = null;
    _all = const [];
    _filter = const IncidentFilter();
    _error = null;

    if (user == null) {
      _loading = false;
      return;
    }

    _loading = true;
    _subscription = _service.watchAll().listen(
      (incidents) {
        _all = incidents;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _loading = false;
        _error = 'Could not load reports. Pull down or try again later.';
        notifyListeners();
      },
    );
  }

  void retry() {
    final user = _user;
    _user = null;
    _subscription?.cancel();
    _subscription = null;
    updateUser(user);
    notifyListeners();
  }

  void setQuery(String query) {
    _filter = _filter.copyWith(query: query);
    notifyListeners();
  }

  void setCategory(IncidentCategory? category) {
    _filter = _filter.copyWith(category: () => category);
    notifyListeners();
  }

  void setStatus(IncidentStatus? status) {
    _filter = _filter.copyWith(status: () => status);
    notifyListeners();
  }

  void setSort(IncidentSort sort) {
    _filter = _filter.copyWith(sort: sort);
    notifyListeners();
  }

  void clearFilters() {
    _filter = IncidentFilter(query: _filter.query, sort: _filter.sort);
    notifyListeners();
  }

  Future<String?> submit(IncidentDraft draft) async {
    final user = _user;
    if (user == null) return 'You need to be signed in.';
    if (user.isStaff) return 'Staff accounts cannot submit student reports.';

    return _guard(() async {
      final id = _service.newId();
      UploadedImage? upload;
      if (draft.image != null) {
        upload = await _storage.uploadIncidentImage(
          incidentId: id,
          file: draft.image!,
        );
      }
      final now = DateTime.now();
      final reporterName = draft.isAnonymous ? '' : user.name;
      final incident = Incident(
        id: id,
        title: draft.title,
        description: draft.description,
        category: draft.category,
        location: draft.location,
        priority: draft.priority,
        status: IncidentStatus.submitted,
        reporterId: user.uid,
        reporterName: reporterName,
        isAnonymous: draft.isAnonymous,
        imageUrl: upload?.url,
        imagePath: upload?.path,
        history: [
          StatusUpdate(
            status: IncidentStatus.submitted,
            note: 'Report submitted',
            byId: user.uid,
            byName: draft.isAnonymous ? 'Reporter' : user.name,
            at: now,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );
      try {
        await _service.create(incident);
      } catch (_) {
        await _storage.deleteImage(upload?.path);
        rethrow;
      }
    });
  }

  Future<String?> update(Incident original, IncidentDraft draft) async {
    final user = _user;
    if (!original.canEdit(user)) {
      return 'Only the reporter can edit a report before staff review it.';
    }

    return _guard(() async {
      String? imageUrl = original.imageUrl;
      String? imagePath = original.imagePath;
      String? oldPathToDelete;

      if (draft.image != null) {
        final upload = await _storage.uploadIncidentImage(
          incidentId: original.id,
          file: draft.image!,
        );
        oldPathToDelete = imagePath;
        imageUrl = upload.url;
        imagePath = upload.path;
      } else if (draft.removeExistingImage) {
        oldPathToDelete = imagePath;
        imageUrl = null;
        imagePath = null;
      }

      await _service.updateDetails(
        id: original.id,
        title: draft.title,
        description: draft.description,
        category: draft.category,
        location: draft.location,
        priority: draft.priority,
        isAnonymous: draft.isAnonymous,
        reporterName: draft.isAnonymous ? '' : user!.name,
        imageUrl: imageUrl,
        imagePath: imagePath,
      );

      if (oldPathToDelete != null) {
        try {
          await _storage.deleteImage(oldPathToDelete);
        } catch (_) {}
      }
    });
  }

  Future<String?> delete(Incident incident) async {
    if (!incident.canDelete(_user)) {
      return 'You do not have permission to delete this report.';
    }
    return _guard(() async {
      await _storage.deleteImage(incident.imagePath);
      await _service.delete(incident.id);
    });
  }

  Future<String?> changeStatus(
    Incident incident,
    IncidentStatus next,
    String note,
  ) async {
    final user = _user;
    if (user == null || !user.isStaff) {
      return 'Only authorised campus staff can update a report status.';
    }
    if (!incident.status.canMoveTo(next)) {
      return 'A report cannot move from ${incident.status.label} '
          'to ${next.label}.';
    }
    if (next.requiresNote && note.trim().length < 5) {
      return 'Add a short reason so the reporter understands the decision.';
    }

    return _guard(() async {
      final entry = StatusUpdate(
        status: next,
        note: note.trim().isEmpty ? 'Status changed to ${next.label}' : note.trim(),
        byId: user.uid,
        byName: user.name,
        at: DateTime.now(),
      );
      await _service.updateStatus(id: incident.id, status: next, entry: entry);
    });
  }

  Future<String?> toggleSupport(Incident incident) async {
    final user = _user;
    if (!incident.canSupport(user)) return null;
    if (_pendingSupport.contains(incident.id)) return null;

    _pendingSupport.add(incident.id);
    notifyListeners();
    try {
      await _service.setSupport(
        id: incident.id,
        uid: user!.uid,
        supported: !incident.isSupportedBy(user.uid),
      );
      return null;
    } on FirebaseException catch (e) {
      return _messageFor(e);
    } catch (_) {
      return 'Could not update. Please try again.';
    } finally {
      _pendingSupport.remove(incident.id);
      notifyListeners();
    }
  }

  Future<String?> _guard(Future<void> Function() action) async {
    _saving = true;
    notifyListeners();
    try {
      await action();
      return null;
    } on FirebaseException catch (e) {
      return _messageFor(e);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  String _messageFor(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
      case 'unauthorized':
        return 'You do not have permission to do that.';
      case 'unavailable':
        return 'The service is unavailable. Check your connection.';
      case 'canceled':
        return 'The upload was cancelled.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
