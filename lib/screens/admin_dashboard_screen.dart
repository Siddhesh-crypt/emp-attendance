import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import '../services/db_connection.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Map<String, dynamic>> _attendanceData = [];
  List<Map<String, dynamic>> _filteredData = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
    _searchController.addListener(_filterData);
  }

  Future<void> _fetchAttendanceData() async {
    final conn = await DatabaseConnection.getConnection();
    var results = await conn.query('SELECT * FROM attendance');
    List<Map<String, dynamic>> tempData = [];
    for (var row in results) {
      tempData.add({
        'username': row['username'],
        'check_in_time': row['check_in_time'],
        'check_out_time': row['check_out_time'],
        'check_in_location': row['check_in_location'],
        'check_out_location': row['check_out_location'],
        'image': row['image'],
      });
    }

    // Sort the tempData by check_in_time in descending order
    tempData.sort((a, b) {
      DateTime checkInTimeA = a['check_in_time'];
      DateTime checkInTimeB = b['check_in_time'];
      return checkInTimeB.compareTo(checkInTimeA); // Sort in descending order
    });

    setState(() {
      _attendanceData = tempData;
      _filteredData = tempData;
    });
  }

  Future<void> _downloadCSV() async {
    try {
      // Request storage permissions
      if (await Permission.storage.request().isGranted) {
        // Fetch attendance data from the database
        final conn = await DatabaseConnection.getConnection();
        var results = await conn.query('SELECT * FROM attendance');

        // Prepare a list of lists (rows) for CSV generation
        List<List<dynamic>> rows = [];

        // Add header row
        rows.add([
          'Username',
          'Check-in Time',
          'Check-out Time',
          'Location',
          'Action',
        ]);

        // Add data rows
        for (var row in results) {
          rows.add([
            row['username'],
            row['check_in_time'],
            row['check_out_time'],
            row['location'],
            row['action'],
          ]);
        }

        // Convert rows to CSV format
        String csv = const ListToCsvConverter().convert(rows);

        // Get the directory for the downloads folder
        final directory = await getExternalStorageDirectory();
        final downloadPath = '${directory!.path}/Download'; // Target Download folder
        final path = '$downloadPath/attendance_data.csv';

        // Write the CSV to a file
        final File file = File(path);
        await file.writeAsString(csv);

        // Notify the user that the file has been saved
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV downloaded: $path')),
        );
      } else {
        // Handle permission denial
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download CSV: $e')),
      );
    }
  }

  Future<void> _saveFile() async {
    List<List<dynamic>> rows = [];
    rows.add(['Name', 'Check-in Time', 'Check-out Time', 'Location', 'Action']);

    for (var record in _attendanceData) {
      rows.add([
        record['username'],
        record['check_in_time'].toString(),
        record['check_out_time'].toString(),
        record['location'],
        record['action'],
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();  // app-specific directory
    String filePath = '${directory.path}/attendance_data.csv';

    final File file = File(filePath);
    await file.writeAsString(csvData);

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance data exported to $filePath'))
    );
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
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final username = arguments['username'];
    final userId = arguments['id'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Color(0xFF5E60CE)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _downloadCSV,
            tooltip: 'Download CSV',
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6E48AA), Color(0xFF5E60CE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Center(
                child: UserAccountsDrawerHeader(
                  accountName: Text(
                    username,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  accountEmail: Text('Admin ID: $userId', style: TextStyle(fontSize: 16, color: Colors.white70)),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      username[0].toUpperCase(),
                      style: TextStyle(fontSize: 40.0, color: Color(0xFF5E60CE)),
                    ),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6E48AA), Color(0xFF5E60CE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.dashboard, color: Colors.white),
                title: Text('Dashboard', style: TextStyle(color: Colors.white, fontSize: 16)),
                onTap: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/admin_dashboard',
                    arguments: {'username': username, 'id': userId},
                  );
                },
              ),
              Divider(color: Colors.white54),
              ListTile(
                leading: Icon(Icons.person_add, color: Colors.white,),
                title: Text('Add Employee Details', style: TextStyle(color: Colors.white, fontSize: 16),),
                onTap: () {
                  Navigator.pushNamed(context, '/employee_details');
                },
              ),
              Divider(color: Colors.white54,),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16)),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Powered by DB SKILLS",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF1F3F5), Color(0xFFE0E7FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by name',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF5E60CE)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF495057),
                  ),
                  dataTextStyle: TextStyle(
                    color: Color(0xFF495057),
                    fontWeight: FontWeight.w500,
                  ),
                  columnSpacing: 30,
                  horizontalMargin: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  columns: [
                    DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Check-in Time', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Check-out Time', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Check-In Location', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Check-Out Location', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _filteredData.map((record) {
                    return DataRow(
                      cells: [
                        DataCell(Text(record['username'], style: TextStyle(color: Color(0xFF5E60CE)))),
                        DataCell(Text(_formatDateTime(record['check_in_time']))),
                        DataCell(Text(_formatDateTime(record['check_out_time']))),
                        DataCell(Text(record['check_in_location'] ?? '')),
                        DataCell(Text(record['check_out_location'] ?? '')),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
