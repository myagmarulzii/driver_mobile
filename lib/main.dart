import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/app.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/session_provider.dart';
import 'core/providers/bluetooth_provider.dart';
import 'core/providers/location_provider.dart';
import 'core/services/database_service.dart';
import 'core/services/permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Database
  await DatabaseService.instance.database;

  // Request permissions
  await PermissionService.requestInitialPermissions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: const DriverMonitoringApp(),
    ),
  );
}
