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
        title: Text(
          'Attendance Records',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 8.0,
        shadowColor: Colors.black54,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar with custom decoration and gradient effect
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by Name',
                  labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: MaterialStateProperty.all(Colors.blueAccent.withOpacity(0.3)),
                  columns: [
                    DataColumn(
                      label: Text(
                        'Name',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Check-in Time',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Check-out Time',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Location',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Action',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
                      ),
                    ),
                  ],
                  rows: _filteredData.map((record) {
                    return DataRow(
                      color: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) return Colors.blueAccent.withOpacity(0.1);
                          return null; // Use the default value.
                        },
                      ),
                      cells: [
                        DataCell(Text(record['username'], style: TextStyle(color: Colors.black87, fontSize: 14))),
                        DataCell(Text(record['check_in_time'].toString(), style: TextStyle(color: Colors.black87, fontSize: 14))),
                        DataCell(Text(record['check_out_time']?.toString() ?? 'N/A', style: TextStyle(color: Colors.black87, fontSize: 14))),
                        DataCell(Text(record['location'], style: TextStyle(color: Colors.black87, fontSize: 14))),
                        DataCell(Text(record['action'], style: TextStyle(color: Colors.black87, fontSize: 14))),
                      ],
                    );
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
