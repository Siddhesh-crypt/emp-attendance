import 'package:emp_attendance/screens/admin_dashboard_screen.dart';
import 'package:emp_attendance/screens/employee_dashboard.dart';
import 'package:flutter/material.dart';
import './screens/login_screen.dart';
import './screens/employee_registration_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Attendance App',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/adminDashboard': (context) => AdminDashboardScreen(),
        '/employeeDashboard': (context) => EmployeeDashboardScreen(),
        // Add dashboard routes here
      },
    );
  }
}
