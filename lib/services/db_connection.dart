import 'package:mysql1/mysql1.dart';

class DatabaseConnection {
  static Future<MySqlConnection> getConnection() async {
    final settings = ConnectionSettings(
      host: 'srv1022.hstgr.io', // e.g., 'sqlXXX.hostinger.com'
      port: 3306,
      user: 'u777017855_attendance_db',
      password: '2aiYOb*I+xE2',
      db: 'u777017855_attendance_db',
    );
    return await MySqlConnection.connect(settings);
  }
}
