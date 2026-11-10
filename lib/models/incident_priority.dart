enum IncidentPriority {
  low('Low'),
  medium('Medium'),
  high('High');

  const IncidentPriority(this.label);
  final String label;

  static IncidentPriority fromValue(String? value) =>
      IncidentPriority.values.firstWhere(
        (p) => p.name == value,
        orElse: () => IncidentPriority.medium,
      );
}
