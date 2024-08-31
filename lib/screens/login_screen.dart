import 'package:emp_attendance/screens/attendance_screen.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'employee_registration_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Replace these with your MySQL database credentials
  final String _host = 'localhost';
  final int _port = 3306;
  final String _user = 'root';
  final String _password = '';
  final String _db = 'attendance_db';

  Future<void> _login() async {
    try {
      // Create a connection
      final conn = await MySqlConnection.connect(ConnectionSettings(
        host: _host,
        port: _port,
        user: _user,
        password: _password,
        db: _db,
      ));

      // Query to check if the user exists and the password matches
      var result = await conn.query(
          'SELECT * FROM employees WHERE name = ? AND password = ?',
          [_usernameController.text, _passwordController.text]);

      if (result.isNotEmpty) {
        // If user is found, navigate to the AttendanceScreen
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => AttendanceScreen()),
        );
      } else {
        // If user is not found, show an error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Invalid username or password'),
        ));
      }

      // Close the connection
      await conn.close();
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred while logging in.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Center(
              child: Image(
                image: AssetImage('assets/dbskill_logo.png'),
                height: 250,
                width: 250,
              ),
            ),
            Center(
              child: Text(
                'Welcome Back!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'IBM Plex Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(73, 80, 87, 1)),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                'Sign in to Continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'IBM Plex Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Color.fromRGBO(116, 120, 141, 1)),
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 10, 0, 0),
              child: Text(
                'Username',
                style: TextStyle(
                    fontFamily: 'IBM Plex Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Color.fromRGBO(73, 80, 87, 1)),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(25, 0, 30, 0),
              child: TextField(
                autofocus: true,
                autocorrect: true,
                controller: _usernameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 10, 0, 0),
              child: Text(
                'Password',
                style: TextStyle(
                    fontFamily: 'IBM Plex Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Color.fromRGBO(73, 80, 87, 1)),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(25, 0, 30, 0),
              child: TextField(
                obscureText: true,
                autofocus: true,
                autocorrect: true,
                controller: _passwordController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all(Colors.deepPurpleAccent),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    fixedSize: MaterialStateProperty.all(Size(300, 60))),
                onPressed: _login,
                child: Text('Login'),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              EmployeeRegistrationScreen()));
                },
                child: Text(
                  'Not a member? Register',
                  style: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
