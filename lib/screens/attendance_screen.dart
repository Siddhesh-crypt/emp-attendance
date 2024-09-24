import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysql1/mysql1.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

import '../services/db_connection.dart';

class AttendanceScreen extends StatefulWidget {
  final String username;

  AttendanceScreen({required this.username});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  File? _image;
  String _location = '';
  String _address = '';
  bool _isCheckedIn = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _checkInStatus(); // Check the attendance status when the app starts
  }

  Future<void> _checkInStatus() async {
    final conn = await DatabaseConnection.getConnection();
    var results = await conn.query(
        'SELECT check_out_time FROM attendance WHERE username = ? ORDER BY check_in_time DESC LIMIT 1',
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
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _location = '${position.latitude}, ${position.longitude}';
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          _address = '${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}, ${placemark.country ?? ''}';
        });
      }
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
    final conn = await DatabaseConnection.getConnection();
    final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final imageBytes = _image?.readAsBytesSync();
    final action = _isCheckedIn ? 'check_out' : 'check_in';

    if (_isCheckedIn) {
      await conn.query(
        'UPDATE attendance SET check_out_time = ?, image = ?, location = ? WHERE username = ? AND check_out_time IS NULL',
        [now, imageBytes, _location, widget.username],
      );
      setState(() {
        _isCheckedIn = false;
      });
    } else {
      await conn.query(
        'INSERT INTO attendance (username, check_in_time, image, location, action) VALUES (?, ?, ?, ?, ?)',
        [widget.username, now, imageBytes, _location, action],
      );
      setState(() {
        _isCheckedIn = true;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You have ${_isCheckedIn ? "checked in" : "checked out"} successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance System',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile image with fancy shadow and border
              if (_image != null)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blueAccent, width: 4.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0,
                        spreadRadius: 5.0,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: FileImage(_image!),
                  ),
                )
              else
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.blueAccent.withOpacity(0.1),
                  child: Icon(Icons.person, size: 60, color: Colors.blueAccent),
                ),
              SizedBox(height: 20),

              // Info cards with rounded corners and gradient background
              _buildInfoCard('Location', _location),
              SizedBox(height: 10),
              _buildInfoCard('Address', _address),

              SizedBox(height: 30),

              // Capture Image Button with gradient background
              _buildActionButton(
                text: 'Capture Image',
                icon: Icons.camera_alt,
                onPressed: _isCheckedIn ? null : _captureImage,
              ),
              SizedBox(height: 20),

              // Check In/Out Button with modern icons and animations
              _buildActionButton(
                text: _isCheckedIn ? 'Check Out' : 'Check In',
                icon: _isCheckedIn ? Icons.logout : Icons.login,
                onPressed: _checkInOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String info) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          subtitle: Text(
            info.isNotEmpty ? info : 'Not available',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required String text, required IconData icon, required VoidCallback? onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(
        text,
        style: TextStyle(fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5.0,
        shadowColor: Colors.blueAccent.withOpacity(0.5),
      ).copyWith(
        side: MaterialStateProperty.all(BorderSide(color: Colors.blueAccent, width: 2)),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey;
            }
            return Colors.blueAccent;
          },
        ),
      ),
      onPressed: onPressed,
    );
  }
}
