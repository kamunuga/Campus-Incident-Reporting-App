import 'package:campusfix/models/incident.dart';
import 'package:campusfix/models/incident_category.dart';
import 'package:campusfix/models/incident_status.dart';

enum IncidentSort {
  newest('Newest first'),
  oldest('Oldest first'),
  mostSupported('Most affected'),
  priority('Highest priority');

  const IncidentSort(this.label);
  final String label;
}

class IncidentFilter {
  const IncidentFilter({
    this.query = '',
    this.category,
    this.status,
    this.sort = IncidentSort.newest,
  });

  final String query;
  final IncidentCategory? category;
  final IncidentStatus? status;
  final IncidentSort sort;

  bool get isActive =>
      query.trim().isNotEmpty || category != null || status != null;

  IncidentFilter copyWith({
    String? query,
    IncidentCategory? Function()? category,
    IncidentStatus? Function()? status,
    IncidentSort? sort,
  }) {
    return IncidentFilter(
      query: query ?? this.query,
      category: category != null ? category() : this.category,
      status: status != null ? status() : this.status,
      sort: sort ?? this.sort,
    );
  }

  bool matches(Incident incident) {
    if (category != null && incident.category != category) return false;
    if (status != null && incident.status != status) return false;
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return incident.title.toLowerCase().contains(q) ||
        incident.description.toLowerCase().contains(q) ||
        incident.location.toLowerCase().contains(q) ||
        incident.category.label.toLowerCase().contains(q);
  }

  List<Incident> apply(Iterable<Incident> incidents) {
    final result = incidents.where(matches).toList();
    int newestFirst(Incident a, Incident b) =>
        b.createdAt.compareTo(a.createdAt);

    switch (sort) {
      case IncidentSort.newest:
        result.sort(newestFirst);
      case IncidentSort.oldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case IncidentSort.mostSupported:
        result.sort((a, b) {
          final bySupport = b.supportCount.compareTo(a.supportCount);
          return bySupport != 0 ? bySupport : newestFirst(a, b);
        });
      case IncidentSort.priority:
        result.sort((a, b) {
          final byPriority = b.priority.index.compareTo(a.priority.index);
          return byPriority != 0 ? byPriority : newestFirst(a, b);
        });
    }
    return result;
  }
}
