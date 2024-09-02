import 'package:mysql1/mysql1.dart';

class DBService {
  final ConnectionSettings settings = ConnectionSettings(
    host: 'srv1022.hstgr.io', // localhost can also be used
    port: 3306, // Default MySQL port
    user: 'u777017855_attendance_db', // Default MySQL user
    db: 'u777017855_attendance_db',
    password: '2aiYOb*I+xE2', // Default password is empty unless you set one
  );

  Future<MySqlConnection> _getConnection() async {
    return await MySqlConnection.connect(settings);
  }

  Future<void> insertEmployee(String name, String password, String imagePath) async {
    final conn = await _getConnection();
    await conn.query('INSERT INTO employees (name, password, image) VALUES (?, ?, ?)', [name, password, imagePath]);
    await conn.close();
  }

  Future<void> markAttendance(String imagePath, String location) async {
    final conn = await _getConnection();
    await conn.query('INSERT INTO attendance (employee_id, time, location) VALUES (?, NOW(), ?)', [1, location]); // Use actual employee ID
    await conn.close();
  }

  Future<List<Map<String, dynamic>>> fetchAttendanceRecords() async {
    final conn = await _getConnection();
    final results = await conn.query('SELECT a.*, e.name as employee_name FROM attendance a JOIN employees e ON a.employee_id = e.id');
    final records = results.map((result) => result.fields).toList();
    await conn.close();
    return records;
  }
}
