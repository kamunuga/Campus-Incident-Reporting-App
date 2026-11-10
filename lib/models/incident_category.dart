enum IncidentCategory {
  facilities('Broken Facilities'),
  water('Water Shortage'),
  electricity('Electricity Outage'),
  furniture('Damaged Furniture'),
  sanitation('Sanitation'),
  safety('Safety Concern'),
  internet('Internet / Wi-Fi'),
  other('Other');

  const IncidentCategory(this.label);
  final String label;

  static IncidentCategory fromValue(String? value) => IncidentCategory.values
      .firstWhere((c) => c.name == value, orElse: () => IncidentCategory.other);
}
