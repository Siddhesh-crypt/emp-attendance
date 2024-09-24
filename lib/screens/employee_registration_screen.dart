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
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match. Please enter the correct password.')),
      );
      return;
    }

    var conn = await DatabaseConnection.getConnection();
    var hashedPassword = generateMd5(_passwordController.text);

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
      backgroundColor: Color(0xFFF1F3F6), // Light grey background
      appBar: AppBar(
        title: Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF5E60CE), // Custom AppBar color
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF5E60CE).withOpacity(0.1), // Light gradient color
              Color(0xFF5E60CE).withOpacity(0.1), // Light gradient color
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Make children take full width
            children: [
              Center(
                child: Image.asset(
                  'assets/dbskill_logo.png',
                  height: 180,
                  width: 180,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _usernameController,
                labelText: 'Name',
                icon: Icons.person,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                labelText: 'Password',
                icon: Icons.lock,
                obscureText: true,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm Password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              SizedBox(height: 30),
              _buildRoleSelector(),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5E60CE), // Button color
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Register',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF5E60CE).withOpacity(0.2), // Gradient color for the text field
              Color(0xFF5E60CE).withOpacity(0.1), // Gradient color for the text field
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Color(0xFF5E60CE)),
            labelText: labelText,
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(16),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF5E60CE)),
              borderRadius: BorderRadius.circular(15),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 45),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Role:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          SizedBox(width: 5),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildRadioOption('Employee', 'employee'),
                SizedBox(width: 20),
                _buildRadioOption('Admin', 'admin'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String text, String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _role,
          activeColor: Color(0xFF5E60CE),
          onChanged: (String? newValue) {
            setState(() {
              _role = newValue!;
            });
          },
        ),
        Text(text, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
