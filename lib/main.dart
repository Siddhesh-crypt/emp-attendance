import 'package:emp_attendance/screens/AddEmployeeScreen.dart';
import 'package:emp_attendance/screens/admin_dashboard_screen.dart';
import 'package:emp_attendance/screens/attendance_screen.dart';
import 'package:emp_attendance/screens/contact_list_screen.dart';
import 'package:emp_attendance/screens/employee_dashboard.dart';
import 'package:emp_attendance/screens/login_screen.dart';
import 'package:emp_attendance/screens/employee_registration_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Attendance App',
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/attendance') {
          final args = settings.arguments as Map;
          return MaterialPageRoute(
            builder: (context) {
              return AttendanceScreen(username: args['username']);
            },
          );
        }
        return null; // Use this to handle undefined routes
      },
      routes: {
        '/': (context) => LoginScreen(),
        '/admin_dashboard': (context) => AdminDashboardScreen(),
        '/employee_dashboard': (context) => EmployeeDashboardScreen(),
        '/register': (context) => RegistrationScreen(),
        '/contact': (context) => ContactListPage(),
        '/employee_details': (context)=> AddEmployeeScreen(),
      },
    );
  }
}
