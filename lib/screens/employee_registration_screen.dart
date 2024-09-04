import 'package:flutter/material.dart';
import '../services/db_connection.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _role = 'employee';

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  Future<void> _register() async {
    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match. Please enter the correct password.')),
      );
      return;
    }

    // Proceed with registration only if passwords match
    var conn = await DatabaseConnection.getConnection();

    // Hash the password using MD5
    var hashedPassword = generateMd5(_passwordController.text);

    // Store user in the database
    await conn.query(
      'INSERT INTO users (username, password, role) VALUES (?, ?, ?)',
      [_usernameController.text, hashedPassword, _role],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registration successful')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Image(
                image: AssetImage('assets/dbskill_logo.png'),
                height: 250,
                width: 250,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 30, 0),
              child: TextField(

                controller: _usernameController,
                autofocus: true,
                autocorrect: true,
                decoration: InputDecoration(
                  labelText: "Name",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 30, 0),
              child: TextField(
                controller: _passwordController,
                autofocus: true,
                autocorrect: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 30, 0),
              child: TextField(
                controller: _confirmPasswordController,
                autofocus: true,
                autocorrect: true,
                decoration: InputDecoration(
                  labelText: "Conform Password",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 10,),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Role:', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'employee',
                        groupValue: _role,
                        onChanged: (String? value) {
                          setState(() {
                            _role = value!;
                          });
                        },
                      ),
                      Text('Employee'),
                      SizedBox(width: 20),
                      Radio<String>(
                        value: 'admin',
                        groupValue: _role,
                        onChanged: (String? value) {
                          setState(() {
                            _role = value!;
                          });
                        },
                      ),
                      Text('Admin'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
