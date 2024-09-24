import 'package:flutter/material.dart';
import 'package:emp_attendance/screens/attendance_screen.dart';
import '../services/db_connection.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  List<Map<String, dynamic>> _attendanceData = [];
  List<Map<String, dynamic>> _filteredData = [];
  late String _currentUsername;
  TextEditingController _searchController = TextEditingController();

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
      setState(() {
        _attendanceData = tempData;
        _filteredData = tempData;
      });
    }
    setState(() {
      _attendanceData = tempData;
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
  void initState() {
    super.initState();
    _searchController.addListener(_filterData);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    _currentUsername = arguments['username'];
    _fetchAttendanceData();
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
                  '/admin_dashboard',
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
              leading: Icon(Icons.logout, color: Color(0xFF495057)),
              title: Text('Logout', style: TextStyle(fontSize: 16)),
              trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFADB5BD)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Powered by CompanyName",
                style: TextStyle(color: Color(0xFFADB5BD), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Color(0xFFF1F3F5), // Light grey background for modern look
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by name',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF5E60CE)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF495057)),
                  dataTextStyle: TextStyle(
                      color: Color(0xFF495057), fontWeight: FontWeight.w500),
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
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Check-in Time')),
                    DataColumn(label: Text('Check-out Time')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: _filteredData.map((record) {
                    return DataRow(
                      cells: [
                        DataCell(Text(record['username'])),
                        DataCell(Text(record['check_in_time'].toString())),
                        DataCell(Text(record['check_out_time'].toString())),
                        DataCell(Text(record['location'])),
                        DataCell(Text(record['action'])),
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
