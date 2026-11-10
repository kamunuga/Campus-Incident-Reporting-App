class AppConstants {
  AppConstants._();

  static const String appName = 'CampusFix';
  static const List<String> allowedEmailDomains = [
    'alustudent.com',
    'alueducation.com',
  ];
  static const int maxImageBytes = 5 * 1024 * 1024;
  static const int maxFeedSize = 300;

  static const String usersCollection = 'users';
  static const String incidentsCollection = 'incidents';
  static const String incidentImagesFolder = 'incidents';
}
