import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import '../services/db_connection.dart';

class AttendanceScreen extends StatefulWidget {
  final String username;
  final String userId;

  AttendanceScreen({required this.username, required this.userId});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  File? _image;
  String _location = '';
  String _address = '';
  bool _isCheckedIn = false;
  String _autoCheckoutMessage = '';

  @override
  void initState() {
    super.initState();
    _getLocation();
    _checkInStatus();
  }

  Future<void> _checkInStatus() async {
    final conn = await DatabaseConnection.getConnection();
    var results = await conn.query(
        'SELECT check_in_time, check_out_time FROM attendance WHERE username = ? ORDER BY check_in_time DESC LIMIT 1',
        [widget.username]);

    if (results.isNotEmpty) {
      var row = results.first;
      setState(() {
        _isCheckedIn = row['check_out_time'] == null;
      });
    }
  }

  Future<void> _getLocation() async {
    final permission = await Permission.location.request();
    if (permission.isGranted) {
      Position position =
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      setState(() {
        _location = '${position.latitude}, ${position.longitude}';
        _address = placemarks.isNotEmpty
            ? '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}, ${placemarks[0].country}'
            : 'Location unavailable';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission denied')),
      );
    }
  }

  Future<void> _captureImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _checkInOut() async {
    if (_image == null || _location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please capture an image and allow location access.')),
      );
      return;
    }

    final conn = await DatabaseConnection.getConnection();
    final now = DateTime.now();

    if (!_isCheckedIn) {
      await conn.query(
        'INSERT INTO attendance (username, check_in_time, check_in_location, image) VALUES (?, ?, ?, ?)',
        [widget.username, DateFormat('yyyy-MM-dd HH:mm:ss').format(now), _address, _image!.path],
      );
      setState(() {
        _isCheckedIn = true;
        _image = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checked in successfully.')),
      );
    } else {
      await conn.query(
        'UPDATE attendance SET check_out_time = ?, check_out_location = ?, image = ? WHERE username = ? AND check_out_time IS NULL',
        [DateFormat('yyyy-MM-dd HH:mm:ss').format(now), _address, _image!.path, widget.username],
      );
      setState(() {
        _isCheckedIn = false;
        _image = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checked out successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Center(
              child: UserAccountsDrawerHeader(
                accountName: Text(widget.username, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                accountEmail: Text('Employee ID: ${widget.userId}', style: TextStyle(fontSize: 14)), // Display userId
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    widget.username[0], // Use the first letter of username
                    style: TextStyle(fontSize: 40.0, color: Color(0xFF5E60CE)),
                  ),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5E60CE), Color(0xFF48BFE3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: Color(0xFF495057)),
              title: Text('Dashboard', style: TextStyle(fontSize: 16)),
              trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFADB5BD)),
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/employee_dashboard',
                  arguments: {'username': widget.username, 'id': widget.userId}, // Pass userId
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.app_registration, color: Color(0xFF495057)),
              title: Text('Attendance', style: TextStyle(fontSize: 16)),
              trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFADB5BD)),
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/attendance',
                  arguments: {'username': widget.username, 'id': widget.userId}, // Pass userId
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person, color: Color(0xFF495057)),
              title: Text('Contacts ', style: TextStyle(fontSize: 16)),
              trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFADB5BD)),
              onTap: () {
                Navigator.pushReplacementNamed(
                    context,
                    '/contact',
                    arguments: {'username': widget.username, 'id': widget.userId} // Pass userId
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Color(0xFF495057)),
              title: Text('Logout', style: TextStyle(fontSize: 16)),
              trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFADB5BD)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Powered by DB Skills",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      body: Container(

        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileImage(),
                SizedBox(height: 20),
                _buildInfoCard('Location', _location),
                _buildInfoCard('Address', _address),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  label: Text('Capture Image'),
                  onPressed: _captureImage,
                  style: _buttonStyle(),
                ),
                SizedBox(height: 20),
                _buildCheckInOutButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: 120,
      backgroundImage: _image != null ? FileImage(_image!) : null,
      backgroundColor: Colors.blueAccent.withOpacity(0.1),
      child: _image == null
          ? Icon(Icons.person, size: 80, color: Colors.blueAccent)
          : null,
    );
  }

  Widget _buildInfoCard(String title, String info) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent.withOpacity(0.7), Colors.blueAccent.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          leading: Icon(Icons.location_on, color: Colors.white),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          subtitle: Text(info, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildCheckInOutButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: !_isCheckedIn && _image != null ? _checkInOut : null,
          child: Text('Check In'),
          style: _buttonStyle(),
        ),
        ElevatedButton(
          onPressed: _isCheckedIn && _image != null ? _checkInOut : null,
          child: Text('Check Out'),
          style: _buttonStyle(),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      backgroundColor: Colors.blueAccent,
      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ).copyWith(
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.grey; // Text color when button is disabled
        }
        return Colors.white; // Text color when button is enabled
      }),
    );
  }

}
