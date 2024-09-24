import 'package:flutter/material.dart';
import 'dart:async';
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
  int _testimonialIndex = 0;
  PageController _pageController = PageController(initialPage: 0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _testimonialIndex = (_testimonialIndex + 1) % 3;
      });
      _pageController.animateToPage(
        _testimonialIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

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
      backgroundColor: Color(0xFFF8F9FA), // Soft background for a clean look
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 60),
            _buildLogoSection(),
            SizedBox(height: 20),
            _buildHeaderText(),
            SizedBox(height: 40),
            _buildInputFields(),
            SizedBox(height: 30),
            _buildLoginButton(),
            SizedBox(height: 20),
            _buildTestimonialsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Image.asset(
        'assets/dbskill_logo.png',
        height: 150,
        width: 150,
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      children: [
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF343A40), // Dark grey for titles
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Sign in to continue',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF868E96), // Light grey for subtitles
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
          child: Text(
            'Username',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF495057)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              hintText: 'Enter your username',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.person, color: Color(0xFF495057)),
            ),
          ),
        ),
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
          child: Text(
            'Password',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF495057)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: TextField(
            obscureText: true,
            controller: _passwordController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              hintText: 'Enter your password',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.lock, color: Color(0xFF495057)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4D5C7C), // A deeper blue/purple shade
          padding: EdgeInsets.symmetric(horizontal: 120, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5, // Adding shadow effect
        ),
        child: Text(
          'Login',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        height: 150,
        child: PageView(
          controller: _pageController,
          children: [
            _buildTestimonialCard(
              text: "The system is smooth and efficient.",
              author: "John Doe, Manager",
            ),
            _buildTestimonialCard(
              text: "I can now track my team's attendance easily.",
              author: "Jane Smith, Employee",
            ),
            _buildTestimonialCard(
              text: "Perfect solution for attendance management!",
              author: "Chris Johnson, CEO",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialCard({required String text, required String author}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      elevation: 3, // Adding elevation for better visual appeal
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 16, color: Color(0xFF343A40)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              author,
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xFF868E96)),
            ),
          ],
        ),
      ),
    );
  }
}
