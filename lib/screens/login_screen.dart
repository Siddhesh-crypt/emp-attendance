import 'package:flutter/material.dart';
import '../services/db_connection.dart';
import 'admin_dashboard_screen.dart';
import 'employee_dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    var conn = await DatabaseConnection.getConnection();
    var results = await conn.query(
      'SELECT * FROM users WHERE username = ? AND password = MD5(?)',
      [_usernameController.text, _passwordController.text],
    );

    if (results.isNotEmpty) {
      var user = results.first;
      var role = user['role'];
      var userId = user['id'];
      var username = user['username'];

      if (role == 'admin') {
        Navigator.pushReplacementNamed(
          context,
          '/admin_dashboard',
          arguments: {'username': username, 'id': userId},
        );
      } else if (role == 'employee') {
        Navigator.pushReplacementNamed(
          context,
          '/employee_dashboard',
          arguments: {'username': username, 'id': userId},
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Center(
              child: Image.asset(
                'assets/dbskill_logo.png',
                height: 250,
                width: 250,
              ),
            ),
            Center(
              child: Text(
                'Welcome Back!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromRGBO(73, 80, 87, 1)),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                'Sign in to Continue.',
                style: TextStyle(fontSize: 14, color: Color.fromRGBO(116, 120, 141, 1)),
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 10, 0, 0),
              child: Text('Username', style: TextStyle(fontSize: 18, color: Color.fromRGBO(73, 80, 87, 1))),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(25, 0, 30, 0),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                ),
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 10, 0, 0),
              child: Text('Password', style: TextStyle(fontSize: 18, color: Color.fromRGBO(73, 80, 87, 1))),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(25, 0, 30, 0),
              child: TextField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
