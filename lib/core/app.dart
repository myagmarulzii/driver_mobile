import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/admin/screens/admin_dashboard.dart';
import '../features/instructor/screens/instructor_dashboard.dart';
import '../features/student/screens/student_dashboard.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';

class DriverMonitoringApp extends StatelessWidget {
  const DriverMonitoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver Course Monitoring',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isAuthenticated) {
            return const LoginScreen();
          }

          // Route based on user role
          switch (auth.currentUser?.role) {
            case 'admin':
              return const AdminDashboard();
            case 'instructor':
              return const InstructorDashboard();
            case 'student':
              return const StudentDashboard();
            default:
              return const LoginScreen();
          }
        },
      ),
    );
  }
}
