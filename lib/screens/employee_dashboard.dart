import 'package:flutter/material.dart';
import 'package:emp_attendance/screens/attendance_screen.dart';
import '../services/db_connection.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  List<Map<String, dynamic>> _attendanceData = [];
  late String _currentUsername;

  Future<void> _fetchAttendanceData() async {
    final conn = await DatabaseConnection.getConnection();
    var results = await conn.query('SELECT * FROM attendance WHERE username = ?', [_currentUsername]);
    List<Map<String, dynamic>> tempData = [];
    for (var row in results) {
      tempData.add({
        'username': row['username'],
        'check_in_time': row['check_in_time'],
        'check_out_time': row['check_out_time'],
        'location': row['location'],
        'action': row['action'],
      });
    }
    print('Fetched data: $tempData'); // Debugging line
    setState(() {
      _attendanceData = tempData;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    _currentUsername = arguments['username'];
    print('Current Username: $_currentUsername'); // Debugging line
    _fetchAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final username = arguments['username'];
    final userId = arguments['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(username),
              accountEmail: Text('Employee ID: $userId'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  username[0],
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/employee_dashboard',
                  arguments: {'username': username, 'id': userId},
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.book_outlined),
              title: Text('Attendance'),
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/attendance',
                  arguments: {'username': username},
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Check-in Time')),
                    DataColumn(label: Text('Check-out Time')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: _attendanceData.map((record) {
                    return DataRow(cells: [
                      DataCell(Text(record['username'] ?? '')),
                      DataCell(Text(record['check_in_time']?.toString() ?? '')),
                      DataCell(Text(record['check_out_time']?.toString() ?? '')),
                      DataCell(Text(record['location'] ?? '')),
                      DataCell(Text(record['action'] ?? '')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
