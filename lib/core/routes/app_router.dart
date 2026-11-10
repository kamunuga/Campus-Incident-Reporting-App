import 'package:flutter/material.dart';

import 'package:campusfix/models/incident.dart';
import 'package:campusfix/screens/auth/register_screen.dart';
import 'package:campusfix/screens/incidents/create_incident_screen.dart';
import 'package:campusfix/screens/incidents/image_viewer_screen.dart';
import 'package:campusfix/screens/incidents/incident_detail_screen.dart';
import 'package:campusfix/widgets/common.dart';

class AppRoutes {
  AppRoutes._();

  static const String register = '/register';
  static const String createIncident = '/incidents/new';
  static const String editIncident = '/incidents/edit';
  static const String incidentDetail = '/incidents/detail';
  static const String imageViewer = '/incidents/image';
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoutes.register:
        return _page(const RegisterScreen(), settings);
      case AppRoutes.createIncident:
        return _page(const CreateIncidentScreen(), settings);
      case AppRoutes.editIncident:
        if (args is Incident) {
          return _page(CreateIncidentScreen(existing: args), settings);
        }
      case AppRoutes.incidentDetail:
        if (args is String) {
          return _page(IncidentDetailScreen(incidentId: args), settings);
        }
      case AppRoutes.imageViewer:
        if (args is ImageViewerArgs) {
          return _page(ImageViewerScreen(args: args), settings);
        }
    }
    return _page(const _NotFoundScreen(), settings);
  }

  static MaterialPageRoute<dynamic> _page(Widget child, RouteSettings s) =>
      MaterialPageRoute(builder: (_) => child, settings: s);
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: EmptyState(
        icon: Icons.explore_off_outlined,
        title: 'Page not found',
        message: 'The page you were looking for does not exist.',
        actionLabel: 'Go back',
        onAction: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
