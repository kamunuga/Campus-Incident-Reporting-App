enum IncidentStatus {
  submitted('Submitted'),
  underReview('Under Review'),
  inProgress('In Progress'),
  resolved('Resolved'),
  rejected('Rejected');

  const IncidentStatus(this.label);
  final String label;

  bool get isOpen =>
      this == IncidentStatus.submitted ||
      this == IncidentStatus.underReview ||
      this == IncidentStatus.inProgress;

  bool get requiresNote => this == IncidentStatus.rejected;

  List<IncidentStatus> get nextStatuses => switch (this) {
        IncidentStatus.submitted => const [
            IncidentStatus.underReview,
            IncidentStatus.inProgress,
            IncidentStatus.rejected,
          ],
        IncidentStatus.underReview => const [
            IncidentStatus.inProgress,
            IncidentStatus.resolved,
            IncidentStatus.rejected,
          ],
        IncidentStatus.inProgress => const [IncidentStatus.resolved],
        IncidentStatus.resolved => const [IncidentStatus.inProgress],
        IncidentStatus.rejected => const [IncidentStatus.underReview],
      };

  bool canMoveTo(IncidentStatus next) => nextStatuses.contains(next);

  static IncidentStatus fromValue(String? value) =>
      IncidentStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => IncidentStatus.submitted,
      );
}
