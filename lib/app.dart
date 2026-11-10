import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campusfix/core/constants/app_constants.dart';
import 'package:campusfix/core/routes/app_router.dart';
import 'package:campusfix/core/theme/app_theme.dart';
import 'package:campusfix/providers/incident_provider.dart';
import 'package:campusfix/providers/session_provider.dart';
import 'package:campusfix/screens/auth/auth_gate.dart';
import 'package:campusfix/services/auth_service.dart';
import 'package:campusfix/services/incident_service.dart';
import 'package:campusfix/services/storage_service.dart';

class CampusFixApp extends StatelessWidget {
  const CampusFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<IncidentService>(create: (_) => IncidentService()),
        Provider<StorageService>(create: (_) => StorageService()),
        ChangeNotifierProvider<SessionProvider>(
          create: (context) => SessionProvider(context.read<AuthService>()),
        ),
        ChangeNotifierProxyProvider<SessionProvider, IncidentProvider>(
          create: (context) => IncidentProvider(
            context.read<IncidentService>(),
            context.read<StorageService>(),
          ),
          update: (_, session, incidents) =>
              incidents!..updateUser(session.user),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
