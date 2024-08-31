import 'package:flutter/material.dart';
import '../services/db_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: FutureBuilder(
        future: DBService().fetchAttendanceRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            final attendanceRecords = snapshot.data as List<Map<String, dynamic>>;
            return ListView.builder(
              itemCount: attendanceRecords.length,
              itemBuilder: (context, index) {
                final record = attendanceRecords[index];
                return ListTile(
                  title: Text(record['employee_name']),
                  subtitle: Text('Time: ${record['time']}\nLocation: ${record['location']}'),
                );
              },
            );
          }
          return Center(child: Text('No records found'));
        },
      ),
    );
  }
}
