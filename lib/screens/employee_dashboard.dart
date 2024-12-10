import 'dart:typed_data';  // Import for Uint8List
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';  // Add MySQL dependency
import 'package:csv/csv.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/db_connection.dart'; // Your custom DB connection file
import 'dart:io';

class EmployeeDashboardScreen extends StatefulWidget {
  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  List<Map<String, dynamic>> _attendanceData = [];
  List<Map<String, dynamic>> _filteredData = [];
  late String _currentUsername;
  TextEditingController _searchController = TextEditingController();

  Future<void> _downloadCSV() async {
    try {
      if (await Permission.storage.request().isGranted) {
        final conn = await DatabaseConnection.getConnection();
        var results = await conn.query('SELECT * FROM attendance');

        List<List<dynamic>> rows = [];
        rows.add([
          'Username',
          'Check-In Time',
          'Check-Out Time',
          'Check-In location',
          'Check-Out location'
        ]);

        for (var row in results) {
          rows.add([
            row['username'],
            row['check_in_time'],
            row['check_out_time'],
            row['check_in_location'],
            row['check_out_location'],
          ]);
        }

        String csv = const ListToCsvConverter().convert(rows);
        final directory = await getExternalStorageDirectory();
        final downloadPath = '${directory!.path}/Download';
        final path = '$downloadPath/attendance_data.csv';
        final File file = File(path);
        await file.writeAsString(csv);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSV downloaded: $path')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Storage permission denied')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download CSV: $e')));
    }
  }

  Future<void> _fetchAttendanceData() async {
    final conn = await DatabaseConnection.getConnection();
    var results = await conn.query('SELECT * FROM attendance WHERE username = ? ORDER BY check_in_time DESC', [_currentUsername]);

    List<Map<String, dynamic>> tempData = [];

    for (var row in results) {
      tempData.add({
        'username': row['username'],
        'check_in_time': row['check_in_time'],
        'check_out_time': row['check_out_time'],
        'check_in_location': row['check_in_location'],
        'check_out_location': row['check_out_location'],
        'image': row['image'],  // Assuming the image data is in the 'image' column
      });
    }

    if (mounted) {
      setState(() {
        _attendanceData = tempData;
        _filteredData = tempData;
      });
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return ' ';
    }
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  void _filterData() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredData = _attendanceData.where((record) {
        return record['username'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterData);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map? arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    if (arguments != null && arguments.containsKey('username')) {
      _currentUsername = arguments['username'];
      _fetchAttendanceData();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterData);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map? arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    final username = arguments?['username'] ?? 'Unknown User';
    final userId = arguments?['id'] ?? 'Unknown ID';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5E60CE), Color(0xFF48BFE3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Employee Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _downloadCSV,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Center(
              child: UserAccountsDrawerHeader(
                accountName: Text(username, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                accountEmail: Text('Employee ID: $userId', style: TextStyle(fontSize: 14)),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    username[0],
                    style: TextStyle(fontSize: 40.0, color: Color(0xFF5E60CE)),
                  ),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5E60CE), Color(0xFF48BFE3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: Color(0xFF495057)),
              title: Text('Dashboard', style: TextStyle(fontSize: 16)),
              trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFADB5BD)),
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/employee_dashboard',
                  arguments: {'username': username, 'id': userId},
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.app_registration, color: Color(0xFF495057)),
              title: Text('Attendance', style: TextStyle(fontSize: 16)),
              trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFADB5BD)),
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/attendance',
                  arguments: {'username': username, 'id': userId},
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person, color: Color(0xFF495057)),
              title: Text('Contacts ', style: TextStyle(fontSize: 16)),
              trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFADB5BD)),
              onTap: () {
                Navigator.pushReplacementNamed(
                    context,
                    '/contact',
                    arguments: {'username': username, 'id': userId}
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by Username',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),

            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(

                    child:DataTable(
                      columnSpacing: 20,
                      horizontalMargin: 0,
                      columns: [
                        DataColumn(label: Text('Username')),
                        DataColumn(label: Text('Check-In Time')),
                        DataColumn(label: Text('Check-Out Time')),
                        DataColumn(label: Text('Check-In Location')),
                        DataColumn(label: Text('Check-Out Location')),

                      ],
                      rows: _filteredData.map((attendance) {
                        return DataRow(cells: [
                          DataCell(Text(attendance['username'])),
                          DataCell(Text(_formatDateTime(attendance['check_in_time']))),
                          DataCell(Text(_formatDateTime(attendance['check_out_time']))),
                          DataCell(Text(attendance['check_in_location'] ?? ' ')),
                          DataCell(Text(attendance['check_out_location'] ?? ' ')),
                        ]);
                      }).toList(),
                    ),
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
