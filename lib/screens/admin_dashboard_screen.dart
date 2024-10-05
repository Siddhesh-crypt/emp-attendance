import 'package:flutter/material.dart';
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
                leading: Icon(Icons.app_registration, color: Colors.white),
                title: Text('Register Employee', style: TextStyle(color: Colors.white, fontSize: 16)),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/register',
                    arguments: {'username': username, 'id': userId},
                  );
                },
              ),
              Divider(color: Colors.white54),
              ListTile(
                leading: Icon(Icons.person_add, color: Colors.white,),
                title: Text('Add Employee Details', style: TextStyle(color: Colors.white, fontSize: 16),),
                onTap: (){
                  Navigator.pushNamed(
                    context,
                    '/employee_details'
                  );
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
      body: Container(
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
            Expanded(
              child: SingleChildScrollView(
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
                    DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _filteredData.map((record) {
                    return DataRow(
                      cells: [
                        DataCell(Text(record['username'], style: TextStyle(color: Color(0xFF5E60CE)))),
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
