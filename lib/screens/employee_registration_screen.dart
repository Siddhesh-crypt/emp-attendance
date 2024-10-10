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
  final _designationController = TextEditingController();  // Added for Designation
  final _contactNumberController = TextEditingController();  // Added for Contact Number
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _role = 'employee'; // Default role is 'employee'

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
      'INSERT INTO users (username, designation, contact_number, password, role) VALUES (?, ?, ?, ?, ?)',
      [_usernameController.text, _designationController.text, _contactNumberController.text, hashedPassword, _role],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registration successful')),
    );

    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Light background color for the entire screen
      appBar: AppBar(
        title: Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF5E60CE), // Custom AppBar color
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Make children take full width
              children: [
                Center(
                  child: Image.asset(
                    'assets/dbskill_logo.png',
                    height: 150,
                    width: 150,
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _usernameController,
                  labelText: 'Username',
                  icon: Icons.person_outline,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _designationController, // Designation Field
                  labelText: 'Designation',
                  icon: Icons.work_outline,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _contactNumberController, // Contact Number Field
                  labelText: 'Contact Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  icon: Icons.lock_outline,
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
                _buildRoleSelector(), // Role is fixed to 'employee'
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5E60CE), // Button color
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10.0,
                    shadowColor: Colors.deepPurpleAccent.withOpacity(0.5), // Add shadow
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                _buildLoginLink() // Add the login button
              ],
            ),
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF5E60CE).withOpacity(0.15), // Gradient color for the text field
              Color(0xFF5E60CE).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Color(0xFF5E60CE)),
            labelText: labelText,
            labelStyle: TextStyle(color: Color(0xFF5E60CE), fontWeight: FontWeight.w600),
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

  // Add a widget for the login link
  Widget _buildLoginLink() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account? ",
            style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/'); // Navigate to login screen
            },
            child: Text(
              'Login',
              style: TextStyle(fontSize: 16, color: Color(0xFF5E60CE), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
