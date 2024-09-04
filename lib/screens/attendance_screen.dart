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

  Future<void> _getLocation() async {
    final permission = await Permission.location.request();

    if (permission.isGranted) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _location = '${position.latitude}, ${position.longitude}';
      });

      // Convert coordinates to address
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          _address = '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
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
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // Convert image to byte data
    final imageBytes = _image?.readAsBytesSync();
    final action = _isCheckedIn ? 'check_out' : 'check_in';

    if (_isCheckedIn) {
      // Update the check-out time for the existing check-in entry
      await conn.query(
        'UPDATE attendance SET check_out_time = ?, image = ?, location = ? WHERE username = ? AND check_out_time IS NULL',
        [now, imageBytes, _location, widget.username],
      );
      setState(() {
        _isCheckedIn = false;
      });
    } else {
      // Insert a new check-in entry
      await conn.query(
        'INSERT INTO attendance (username, check_in_time, image, location, action) VALUES (?, ?, ?, ?, ?)',
        [widget.username, now, imageBytes,  _location, action],
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
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance System')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display the image in a circular avatar with a 3D shadow effect
            if (_image != null)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      spreadRadius: 5.0,
                      offset: Offset(0, 5), // 3D effect shadow
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 80, // Adjust the size of the avatar
                  backgroundImage: FileImage(_image!),
                ),
              ),
            SizedBox(height: 20),
            Text('Location: $_location'),
            Text('Address: $_address'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isCheckedIn ? null : _captureImage,
              child: Text('Capture Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isCheckedIn ? null : _checkInOut,
              child: Text('Check In'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: !_isCheckedIn ? null : _checkInOut,
              child: Text('Check Out'),
            ),
          ],
        ),
      ),
    );
  }
}
