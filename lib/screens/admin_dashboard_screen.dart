import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:emp_attendance/screens/employee_registration_screen.dart';
import 'package:flutter/material.dart';
import '../services/db_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {

  final List<Widget> _navigationItem = [
    const Icon(Icons.dashboard),
    const Icon(Icons.app_registration),
    const Icon(Icons.settings)
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Admin Dashboard'),
        leading: BackButton(),
        centerTitle: true,
      ),

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

      bottomNavigationBar: CurvedNavigationBar(
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.deepPurpleAccent,
        animationDuration: const Duration(microseconds: 400),
        items: _navigationItem,
        onTap: (index){
          if(index == 0){
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AdminDashboardScreen()));
          }else if(index == 1){
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => RegistrationScreen()));
          }else if(index == 2){
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AdminDashboardScreen()));
          }
        },
      ),
    );
  }
}
