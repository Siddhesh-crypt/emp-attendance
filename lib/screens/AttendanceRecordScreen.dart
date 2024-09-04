import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

import '../services/db_connection.dart';

class AttendanceRecordScreen extends StatefulWidget {
  @override
  _AttendanceRecordScreenState createState() => _AttendanceRecordScreenState();
}

class _AttendanceRecordScreenState extends State<AttendanceRecordScreen> {
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
        'location': row['location'],
        'action': row['action'],
      });
    }
    setState(() {
      _attendanceData = tempData;
      _filteredData = tempData;
    });
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Records'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 20),
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
                  rows: _filteredData.map((record) {
                    return DataRow(cells: [
                      DataCell(Text(record['username'])),
                      DataCell(Text(record['check_in_time'].toString())),
                      DataCell(Text(record['check_out_time']?.toString() ?? 'N/A')),
                      DataCell(Text(record['location'])),
                      DataCell(Text(record['action'])),
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
